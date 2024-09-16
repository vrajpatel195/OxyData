import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../demo.dart';

class PressureDemo extends StatefulWidget {
  const PressureDemo({super.key});

  @override
  State<PressureDemo> createState() => _PressureState();
}

class _PressureState extends State<PressureDemo> {
  double maxLimit = 60;
  double minLimit = 0;
  Timer? _timer;
  Duration _timerDuration = Duration(milliseconds: 300);
  int _holdTime = 0;
  @override
  void initState() {
    loadData();
    // TODO: implement initState
    super.initState();
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      maxLimit = prefs.getDouble('Pressure_maxLimit') ?? 0;
      minLimit = prefs.getDouble('Pressure_minLimit') ?? 0;
    });
  }

  void updateMaxLimit(double value) async {
    setState(() {
      double newMaxLimit =
          value.clamp(minLimit + 1.0, double.infinity).toDouble();
      maxLimit = newMaxLimit;
    });
  }

  void updateMinLimit(double value) async {
    setState(() {
      minLimit = (value.clamp(0.0, maxLimit.toDouble() - 1.0)).toDouble();
    });
  }

  void _saveLimit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('Pressure_maxLimit', maxLimit);
    prefs.setDouble('Pressure_minLimit', minLimit);
  }

  void _startTimer(void Function() callback) {
    _timerValue(callback);
    _timer = Timer.periodic(_timerDuration, (timer) {
      _timerValue(callback);
    });
  }

  void _timerValue(VoidCallback callback) {
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
    _timer?.cancel();
    _timer = Timer.periodic(duration, (timer) {
      _timerValue(callback); // Pass the actual increment logic
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _holdTime = 0; // Reset hold time when the button is released
    _timerDuration = Duration(milliseconds: 300); // Reset to slow speed
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_outlined)),
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
              )
            ],
          ),
        ),
        backgroundColor: Color.fromARGB(141, 241, 241, 241),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0), // Adjust the height as needed
          child: Container(
            color: Colors.black, // Change this to the desired border color
            height: 4.0, // Height of the bottom border
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text("O2", style: TextStyle(fontSize: 20)),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      updateMaxLimit(maxLimit.toDouble() - 1.0);
                    },
                    onLongPressStart: (_) {
                      _startTimer(() {
                        updateMaxLimit(maxLimit.toDouble() - 1.0);
                      });
                    },
                    onLongPressEnd: (_) {
                      _stopTimer();
                    },
                    child: Icon(Icons.remove, size: 40),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: 150,
                    child: Card(
                      color: const Color.fromARGB(255, 195, 0, 0),
                      child: Column(
                        children: [
                          Text(
                            '${maxLimit}',
                            style: TextStyle(fontSize: 31, color: Colors.white),
                          ),
                          Text(
                            "Maximum Limit",
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          )
                        ],
                      ),
                      margin: EdgeInsets.all(10),
                    ),
                  ), //${product.minLimit}
                  GestureDetector(
                    onTap: () {
                      updateMaxLimit(maxLimit.toDouble() + 1.0);
                    },
                    onLongPressStart: (_) {
                      _startTimer(() {
                        updateMaxLimit(maxLimit.toDouble() + 1.0);
                      });
                    },
                    onLongPressEnd: (_) {
                      _stopTimer();
                    },
                    child: Icon(Icons.add, size: 40),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      updateMinLimit(minLimit.toDouble() - 1.0);
                    },
                    onLongPressStart: (_) {
                      _startTimer(() {
                        updateMinLimit(minLimit.toDouble() - 1.0);
                      });
                    },
                    onLongPressEnd: (_) {
                      _stopTimer();
                    },
                    child: Icon(Icons.remove, size: 40),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: 150,
                    child: Card(
                      color: const Color.fromARGB(255, 195, 0, 0),
                      child: Column(
                        children: [
                          Text(
                            '${minLimit}',
                            style: TextStyle(fontSize: 31, color: Colors.white),
                          ),
                          Text(
                            "Minimum Limit",
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          )
                        ],
                      ),
                      margin: EdgeInsets.all(10),
                    ),
                  ), //${product.maxLimit}
                  GestureDetector(
                    onTap: () {
                      updateMinLimit(minLimit.toDouble() + 1.0);
                    },
                    onLongPressStart: (_) {
                      _startTimer(() {
                        updateMinLimit(minLimit.toDouble() + 1.0);
                      });
                    },
                    onLongPressEnd: (_) {
                      _stopTimer();
                    },
                    child: Icon(Icons.add, size: 40),
                  ),
                ],
              ),

              GestureDetector(
                onTap: () {
                  _saveLimit();
                  _changeColor();
                  final value = 1;
                  Navigator.pop(context, value);
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: 100,
                  child: Card(
                    elevation: 5.0,
                    color: _cardColor,
                    child: Center(
                      child: Text("OK",
                          style: TextStyle(fontSize: 25, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _cardColor = Color.fromARGB(255, 4, 144, 199);
  void _changeColor() {
    setState(() {
      _cardColor = _cardColor == Color.fromARGB(255, 4, 144, 199)
          ? Colors.red
          : Color.fromARGB(255, 4, 144, 199);
    });
  }
}
