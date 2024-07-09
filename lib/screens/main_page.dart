import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/demo.dart';
import 'HomePage.dart';

class Dashboard extends StatefulWidget {
  Dashboard({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  String? _wifiName;
  bool _isLoading = true;
  String _targetWifiName = "Press_data";
  //final LineCharWid _lineChartWid = LineCharWid();

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initWifiName();
    // Start periodic checking of WiFi network
    _startWifiCheckTimer();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _stopWifiCheckTimer();
    _animationController.dispose();
    super.dispose();
  }

  void _initWifiName() async {
    // Request necessary permissions
    await _requestLocationPermissions();

    // Retrieve WiFi name
    try {
      String? wifiName = await NetworkInfo().getWifiName();
      print("wifi name: \"${wifiName}\"");
      setState(() {
        _wifiName = wifiName;
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      print("Failed to get wifi name: '${e.message}'.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestLocationPermissions() async {
    // Request location permissions
    await Permission.locationAlways.request();
    await Permission.locationWhenInUse.request();
    await Permission.accessMediaLocation.request();
    await Permission.activityRecognition.request();
  }

  // Timer for periodic checking of WiFi network
  late Timer _wifiCheckTimer;

  void _startWifiCheckTimer() {
    // Check every 5 seconds
    _wifiCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _updateWifiStatus();
    });
  }

  void _stopWifiCheckTimer() {
    _wifiCheckTimer.cancel();
  }

  void _updateWifiStatus() async {
    String? wifiName = await NetworkInfo().getWifiName();
    setState(() {
      _wifiName = wifiName;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return PopScope(
    canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: RichText(
                  text: const TextSpan(
                      text: 'Oxy ',
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0), fontSize: 25),
                      children: [
                        TextSpan(
                          text: 'Data -',
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0), fontSize: 25),
                        ),
                        TextSpan(
                          text: ' Oxygen Data Analyser',
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0), fontSize: 20),
                        ),
                      ]),
                ),
              ),
            ],
          ),
          toolbarHeight: 40,
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.612),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _wifiName != null && _wifiName == "\"${_targetWifiName}\""
                ? Stack(
                    children: [
                      // _lineChartWid,
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _animation.value,
                              child: Icon(
                                Icons.wifi_off,
                                size: 50,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        Text("Internet is not connected"),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.black87),
                                borderRadius:
                                    BorderRadius.circular(5), // Square corners
                              ),
                              minimumSize: Size(
                                  90, 25), // Set minimum size to maintain height
                              backgroundColor:
                                  Color.fromARGB(255, 192, 191, 191)),
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const DemoWid()));
                          },
                          child: const Text(
                            'Demo Mode',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 0, 0, 0),
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.grey,
                                  offset: Offset(2, 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
