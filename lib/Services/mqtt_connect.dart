import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class MqttService {
  MqttServerClient? client;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  Stream<String> get messageStream => _messageController.stream;
  String topic1Payload = '';
  String topic2Payload = '';

  Future<void> connect() async {
    client = await _connect();
    if (client != null &&
        client?.connectionStatus?.state == MqttConnectionState.connected) {
      print('Connected to MQTT');
    } else {
      print('Failed to connect to MQTT');
    }
  }

  Future<MqttServerClient> _connect() async {
    final mqttClient = MqttServerClient.withPort(
        'jmq.jcntechnology.in', 'flutter_client1', 8883);

    mqttClient.logging(on: true);
    mqttClient.onConnected = () {
      print('Connected to MQTT broker');
    };
    mqttClient.onDisconnected = () {
      print('Disconnected from MQTT broker');
    };

    // Load the certificates for TLS connection
    final SecurityContext context = SecurityContext();
    List<int> caBytes = await loadBytes('assets/JCNTECHNOLOGY-CA.pem');
    List<int> clientCertBytes = await loadBytes('assets/jw.crt');
    List<int> clientKeyBytes = await loadBytes('assets/jw.key');

    context.setTrustedCertificatesBytes(caBytes);
    context.useCertificateChainBytes(clientCertBytes);
    context.usePrivateKeyBytes(clientKeyBytes);

    mqttClient.secure = true;
    mqttClient.securityContext = context;

    mqttClient.onBadCertificate = (Object cert) {
      return true;
    };

    final connMess = MqttConnectMessage()
        .withClientIdentifier("flutter_client")
        .keepAliveFor(60)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    mqttClient.connectionMessage = connMess;

    try {
      await mqttClient.connect();
    } catch (e) {
      print('Exception during MQTT connection: $e');
      mqttClient.disconnect();
    }

    if (mqttClient.connectionStatus?.state == MqttConnectionState.connected) {
      print('MQTT client connected');

      const topic1 = 'OPP09240211/t_jw_dou_1s';
      mqttClient.subscribe(topic1, MqttQos.atLeastOnce);
      const topic2 = 'OPP09240211/t_jw_dou_para_1';
      mqttClient.subscribe(topic2, MqttQos.atLeastOnce);
      print('Subscribed to topics: $topic1 and $topic2');

      mqttClient.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        print('Received message: $payload from topic: ${c[0].topic}');

        if (c[0].topic == topic1) {
          topic1Payload = payload;
          _messageController.add(payload);
          print('Updated topic1Payload: $topic1Payload');
        } else if (c[0].topic == topic2) {
          topic2Payload = payload;
          _messageController.add(payload);
          print('Updated topic2Payload: $topic2Payload');
        } else {
          print('Message received on an unexpected topic: ${c[0].topic}');
        }
      });
    } else {
      print('Connection failed');
      mqttClient.disconnect();
    }

    return mqttClient;
  }

  Future<void> publishPuritySettings() async {
    if (client == null ||
        client?.connectionStatus?.state != MqttConnectionState.connected) {
      print('MQTT client is not connected');
      return; // Exit the function if not connected
    }

    final prefs = await SharedPreferences.getInstance();
    String serialNo = prefs.getString('serialNo') ?? 'Unknown';
    double o2Min = prefs.getDouble('purityMin') ?? 0.0;
    double o2Max = prefs.getDouble('purityMax') ?? 0.0;
    double flowMax = prefs.getDouble('flowMax') ?? 0.0;
    double flowMin = prefs.getDouble('flowMin') ?? 0.0;
    double pressureMax = prefs.getDouble('pressureMax') ?? 0.0;
    double pressureMin = prefs.getDouble('pressureMin') ?? 0.0;
    double tempMax = prefs.getDouble('tempMax') ?? 0.0;
    double tempMin = prefs.getDouble('tempMin') ?? 0.0;

    final messagePayload = jsonEncode({
      "serialNo": serialNo,
      "o2_min": o2Min.toString(),
      "o2_max": o2Max.toString(),
      "flow_min": flowMin.toString(),
      "flow_max": flowMax.toString(),
      "pressure_min": pressureMin.toString(),
      "pressure_max": pressureMax.toString(),
      "temperature_min": tempMin.toString(),
      "temperature_max": tempMax.toString(),
    });

    const topic = 'OPP09240211/t_jw_din_para_1'; // Topic 3

    final builder = MqttClientPayloadBuilder();
    builder.addString(messagePayload);

    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('Message published to $topic: $messagePayload');
  }

  Future<List<int>> loadBytes(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  // Close the StreamController when done
  void dispose() {
    _messageController.close();
  }
}
