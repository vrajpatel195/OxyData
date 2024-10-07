import 'package:flutter/material.dart';

import '../Services/mqtt_connect.dart';
import 'DisplayMessagePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final MqttService mqttService =
      MqttService(); // Create an instance of MqttService

  void _loginAndConnect() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      // Call the MQTT connect function

      // Navigate to the display page and pass the mqttService instance
    } else {
      // Show an error if credentials are not entered
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              child: ElevatedButton(
                onPressed: _loginAndConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.blueAccent,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
