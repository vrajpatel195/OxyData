// lib/o2_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import '../Database/db/app_db.dart';
import 'api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:drift/drift.dart' as drift;

class TempSetting extends StatefulWidget {
  final double min;
  final double max;
  TempSetting({required this.min, required this.max});
  @override
  _TempSettingState createState() => _TempSettingState();
}

class _TempSettingState extends State<TempSetting> {
  final _formKey = GlobalKey<FormState>();

  Timer? _incrementTimer;
  Timer? _decrementTimer;
  bool _isLoading = false;
  double tempMax = 0.0;
  double tempMin = 0.0;
  String? serialNo;
  int _holdTime = 0;
  Duration _incrementDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    tempMax = widget.max;
    tempMin = widget.min;
    super.initState();
  }

  Future<void> _saveToSharedPreferences() async {
    final _db = await AppDbSingleton().database;

    final prefs = await SharedPreferences.getInstance();

    double max = double.parse(tempMax.toStringAsFixed(1));
    double min = double.parse(tempMin.toStringAsFixed(1));
    DateTime dateTime = DateTime.now();
    prefs.setDouble('tempMax', max);
    prefs.setDouble('tempMin', min);

    serialNo = prefs.getString('serialNo') ?? "";
    try {
      await _db.insertLimitSetting(LimitSettingsTableCompanion(
        limit_max: drift.Value(max),
        limit_min: drift.Value(min),
        type: drift.Value("Temperature"),
        serialNo: drift.Value(serialNo!),
        recordedAt: drift.Value(dateTime),
      ));
    } catch (e) {
      print("Error on temp data --> $e");
    }

    List<LimitSettingsTableData> storedData = await _db.getAllLimitSettings();
    print("Storedddd data =>   $storedData");
  }

  @override
  void dispose() {
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
    super.dispose();
  }

  void _incrementMaxLimit() {
    setState(() {
      double newMax = tempMax + 0.1;
      if (newMax > tempMin) {
        tempMax = newMax;
      }
    });
  }

  void _decrementMaxLimit() {
    setState(() {
      double newMax = tempMax - 0.1;
      if (newMax > tempMin) {
        tempMax = newMax;
      }
    });
  }

  void _incrementMinLimit() {
    setState(() {
      double newMin = tempMin + 0.1;
      if (newMin < tempMax) {
        tempMin = newMin;
      }
    });
  }

  void _decrementMinLimit() {
    setState(() {
      double newMin = tempMin - 0.1;
      if (newMin >= 0) {
        tempMin = newMin;
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

  // Dynamic speed adjustment for decrementing
  void _startDecrementTimer(VoidCallback callback) {
    _decrementValue(callback);
    _decrementTimer = Timer.periodic(_incrementDuration, (timer) {
      _decrementValue(callback);
    });
  }

  void _decrementValue(VoidCallback callback) {
    setState(() {
      _holdTime++;
      callback();
      if (_holdTime == 2) {
        _resetDecrementTimer(
            Duration(milliseconds: 250), callback); // Medium speed
      } else if (_holdTime == 5) {
        _resetDecrementTimer(
            Duration(milliseconds: 150), callback); // Fast speed
      } else if (_holdTime == 8) {
        _resetDecrementTimer(
            Duration(milliseconds: 100), callback); // Fast speed
      } else if (_holdTime == 11) {
        _resetDecrementTimer(
            Duration(milliseconds: 75), callback); // Fast speed
      }
    });
  }

  void _resetDecrementTimer(Duration duration, VoidCallback callback) {
    _decrementTimer?.cancel();
    _decrementTimer = Timer.periodic(duration, (timer) {
      _decrementValue(callback); // Pass the actual decrement logic
    });
  }

  void _stopDecrementTimer() {
    _decrementTimer?.cancel();
    _holdTime = 0; // Reset hold time
    _incrementDuration = Duration(milliseconds: 300); // Reset to slow speed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_outlined),
          ),
          title: Center(
            child: Column(
              children: [
                Text(
                  "Temp Limit Settings",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "°C",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.0),
            child: Container(
              color: Colors.black,
              height: 4.0,
            ),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildLimitCard('Temp Max', tempMax, _incrementMaxLimit,
                      _decrementMaxLimit),
                  buildLimitCard('Temp Min', tempMin, _incrementMinLimit,
                      _decrementMinLimit),
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

                                await postStoredData();
                                Navigator.pop(context, 1);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Data posted successfully')),
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
            )));
  }

  Widget buildLimitCard(String label, double initialValue,
      VoidCallback increment, VoidCallback decrement) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: decrement,
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
            color: Color.fromARGB(255, 3, 161, 84),
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
          onTap: increment,
          onTapDown: (_) {
            _startDecrementTimer(increment);
          },
          onTapUp: (_) {
            _stopDecrementTimer();
          },
          onTapCancel: () {
            _stopDecrementTimer();
          },
          child: Icon(Icons.add, size: screenHeight / 8),
        ),
      ],
    );
  }
}
