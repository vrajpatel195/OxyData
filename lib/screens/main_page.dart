import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../LimitSetting.dart/api_service.dart';
import '../LimitSetting.dart/min_max_data.dart';
import '../widgets/demo.dart';
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

  String oxyDataTitle = 'OxyData';

  @override
  void initState() {
    super.initState();
    _initWifiName();
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
    // await _requestLocationPermissions();

    // Retrieve WiFi name
    // try {
    //   String? wifiName = await NetworkInfo().getWifiName();
    //   print("wifi name: \"${wifiName}\"");
    //   setState(() {
    //     _wifiName = wifiName;
    //     _isLoading = false;
    //   });

    // Check serial number after getting WiFi name
    await getSerialNo();
    // } on PlatformException catch (e) {
    //   print("Failed to get wifi name: '${e.message}'.");
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }

    // Start periodic WiFi check timer
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
    _wifiCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await getSerialNo();
    });
  }

  void _stopWifiCheckTimer() {
    _wifiCheckTimer.cancel();
  }

  // void _updateWifiStatus() async {
  //   // String? wifiName = await NetworkInfo().getWifiName();
  //   // setState(() {
  //   //   _wifiName = wifiName;
  //   // });
  //   // print("wifiName123->>>$wifiName");

  //   // Check serial number after getting WiFi name

  // }

  Future<void> getSerialNo() async {
    print("hii123");
    try {
      MinMaxData data = await ApiService.fetchMinMaxData();
      print("data123->>>${data}");
      String newSerialNo = data.serialNo;

      setState(() {
        serialNo = newSerialNo;
        if (serialNo.startsWith('OD')) {
          if (serialNo.startsWith('ODC')) {
            oxyDataTitle = 'OxyData -C';
          } else if (serialNo.startsWith('ODG')) {
            oxyDataTitle = 'OxyData -G';
          } else if (serialNo.startsWith('ODP')) {
            print("ODP");
            oxyDataTitle = 'OxyData -P';
            print("OxyData -P");
          }

          setState(() {
            print("true123");
            checker = true;
          });
        }
      });
    } catch (e) {
      setState(() {
        print("hii");
        checker = false;
      });
    }
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sr NO. $serialNo",
                style: TextStyle(
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
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 25,
                      ),
                      children: [
                        TextSpan(
                          text: ' Oxygen Data Analyser',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Spacer to balance the layout
            ],
          ),
          toolbarHeight: 40,
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.612),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : (_wifiName == "\"${_targetWifiName}\"") || checker
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
                              minimumSize: Size(90,
                                  25), // Set minimum size to maintain height
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
