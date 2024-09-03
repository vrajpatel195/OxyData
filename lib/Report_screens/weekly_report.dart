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
  WeeklyReport(
      {super.key,
      required this.weekRange,
      required this.remark,
      required this.startDate,
      required this.endDate,
      required this.serialNo});
  String? weekRange;
  final String remark;
  DateTime startDate;
  DateTime endDate;
  String serialNo;
  @override
  State<WeeklyReport> createState() => _WeeklyReportState();
}

class _WeeklyReportState extends State<WeeklyReport> {
  late List<Map<String, dynamic>> _dataPoints;
  late List<Map<String, dynamic>> _dataPointsmove;
  late List<Map<String, dynamic>> _dataLimits;
  late List<Map<String, dynamic>> _datainitialLimit;
  late List<Map<String, dynamic>> _dataAlarms;

  final GlobalKey _chartKey = GlobalKey();
  DateTime? startDate;
  DateTime? endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    startDate = widget.startDate;
    endDate = widget.endDate;
    //  printLatestLimitSettings(startDate!);
    _getWeeklyData();
    _getWeeklyLimitData();
    _getWeeklyAlarmData();
  }

  void _getWeeklyData() async {
    final _db = await AppDbSingleton().database;
    List<OxyDatabaseData> dbData =
        await _db.getDataByDateRange(startDate!, endDate!, widget.serialNo);

    // Create a map with default 0 values for each day in the date range
    final Map<DateTime, Map<String, double>> fullWeekMap = {};

    for (DateTime day = startDate!;
        day.isBefore(endDate!) || day.isAtSameMomentAs(endDate!);
        day = day.add(Duration(minutes: 1))) {
      fullWeekMap[day] = {
        'purity': -1.0,
        'flowRate': -1.0,
        'pressure': -1.0,
        'temperature': -1.0,
      };
    }

    // Populate the map with actual data from the database
    for (var data in dbData) {
      DateTime normalizedDay = DateTime(
        data.recordedAt!.year,
        data.recordedAt!.month,
        data.recordedAt!.day,
      );

      if (fullWeekMap.containsKey(normalizedDay)) {
        fullWeekMap[normalizedDay] = {
          'purity': data.purity,
          'flowRate': data.flow,
          'pressure': data.pressure,
          'temperature': data.temp,
        };
      }
    }

    // Convert the map back to a list
    final List<Map<String, dynamic>> fullWeekData =
        fullWeekMap.entries.map((entry) {
      return {
        'timestamp': entry.key,
        'purity': entry.value['purity'],
        'flowRate': entry.value['flowRate'],
        'pressure': entry.value['pressure'],
        'temperature': entry.value['temperature'],
      };
    }).toList();

    setState(() {
      _dataPoints = fullWeekData;
    });

    setState(() {
      _dataPointsmove = dbData
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
        await _db.getLimitSettingsByWeek(startDate!, endDate!, widget.serialNo);
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

  void printLatestLimitSettings(DateTime selectDate) async {
    final _db = await AppDbSingleton().database;

    Map<String, LimitSettingsTableData?> results =
        await _db.getLatestLimitSettingsForAllTypesBeforeDate(
            selectDate, widget.serialNo);

    _datainitialLimit.clear();

    results.forEach((type, data) {
      if (data != null) {
        print('Type: $type');
        print('Max Limit: ${data.limit_max}');
        print('Min Limit: ${data.limit_min}');
        print('Serial No: ${data.serialNo}');
        print('Recorded At: ${data.recordedAt}');
        print('--------------------------');

        _datainitialLimit.add({
          'timestamp': data.recordedAt,
          'limit_max': data.limit_max,
          'limit_min': data.limit_min,
          'type': type,
        });
      } else {
        print('No data found for Type: $type on or before $selectDate');
        print('--------------------------');
      }
    });
  }

  void _getWeeklyAlarmData() async {
    final _db = await AppDbSingleton().database;
    List<AlarmTableData> dbData =
        await _db.getAlarmsByWeek(startDate!, endDate!, widget.serialNo);
    setState(() {
      _dataAlarms = dbData
          .map((data) => {
                'timestamp': data.recordedAt,
                'limitmax': data.limitmax,
                'limitmin': data.limitmin,
                'Alarms': data.value,
                'type': data.type,
              })
          .toList();
    });
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
        child: _dataPointsmove.isEmpty
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
              data: _dataPointsmove,
              dataLimit: _dataLimits,
              dataAlarms: _dataAlarms,
              title: "Weekly",
              datainitialLimit: []).generateReportPdf(
            context,
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
