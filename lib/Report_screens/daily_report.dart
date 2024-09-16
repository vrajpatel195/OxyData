import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import '../Database/db/app_db.dart';

import '../widgets/generate_report.dart';

class DailyReport extends StatefulWidget {
  final String remark;
  final String serialNo;
  DailyReport(
      {super.key,
      required this.selectedDate,
      required this.remark,
      required this.serialNo});
  final DateTime? selectedDate;
  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  late List<Map<String, dynamic>> _dataPoints;
  late List<Map<String, dynamic>> _dataPointsmove;
  late List<Map<String, dynamic>> _dataLimits;
  List<Map<String, dynamic>> _datainitialLimit = [];
  List<Map<String, dynamic>> _dataAlarms = [];
  late DateTime _selectedDate;
  final GlobalKey _chartKey = GlobalKey();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getDailyData();
    _selectedDate = widget.selectedDate!;
    printLatestLimitSettings(_selectedDate);
    _getDailyLimitData();

    _getDailyAlarmData();
  }

  void _getDailyData() async {
    final _db = await AppDbSingleton().database;
    List<OxyDatabaseData> dbData =
        await _db.getDataByDate(_selectedDate, widget.serialNo);

    // Create a map with default 0 values for every minute of the day
    final Map<DateTime, Map<String, double>> fullDayMap = {};
    final startOfDay = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
    final endOfDay = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59);

    for (DateTime time = startOfDay;
        time.isBefore(endOfDay);
        time = time.add(const Duration(minutes: 1))) {
      fullDayMap[time] = {
        'purity': -1.0,
        'flowRate': -1.0,
        'pressure': -1.0,
        'temperature': -1.0,
      };
    }

    // Normalize the recordedAt time to the nearest minute (ignoring seconds and milliseconds)
    for (var data in dbData) {
      DateTime normalizedTime = DateTime(
          data.recordedAt!.year,
          data.recordedAt!.month,
          data.recordedAt!.day,
          data.recordedAt!.hour,
          data.recordedAt!.minute);

      if (fullDayMap.containsKey(normalizedTime)) {
        fullDayMap[normalizedTime] = {
          'purity': data.purity,
          'flowRate': data.flow,
          'pressure': data.pressure,
          'temperature': data.temp,
        };
      }
    }

    // Convert the map back to a list
    final List<Map<String, dynamic>> fullDayData =
        fullDayMap.entries.map((entry) {
      return {
        'timestamp': entry.key,
        'purity': entry.value['purity'],
        'flowRate': entry.value['flowRate'],
        'pressure': entry.value['pressure'],
        'temperature': entry.value['temperature'],
      };
    }).toList();

    setState(() {
      _dataPoints = fullDayData;
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

  void printLatestLimitSettings(DateTime selectDate) async {
    final _db = await AppDbSingleton().database;
    Map<String, LimitSettingsTableData?> results =
        await _db.getLatestLimitSettingsForAllTypesBeforeDate(
            selectDate, widget.serialNo);
    _datainitialLimit.clear(); // Clear the list to store fresh data

    results.forEach((type, data) {
      if (data != null) {
        print('Type: $type');
        print('Max Limit: ${data.limit_max}');
        print('Min Limit: ${data.limit_min}');
        print('Serial No: ${data.serialNo}');
        print('Recorded At: ${data.recordedAt}');
        print('--------------------------');

        // Store the data in _datainitialLimit
        _datainitialLimit.add({
          'timestamp': data.recordedAt,
          'limit_max': data.limit_max,
          'limit_min': data.limit_min,
          'type': type,
        });

        print(" data found for Type:  $_datainitialLimit");
      } else {
        print('No data found for Type: $type on or before $selectDate    ');
        print('--------------------------');
      }
    });
  }

  void _getDailyLimitData() async {
    final _db = await AppDbSingleton().database;
    List<LimitSettingsTableData> dbData =
        await _db.getLimitSettingsByDate(_selectedDate, widget.serialNo);
    setState(() {
      _dataLimits = dbData
          .map((data) => {
                'timestamp': data.recordedAt,
                'limit_max': data.limit_max,
                'limit_min': data.limit_min,
                'type': data.type,
              })
          .toList();
    });
  }

  void _getDailyAlarmData() async {
    final _db = await AppDbSingleton().database;
    List<AlarmTableData> dbData =
        await _db.getAlarmsByDate(_selectedDate, widget.serialNo);
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

  double _getLPMYAxisMaxValue(String serialNo) {
    if (serialNo.startsWith('OP1')) {
      return 100;
    } else if (serialNo.startsWith('OP2')) {
      return 250;
    } else if (serialNo.startsWith('OP5')) {
      return 500;
    } else if (serialNo.startsWith('OP9')) {
      return 1000;
    } else {
      return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('dd-MM-yyyy').format(_selectedDate);
    final startOfDay = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
    final endOfDay = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(141, 241, 241, 241),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text('Daily Report OxyData'),
        actions: [
          Text("Selected Date: $date"),
          const SizedBox(
            width: 15,
          ),
          if (_dataPoints.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: ElevatedButton(
                onPressed: () {
                  _generatePdfAfterRender();
                },
                child: _isLoading
                    ? CircularProgressIndicator()
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.picture_as_pdf, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Report',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Text color
                  shadowColor: Colors.blueAccent, // Shadow color
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
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
                  "No data found!     ($date)",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
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
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          majorGridLines: const MajorGridLines(
                            color: Colors.black,
                            width: 1,
                          ),
                          axisLine: const AxisLine(
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
                        axes: <ChartAxis>[
                          const NumericAxis(
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
                            maximum: _getLPMYAxisMaxValue(widget.serialNo),
                            labelStyle: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            majorGridLines: const MajorGridLines(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          const NumericAxis(
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
                          const NumericAxis(
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
                          const NumericAxis(
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
                        legend: const Legend(isVisible: true),
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
                  title: "Daily",
                  datainitialLimit: _datainitialLimit)
              .generateReportPdf(context, chartImage, widget.remark,
                  selectDate: _selectedDate);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report generated successfully!')),
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
