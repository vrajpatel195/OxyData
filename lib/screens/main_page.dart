import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:pressdata/screens/report_screen.dart';
// import 'package:pressdata/screens/setting.dart';
// import 'package:pressdata/widgets/linechart.dart';
import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class Dashboard extends StatefulWidget {
  Dashboard({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> {
  String? _wifiName;
  bool _isLoading = true;
  String _targetWifiName = "null";
  // final LineCharWid _lineChartWid = LineCharWid();

  @override
  void initState() {
    super.initState();
    _initWifiName();
    // Start periodic checking of WiFi network
    _startWifiCheckTimer();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _stopWifiCheckTimer();
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: RichText(
                text: const TextSpan(
                    text: 'Press ',
                    style: TextStyle(
                        color: Color.fromRGBO(0, 25, 152, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                    children: [
                      TextSpan(
                        text: 'Data ',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'Medical Gas Alram + Analyser ',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0), fontSize: 20),
                      ),
                    ]),
              ),
            ),
          ],
        ),
        toolbarHeight: 40,
        backgroundColor: Color.fromRGBO(228, 100, 128, 100),
      ),
      body: Stack(
        children: [
          // _lineChartWid,
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 30,
              color: Colors.grey[200], // Background color of the bar
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Spacer(flex: 20),
                  const Text(
                    'SYSTEM IS RUNNING OK',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(
                    flex: 12,
                  ),
                  Positioned(
                    right: 130,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              style: BorderStyle.solid, color: Colors.black87),
                          borderRadius:
                              BorderRadius.circular(5), // Square corners
                        ),
                        minimumSize:
                            Size(90, 25), // Set minimum size to maintain height
                        backgroundColor: Color.fromARGB(255, 192, 191, 191),
                      ),
                      onPressed: () async {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => Setting1()),
                        // );
                      },
                      child: const Text(
                        'Settings',
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
                  ),
                  SizedBox(width: 12), // Add spacing between the buttons
                  Positioned(
                    right: 20,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              style: BorderStyle.solid, color: Colors.black87),
                          borderRadius:
                              BorderRadius.circular(5), // Square corners
                        ),
                        minimumSize:
                            Size(90, 25), // Set minimum size to maintain height
                        backgroundColor: Color.fromARGB(255, 192, 191, 191),
                      ),
                      onPressed: () async {
                        // Uint8List imageBytes =
                        //     await _lineChartWid.captureChartImage();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         ReportScreen(imageBytes: imageBytes),
                        //   ),
                        // );
                      },
                      child: const Text(
                        'Report',
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
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
