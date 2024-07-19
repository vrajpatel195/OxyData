import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oxydata/widgets/demo.dart';

import 'package:shared_preferences/shared_preferences.dart';

class FlowDemo extends StatefulWidget {
  const FlowDemo({super.key});

  @override
  State<FlowDemo> createState() => _FlowDemoState();
}

class _FlowDemoState extends State<FlowDemo> {
  int maxLimit = 0;
  int minLimit = 0;
  Timer? _timer;

  @override
  void initState() {
    loadData();
    // TODO: implement initState
    super.initState();
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      maxLimit = prefs.getInt('Flow_maxLimit') ?? 0;
      minLimit = prefs.getInt('Flow_minLimit') ?? 0;
    });
  }

  void updateMaxLimit(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      maxLimit = (value.clamp(1.0, double.infinity) - 1.0).toInt() + 1;
      prefs.setInt('Flow_maxLimit', maxLimit);
    });
  }

  void updateMinLimit(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      minLimit = (value.clamp(0.0, maxLimit.toDouble() - 1.0)).toInt();
      prefs.setInt('Flow_minLimit', minLimit);
    });
  }

  void _startTimer(void Function() callback) {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      callback();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
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
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_outlined)),
        title: Center(
          child: Column(
            children: [
              Text(
                "Flow Limit Settings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "LPM",
                style: TextStyle(fontSize: 15),
              )
            ],
          ),
        ),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
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
                      color: Color.fromARGB(255, 248, 186, 40),
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
                      color: Color.fromARGB(255, 248, 186, 40),
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
