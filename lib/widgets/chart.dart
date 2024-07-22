import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartSample extends StatefulWidget {
  @override
  _LineChartSampleState createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> {
  List<FlSpot> purityData = [];
  List<FlSpot> flowData = [];
  List<FlSpot> pressureData = [];
  List<FlSpot> tempData = [];

  @override
  void initState() {
    super.initState();
    _generateRandomData();
  }

  void _generateRandomData() {
    final random = Random();
    for (int i = 0; i < 60; i++) {
      purityData.add(FlSpot(i.toDouble(), 80 + random.nextDouble() * 20));
      flowData.add(FlSpot(i.toDouble(), 10 + random.nextDouble() * 10));
      pressureData.add(FlSpot(i.toDouble(), 10 + random.nextDouble() * 10));
      tempData.add(FlSpot(i.toDouble(), 30 + random.nextDouble() * 20));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Line Chart'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            children: [
              Column(
                children: [
                  Text(
                    "100",
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(
                    height: screenHeight * 0.06,
                  ),
                  Text(
                    "80",
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "60",
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(
                    height: screenHeight * 0.069,
                  ),
                  Text(
                    "40",
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "20",
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "0",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              SizedBox(
                width: screenWidth * 0.05,
              ),
              Column(
                children: [
                  Text(
                    "100",
                  ),
                  SizedBox(
                    height: screenHeight * 0.06,
                  ),
                  Text(
                    "80",
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "60",
                  ),
                  SizedBox(
                    height: screenHeight * 0.069,
                  ),
                  Text(
                    "40",
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "20",
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "0",
                  ),
                ],
              ),
            ],
          ),
          Center(
            child: Container(
              height: screenHeight * 0.70,
              width: screenWidth * 0.70,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 10 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 10),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: purityData,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: flowData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: pressureData,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: tempData,
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 2,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d)),
                  ),
                  minY: 0,
                  maxY: 100,
                  minX: 0,
                  maxX: 59,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    "10",
                    style: TextStyle(color: Colors.blue),
                  ),
                  SizedBox(
                    height: screenHeight * 0.06,
                  ),
                  Text(
                    "8",
                    style: TextStyle(color: Colors.blue),
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "6",
                    style: TextStyle(color: Colors.blue),
                  ),
                  SizedBox(
                    height: screenHeight * 0.069,
                  ),
                  Text(
                    "4",
                    style: TextStyle(color: Colors.blue),
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "2",
                    style: TextStyle(color: Colors.blue),
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "0",
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              SizedBox(
                width: screenWidth * 0.05,
              ),
              Column(
                children: [
                  Text(
                    "50",
                    style: TextStyle(color: Colors.green),
                  ),
                  SizedBox(
                    height: screenHeight * 0.06,
                  ),
                  Text(
                    "40",
                    style: TextStyle(color: Colors.green),
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "30",
                    style: TextStyle(color: Colors.green),
                  ),
                  SizedBox(
                    height: screenHeight * 0.069,
                  ),
                  Text(
                    "20",
                    style: TextStyle(color: Colors.green),
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "10",
                    style: TextStyle(color: Colors.green),
                  ),
                  SizedBox(
                    height: screenHeight * 0.065,
                  ),
                  Text(
                    "0",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
