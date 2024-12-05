import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oxydata/Database/db/app_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'min_max_data.dart';
import 'package:drift/drift.dart' as drift;

class FlowSetting extends StatefulWidget {
  final double min;
  final double max;
  final int isInternet;
  FlowSetting({required this.min, required this.max, required this.isInternet});

  @override
  _FlowSettingState createState() => _FlowSettingState();
}

class _FlowSettingState extends State<FlowSetting> {
  final _formKey = GlobalKey<FormState>();
  Timer? _incrementTimer;
  Timer? _decrementTimer;
  bool _isLoading = false;
  double flowmax = 0.0;
  double flowmin = 0.0;
  String? serialNo;
  int _holdTime = 0;
  Duration _incrementDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    flowmax = widget.max;
    flowmin = widget.min;
    print("Valeu Of MinMAx  ==> F A  ${widget.max}");
  }

  Future<void> _saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    double max = double.parse(flowmax.toStringAsFixed(1));
    double min = double.parse(flowmin.toStringAsFixed(1));

    prefs.setDouble('flowMax', max);
    prefs.setDouble('flowMin', min);

    serialNo = prefs.getString('serialNo') ?? "";

    if (widget.isInternet == 3) {
      final _db = await AppDbSingleton().database;
      DateTime dateTime = DateTime.now();
      try {
        await _db.insertLimitSetting(LimitSettingsTableCompanion(
          limit_max: drift.Value(max),
          limit_min: drift.Value(min),
          type: drift.Value("Flow"),
          serialNo: drift.Value(serialNo!),
          recordedAt: drift.Value(dateTime),
        ));
      } catch (e) {
        print("error in purity data--> $e");
      }

      List<LimitSettingsTableData> storedData = await _db.getAllLimitSettings();
      print("Storedddd data =>   $storedData");
    }
  }

  @override
  void dispose() {
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
    super.dispose();
  }

  void _incrementMaxLimit() {
    setState(() {
      double newMax = flowmax + 0.1;
      if (newMax > flowmin) {
        flowmax = newMax;
      }
    });
  }

  void _decrementMaxLimit() {
    setState(() {
      double newMax = flowmax - 0.1;
      if (newMax > flowmin) {
        flowmax = newMax;
      }
    });
  }

  void _incrementMinLimit() {
    setState(() {
      double newMin = flowmin + 0.1;
      if (newMin < flowmax) {
        flowmin = newMin;
      }
    });
  }

  void _decrementMinLimit() {
    setState(() {
      double newMin = double.parse(flowmin.toStringAsFixed(1)) - 0.1;
      if (newMin >= 0.0) {
        flowmin = newMin;
      }
    });
  }

  // Dynamic speed adjustment for incrementing
  void _startIncrementTimer(VoidCallback callback) {
    _incrementValue(callback);
    _incrementTimer = Timer.periodic(_incrementDuration, (timer) {
      _incrementValue(callback);
    });
  }

  void _incrementValue(VoidCallback callback) {
    setState(() {
      _holdTime++;
      callback();
      if (_holdTime == 2) {
        _resetIncrementTimer(
            Duration(milliseconds: 250), callback); // Medium speed
      } else if (_holdTime == 5) {
        _resetIncrementTimer(
            Duration(milliseconds: 150), callback); // Fast speed
      } else if (_holdTime == 10) {
        _resetIncrementTimer(
            Duration(milliseconds: 100), callback); // Fast speed
      } else if (_holdTime == 20) {
        _resetIncrementTimer(
            Duration(milliseconds: 75), callback); // Fast speed
      } else if (_holdTime == 35) {
        _resetIncrementTimer(
            Duration(milliseconds: 50), callback); // Fast speed
      } else if (_holdTime == 60) {
        _resetIncrementTimer(
            Duration(milliseconds: 25), callback); // Fast speed
      } else if (_holdTime == 90) {
        _resetIncrementTimer(
            Duration(milliseconds: 10), callback); // Fast speed
      } else if (_holdTime == 999) {
        _resetIncrementTimer(Duration(milliseconds: 1), callback); // Fast speed
      }
    });
  }

  void _resetIncrementTimer(Duration duration, VoidCallback callback) {
    _incrementTimer?.cancel();
    _incrementTimer = Timer.periodic(duration, (timer) {
      _incrementValue(callback); // Pass the actual increment logic
    });
  }

  void _stopIncrementTimer() {
    _incrementTimer?.cancel();
    _holdTime = 0; // Reset hold time when the button is released
    _incrementDuration = Duration(milliseconds: 300); // Reset to slow speed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined),
        ),
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Flow Limit Settings ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                " (LPM)",
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        backgroundColor: Color.fromARGB(141, 241, 241, 241),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Colors.black,
            height: 4.0,
          ),
        ),
        toolbarHeight: 40,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildLimitCard(
                  'Flow Max', flowmax, _incrementMaxLimit, _decrementMaxLimit),
              buildLimitCard(
                  'Flow Min', flowmin, _incrementMinLimit, _decrementMinLimit),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        await _saveToSharedPreferences();

                        if (_formKey.currentState!.validate()) {
                          try {
                            setState(() {
                              _isLoading = true;
                            });

                            if (widget.isInternet == 3) {
                              await postStoredData();
                            }
                            Navigator.pop(context, 1);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Flow Limit Set successfully')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to post data: $e')),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      child: Text('OK'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLimitCard(String label, double initialValue,
      VoidCallback increment, VoidCallback decrement) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTapDown: (_) {
            _startIncrementTimer(decrement);
          },
          onTapUp: (_) {
            _stopIncrementTimer();
          },
          onTapCancel: () {
            _stopIncrementTimer();
          },
          child: Icon(Icons.remove, size: screenHeight / 8),
        ),
        Container(
          height: screenHeight * 0.30,
          width: screenWidth / 4.5,
          child: Card(
            color: Color.fromARGB(255, 248, 186, 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  initialValue.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: screenWidth / 20, color: Colors.white),
                ),
                Text(
                  label,
                  style: TextStyle(
                      fontSize: screenWidth / 60, color: Colors.white),
                ),
              ],
            ),
            margin: EdgeInsets.all(10),
          ),
        ),
        GestureDetector(
          onTapDown: (_) {
            _startIncrementTimer(increment);
          },
          onTapUp: (_) {
            _stopIncrementTimer();
          },
          onTapCancel: () {
            _stopIncrementTimer();
          },
          child: Icon(Icons.add, size: screenHeight / 8),
        ),
      ],
    );
  }
}
