// lib/o2_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import '../Database/db/app_db.dart';
import 'api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:drift/drift.dart' as drift;

class PuritySetting extends StatefulWidget {
  final double min;
  final double max;
  PuritySetting({required this.min, required this.max});
  @override
  _PuritySettingState createState() => _PuritySettingState();
}

class _PuritySettingState extends State<PuritySetting> {
  final _formKey = GlobalKey<FormState>();

  Timer? _incrementTimer;
  Timer? _decrementTimer;
  bool _isLoading = false;
  double puritymax = 0.0;
  double puritymin = 0.0;
  String? serialNo;

  @override
  void initState() {
    print("kjvhbsjvhbsdjvgdujsvgbdjvgb ${widget.max}");
    puritymax = widget.max;
    puritymin = widget.min;

    super.initState();
  }

  Future<void> _saveToSharedPreferences() async {
    final _db = await AppDbSingleton().database;
    final prefs = await SharedPreferences.getInstance();

    double max = double.parse(puritymax.toStringAsFixed(1));
    double min = double.parse(puritymin.toStringAsFixed(1));
    print("sdjhgvdsfgvjdh: $max");
    DateTime dateTime = DateTime.now();

    prefs.setDouble('purityMax', max);
    prefs.setDouble('purityMin', min);
    serialNo = prefs.getString('serialNo') ?? "";
    try {
      await _db.insertLimitSetting(LimitSettingsTableCompanion(
        limit_max: drift.Value(max),
        limit_min: drift.Value(min),
        type: drift.Value("Purity"),
        serialNo: drift.Value(serialNo!),
        recordedAt: drift.Value(dateTime),
      ));
    } catch (e) {
      print("error in purity data--> $e");
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
      double newMax = puritymax + 0.1;
      if (newMax > puritymin) {
        puritymax = newMax;
      }
    });
  }

  void _decrementMaxLimit() {
    setState(() {
      double newMax = puritymax - 0.1;
      if (newMax > puritymin) {
        puritymax = newMax;
      }
    });
  }

  void _incrementMinLimit() {
    setState(() {
      double newMin = puritymin + 0.1;
      if (newMin < puritymax) {
        puritymin = newMin;
      }
    });
  }

  void _decrementMinLimit() {
    setState(() {
      double newMin = puritymin - 0.1;
      if (newMin >= 0) {
        puritymin = newMin;
      }
    });
  }

  void _startIncrementTimer(VoidCallback callback) {
    _incrementTimer = Timer.periodic(Duration(milliseconds: 10), (_) {
      callback();
    });
  }

  void _stopIncrementTimer() {
    _incrementTimer?.cancel();
  }

  void _startDecrementTimer(VoidCallback callback) {
    _decrementTimer = Timer.periodic(Duration(milliseconds: 10), (_) {
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
                  "Purity Limit Settings",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "%",
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
                  buildLimitCard('Purity Max', puritymax, _incrementMaxLimit,
                      _decrementMaxLimit),
                  buildLimitCard('Purity Min', puritymin, _incrementMinLimit,
                      _decrementMinLimit),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                          // width: MediaQuery.of(context).size.width / 8,
                          // height: MediaQuery.of(context).size.height / 12,
                          child: ElevatedButton(
                            onPressed: () async {
                              print(
                                  "kjvhbsjvhbsdjvgdujsvgbdjvgb ${widget.max}");
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
                                        content:
                                            Text('Failed to post data: $e')),
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
            color: const Color.fromARGB(255, 0, 34, 145),
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
