import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oxydata/Database/db/app_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

import 'package:drift/drift.dart' as drift;

class PressureSetting extends StatefulWidget {
  final double min;
  final double max;
  PressureSetting({required this.min, required this.max});
  @override
  _PressureSettingState createState() => _PressureSettingState();
}

class _PressureSettingState extends State<PressureSetting> {
  final _formKey = GlobalKey<FormState>();

  Timer? _incrementTimer;
  Timer? _decrementTimer;
  bool _isLoading = false;
  double pressuremax = 0.0;
  double pressuremin = 0.0;
  String? serialNo;
  // Added this to track if data is loaded

  @override
  void initState() {
    pressuremax = widget.max;
    pressuremin = widget.min;

    super.initState();
  }

  Future<void> _saveToSharedPreferences() async {
    final _db = await AppDbSingleton().database;

    final prefs = await SharedPreferences.getInstance();

    double max = double.parse(pressuremax.toStringAsFixed(1));
    double min = double.parse(pressuremin.toStringAsFixed(1));

    prefs.setDouble('pressureMax', max);
    prefs.setDouble('pressureMin', min);

    DateTime dateTime = DateTime.now();
    serialNo = prefs.getString('serialNo') ?? "";
    print("Heloooooooo");
    try {
      await _db.insertLimitSetting(LimitSettingsTableCompanion(
        limit_max: drift.Value(max),
        limit_min: drift.Value(min),
        type: drift.Value("Pressure"),
        serialNo: drift.Value(serialNo!),
        recordedAt: drift.Value(dateTime),
      ));
    } catch (e) {
      print("Error pressure max --> $e");
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
      double newMax = pressuremax + 0.1;
      if (newMax > pressuremin) {
        pressuremax = newMax;
      }
    });
  }

  void _decrementMaxLimit() {
    setState(() {
      double newMax = pressuremax - 0.1;
      if (newMax > pressuremin) {
        pressuremax = newMax;
      }
    });
  }

  void _incrementMinLimit() {
    setState(() {
      double newMin = pressuremin + 0.1;
      if (newMin < pressuremax) {
        pressuremin = newMin;
      }
    });
  }

  void _decrementMinLimit() {
    setState(() {
      double newMin = pressuremin - 0.1;
      if (newMin >= 0) {
        pressuremin = newMin;
      }
    });
  }

  void _startIncrementTimer(VoidCallback callback) {
    _incrementTimer = Timer.periodic(Duration(milliseconds: 120), (_) {
      callback();
    });
  }

  void _stopIncrementTimer() {
    _incrementTimer?.cancel();
  }

  void _startDecrementTimer(VoidCallback callback) {
    _decrementTimer = Timer.periodic(Duration(milliseconds: 120), (_) {
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
              Navigator.pop(context, 1);
            },
            icon: Icon(Icons.arrow_back_outlined),
          ),
          title: Center(
            child: Column(
              children: [
                Text(
                  "Pressure Limit Settings",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "PSI",
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
                  buildLimitCard('Pressure Max', pressuremax,
                      _incrementMaxLimit, _decrementMaxLimit),
                  buildLimitCard('Pressure Min', pressuremin,
                      _incrementMinLimit, _decrementMinLimit),
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
            color: const Color.fromARGB(255, 195, 0, 0),
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
