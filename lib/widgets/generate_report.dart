import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import '../LimitSetting.dart/api_service.dart';
import '../LimitSetting.dart/min_max_data.dart';

class GenerateReport {
  final List<Map<String, dynamic>> data;
  final String title;

  GenerateReport({
    required this.data,
    required this.title,
  });

  String _currentDateTime = _formatDateTime(DateTime.now());
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

  static String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy, HH:mm').format(dateTime);
  }

  void _calculateMinMaxAvgValues() {
    _minPurity = data
        .map((e) => e['purity'] as double)
        .reduce((min, val) => min < val ? min : val);
    _maxPurity = data
        .map((e) => e['purity'] as double)
        .reduce((max, val) => max > val ? max : val);
    _avgPurity =
        data.map((e) => e['purity'] as double).reduce((a, b) => a + b) /
            data.length;

    _minFlow = data
        .map((e) => e['flowRate'] as double)
        .reduce((min, val) => min < val ? min : val);
    _maxFlow = data
        .map((e) => e['flowRate'] as double)
        .reduce((max, val) => max > val ? max : val);
    _avgFlow =
        data.map((e) => e['flowRate'] as double).reduce((a, b) => a + b) /
            data.length;

    _minPressure = data
        .map((e) => e['pressure'] as double)
        .reduce((min, val) => min < val ? min : val);
    _maxPressure = data
        .map((e) => e['pressure'] as double)
        .reduce((max, val) => max > val ? max : val);
    _avgPressure =
        data.map((e) => e['pressure'] as double).reduce((a, b) => a + b) /
            data.length;

    _minTemperature = data
        .map((e) => e['temperature'] as double)
        .reduce((min, val) => min < val ? min : val);
    _maxTemperature = data
        .map((e) => e['temperature'] as double)
        .reduce((max, val) => max > val ? max : val);
    _avgTemperature =
        data.map((e) => e['temperature'] as double).reduce((a, b) => a + b) /
            data.length;
  }

  Future<void> generateReportPdf(Uint8List chartImage, String remark,
      {DateTime? selectDate}) async {
    MinMaxData data = await ApiService.fetchMinMaxData();
    final _selectedDate = selectDate ?? DateTime.now();
    final pdf = pw.Document();
    _calculateMinMaxAvgValues();

    final titleStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
    );

    final regularStyle = const pw.TextStyle(
      fontSize: 12,
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String hospital_name = prefs.getString('hospital_name') ?? "null";

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
            child: pw.Text('${double.tryParse(min)! / 10.0}'),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text('${double.tryParse(max)! / 10.0}'),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
          ),
        ],
      );
    }

    // Add chart image and statistics to a single page in PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Container(
            // margin: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            // padding: pw.EdgeInsets.all(2),
            // decoration: pw.BoxDecoration(
            //   border: pw.Border.all(color: PdfColors.black),
            //   borderRadius: pw.BorderRadius.circular(5),
            // ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  // crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('OxyData ${title} Report', style: titleStyle),
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
                      if (title == "Daily")
                        pw.Text(
                            "Date: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}")
                    ]),
                pw.SizedBox(height: 8),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Report Generation Date: ${_currentDateTime}"),
                      if (title == "Weekly") pw.Text("Start Date: "),
                    ]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                  if (title == "Weekly") pw.Text("End Date: "),
                ]),
                pw.Divider(),
                pw.SizedBox(height: 5),
                if (title == "Daily")
                  pw.Text(
                      "Graph - Time (HH 00 to 24 ) Vs Oxygen Parameter Values"),
                pw.SizedBox(height: 5),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text("_____ Purity 0-100%"),
                      pw.SizedBox(width: 10),
                      pw.Text("_____ Pressure 0-100 PSI",
                          style: pw.TextStyle(color: PdfColors.red)),
                      pw.SizedBox(width: 10),
                      pw.Text("_____ Flow 0-10 LPM",
                          style: pw.TextStyle(color: PdfColors.blue)),
                      pw.SizedBox(width: 10),
                      pw.Text("_____ Temperature 0-50 Deg",
                          style: pw.TextStyle(color: PdfColors.green)),
                    ]),
                pw.SizedBox(height: 5),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Image(
                        pw.MemoryImage(chartImage),
                        height: 200,
                      ),
                    ]),
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
                        '${_minPurity}',
                        '${_maxPurity}',
                        '${_avgPurity.toStringAsFixed(2)}'
                      ],
                      [
                        'Gas Pressure   (PSI)',
                        '${_minPressure}',
                        '${_maxPressure}',
                        '${_avgPressure.toStringAsFixed(2)}'
                      ],
                      [
                        'Gas Flow   (LPM)',
                        '${_minFlow}',
                        '${_maxFlow}',
                        '${_avgFlow.toStringAsFixed(2)}'
                      ],
                      [
                        'Gas Temperature  (°C)',
                        '${_minTemperature}',
                        '${_maxTemperature}',
                        '${_avgTemperature.toStringAsFixed(2)}'
                      ],
                    ],
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    cellAlignment: pw.Alignment.centerLeft,
                    tableWidth: pw.TableWidth.max,
                    cellHeight: 0.01,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Padding(
                  padding: pw.EdgeInsets.only(left: 20),
                  child: pw.Table(
                    tableWidth: pw.TableWidth.min,
                    columnWidths: {
                      0: pw.FixedColumnWidth(
                          229), // First column width relative to others
                      1: pw.FixedColumnWidth(
                          98), // Second column width relative to others
                      2: pw.FixedColumnWidth(
                          98) // Third column width relative to others
                    },
                    border: pw.TableBorder(
                      left: pw.BorderSide(color: PdfColors.black, width: 1),
                      right: pw.BorderSide(color: PdfColors.black, width: 1),
                      horizontalInside:
                          pw.BorderSide(color: PdfColors.black, width: 1),
                      top: pw.BorderSide(color: PdfColors.black, width: 1),
                      bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                      verticalInside:
                          pw.BorderSide(color: PdfColors.black, width: 1),
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
                                    color: PdfColors.black, width: 1),
                              ),
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
                                    color: PdfColors.black, width: 1),
                              ),
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
                                    color: PdfColors.black, width: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Data rows
                      createTableRow(
                          'Oxygen Purity (%)', data.o2Min, data.o2Max),
                      createTableRow('Gas Pressure (PSI)', data.pressureMin,
                          data.pressureMax),
                      createTableRow(
                          'Gas Flow (LPM)', data.flowMin, data.flowMax),
                      createTableRow('Gas Temperature (°C)',
                          data.temperatureMin, data.temperatureMax),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Text("Alarm Condition",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    "Alarm Condition",
                  ),
                ),
                pw.SizedBox(height: 28),
                pw.Divider(),
                pw.Text("Remark:", style: regularStyle),
                pw.Padding(
                  padding: pw.EdgeInsets.only(left: 20),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(remark, style: regularStyle),
                        pw.Text("Sign:                         ")
                      ]),
                ),
                pw.SizedBox(height: 18),
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
    OpenFile.open(file.path);

    // Show a dialog to inform user that PDF is generated
  }
}
