// void generatePDF_Daily() async {
//     if (!mounted) return;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final logoBytes = await rootBundle.load('assets/Wavevison-Logo.png');
//     final logoImage = logoBytes.buffer.asUint8List();
//     String hospitalCompany = prefs.getString('hospitalCompany') ?? '';
//     final pdf = pw.Document();
//     String remark = _remarkController.text;
//     final titleStyle = pw.TextStyle(
//       fontSize: 16,
//       fontWeight: pw.FontWeight.bold,
//     );

//     final regularStyle = pw.TextStyle(
//       fontSize: 10,
//     );

//     final footerStyle = pw.TextStyle(
//       fontSize: 8,
//     );

//     final selectedGasesHeader = widget.selectedValues.join(', ');

//     String dynamicHeading;
//     if (selectedOption == 'Daily' && widget.seletedDate != null) {
//       dynamicHeading =
//           'Daily Report for ${DateFormat.yMMMd().format(widget.seletedDate!)}';
//     }

//     // Create a footer with page number and logo
//     pw.Widget footer(int currentPage, int totalPages) {
//       return pw.Column(
//         children: [
//           pw.Divider(),
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text('Page $currentPage of $totalPages', style: footerStyle),
//               pw.Container(
//                 width: 50,
//                 height: 50,
//                 child: pw.Image(pw.MemoryImage(logoImage)),
//               ),
//               pw.Text(
//                 'Report generated from PressData® by wavevisions.in',
//                 style: footerStyle,
//               ),
//             ],
//           ),
//         ],
//       );
//     }

//     // Header content
//     pw.Widget headerContent() {
//       return pw.Container(
//         padding: pw.EdgeInsets.all(8),
//         child: pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.center,
//               crossAxisAlignment: pw.CrossAxisAlignment.center,
//               children: [
//               pw.RichText(
//   text: pw.TextSpan(
//     text: 'Press',  // Text before "Data"
//     style: titleStyle,  // Your predefined title style
//     children: [
//       pw.TextSpan(
//         text: 'Data',  // Main text with the registered symbol
//         style: titleStyle,
//         children: [
//           pw.WidgetSpan(
//             child: pw.Transform(
//               transform: Matrix4.translationValues(2, 4, 0),  // Correctly position the symbol above "Data"
//               child: pw.Text(
//                 '®',
//                 style: titleStyle.copyWith(fontSize: 10),  // Adjust font size for the trademark symbol
//               ),
//             ),
//           ),
//         ],
//       ),
//       pw.TextSpan(
//         text: ' Report - $selectedGasesHeader',  // Continuation of the text after "Data"
//         style: titleStyle,
//       ),
//     ],
//   ),
// ),
//               ],
//             ),
//             pw.SizedBox(height: 4),
//             pw.Divider(),
//             pw.SizedBox(height: 8),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text('Hospital/Company: $hospitalCompany',
//                     style: regularStyle),
//                 pw.Text('Location: ${widget.locationname} ',
//                     style: regularStyle),
//               ],
//             ),
//             pw.SizedBox(height: 8),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.start,
//               children: [
//                 pw.Text('PressData unit Sr no: ${widget.serial}',
//                     style: regularStyle),
//               ],
//             ),
//             pw.SizedBox(height: 8),
//             pw.Divider(),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text(
//                     'Date: ${DateFormat('dd-MM-yyyy').format(widget.seletedDate!)}',
//                     style: regularStyle),
//                 pw.Text(
//                     'Report generation Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
//                     style: regularStyle),
//               ],
//             ),
//             pw.SizedBox(height: 8),
//             pw.Divider(),
//             pw.SizedBox(height: 8),
//           ],
//         ),
//       );
//     }

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.all(5),
//         footer: (pw.Context context) =>
//             footer(context.pageNumber, context.pagesCount),
//         header: (pw.Context context) => headerContent(), // Set the header
//         build: (pw.Context context) {
//           List<pw.Widget> content = [];

//           content.add(
//             pw.Center(
//               child: pw.Text(
//                 'Graph - Time (HH 00 to 24) Vs $selectedGasesHeader Gas Values',
//               ),
//             ),
//           );

//           content.add(
//             pw.Container(
//               height: 200,
//               child: pw.Image(pw.MemoryImage(pngBytes)),
//             ),
//           );

