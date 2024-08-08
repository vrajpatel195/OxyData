import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:oxydata/Demo/demo_generate_report.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class DemoWeeklyReport extends StatefulWidget {
  DemoWeeklyReport({
    super.key,
    required this.weekRange,
    required this.remark,
    required this.startDate,
    required this.endDate,
  });
  String? weekRange;
  final String remark;
  DateTime startDate;
  DateTime endDate;

  @override
  State<DemoWeeklyReport> createState() => _DemoWeeklyReportState();
}

class _DemoWeeklyReportState extends State<DemoWeeklyReport> {
  late List<Map<String, dynamic>> _dataPoints;
  late List<Map<String, dynamic>> _dataLimits;

  final GlobalKey _chartKey = GlobalKey();
  DateTime? startDate;
  DateTime? endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    startDate = widget.startDate;
    endDate = widget.endDate;
    _dataPoints = _generateSequentialRandomDataPoints(startDate!, endDate!, 10);
    _dataLimits = _generateRandomDataLimits(endDate!);
  }

  List<Map<String, dynamic>> _generateSequentialRandomDataPoints(
      DateTime startDate, DateTime endDate, int numberOfPoints) {
    final random = Random();
    List<Map<String, dynamic>> dataPoints = [];

    // Calculate the total number of seconds between start and end date
    int totalSeconds = endDate.difference(startDate).inSeconds;

    // Calculate the step to ensure increasing order of timestamps
    int step = (totalSeconds / numberOfPoints).floor();

    DateTime currentTimestamp = startDate;

    for (int i = 0; i < numberOfPoints; i++) {
      // Generate random values for purity, flow rate, pressure, and temperature
      double purity = random.nextDouble() * 10 + 80;
      double flowRate = random.nextDouble() * 10 + 10;
      double pressure = random.nextDouble() * 20;
      double temperature = random.nextDouble() * 10 + 30;

      // Add the generated data point to the list
      dataPoints.add({
        'timestamp': currentTimestamp,
        'purity': purity,
        'flowRate': flowRate,
        'pressure': pressure,
        'temperature': temperature,
      });

      // Increment the timestamp by the calculated step to ensure increasing order
      currentTimestamp = currentTimestamp.add(Duration(seconds: step));
    }

    return dataPoints;
  }

  List<Map<String, dynamic>> _generateRandomDataLimits(DateTime selectedDate) {
    final random = Random();
    List<Map<String, dynamic>> dataLimits = [];

    // Define the types and their corresponding limit ranges
    List<Map<String, dynamic>> types = [
      {
        'type': 'purity',
        'limitMaxRange': [90, 100], // Max between 90 and 100
        'limitMinRange': [80, 90], // Min between 80 and 90
      },
      {
        'type': 'flow',
        'limitMaxRange': [5, 10], // Max between 5 and 10
        'limitMinRange': [1, 5], // Min between 1 and 5
      },
      {
        'type': 'pressure',
        'limitMaxRange': [40, 50], // Max between 40 and 50
        'limitMinRange': [30, 40], // Min between 30 and 40
      },
      {
        'type': 'temp',
        'limitMaxRange': [30, 40], // Max between 30 and 40
        'limitMinRange': [20, 30], // Min between 20 and 30
      }
    ];

    for (var type in types) {
      DateTime timestamp = DateTime(
        selectedDate.year,
        selectedDate.month,
        random.nextInt(7),
        random.nextInt(24), // Random hour
        random.nextInt(60), // Random minute
        random.nextInt(60), // Random second
      );

      double limitMax = type['limitMaxRange'][0] +
          random.nextDouble() *
              (type['limitMaxRange'][1] - type['limitMaxRange'][0]);
      double limitMin = type['limitMinRange'][0] +
          random.nextDouble() *
              (type['limitMinRange'][1] - type['limitMinRange'][0]);

      dataLimits.add({
        'timestamp': timestamp,
        'limit_max': limitMax,
        'limit_min': limitMin,
        'type': type['type'],
      });
    }

    return dataLimits;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back)),
        title: Text('Weekly Report'),
        actions: [
          Text("Selected Week: ${widget.weekRange}"),
          SizedBox(
            width: 15,
          ),
          if (_dataPoints.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                _generatePdfAfterRender();
              },
              child: _isLoading ? CircularProgressIndicator() : Text("Report"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
        ],
      ),
      body: RepaintBoundary(
        key: _chartKey,
        child: _dataPoints.isEmpty
            ? Center(
                child: Text(
                  "No data found!     (${widget.weekRange})",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.80,
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(
                          intervalType: DateTimeIntervalType.days,
                          dateFormat: DateFormat('EEE'),
                          minimum: startDate,
                          maximum: endDate,
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          rangePadding: ChartRangePadding.none,
                          labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          majorGridLines: MajorGridLines(
                            color: Colors.black,
                            width: 1,
                          ),
                          axisLine: AxisLine(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        primaryYAxis: const NumericAxis(
                          name: 'primaryYAxis1',
                          minimum: 0,
                          maximum: 100,
                          interval: 20,
                          labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          majorGridLines: MajorGridLines(
                            color: Colors.black,
                            width: 1,
                          ),
                          axisLine: AxisLine(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        axes: const <ChartAxis>[
                          NumericAxis(
                            name: 'spacerYAxis',
                            opposedPosition: false,
                            minimum: 0,
                            maximum: 10,
                            interval: 2,
                            labelStyle: TextStyle(
                              color: Colors.transparent,
                            ),
                            majorGridLines: MajorGridLines(
                              color: Colors.transparent,
                            ),
                            axisLine: AxisLine(
                              color: Colors.transparent,
                            ),
                          ),
                          NumericAxis(
                            name: 'primaryYAxis2',
                            opposedPosition: false,
                            minimum: 0,
                            maximum: 20,
                            interval: 4,
                            labelStyle: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            majorGridLines: MajorGridLines(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          NumericAxis(
                            name: 'secondaryYAxis1',
                            opposedPosition: true,
                            minimum: 0,
                            maximum: 100,
                            interval: 20,
                            labelStyle: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            majorGridLines: MajorGridLines(
                              color: Colors.black,
                              width: 1,
                            ),
                            axisLine: AxisLine(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          NumericAxis(
                            name: 'spacerYAxis1',
                            opposedPosition: true,
                            minimum: 0,
                            maximum: 10,
                            interval: 2,
                            labelStyle: TextStyle(
                              color: Colors.transparent,
                            ),
                            majorGridLines: MajorGridLines(
                              color: Colors.transparent,
                            ),
                            axisLine: AxisLine(
                              color: Colors.transparent,
                            ),
                          ),
                          NumericAxis(
                            name: 'secondaryYAxis2',
                            opposedPosition: true,
                            minimum: 0,
                            maximum: 50,
                            interval: 10,
                            labelStyle: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            majorGridLines: MajorGridLines(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ],
                        series: <LineSeries<Map<String, dynamic>, DateTime>>[
                          LineSeries<Map<String, dynamic>, DateTime>(
                            dataSource: _dataPoints,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                data['timestamp'] as DateTime,
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                data['purity'] as double,
                            name: 'Purity',
                            color: Colors.black,
                            yAxisName: 'primaryYAxis1',
                          ),
                          LineSeries<Map<String, dynamic>, DateTime>(
                            dataSource: _dataPoints,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                data['timestamp'] as DateTime,
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                data['flowRate'] as double,
                            name: 'Flow Rate',
                            yAxisName: 'primaryYAxis2',
                            color: Colors.blue,
                          ),
                          LineSeries<Map<String, dynamic>, DateTime>(
                            dataSource: _dataPoints,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                data['timestamp'] as DateTime,
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                data['pressure'] as double,
                            name: 'Pressure',
                            yAxisName: 'secondaryYAxis1',
                            color: Colors.red,
                          ),
                          LineSeries<Map<String, dynamic>, DateTime>(
                            dataSource: _dataPoints,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                data['timestamp'] as DateTime,
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                data['temperature'] as double,
                            name: 'Temperature',
                            yAxisName: 'secondaryYAxis2',
                            color: Colors.green,
                          ),
                        ],
                        legend: Legend(isVisible: true),
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _generatePdfAfterRender() async {
    setState(() {
      _isLoading = true;
    });
    try {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        final Uint8List chartImage = await _captureChart();
        try {
          await DemoGenerateReport(
            data: _dataPoints,
            dataLimit: _dataLimits,
            title: "Weekly",
          ).generateReportPdf(
            chartImage,
            widget.remark,
            weekStartDate: startDate,
            weekEndDate: endDate,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report generated successfully!')),
          );
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to generate report: $error')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print("Error generating PDF after rendering: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Uint8List> _captureChart() async {
    try {
      RenderRepaintBoundary boundary =
          _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      print("Error capturing chart image: $e");
      rethrow;
    }
  }
}
