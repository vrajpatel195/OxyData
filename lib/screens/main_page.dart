import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Database/db/app_db.dart';
import '../LimitSetting.dart/api_service.dart';
import '../LimitSetting.dart/min_max_data.dart';
import '../Report_screens/old_report_screen.dart';
import '../Demo/demo.dart';
import '../Services/mqtt_connect.dart';
import 'HomePage.dart';
import 'login_internet.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key, required this.version});
  String version;

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
  int isInternet = 1;

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
  late MqttService mqttService;

  @override
  void initState() {
    super.initState();

    fetchSerialNumbers();

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
    _wifiCheckTimer.cancel();

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
      print("Error in wifi getting name: $e");

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
      if (mounted) {
        setState(() {
          checker = false;
        });
      }
    }
  }

  Future<void> getInternetSerialNo(String serialNo1) async {
    try {
      String newSerialNo = serialNo1;
      print("seialnondcvnkjnvk: $serialNo1");

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
      if (mounted) {
        setState(() {
          checker = false;
        });
      }
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
                width: MediaQuery.of(context).size.height / 2.2,
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

                child: ((_wifiName == "\"$_targetWifiName\"") ||
                        _isConnected ||
                        checker ||
                        isInternet == 2)
                    ? Stack(
                        children: [
                          LineCharWid(
                            isInternet: isInternet,
                            mqttService: isInternet == 2 ? mqttService : null,
                          )
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showCustomDialog(context);
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
                                        Icon(Icons.refresh, size: 24),
                                        SizedBox(width: 10),
                                        Text('Connect'),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => DemoWid(
                                                    version: widget.version,
                                                  )));
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
                              ],
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

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Connection Type'),
          content: const Text('Please choose how to connect.'),
          actions: [
            // Local Device Button
            SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isInternet = 3;
                  });
                  _initWifiName();
                  _startWifiCheckTimer();
                  getSerialNo();
                  Navigator.pop(context); // Close the dialog
                  // Add your functionality for local device connection here
                },
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.devices, size: 24),
                    SizedBox(width: 10),
                    Text('Local Device'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Internet Button
            SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isInternet = 2;
                  });
                  mqttService = MqttService();
                  mqttService.connect();
                  mqttService.messageStream.listen((message) {
                    try {
                      var jsonData = jsonDecode(message);
                      serialNo = jsonData['serialNo'] ?? '';
                      print("seialnondcvnkjnvkcvdc: $serialNo");

                      getInternetSerialNo(serialNo);
                    } catch (e) {
                      print("Error parsing message: $e");
                    }
                  });

                  Navigator.pop(context); // Close the dialog

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (_) => LoginPage()), // Navigate to login page
                  // );
                },
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi, size: 24),
                    SizedBox(width: 10),
                    Text('Internet'),
                  ],
                ),
              ),
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
