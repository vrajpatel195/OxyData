import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:oxydata/screens/old_report_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Database/db/app_db.dart';
import '../LimitSetting.dart/api_service.dart';
import '../LimitSetting.dart/min_max_data.dart';
import '../main.dart';
import '../Demo/demo.dart';
import 'HomePage.dart';

import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  String? _wifiName;
  bool _isLoading = false;
  String _targetWifiName = "Oxydata";
  final LineCharWid _lineChartWid = LineCharWid();
  bool checker = false;

  late AnimationController _animationController;
  late Animation<double> _animation;
  String serialNo = '';
  bool _isConnected = false;
  bool? permissionGranted;

  String oxyDataTitle = 'OxyData';
  String? selectedSerialNo;
  List<String> serialNumbers = [];

  @override
  void initState() {
    super.initState();

    fetchSerialNumbers();
    _initWifiName();

    _startWifiCheckTimer();
    getSerialNo();

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
    _stopWifiCheckTimer();
    _animationController.dispose();
    super.dispose();
  }

  void _initWifiName() async {
    await _requestLocationPermissions();

    try {
      String? wifiName = await NetworkInfo().getWifiName();

      bool isConnected = await WifiService.isWifiConnected(_targetWifiName);
      print("wifi name: \"${wifiName}\"");
      if (mounted) {
        setState(() {
          _wifiName = wifiName;
          _isConnected = isConnected;
          _isLoading = false;
        });
      }
    } on PlatformException catch (e) {
      print("Failed to get wifi name: '${e.message}'.");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    getSerialNo();
  }

  Future<void> _requestLocationPermissions() async {
    await Permission.locationAlways.request();
    await Permission.locationWhenInUse.request();
    await Permission.accessMediaLocation.request();
    await Permission.activityRecognition.request();
  }

  static const platform = MethodChannel('com.example.app/storage');

  late Timer _wifiCheckTimer;

  void _startWifiCheckTimer() {
    _wifiCheckTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      _updateWifiStatus();
    });
  }

  void _stopWifiCheckTimer() {
    _wifiCheckTimer.cancel();
  }

  void _updateWifiStatus() async {
    String? wifiName = await NetworkInfo().getWifiName();
    bool isConnected = await WifiService.isWifiConnected(_targetWifiName);
    if (wifiName == null || isConnected == false) {
      getSerialNo();
    }
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
        _wifiName = wifiName;
      });
    }
  }

  Future<void> getSerialNo() async {
    try {
      MinMaxData data = await ApiService.fetchMinMaxData();

      String newSerialNo = data.serialNo;

      if (mounted) {
        setState(() {
          serialNo = newSerialNo;
          if (serialNo.startsWith('OD')) {
            if (serialNo.startsWith('ODC')) {
              oxyDataTitle = 'OxyData -C';
            } else if (serialNo.startsWith('ODG')) {
              oxyDataTitle = 'OxyData -G';
            } else if (serialNo.startsWith('ODP')) {
              oxyDataTitle = 'OxyData -P';
            }
          }
          checker = true;
        });
      }
    } catch (e) {
      setState(() {
        print("vjddjvhbjvb");

        checker = false;
      });
    }
  }

  Future<void> fetchSerialNumbers() async {
    final db = await AppDbSingleton().database;
    List<String> serialNos = await db.getAllSerialNumbers();
    setState(() {
      serialNumbers = serialNos;
    });
  }

  Future<void> _refreshPage() async {
    setState(() {
      _isLoading = true;
    });
    _initWifiName();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Sr NO. $serialNo",
              style: TextStyle(
                fontFamily: "NexaRegular",
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    text: '$oxyDataTitle -',
                    style: TextStyle(
                      fontFamily: "NexaBold",
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 25,
                    ),
                    children: [
                      TextSpan(
                        text: ' Oxygen Data Analyser',
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        toolbarHeight: 40,
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.612),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshPage, // Your refresh logic

              child: (_wifiName == "\"${_targetWifiName}\"") ||
                      _isConnected ||
                      checker
                  ? Stack(
                      children: [
                        _lineChartWid,
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
                          Text(
                            "Internet is not connected",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: 185,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => DemoWid()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.blueAccent,
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_arrow, size: 24),
                                  SizedBox(width: 10),
                                  Text('Demo Mode'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 185,
                            child: ElevatedButton(
                              onPressed: () {
                                _showSerialNoDialog();
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (_) => OldReportScreen()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.blueAccent,
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.picture_as_pdf, size: 24),
                                  SizedBox(width: 10),
                                  Text('Report'),
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

  void _showSerialNoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Serial Number"),
          content: DropdownButton<String>(
            value: selectedSerialNo,
            hint: Text("Select Serial Number"),
            items: serialNumbers.map((String serialNo) {
              return DropdownMenuItem<String>(
                value: serialNo,
                child: Text(serialNo),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedSerialNo = newValue;
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => OldReportScreen(
                            serialNo: selectedSerialNo!,
                          ))); // Close the dialog
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}

class WifiService {
  static const MethodChannel _channel = MethodChannel('wifi_name');

  static Future<bool> isWifiConnected(String ssid) async {
    try {
      final bool isConnected =
          await _channel.invokeMethod('isWifiConnected', {'ssid': ssid});
      return isConnected;
    } on PlatformException catch (e) {
      print("Failed to check WiFi connection: '${e.message}'.");
      return false;
    }
  }
}
