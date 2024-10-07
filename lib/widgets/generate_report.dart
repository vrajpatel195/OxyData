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
import 'package:device_info_plus/device_info_plus.dart';

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

  // Future<void> generateReportPdf(
  //     BuildContext context, Uint8List chartImage, String remark,
  //     {DateTime? selectDate,
  //     DateTime? weekStartDate,
  //     DateTime? weekEndDate}) async {
  //   final _selectedDate = selectDate ?? DateTime.now();
  //   final _weekStartDate = weekStartDate ?? DateTime.now();
  //   final _weekEndDate = weekEndDate ?? DateTime.now();
  //   final pdf = pw.Document();
  //   _calculateMinMaxAvgValues();

  //   final titleStyle = pw.TextStyle(
  //     fontSize: 16,
  //     fontWeight: pw.FontWeight.bold,
  //   );

  //   final regularStyle = const pw.TextStyle(
  //     fontSize: 12,
  //   );

  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String hospital_name = prefs.getString('hospital_name') ?? "null";

  //   final headers = ['DateTime', 'Limit Max', 'Limit Min', 'Type'];
  //   final dataRows1 = datainitialLimit.map((data) {
  //     return [
  //       data['timestamp'].toString(), // DateTime
  //       data['limit_max'].toString(), // Limit Max
  //       data['limit_min'].toString(), // Limit Min
  //       data['type'].toString(), // Type
  //     ];
  //   }).toList();

  //   final dataRows2 = dataLimit.map((data) {
  //     return [
  //       data['timestamp'].toString(), // DateTime
  //       data['limit_max'].toString(), // Limit Max
  //       data['limit_min'].toString(), // Limit Min
  //       data['type'].toString(), // Type
  //     ];
  //   }).toList();

  //   final combinedDataRows = [...dataRows1, ...dataRows2];

  //   final alarmHeaders = [
  //     'DateTime',
  //     'Limit Max',
  //     'Limit Min',
  //     'Alarms',
  //     'Type'
  //   ];
  //   final dataAlarmsRow = dataAlarms.map((data) {
  //     return [
  //       data['timestamp'].toString(), // DateTime
  //       data['limitmax'].toString(), // Limit Max
  //       data['limitmin'].toString(), // Limit Min
  //       data['Alarms'].toString(),
  //       data['type'].toString(), // Type
  //     ];
  //   }).toList();

  //   pdf.addPage(
  //     pw.MultiPage(
  //       pageFormat: PdfPageFormat.a4,
  //       margin: pw.EdgeInsets.all(20),
  //       build: (pw.Context context) {
  //         return [
  //           pw.Container(
  //             child: pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.stretch,
  //               children: [
  //                 pw.Row(
  //                   mainAxisAlignment: pw.MainAxisAlignment.center,
  //                   children: [
  //                     pw.Text('OxyData ${title} Report', style: titleStyle),
  //                   ],
  //                 ),
  //                 pw.Divider(),
  //                 pw.SizedBox(height: 8),
  //                 pw.Row(
  //                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       pw.Text("Hospital name: $hospital_name"),
  //                       pw.Text(
  //                           "Location: ${prefs.getString('locationName') ?? 'null'}"),
  //                     ]),
  //                 pw.SizedBox(height: 8),
  //                 pw.Row(
  //                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       pw.Text(
  //                           "OxyData unit Sr no : ${prefs.getString('serialNo') ?? 'null'}"),
  //                       if (title == "Daily")
  //                         pw.Text(
  //                             "Date: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}")
  //                     ]),
  //                 pw.SizedBox(height: 8),
  //                 pw.Row(
  //                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       pw.Text(
  //                           "Report Generation Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}"),
  //                       if (title == "Weekly" || title == "Monthly")
  //                         pw.Text(
  //                             "Start Date: ${DateFormat('dd-MM-yyyy').format(_weekStartDate)}"),
  //                     ]),
  //                 pw.Row(
  //                     mainAxisAlignment: pw.MainAxisAlignment.end,
  //                     children: [
  //                       if (title == "Weekly" || title == "Monthly")
  //                         pw.Text(
  //                             "End Date: ${DateFormat('dd-MM-yyyy').format(_weekEndDate)}"),
  //                     ]),
  //                 pw.Divider(),
  //                 pw.SizedBox(height: 5),
  //                 if (title == "Daily")
  //                   pw.Text(
  //                       "Graph - Time (HH 00 to 24) Vs Oxygen Parameter Values"),
  //                 if (title == "Weekly")
  //                   pw.Text(
  //                       "Graph - Day (Sunday to Saturday) Vs Oxygen Parameter Values"),
  //                 if (title == "Monthly")
  //                   pw.Text(
  //                       "Graph - Date (01-MM to 30-MM) Vs Oxygen Parameter Values"),
  //                 pw.SizedBox(height: 5),
  //                 pw.Row(
  //                     mainAxisAlignment: pw.MainAxisAlignment.center,
  //                     children: [
  //                       pw.Text("_____ Purity 0-100%"),
  //                       pw.SizedBox(width: 10),
  //                       pw.Text("_____ Pressure 0-100 PSI",
  //                           style: pw.TextStyle(color: PdfColors.red)),
  //                       pw.SizedBox(width: 10),
  //                       pw.Text("_____ Flow 0-10 LPM",
  //                           style: pw.TextStyle(color: PdfColors.blue)),
  //                       pw.SizedBox(width: 10),
  //                       pw.Text("_____ Temperature 0-50 Deg",
  //                           style: pw.TextStyle(color: PdfColors.green)),
  //                     ]),
  //                 pw.SizedBox(height: 5),
  //                 pw.Row(
  //                     mainAxisAlignment: pw.MainAxisAlignment.center,
  //                     children: [
  //                       pw.Image(
  //                         pw.MemoryImage(chartImage),
  //                         height: 200,
  //                       ),
  //                     ]),
  //                 pw.SizedBox(height: 10),
  //                 pw.Padding(
  //                   padding: pw.EdgeInsets.symmetric(horizontal: 20),
  //                   child: pw.Table.fromTextArray(
  //                     headers: [
  //                       'Current period overview',
  //                       'Minimum',
  //                       'Maximum',
  //                       'Average'
  //                     ],
  //                     data: [
  //                       [
  //                         'Oxygen Purity  (%)',
  //                         '$_minPurity',
  //                         '$_maxPurity',
  //                         '${_avgPurity.toStringAsFixed(2)}'
  //                       ],
  //                       [
  //                         'Gas Pressure   (PSI)',
  //                         '$_minPressure',
  //                         '$_maxPressure',
  //                         '${_avgPressure.toStringAsFixed(2)}'
  //                       ],
  //                       [
  //                         'Gas Flow   (LPM)',
  //                         '$_minFlow',
  //                         '$_maxFlow',
  //                         '${_avgFlow.toStringAsFixed(2)}'
  //                       ],
  //                       [
  //                         'Gas Temperature  (°C)',
  //                         '$_minTemperature',
  //                         '$_maxTemperature',
  //                         '${_avgTemperature.toStringAsFixed(2)}'
  //                       ],
  //                     ],
  //                     headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //                     cellAlignment: pw.Alignment.centerLeft,
  //                     tableWidth: pw.TableWidth.max,
  //                   ),
  //                 ),
  //                 pw.Padding(
  //                   padding: pw.EdgeInsets.symmetric(horizontal: 20),
  //                   child: pw.Column(
  //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                     children: [
  //                       pw.Text(
  //                         "Limit Conditions:", // Replace with your table name
  //                         style: pw.TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: pw.FontWeight.bold,
  //                         ),
  //                       ),
  //                       pw.SizedBox(
  //                           height:
  //                               8), // Space between the table name and the table

  //                       pw.Table.fromTextArray(
  //                         headers: headers,
  //                         data: combinedDataRows,
  //                         headerStyle:
  //                             pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //                         cellAlignment: pw.Alignment.centerLeft,
  //                         tableWidth: pw.TableWidth.max,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 pw.Padding(
  //                   padding: pw.EdgeInsets.symmetric(horizontal: 20),
  //                   child: pw.Column(
  //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                     children: [
  //                       pw.Text(
  //                         "Alarm Condition:", // Replace with your table name
  //                         style: pw.TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: pw.FontWeight.bold,
  //                         ),
  //                       ),
  //                       pw.SizedBox(
  //                           height:
  //                               8), // Space between the table name and the table
  //                       pw.Table.fromTextArray(
  //                         headers: alarmHeaders,
  //                         data: dataAlarmsRow,
  //                         headerStyle:
  //                             pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //                         cellAlignment: pw.Alignment.centerLeft,
  //                         tableWidth: pw.TableWidth.max,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ];
  //       },
  //       footer: (pw.Context context) {
  //         if (context.pageNumber == context.pagesCount) {
  //           return pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.center,
  //             mainAxisAlignment: pw.MainAxisAlignment.center,
  //             children: [
  //               pw.Divider(),
  //               pw.SizedBox(height: 5),
  //               pw.Text("Remark:", style: regularStyle),
  //               pw.Padding(
  //                 padding: pw.EdgeInsets.only(left: 20),
  //                 child: pw.Row(
  //                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     pw.Text(remark, style: regularStyle),
  //                     pw.Text("Sign:                         "),
  //                   ],
  //                 ),
  //               ),
  //               pw.SizedBox(height: 18),
  //               pw.Divider(),
  //               pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.center,
  //                 children: [
  //                   pw.Text(
  //                     'Report generated from OxyData by wavevisions.in',
  //                     style: pw.TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: pw.FontWeight.bold,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           );
  //         } else {
  //           return pw.Container(); // Empty footer on other pages
  //         }
  //       },
  //     ),
  //   );

  //   if (await Permission.manageExternalStorage.request().isGranted) {
  //     try {
  //       // Define the path to the Download directory
  //       final documentsDir =
  //           Directory('/storage/emulated/0/Download/OxyData/$title');
  //       if (!documentsDir.existsSync()) {
  //         documentsDir.createSync(recursive: true);
  //       }

  //       // Create a unique file name with a timestamp
  //       String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  //       final filePath = '${documentsDir.path}/Report$title _$timestamp.pdf';
  //       final file = File(filePath);

  //       // Save the PDF to the specified location
  //       final pdfBytes = await pdf.save();
  //       await file.writeAsBytes(pdfBytes);

  //       // Open the PDF file using OpenFile
  //       final result = await OpenFile.open(filePath)
  //       print("Failed to save or open file: $e");
  //     }
  //   }
  // }

  Future<void> generateReportPdf(
    BuildContext context,
    Uint8List chartImage,
    String remark, {
    DateTime? selectDate,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
  }) async {
    final _selectedDate = selectDate ?? DateTime.now();
    final _weekStartDate = weekStartDate ?? DateTime.now();
    final _weekEndDate = weekEndDate ?? DateTime.now();
    final pdf = pw.Document();
    int androidVersion = 0;
    int sdkVersion1 = 0;
    String versionRelease = "";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    sdkVersion1 = androidInfo.version.sdkInt;
    versionRelease = androidInfo.version.release;

    print('Android SDK: $sdkVersion1');
    print('Android Version: $versionRelease');

    _calculateMinMaxAvgValues(); // Ensure this function is defined and works correctly

    final titleStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
    );

    final regularStyle = const pw.TextStyle(
      fontSize: 12,
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String hospitalName = prefs.getString('hospital_name') ?? "null";
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');

    final headers = ['DateTime', 'Limit Max', 'Limit Min', 'Type'];
    final dataRows1 = datainitialLimit.map((data) {
      final timestamp = DateTime.parse(data['timestamp'].toString());
      return [
        formatter.format(timestamp),
        data['limit_max'].toString(),
        data['limit_min'].toString(),
        data['type'].toString(),
      ];
    }).toList();

    final dataRows2 = dataLimit.map((data) {
      final timestamp = DateTime.parse(data['timestamp'].toString());
      return [
        formatter.format(timestamp),
        data['limit_max'].toString(),
        data['limit_min'].toString(),
        data['type'].toString(),
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
      final timestamp = DateTime.parse(data['timestamp'].toString());
      return [
        formatter.format(timestamp),
        data['limitmax'].toString(),
        data['limitmin'].toString(),
        data['Alarms'].toString(),
        data['type'].toString(),
      ];
    }).toList();

    pw.Widget footer(int pageNumber, int pagesCount) {
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
                'Page ${pageNumber} | ${pagesCount}',
                style: regularStyle,
              ),
            ],
          ),
        ],
      );
    }

    pw.Widget header() {
      return pw
          .Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
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
            pw.Text("Hospital name: $hospitalName"),
            pw.Text("Location: ${prefs.getString('locationName') ?? 'null'}"),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
                "OxyData unit Sr no : ${prefs.getString('serialNo') ?? 'null'}"),
            if (title == "Daily")
              pw.Text(
                  "Date: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}"),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
                "Report Generation Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}"),
            if (title == "Weekly" || title == "Monthly")
              pw.Text(
                  "Start Date: ${DateFormat('dd-MM-yyyy').format(_weekStartDate)}"),
          ],
        ),
        if (title == "Weekly" || title == "Monthly")
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                  "End Date: ${DateFormat('dd-MM-yyyy').format(_weekEndDate)}"),
            ],
          ),
        pw.Divider(),
        pw.SizedBox(height: 5),
      ]);
    }

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
      footer: (pw.Context context) =>
          footer(context.pageNumber, context.pagesCount),
      header: (pw.Context context) => header(),
      build: (pw.Context context) {
        List<pw.Widget> content = [];

        // Header Section
        content.add(
          pw.Container(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
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
                    pw.Image(pw.MemoryImage(chartImage), height: 200),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 0),
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
              ],
            ),
          ),
        );

        content.add(pw.SizedBox(height: 15));
        content.add(pw.Text('Limit conditions:', style: titleStyle));

        // Split Table Rows
        _addPaginatedTable(content, headers, combinedDataRows);
        content.add(pw.SizedBox(height: 15));
        content.add(pw.Text('Alarm conditions:', style: titleStyle));
        _addPaginatedTable(content, alarmHeaders, dataAlarmsRow);

        content.add(pw.SizedBox(height: 22));
        content.add(pw.Divider());
        content.add(pw.Text('Remarks:', style: regularStyle));
        content.add(pw.SizedBox(height: 8));
        content.add(pw.Text('$remark', style: regularStyle));
        content.add(pw.SizedBox(height: 8));
        content.add(
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.SizedBox(width: 300),
              pw.Text('Sign:', style: regularStyle),
              pw.SizedBox(width: 150), // Adjust the width as necessary
            ],
          ),
        );

        return content;
      },
    ));
    if (sdkVersion1 <= 29) {
      if (await _requestStoragePermission()) {
        final directory =
            Directory('/storage/emulated/0/Download/OxyData/$title');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final filePath = '${directory.path}/Report$title _$timestamp.pdf';
        final file = File(filePath);

        final pdfBytes =
            await pdf.save(); // Assuming you have the pdf data ready
        await file.writeAsBytes(pdfBytes);

        OpenFile.open(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to Downloads: $filePath')),
        );
      } else {
        // Permission denied - generate report but not save it
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
            Directory('/storage/emulated/0/Download/OxyData/$title');
        final documentsDirectory = await getExternalStorageDirectory();

        if (!documentsDir.existsSync()) {
          documentsDir.createSync(recursive: true);
        }

        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final filePath = '${documentsDir.path}/Report$title _$timestamp.pdf';
        final filepathopen =
            '${documentsDirectory?.path}/Report$title _$timestamp.pdf';

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

  void _addPaginatedTable(List<pw.Widget> content, List<String> headers,
      List<List<String>> dataRows) {
    const int rowsPerPage = 25; // Adjust as necessary
    for (int i = 0; i < dataRows.length; i += rowsPerPage) {
      int endIndex = (i + rowsPerPage < dataRows.length)
          ? i + rowsPerPage
          : dataRows.length;
      content.add(
        pw.Table.fromTextArray(
          headers: headers,
          data: dataRows.sublist(i, endIndex),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          tableWidth: pw.TableWidth.max,
        ),
      );

      if (endIndex < dataRows.length) {
        content.add(pw.NewPage());
      }
    }
  }
}
