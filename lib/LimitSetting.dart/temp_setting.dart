// lib/o2_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'min_max_data.dart';
import 'purity_setting.dart';

class TempSetting extends StatefulWidget {
  @override
  _TempSettingState createState() => _TempSettingState();
}

class _TempSettingState extends State<TempSetting> {
  late Future<MinMaxData> futureData;
  final _formKey = GlobalKey<FormState>();
  MinMaxData? _data;

  Timer? _incrementTimer;
  Timer? _decrementTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    futureData = ApiService.fetchMinMaxData();
  }

  Future<void> _postData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.postMinMaxData(_data!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data posted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tempMax', _data!.temperatureMax);
    await prefs.setString('tempMin', _data!.temperatureMin);
  }

  @override
  void dispose() {
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
    super.dispose();
  }

  void _incrementMaxLimit() {
    setState(() {
      int newMax = int.parse(_data!.temperatureMax) + 1;
      if (newMax > int.parse(_data!.temperatureMin)) {
        _data!.temperatureMax = newMax.toString();
      }
    });
  }

  void _decrementMaxLimit() {
    setState(() {
      int newMax = int.parse(_data!.temperatureMax) - 1;
      if (newMax > int.parse(_data!.temperatureMin)) {
        _data!.temperatureMax = newMax.toString();
      }
    });
  }

  void _incrementMinLimit() {
    setState(() {
      int newMin = int.parse(_data!.temperatureMin) + 1;
      if (newMin < int.parse(_data!.temperatureMax)) {
        _data!.temperatureMin = newMin.toString();
      }
    });
  }

  void _decrementMinLimit() {
    setState(() {
      int newMin = int.parse(_data!.temperatureMin) - 1;
      if (newMin >= 0) {
        _data!.temperatureMin = newMin.toString();
      }
    });
  }

  void _startIncrementTimer(VoidCallback callback) {
    _incrementTimer = Timer.periodic(Duration(milliseconds: 150), (_) {
      callback();
    });
  }

  void _stopIncrementTimer() {
    _incrementTimer?.cancel();
  }

  void _startDecrementTimer(VoidCallback callback) {
    _decrementTimer = Timer.periodic(Duration(milliseconds: 150), (_) {
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
      body: FutureBuilder<MinMaxData>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            _data = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildLimitCard('temp Max', _data!.temperatureMax,
                        _incrementMaxLimit, _decrementMaxLimit),
                    SizedBox(height: 5),
                    buildLimitCard('temp Min', _data!.temperatureMin,
                        _incrementMinLimit, _decrementMinLimit),
                    SizedBox(height: 10),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await ApiService.postMinMaxData(_data!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Data posted successfully')),
                                );
                              }
                              await _saveToSharedPreferences();
                              Navigator.pop(context, 1);
                            },
                            child: Text('OK'),
                          ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildLimitCard(String label, String initialValue,
      VoidCallback increment, VoidCallback decrement) {
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
          child: Icon(Icons.remove, size: 40),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.25,
          width: 150,
          child: Card(
            color: Color.fromARGB(255, 4, 160, 84),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  initialValue,
                  style: TextStyle(fontSize: 31, color: Colors.white),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.white),
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
          child: Icon(Icons.add, size: 40),
        ),
      ],
    );
  }
}