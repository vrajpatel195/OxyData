import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import '../Database/db/app_db.dart';
import '../widgets/generate_report.dart';

// ignore: must_be_immutable
class WeeklyReport extends StatefulWidget {
  WeeklyReport({super.key, required this.weekRange, required this.remark});
  String? weekRange;
  final String remark;
  @override
  State<WeeklyReport> createState() => _WeeklyReportState();
}

class _WeeklyReportState extends State<WeeklyReport> {
  late List<Map<String, dynamic>> _dataPoints;
  late List<Map<String, dynamic>> _dataLimits;

  final GlobalKey _chartKey = GlobalKey();
  DateTime? startDate;
  DateTime? endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _convertWeekRangeToDateTime();

    _getWeeklyData();
    _getWeeklyLimitData();
  }

  void _getWeeklyData() async {
    final _db = await AppDbSingleton().database;
    List<OxyDatabaseData> dbData =
        await _db.getDataByDateRange(startDate!, endDate!);
    setState(() {
      _dataPoints = dbData
          .map((data) => {
                'timestamp': data.recordedAt!,
                'purity': data.purity,
                'flowRate': data.flow,
                'pressure': data.pressure,
                'temperature': data.temp,
              })
          .toList();
    });
  }

  void _getWeeklyLimitData() async {
    final _db = await AppDbSingleton().database;
    List<LimitSettingsTableData> dbData =
        await _db.getLimitSettingsByWeek(startDate!, endDate!);
    setState(() {
      _dataLimits = dbData
          .map((data) => {
                'timestamp': data.recordedAt!,
                'limit_max': data.limit_max,
                'limit_min': data.limit_min,
                'type': data.type,
              })
          .toList();
    });
  }

  void _convertWeekRangeToDateTime() {
    List<String> dates = widget.weekRange!.split(' to ');
    if (dates.length == 2) {
      startDate = DateTime.parse(dates[0]);
      endDate = DateTime.parse(dates[1]);
    }
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
          await GenerateReport(
                  data: _dataPoints, dataLimit: _dataLimits, title: "Weekly")
              .generateReportPdf(chartImage, widget.remark,
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