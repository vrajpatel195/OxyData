import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Database/db/app_db.dart';
import '../LimitSetting.dart/api_service.dart';
import '../LimitSetting.dart/min_max_data.dart';
import '../Report_screens/old_report_screen.dart';
import '../Demo/demo.dart';
import 'HomePage.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  String? _wifiName;
  bool _isLoading = false;
  final String _targetWifiName = "Oxydata_1";
  final LineCharWid _lineChartWid = const LineCharWid();
  bool checker = false;

  late AnimationController _animationController;
  late Animation<double> _animation;
  String serialNo = '';
  bool _isConnected = false;
  bool? permissionGranted;

  String oxyDataTitle = 'OxyData';
  String? selectedSerialNo;
  List<String> serialNumbers = [];

  String _formattedDateTime = '';
  late Timer _dateTimeTimer;

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
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _updateDateTime();
    _dateTimeTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _updateDateTime();
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy  HH:mm:ss  ');
    setState(() {
      _formattedDateTime = formatter.format(now);
    });
  }

  @override
  void dispose() {
    _stopWifiCheckTimer();
    _animationController.dispose();
    _dateTimeTimer.cancel();
    super.dispose();
  }

  void _initWifiName() async {
    await _requestLocationPermissions();

    try {
      String? wifiName = await NetworkInfo().getWifiName();

      bool isConnected = await WifiService.isWifiConnected(_targetWifiName);
      if (mounted) {
        setState(() {
          _wifiName = wifiName;
          _isConnected = isConnected;
          _isLoading = false;
        });
      }
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print("Error to getting wifi name: $e");
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

  late Timer _wifiCheckTimer;

  void _startWifiCheckTimer() {
    _wifiCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
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

          if (serialNo.startsWith('ODC')) {
            oxyDataTitle = 'OxyData -C';
          } else if (serialNo.startsWith('ODG')) {
            oxyDataTitle = 'OxyData -G';
          } else if (serialNo.startsWith('OGP')) {
            oxyDataTitle = 'OxyData -GP';
          } else if (serialNo.startsWith('ODP')) {
            oxyDataTitle = 'OxyData -P';
          } else if (serialNo.startsWith('OPP')) {
            oxyDataTitle = 'OxyData -PP';
          } else if (serialNo.startsWith('OP9') ||
              serialNo.startsWith('OP1') ||
              serialNo.startsWith('OP2') ||
              serialNo.startsWith('OP5')) {
            oxyDataTitle = 'OxyData -PPF';
          } else if (serialNo.startsWith('ODA')) {
            oxyDataTitle = 'OxyData -AV';
          }

          checker = true;
        });
      }
    } catch (e) {
      setState(() {
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

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Exit'),
            content: const Text('Do you want to leave the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  SystemChannels.platform
                      .invokeMethod<void>('SystemNavigator.pop');
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sr NO. $serialNo",
                style: const TextStyle(
                  fontFamily: "NexaRegular",
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      text: '$oxyDataTitle -',
                      style: const TextStyle(
                        fontFamily: "NexaBold",
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 22,
                      ),
                      children: const [
                        TextSpan(
                          text: ' Oxygen Analyzer',
                          style: TextStyle(
                            fontFamily: "NexaRegular",
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 150,
                child: Text(
                  _formattedDateTime,
                  style: const TextStyle(
                    fontFamily: "NexaRegular",
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          toolbarHeight: 40,
          backgroundColor: Color.fromARGB(141, 241, 241, 241),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshPage, // Your refresh logic

                child: (_wifiName == "\"$_targetWifiName\"") ||
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
                                  child: const Icon(
                                    Icons.wifi_off,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Internet is not connected",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const DemoWid()));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.blueAccent,
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.play_arrow, size: 24),
                                    SizedBox(width: 10),
                                    Text('Demo Mode'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: const Row(
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
      ),
    );
  }

  void _showSerialNoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Serial Number"),
          content: DropdownButton<String>(
            value: selectedSerialNo,
            hint: const Text("Select Serial Number"),
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
              child: const Text("Cancel"),
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
      // ignore: avoid_print
      print("Failed to check WiFi connection: '${e.message}'.");
      return false;
    }
  }
}
