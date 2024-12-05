import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class DemoGenerateReport {
  final List<Map<String, dynamic>> data;
  final String title;
  final List<Map<String, dynamic>> dataLimit;

  DemoGenerateReport({
    required this.data,
    required this.dataLimit,
    required this.title,
  });

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

    final dataRows = dataLimit.map((data) {
      return [
        data['timestamp'].toString(), // DateTime
        data['limit_max'].toStringAsFixed(1), // Limit Max
        data['limit_min'].toStringAsFixed(1), // Limit Min
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
            pw.Stack(children: [
              // Background watermark
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Transform.rotate(
                    angle: -0.5,
                    child: pw.Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: pw.Center(
                        child: pw.Text(
                          'Demo',
                          style: pw.TextStyle(
                            color: PdfColors.grey300,
                            fontSize: 150,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
                          pw.Text("____ Purity 0-100%"),
                          pw.SizedBox(width: 10),
                          pw.Text("____ Pressure 0-100 PSI",
                              style: pw.TextStyle(color: PdfColors.red)),
                          pw.SizedBox(width: 10),
                          pw.Text("____ Flow 0-10 LPM",
                              style: pw.TextStyle(color: PdfColors.blue)),
                          pw.SizedBox(width: 10),
                          pw.Text("____ Temperature 0-50 Deg",
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
                            '${_minPurity.toStringAsFixed(1)}',
                            '${_maxPurity.toStringAsFixed(1)}',
                            '${_avgPurity.toStringAsFixed(2)}'
                          ],
                          [
                            'Gas Pressure   (PSI)',
                            '${_minPressure.toStringAsFixed(1)}',
                            '${_maxPressure.toStringAsFixed(1)}',
                            '${_avgPressure.toStringAsFixed(2)}'
                          ],
                          [
                            'Gas Flow   (LPM)',
                            '${_minFlow.toStringAsFixed(1)}',
                            '${_maxFlow.toStringAsFixed(1)}',
                            '${_avgFlow.toStringAsFixed(2)}'
                          ],
                          [
                            'Gas Temperature  (°C)',
                            '${_minTemperature.toStringAsFixed(1)}',
                            '${_maxTemperature.toStringAsFixed(1)}',
                            '${_avgTemperature.toStringAsFixed(2)}'
                          ],
                        ],
                        headerStyle:
                            pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        cellAlignment: pw.Alignment.centerLeft,
                        tableWidth: pw.TableWidth.max,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 20),
                      child: pw.Table.fromTextArray(
                        headers: headers,
                        data: dataRows,
                        headerStyle:
                            pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        cellAlignment: pw.Alignment.centerLeft,
                        tableWidth: pw.TableWidth.max,
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
                      children: [
                        pw.Text(
                            'Report generated from OxyData by wavevisions.in',
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ];
        },
      ),
    );
    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/report.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }
}
