import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:open_file/open_file.dart';

import '../LimitSetting.dart/api_service.dart';
import '../LimitSetting.dart/min_max_data.dart';

class GraphReport extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  String remark;
  GraphReport({Key? key, required this.data, required this.remark})
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

  final GlobalKey _chartKey = GlobalKey();

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

    super.initState();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Chart Screen'),
        actions: [
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () {
                    _generatePdfAfterRender();
                  },
                  child: Text("Report"),
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
        child: SfCartesianChart(
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 100,
            interval: 20,
          ),
          primaryXAxis: DateTimeAxis(
            minimum: _minimumTime,
            maximum: _maximumTime,
            intervalType: DateTimeIntervalType.minutes,
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            dateFormat: DateFormat('hh:mm'),
          ),
          series: <LineSeries<Map<String, dynamic>, DateTime>>[
            LineSeries<Map<String, dynamic>, DateTime>(
              dataSource: widget.data,
              xValueMapper: (Map<String, dynamic> data, _) =>
                  DateTime.parse(data['timestamp']),
              yValueMapper: (Map<String, dynamic> data, _) => data['purity'],
              name: 'Purity',
            ),
            LineSeries<Map<String, dynamic>, DateTime>(
              dataSource: widget.data,
              xValueMapper: (Map<String, dynamic> data, _) =>
                  DateTime.parse(data['timestamp']),
              yValueMapper: (Map<String, dynamic> data, _) => data['flowRate'],
              name: 'Flow',
            ),
            LineSeries<Map<String, dynamic>, DateTime>(
              dataSource: widget.data,
              xValueMapper: (Map<String, dynamic> data, _) =>
                  DateTime.parse(data['timestamp']),
              yValueMapper: (Map<String, dynamic> data, _) => data['pressure'],
              name: 'Pressure',
            ),
            LineSeries<Map<String, dynamic>, DateTime>(
              dataSource: widget.data,
              xValueMapper: (Map<String, dynamic> data, _) =>
                  DateTime.parse(data['timestamp']),
              yValueMapper: (Map<String, dynamic> data, _) =>
                  data['temperature'],
              name: 'Temperature',
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
          MinMaxData data = await ApiService.fetchMinMaxData();
          await generateReportPdf(chartImage, data);
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to generate report: $error')),
          );
        }
      });
    } catch (e) {
      print("Error generating PDF after rendering: $e");
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

    // Add chart image and statistics to a single page in PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            margin: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            padding: pw.EdgeInsets.all(2),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  // crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('OxyData Current Report', style: titleStyle),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Hospital name: ${hospital_name}"),
                      pw.Text("Location: ${data.locationName}"),
                    ]),
                pw.SizedBox(height: 8),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("OxyData unit Sr no : ${data.serialNo}"),
                      pw.Text("Date: 13-12-23"),
                    ]),
                pw.SizedBox(height: 8),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Report Generation Date: ${_currentDateTime}"),
                      pw.Text(
                          "Start Time: ${DateFormat('HH:mm').format(firstTimestamp)}"),
                    ]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                  pw.Text(
                      "End Time: ${DateFormat('HH:mm').format(lastTimestamp)}"),
                ]),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Image(
                        pw.MemoryImage(chartImage),
                        height: 165,
                      ),
                    ]),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: [
                    'Current period overview',
                    'Minimum',
                    'Maximum',
                    'Average'
                  ],
                  data: [
                    [
                      'Oxygen Purity',
                      '${_minPurity} %',
                      '${_maxPurity}',
                      '${_avgPurity.toStringAsFixed(2)} %'
                    ],
                    [
                      'Gas Pressure',
                      '${_minPressure} PSI',
                      '${_maxPressure} PSI',
                      '${_avgPressure.toStringAsFixed(2)} PSI'
                    ],
                    [
                      'Gas Flow',
                      '${_minFlow} LPM',
                      '${_maxFlow} LPM',
                      '${_avgFlow.toStringAsFixed(2)} LPM'
                    ],
                    [
                      'Gas Temperature',
                      '${_minTemperature} °C',
                      '${_maxTemperature} °C',
                      '${_avgTemperature.toStringAsFixed(2)} °C'
                    ],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellHeight: 0.01,
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: [
                    'Alarms Set levels:',
                    'Minimum',
                    'Maximum',
                  ],
                  data: [
                    [
                      'Oxygen Purity',
                      '${data.o2Min} %',
                      '${data.o2Max} %',
                    ],
                    [
                      'Gas Pressure',
                      '${data.pressureMin} PSI',
                      '${data.pressureMax} PSI',
                    ],
                    [
                      'Gas Flow',
                      '${data.flowMin} LPM',
                      '${data.flowMax} LPM',
                    ],
                    [
                      'Gas Temperature',
                      '${data.temperatureMin} °C',
                      '${data.temperatureMax} °C',
                    ],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellHeight: 0.01,
                ),
                pw.SizedBox(height: 10),
                pw.Text("Alarm Condition",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    "Alarm Condition",
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Text("Remark:", style: regularStyle),
                pw.Padding(
                  padding: pw.EdgeInsets.only(left: 20),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("${widget.remark}", style: regularStyle),
                        pw.Text("Sign:                         ")
                      ]),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  // crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Report generated from OxyData by wavevisions.in',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/report.pdf");
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved at ${file.path}')),
    );

    OpenFile.open(file.path);
    setState(() {
      _isLoading = false;
    });
    // Show a dialog to inform user that PDF is generated
  }
}