import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:open_file/open_file.dart';

import '../Database/db/app_db.dart';
import '../LimitSetting.dart/api_service.dart';
import '../LimitSetting.dart/min_max_data.dart';

class GraphReport extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  DateTime appStartTime;
  String remark;
  GraphReport(
      {Key? key,
      required this.data,
      required this.remark,
      required this.appStartTime})
      : super(key: key);

  @override
  GraphReportState createState() => GraphReportState();
}

class GraphReportState extends State<GraphReport> {
  late DateTime _minimumTime = DateTime.now();
  late DateTime _maximumTime = DateTime.now().add(Duration(minutes: 10));

  late double _minPurity = 0.0;
  late double _maxPurity = 0.0;
  late double _avgPurity = 0.0;
  late double _minFlow = 0.0;
  late double _maxFlow = 0.0;
  late double _avgFlow = 0.0;
  late double _minPressure = 0.0;
  late double _maxPressure = 0.0;
  late double _avgPressure = 0.0;
  late double _minTemperature = 0.0;
  late double _maxTemperature = 0.0;
  late double _avgTemperature = 0.0;
  bool _isLoading = false;
  String _currentDateTime = _formatDateTime(DateTime.now());
  late DateTime lastTimestamp;
  late DateTime firstTimestamp;

  List<Map<String, dynamic>> _dataAlarms = [];

  final GlobalKey _chartKey = GlobalKey();

  late final file;

  void initializeTimes() {
    if (widget.data.isNotEmpty) {
      firstTimestamp = DateTime.parse(widget.data.first['timestamp']);
      lastTimestamp = DateTime.parse(widget.data.last['timestamp']);
      _minimumTime = firstTimestamp;
      if (lastTimestamp.isBefore(firstTimestamp.add(Duration(minutes: 10)))) {
        _maximumTime = firstTimestamp.add(Duration(minutes: 10));
      } else {
        _maximumTime = lastTimestamp;
      }
    }
    _calculateMinMaxAvgValues();
  }

  @override
  void initState() {
    initializeTimes();
    _getCurrentAlarmData();
    super.initState();
  }

  void _getCurrentAlarmData() async {
    final _db = await AppDbSingleton().database;
    DateTime endOfTime = DateTime.now();
    List<AlarmTableData> dbData =
        await _db.getAlarmsByCurrent(widget.appStartTime, endOfTime);
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
    print("Data Alarms of current report: $_dataAlarms");
  }

  static String _formatDateTime(DateTime dateTime) {
    return DateFormat('d-M-yyyy, HH:mm').format(dateTime);
  }