//           content.add(pw.SizedBox(height: 8));

//           content.add(
//             pw.Table.fromTextArray(
//               headers: [
//                 'Parameters',
//                 'Max',
//                 'Min',
//                 'Average',
//                 'Max Time',
//                 'Min Time'
//               ],
//               data: List.generate(widget.selectedValues.length, (index) {
//                 return [
//                   widget.selectedValues[index],
//                   maxPressure[index].toString(),
//                   minPressure[index].toString(),
//                   avgPressure[index].toString(),
//                   maxPressureTime[index].toIso8601String(),
//                   minPressureTime[index].toIso8601String(),
//                 ];
//               }),
//               cellStyle: regularStyle,
//               headerStyle: titleStyle,
//               border: pw.TableBorder.all(color: PdfColors.black),
//               headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
//               cellAlignment: pw.Alignment.centerLeft,
//             ),
//           );

//           content.add(pw.SizedBox(height: 22));

//           content.add(
//             pw.Text('Alarm conditions:', style: regularStyle),
//           );

//           if (logs.isEmpty) {
//             content.add(
//               pw.Row(children: [
//                 pw.SizedBox(width: 150),
//                 pw.Text('No alarm detected today.', style: regularStyle),
//               ]),
//             );
//           } else {
//             // Calculate row height and available space
//             final rowHeight = 14; // Adjust based on your row height
//             final pageHeight =
//                 PdfPageFormat.a4.height - 100; // Margin and footer space
//             final maxRowsPerPage = (pageHeight / rowHeight).floor();

//             int start = 0;
//             while (start < logs.length) {
//               int end = (start + maxRowsPerPage > logs.length)
//                   ? logs.length
//                   : start + maxRowsPerPage;

//               content.add(
//                 pw.Table.fromTextArray(
//                   headers: [
//                     'Parameters',
//                     'Max Value',
//                     'Min Value',
//                     'Log',
//                     'Time',
//                   ],
//                   data: List.generate(end - start, (index) {
//                     int i = start + index;
//                     return [
//                       parameters_log[i],
//                       maxvalue[i].toString(),
//                       minvalue[i].toString(),
//                       logs[i].toString(),
//                       Time[i].toIso8601String(),
//                     ];
//                   }),
//                   cellStyle: regularStyle,
//                   headerStyle: titleStyle,
//                   border: pw.TableBorder.all(color: PdfColors.black),
//                   headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
//                   cellAlignment: pw.Alignment.centerLeft,
//                 ),
//               );

//               start = end;

//               // Add a new page if more data is left
//               if (start < logs.length) {
//                 pdf.addPage(
//                   pw.Page(
//                     pageFormat: PdfPageFormat.a4,
//                     build: (pw.Context context) => pw.Center(
//                       child: pw.Text(
//                           'Page ${context.pageNumber} of ${context.pagesCount}'),
//                     ),
//                   ),
//                 );
//               }
//             }
//           }

//           content.add(pw.SizedBox(height: 22));
//           content.add(pw.Text('Remarks:', style: regularStyle));
//           content.add(pw.SizedBox(height: 8));
//           content.add(pw.Text('$remark', style: regularStyle));
//           content.add(pw.SizedBox(height: 8));
//           content.add(
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.SizedBox(width: 300),
//                 pw.Text('Sign:', style: regularStyle),
//                 pw.SizedBox(width: 150), // Adjust the width as necessary
//               ],
//             ),
//           );

//           return content;
//         },
//       ),
//     );

//     final documentsDirstore =
//         Directory('/storage/emulated/0/Download/PressData/Daily');
//     final documentsDir = await getExternalStorageDirectory();
//     if (!documentsDirstore.existsSync()) {
//       documentsDirstore.createSync(recursive: true);
//     }
//     String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
//     final pdfpath = '/ReportDaily${widget.serial}_$timestamp.pdf';
//     final filePath = '${documentsDir?.path}${pdfpath}';
//     final filepathStore = '${documentsDirstore.path}${pdfpath}';
//     final file = File(filePath);
//     final filestore = File(filepathStore);
//     final pdfBytes = await pdf.save();
//     await file.writeAsBytes(pdfBytes);
//     await filestore.writeAsBytes(pdfBytes);

//     OpenFile.open(filePath);

//     _clearSelectedData();
//  }