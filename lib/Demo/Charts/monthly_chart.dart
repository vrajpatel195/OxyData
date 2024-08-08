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
class DemoMonthlyReport extends StatefulWidget {
  DemoMonthlyReport({
    super.key,
    required this.selectedMonth,
    required this.remark,
    required this.startDate,
  });
  String? selectedMonth;
  final String remark;
  DateTime? startDate;

  @override
  State<DemoMonthlyReport> createState() => _DemoMonthlyReportState();
}

class _DemoMonthlyReportState extends State<DemoMonthlyReport> {
  DateTime? selectedMonthDate;
  late List<Map<String, dynamic>> _dataPoints;
  late List<Map<String, dynamic>> _dataLimits;

  final GlobalKey _chartKey = GlobalKey();
  DateTime? startDate;
  DateTime? endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print("Startbvhdhgbvjdbv -> ${widget.startDate}");
    _convertMonthToDateTime();
    _setDateRange();
    _generateRandomDataPoints();
    _dataLimits = _generateRandomDataLimits(widget.startDate!);
  }

  void _setDateRange() {
    DateFormat dateFormat = DateFormat('MMMM yyyy');
    DateTime parsedDate = dateFormat.parse(widget.selectedMonth!);
    startDate = DateTime(parsedDate.year, parsedDate.month, 1);
    endDate = DateTime(parsedDate.year, parsedDate.month + 1, 0, 23, 59, 59);
  }

  void _convertMonthToDateTime() {
    try {
      DateFormat dateFormat = DateFormat('MMMM yyyy');
      selectedMonthDate = dateFormat.parse(widget.selectedMonth!);
    } catch (e) {
      print('Error parsing date: $e');
    }
  }

  void _generateRandomDataPoints() {
    final random = Random();

    _dataPoints = [];
    DateTime currentTimestamp = startDate!;

    while (currentTimestamp.isBefore(endDate!)) {
      // Generate random values for each parameter
      double purity = random.nextDouble() * 10 + 80;
      double flowRate = random.nextDouble() * 10 + 10;
      double pressure = random.nextDouble() * 20;
      double temperature = random.nextDouble() * 10 + 30;

      // Add a new data point
      _dataPoints.add({
        'timestamp': currentTimestamp,
        'purity': purity,
        'flowRate': flowRate,
        'pressure': pressure,
        'temperature': temperature,
      });

      // Move the timestamp forward by a random number of minutes
      currentTimestamp = currentTimestamp.add(Duration(
        days: random.nextInt(2), // Random number of days (0 or 1)
        hours: random.nextInt(24), // Random number of hours (0-23)
        minutes: random.nextInt(60), // Random number of minutes (0-59)
      ));

      // Ensure the timestamp does not exceed the end date
      if (currentTimestamp.isAfter(endDate!)) {
        break;
      }
    }

    // Sort the data points by timestamp to ensure they are in increasing order
    _dataPoints.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

    setState(() {
      // Trigger UI update after generating data points
    });
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
        selectedDate.day,
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
        title: Text('Monthly Report'),
        actions: [
          Text("Selected Month: ${widget.selectedMonth}"),
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
                  "No data found!     (${widget.selectedMonth})",
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
                          interval: (startDate!.month == 4 ||
                                  startDate!.month == 9 ||
                                  startDate!.month == 6 ||
                                  startDate!.month == 11)
                              ? 29 / 6
                              : 5,
                          dateFormat: DateFormat('dd MMM'),
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
            title: "Monthly",
          ).generateReportPdf(chartImage, widget.remark,
              weekStartDate: startDate, weekEndDate: endDate);
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