  void _calculateMinMaxAvgValues() {
    _minPurity = widget.data
        .map((e) => e['purity'] as double)
        .reduce((min, val) => min < val ? min : val);
    _maxPurity = widget.data
        .map((e) => e['purity'] as double)
        .reduce((max, val) => max > val ? max : val);
    _avgPurity =
        widget.data.map((e) => e['purity'] as double).reduce((a, b) => a + b) /
            widget.data.length;

    _minFlow = widget.data
        .map((e) => e['flowRate'] as double)
        .reduce((min, val) => min < val ? min : val);
    _maxFlow = widget.data
        .map((e) => e['flowRate'] as double)
        .reduce((max, val) => max > val ? max : val);
    _avgFlow = widget.data
            .map((e) => e['flowRate'] as double)
            .reduce((a, b) => a + b) /
        widget.data.length;

    _minPressure = widget.data
        .map((e) => e['pressure'] as double)
        .reduce((min, val) => min < val ? min : val);
    _maxPressure = widget.data
        .map((e) => e['pressure'] as double)
        .reduce((max, val) => max > val ? max : val);
    _avgPressure = widget.data
            .map((e) => e['pressure'] as double)
            .reduce((a, b) => a + b) /
        widget.data.length;

    _minTemperature = widget.data
        .map((e) => e['temperature'] as double)
        .reduce((min, val) => min < val ? min : val);
    _maxTemperature = widget.data
        .map((e) => e['temperature'] as double)
        .reduce((max, val) => max > val ? max : val);
    _avgTemperature = widget.data
            .map((e) => e['temperature'] as double)
            .reduce((a, b) => a + b) /
        widget.data.length;

    print('Purity: Min = $_minPurity, Max = $_maxPurity, Avg = $_avgPurity');
    print('Flow: Min = $_minFlow, Max = $_maxFlow, Avg = $_avgFlow');
    print(
        'Pressure: Min = $_minPressure, Max = $_maxPressure, Avg = $_avgPressure');
    print(
        'Temperature: Min = $_minTemperature, Max = $_maxTemperature, Avg = $_avgTemperature');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Current Report OxyData'),
          actions: [
            _isLoading
                ? CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        _generatePdfAfterRender();
                      },
                      child: const Row(
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: screenHeight * 0.80,
                  width: screenWidth * 0.80,
                  child: SfCartesianChart(
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePinching: true, // Enables pinch-to-zoom
                      enablePanning: true, // Enables dragging to pan
                      zoomMode: ZoomMode
                          .x, // Enables zooming in both X and Y directions
                      enableDoubleTapZooming:
                          true, // Enables double-tap zooming
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
                    primaryXAxis: DateTimeAxis(
                      minimum: _minimumTime,
                      maximum: _maximumTime,
                      intervalType: DateTimeIntervalType.auto,
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      dateFormat: DateFormat('hh:mm'),
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
                        dataSource: widget.data,
                        xValueMapper: (Map<String, dynamic> data, _) =>
                            DateTime.parse(data['timestamp']),
                        yValueMapper: (Map<String, dynamic> data, _) =>
                            data['purity'],
                        name: 'Purity',
                        color: Colors.black,
                        yAxisName: 'primaryYAxis1',
                      ),
                      LineSeries<Map<String, dynamic>, DateTime>(
                        dataSource: widget.data,
                        xValueMapper: (Map<String, dynamic> data, _) =>
                            DateTime.parse(data['timestamp']),
                        yValueMapper: (Map<String, dynamic> data, _) =>
                            data['flowRate'],
                        name: 'Flow',
                        yAxisName: 'primaryYAxis2',
                        color: Colors.blue,
                      ),
                      LineSeries<Map<String, dynamic>, DateTime>(
                        dataSource: widget.data,
                        xValueMapper: (Map<String, dynamic> data, _) =>
                            DateTime.parse(data['timestamp']),
                        yValueMapper: (Map<String, dynamic> data, _) =>
                            data['pressure'],
                        name: 'Pressure',
                        yAxisName: 'secondaryYAxis1',
                        color: Colors.red,
                      ),
                      LineSeries<Map<String, dynamic>, DateTime>(
                        dataSource: widget.data,
                        xValueMapper: (Map<String, dynamic> data, _) =>
                            DateTime.parse(data['timestamp']),
                        yValueMapper: (Map<String, dynamic> data, _) =>
                            data['temperature'],
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
        ));
  }

  Future<void> _generatePdfAfterRender() async {
    setState(() {
      _isLoading = true;
    });
    try {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        final Uint8List chartImage = await _captureChart();
        try {
          MinMaxData data = await ApiService.fetchMinMaxData();
          await generateReportPdf(chartImage, data);
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

  Future<void> generateReportPdf(Uint8List chartImage, MinMaxData data) async {
    final pdf = pw.Document();
    int androidVersion = 0;
    int sdkVersion1 = 0;
    String versionRelease = "";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    sdkVersion1 = androidInfo.version.sdkInt;

    final titleStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
    );

    final regularStyle = const pw.TextStyle(
      fontSize: 12,
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String hospital_name = prefs.getString('hospital_name') ?? "null";

    // Capture the chart image
    final Uint8List chartImage = await _captureChart();

    final alarmHeaders = [
      'DateTime',
      'Limit Max',
      'Limit Min',
      'Alarms',
      'Type'
    ];
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    final dataAlarmsRow = _dataAlarms.map((data) {
      final timestamp = DateTime.parse(data['timestamp'].toString());
      return [
        formatter.format(timestamp), // DateTime
        data['limitmax'].toString(), // Limit Max
        data['limitmin'].toString(), // Limit Min
        data['Alarms'].toString(),
        data['type'].toString(), // Type
      ];
    }).toList();

    pw.TableRow createTableRow(String title, String min, String max) {
      return pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(title),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            child:
                pw.Text('${(double.tryParse(min)! / 10.0).toStringAsFixed(2)}'),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            child:
                pw.Text('${(double.tryParse(max)! / 10.0).toStringAsFixed(2)}'),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
          ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 10),
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text('OxyData CurrentReport', style: titleStyle),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Hospital name: $hospital_name"),
                    pw.Text(
                        "Location: ${prefs.getString('locationName') ?? 'null'}"),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("OxyData unit Sr no : ${data.serialNo}"),
                    pw.Text("Date: 13-12-23"),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Report Generation Date: ${_currentDateTime}"),
                    pw.Text(
                        "Start Time: ${DateFormat('HH:mm').format(firstTimestamp)}"),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                        "End Time: ${DateFormat('HH:mm').format(lastTimestamp)}"),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 5),
                pw.Text(
                    "Graph - Time (Min 00 to 24 ) Vs Oxygen Parameter Values"),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Image(pw.MemoryImage(chartImage), height: 200),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 20),
                  child: pw.Table.fromTextArray(
                    headers: [
                      'Current period overview',
                      'Minimum',
                      'Maximum',
                      'Average'
                    ],
                    data: [
                      [
                        'Oxygen Purity  (%)',
                        '$_minPurity',
                        '$_maxPurity',
                        '${_avgPurity.toStringAsFixed(2)}'
                      ],
                      [
                        'Gas Pressure   (PSI)',
                        '$_minPressure',
                        '$_maxPressure',
                        '${_avgPressure.toStringAsFixed(2)}'
                      ],
                      data.serialNo.startsWith("OD2") ||
                              data.serialNo.startsWith("OP1") ||
                              data.serialNo.startsWith("ODC") ||
                              data.serialNo.startsWith("OD5") ||
                              data.serialNo.startsWith("OD9")
                          ? [
                              'Gas Flow   (LPM)',
                              '$_minFlow',
                              '$_maxFlow',
                              '${_avgFlow.toStringAsFixed(2)}'
                            ]
                          : [],
                      [
                        'Gas Temperature  (°C)',
                        '$_minTemperature',
                        '$_maxTemperature',
                        '${_avgTemperature.toStringAsFixed(2)}'
                      ],
                    ],
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    cellAlignment: pw.Alignment.centerLeft,
                    tableWidth: pw.TableWidth.max,
                  ),
                ),

                pw.SizedBox(height: 15),
                // Add the first 8 rows of the Limit Conditions Table

                pw.Padding(
                    padding: pw.EdgeInsets.only(left: 20),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Limit Conditions:',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 10),
                          pw.Table(
                            tableWidth: pw.TableWidth.min,
                            columnWidths: {
                              0: pw.FixedColumnWidth(229),
                              1: pw.FixedColumnWidth(98),
                              2: pw.FixedColumnWidth(98),
                            },
                            border: pw.TableBorder(
                              left: pw.BorderSide(
                                  color: PdfColors.black, width: 1),
                              right: pw.BorderSide(
                                  color: PdfColors.black, width: 1),
                              horizontalInside: pw.BorderSide(
                                  color: PdfColors.black, width: 1),
                              top: pw.BorderSide(
                                  color: PdfColors.black, width: 1),
                              bottom: pw.BorderSide(
                                  color: PdfColors.black, width: 1),
                              verticalInside: pw.BorderSide(
                                  color: PdfColors.black, width: 1),
                            ),
                            children: [
                              // Headers
                              pw.TableRow(
                                children: [
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(5),
                                    child: pw.Text('Alarms Set levels:',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold)),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(
                                          left: pw.BorderSide(
                                              color: PdfColors.black,
                                              width: 1)),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(5),
                                    child: pw.Text('Minimum',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold)),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(
                                          left: pw.BorderSide(
                                              color: PdfColors.black,
                                              width: 1)),
                                    ),
                                  ),
                                  pw.Container(
                                    alignment: pw.Alignment.center,
                                    padding: pw.EdgeInsets.all(5),
                                    child: pw.Text('Maximum',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold)),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(
                                          left: pw.BorderSide(
                                              color: PdfColors.black,
                                              width: 1)),
                                    ),
                                  ),
                                ],
                              ),
                              // Data rows
                              createTableRow(
                                  'Oxygen Purity (%)', data.o2Min, data.o2Max),
                              createTableRow('Gas Pressure (PSI)',
                                  data.pressureMin, data.pressureMax),
                              if (data.serialNo.startsWith("OD2") ||
                                  data.serialNo.startsWith("OP1") ||
                                  data.serialNo.startsWith("ODC") ||
                                  data.serialNo.startsWith("OD5") ||
                                  data.serialNo.startsWith("OD9"))
                                createTableRow('Gas Flow (LPM)', data.flowMin,
                                    data.flowMax),
                              createTableRow('Gas Temperature (°C)',
                                  data.temperatureMin, data.temperatureMax),
                            ],
                          ),
                        ])),
                pw.SizedBox(height: 15),
                if (_dataAlarms.isEmpty)
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Alarm Condition:",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: pw.EdgeInsets.only(top: 5, bottom: 5),
                          child: pw.Text(
                            "No alarms",
                          ),
                        ),
                        pw.Divider(),
                        pw.SizedBox(height: 5),
                        pw.Text("Remark:", style: regularStyle),
                        pw.Padding(
                          padding: pw.EdgeInsets.only(left: 20),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(widget.remark, style: regularStyle),
                              pw.Text("Sign:                         "),
                            ],
                          ),
                        ),
                      ]),
              ],
            ),
          ];
          // Only show the table if the rows are 8 or less
        },
        footer: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Align(
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'Report generated from OxyData by wavevisions.in',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} | ${context.pagesCount}',
                    style: regularStyle,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Add Alarm Conditions Table
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 10),
        footer: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Align(
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'Report generated from OxyData by wavevisions.in',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} | ${context.pagesCount}',
                    style: regularStyle,
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          final rowsPerPage = 28; // Define how many rows per page
          final pageCount = (dataAlarmsRow.length / rowsPerPage).ceil();

          return List.generate(pageCount, (pageIndex) {
            final start = pageIndex * rowsPerPage;
            final end = (start + rowsPerPage < dataAlarmsRow.length)
                ? start + rowsPerPage
                : dataAlarmsRow.length;

            final pageRows = dataAlarmsRow.sublist(start, end);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (pageIndex == 0) ...[
                  pw.Text(
                    "Alarm Condition:",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(
                      height: 3), // Space between the title and the table
                ],
                pw.Table.fromTextArray(
                    headers: alarmHeaders,
                    data: pageRows,
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.SizedBox(height: 5),
                pw.Text("Remark:", style: regularStyle),
                pw.Padding(
                  padding: pw.EdgeInsets.only(left: 20),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(widget.remark, style: regularStyle),
                      pw.Text("Sign:                         "),
                    ],
                  ),
                ),
              ],
            );
          });
        },
      ),
    );

    if (sdkVersion1 <= 29) {
      if (await _requestStoragePermission()) {
        final directory =
            Directory('/storage/emulated/0/Download/OxyData/Current');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final filePath = '${directory.path}/Report_Current _$timestamp.pdf';
        final file = File(filePath);

        final pdfBytes =
            await pdf.save(); // Assuming you have the pdf data ready
        await file.writeAsBytes(pdfBytes);

        OpenFile.open(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to Downloads: $filePath')),
        );
      } else {
        final pdfBytes = await pdf.save();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Permission denied. Report generated but not saved.')),
        );
      }
    } else {
      try {
        final documentsDir =
            Directory('/storage/emulated/0/Download/OxyData/Current');
        final documentsDirectory = await getExternalStorageDirectory();

        if (!documentsDir.existsSync()) {
          documentsDir.createSync(recursive: true);
        }
        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final filePath = '${documentsDir.path}/Report_Current _$timestamp.pdf';
        final filepathopen =
            '${documentsDirectory?.path}/ReportCurrent _$timestamp.pdf';

        final file = File(filePath);
        final fileopen = File(filepathopen);

        final pdfBytes = await pdf.save();
        await file.writeAsBytes(pdfBytes);
        await fileopen.writeAsBytes(pdfBytes);

        final result = await OpenFile.open(filepathopen);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to $filepathopen')),
        );
        print("File Path: $filePath");
        print("Open File Result: ${result.message}");
      } catch (e) {
        print("Failed to save or open file: $e");
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }
}
