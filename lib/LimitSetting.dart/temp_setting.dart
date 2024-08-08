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
  // Added this to track if data is loaded

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

  void _startIncrementTimer(VoidCallback callback) {
    _incrementTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      callback();
    });
  }

  void _stopIncrementTimer() {
    _incrementTimer?.cancel();
  }

  void _startDecrementTimer(VoidCallback callback) {
    _decrementTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      callback();
    });
  }

  void _stopDecrementTimer() {
    _decrementTimer?.cancel();
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
          child: Icon(Icons.remove, size: screenHeight / 10),
        ),
        Container(
          height: screenHeight * 0.30,
          width: screenWidth / 5,
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
          child: Icon(Icons.add, size: screenHeight / 10),
        ),
      ],
    );
  }
}
