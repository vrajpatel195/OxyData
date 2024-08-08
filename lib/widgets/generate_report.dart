import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LimitSetting.dart/api_service.dart';
import '../LimitSetting.dart/min_max_data.dart';

class GenerateReport {
  final List<Map<String, dynamic>> data;
  final String title;
  final List<Map<String, dynamic>> dataLimit;
  final List<Map<String, dynamic>> datainitialLimit;
  final List<Map<String, dynamic>> dataAlarms;

  GenerateReport(
      {required this.data,
      required this.dataLimit,
      required this.title,
      required this.datainitialLimit,
      required this.dataAlarms});

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

  Future<void> generateReportPdf(
      BuildContext context, Uint8List chartImage, String remark,
      {DateTime? selectDate,
      DateTime? weekStartDate,
      DateTime? weekEndDate}) async {
    final _selectedDate = selectDate ?? DateTime.now();
    final _weekStartDate = weekStartDate ?? DateTime.now();
    final _weekEndDate = weekEndDate ?? DateTime.now();
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

    final headers = ['DateTime', 'Limit Max', 'Limit Min', 'Type'];
    final dataRows1 = datainitialLimit.map((data) {
      return [
        data['timestamp'].toString(), // DateTime
        data['limit_max'].toString(), // Limit Max
        data['limit_min'].toString(), // Limit Min
        data['type'].toString(), // Type
      ];
    }).toList();

    final dataRows2 = dataLimit.map((data) {
      return [
        data['timestamp'].toString(), // DateTime
        data['limit_max'].toString(), // Limit Max
        data['limit_min'].toString(), // Limit Min
        data['type'].toString(), // Type
      ];
    }).toList();

    final combinedDataRows = [...dataRows1, ...dataRows2];

    final alarmHeaders = [
      'DateTime',
      'Limit Max',
      'Limit Min',
      'Alarms',
      'Type'
    ];
    final dataAlarmsRow = dataAlarms.map((data) {
      return [
        data['timestamp'].toString(), // DateTime
        data['limitmax'].toString(), // Limit Max
        data['limitmin'].toString(), // Limit Min
        data['Alarms'].toString(),
        data['type'].toString(), // Type
      ];
    }).toList();
    // dataRows2.addAll(dataRows1);
    // final dataRows = dataRows2;
    // final dataRows = [
    //   dataRows1,
    //   dataRows2,
    // ];
    // Add chart image and statistics to a single page in PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Container(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text('OxyData ${title} Report', style: titleStyle),
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
                      ]),
                  pw.SizedBox(height: 8),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                            "OxyData unit Sr no : ${prefs.getString('serialNo') ?? 'null'}"),
                        if (title == "Daily")
                          pw.Text(
                              "Date: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}")
                      ]),
                  pw.SizedBox(height: 8),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                            "Report Generation Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}"),
                        if (title == "Weekly" || title == "Monthly")
                          pw.Text(
                              "Start Date: ${DateFormat('dd-MM-yyyy').format(_weekStartDate)}"),
                      ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        if (title == "Weekly" || title == "Monthly")
                          pw.Text(
                              "End Date: ${DateFormat('dd-MM-yyyy').format(_weekEndDate)}"),
                      ]),
                  pw.Divider(),
                  pw.SizedBox(height: 5),
                  if (title == "Daily")
                    pw.Text(
                        "Graph - Time (HH 00 to 24) Vs Oxygen Parameter Values"),
                  if (title == "Weekly")
                    pw.Text(
                        "Graph - Day (Sunday to Saturday) Vs Oxygen Parameter Values"),
                  if (title == "Monthly")
                    pw.Text(
                        "Graph - Date (01-MM to 30-MM) Vs Oxygen Parameter Values"),
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
                        [
                          'Gas Flow   (LPM)',
                          '$_minFlow',
                          '$_maxFlow',
                          '${_avgFlow.toStringAsFixed(2)}'
                        ],
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
                  pw.SizedBox(height: 10),
                  pw.Padding(
                    padding: pw.EdgeInsets.symmetric(horizontal: 20),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Limit Conditions:", // Replace with your table name
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(
                            height:
                                8), // Space between the table name and the table
                        pw.Table.fromTextArray(
                          headers: headers,
                          data: combinedDataRows,
                          headerStyle:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          cellAlignment: pw.Alignment.centerLeft,
                          tableWidth: pw.TableWidth.max,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Padding(
                    padding: pw.EdgeInsets.symmetric(horizontal: 20),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Alarm Condition:", // Replace with your table name
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(
                            height:
                                8), // Space between the table name and the table
                        pw.Table.fromTextArray(
                          headers: alarmHeaders,
                          data: dataAlarmsRow,
                          headerStyle:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          cellAlignment: pw.Alignment.centerLeft,
                          tableWidth: pw.TableWidth.max,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        footer: (pw.Context context) {
          if (context.pageNumber == context.pagesCount) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
                 mainAxisAlignment: pw.MainAxisAlignment.center,

              children: [
                pw.Divider(),
                pw.SizedBox(height: 5),
                pw.Text("Remark:", style: regularStyle),
                pw.Padding(
                  padding: pw.EdgeInsets.only(left: 20),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(remark, style: regularStyle),
                      pw.Text("Sign:                         "),
                    ],
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Report generated from OxyData by wavevisions.in',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return pw.Container(); // Empty footer on other pages
          }
        },
      ),
    );

    if (await Permission.manageExternalStorage.request().isGranted) {
      try {
        // Define the path to the Download directory
        final documentsDir =
            Directory('/storage/emulated/0/Download/OxyData/$title');
        if (!documentsDir.existsSync()) {
          documentsDir.createSync(recursive: true);
        }

        // Create a unique file name with a timestamp
        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final filePath = '${documentsDir.path}/Report$title _$timestamp.pdf';
        final file = File(filePath);

        // Save the PDF to the specified location
        final pdfBytes = await pdf.save();
        await file.writeAsBytes(pdfBytes);

        // Open the PDF file using OpenFile
        final result = await OpenFile.open(filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to $filePath')),
        );
        print("File Path: $filePath");
        print("Open File Result: ${result.message}");
      } catch (e) {
        print("Failed to save or open file: $e");
      }
    }
  }
}
