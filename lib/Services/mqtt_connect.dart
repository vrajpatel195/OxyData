import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
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
  VoidCallback? onDisconnectedCallback;
  String serialNo = '';
  SharedPreferences? prefs;

  Future<void> connect(BuildContext context, String serialNo) async {
    client = await _connect(context);
    prefs = await SharedPreferences.getInstance();
    print("clientvdjhv1: $client");
    if (client != null &&
        client?.connectionStatus?.state == MqttConnectionState.connected) {
      print('Connected to MQTT');
      subscribeToTopic1(serialNo, context);
    } else {
      print('Failed to connect to MQTT');
    }
  }

  Future<MqttServerClient> _connect(BuildContext context) async {
    final mqttClient = MqttServerClient.withPort(
        'jmq.jcntechnology.in', 'flutter_client1', 8883);

    mqttClient.logging(on: true);
    mqttClient.onConnected = () {
      print('Connected to MQTT broker');
    };
    mqttClient.onDisconnected = () {
      print('Disconnected from MQTT broker');
      if (onDisconnectedCallback != null) {
        onDisconnectedCallback!(); // Trigger the callback when disconnected
      }
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

      //subscribeToTopic2();
    } else {
      print('Connection failed');
      mqttClient.disconnect();
    }

    return mqttClient;
  }

  void subscribeToTopic1(String serialNo, BuildContext context) {
    print("serialNokvjhb: $serialNo");
    String topic1 = '$serialNo/t_jw_dou_1s';

    // Before subscribing, check if the client is connected
    if (client == null ||
        client?.connectionStatus?.state != MqttConnectionState.connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Not connected to MQTT broker.'),
          backgroundColor: Colors.red,
        ),
      );
      print("Not connected to MQTT broker.");
      return;
    }

    // Subscribe to the topic using the given serial number
    client?.subscribe(topic1, MqttQos.atLeastOnce);

    // Add a listener for subscription failures
    client?.onSubscribeFail = (String topic) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to subscribe to the topic: $topic'),
          backgroundColor: Colors.red,
        ),
      );
      print("Failed to subscribe to the topic: $topic");
    };

    print("Subscribed to topic: $topic1");

    // Listen to updates from the subscribed topic
    client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      if (c[0].topic == topic1) {
        print('Received message for topic 1: $payload');

        if (_isValidPayload(payload)) {
          topic1Payload = payload;
          _messageController.add(payload);
          print('Updated topic1Payload: $topic1Payload');
        } else {
          // Show error in ScaffoldMessenger when serial number is wrong or invalid
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: Invalid or wrong serial number.'),
              backgroundColor: Colors.red,
            ),
          );
          print('Serial number is wrong or invalid.');
        }
      }
    });
  }

// Helper function to validate the payload/message
  bool _isValidPayload(String payload) {
    // Here you can add your specific validation logic for the received payload
    // This could involve checking for a specific format, error messages, or conditions
    if (payload.isEmpty ||
        payload.contains('error') ||
        payload == 'INVALID_SERIAL') {
      return false; // Consider this as an invalid payload
    }
    return true; // Payload is valid
  }

  void subscribeToTopic2(String serialNo) {
    String topic2 = '$serialNo/t_jw_dou_para_1';
    client?.subscribe(topic2, MqttQos.atLeastOnce);

    client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      if (c[0].topic == topic2) {
        print('Received message for topic 2: $payload');
        topic2Payload = payload;
        print('Updated topic2Payload: $topic2Payload');
      }
    });
  }

  Future<void> publishPuritySettings(String serialNo) async {
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

    String topic = '$serialNo/t_jw_din_para_1'; // Topic 3

    final builder = MqttClientPayloadBuilder();
    builder.addString(messagePayload);

    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('Message published to $topic: $messagePayload');
  }

  String getConnectionStatusMessage() {
    switch (client?.connectionStatus?.state) {
      case MqttConnectionState.connected:
        return 'Connected';
      case MqttConnectionState.disconnected:
        return 'Disconnected';
      case MqttConnectionState.connecting:
        return 'Connecting';
      default:
        return 'Unknown Status';
    }
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
