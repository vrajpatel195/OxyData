import 'package:flutter/material.dart';

import '../Services/mqtt_connect.dart';

class DisplayMessagePage extends StatelessWidget {
  final MqttService mqttService;

  const DisplayMessagePage({Key? key, required this.mqttService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Message'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<String>(
                stream:
                    mqttService.messageStream, // Listen to the message stream
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'Received: ${snapshot.data}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    );
                  } else {
                    return const Text(
                      'No message received yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
