import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Database/db/app_db.dart';
import '../widgets/generate_report.dart';

class DailyReport extends StatefulWidget {
  final String remark;
  DailyReport({super.key, required this.selectedDate, required this.remark});
  final DateTime? selectedDate;
  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  late List<Map<String, dynamic>> _dataPoints;
  late DateTime _selectedDate;
  final GlobalKey _chartKey = GlobalKey();
  final AppDb _database = AppDb();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate!;
    _getDailyData();
  }

  void _getDailyData() async {
    List<OxyDatabaseData> dbData = await _database.getDataByDate(_selectedDate);
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

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('dd-MM-yyyy').format(_selectedDate);
    final startOfDay = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
    final endOfDay = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59);
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Report'),
        actions: [
          Text("Selected Date: $date"),
          SizedBox(
            width: 15,
          ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.80,
                width: MediaQuery.of(context).size.width * 0.80,
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    intervalType: DateTimeIntervalType.hours,
                    interval: 3,
                    dateFormat: DateFormat.Hm(),
                    minimum: startOfDay,
                    maximum: endOfDay,
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
          await GenerateReport(data: _dataPoints, title: "Daily")
              .generateReportPdf(chartImage, widget.remark,
                  selectDate: _selectedDate);
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
