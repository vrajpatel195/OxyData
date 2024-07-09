// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:http/http.dart' as http;

// import 'package:syncfusion_flutter_charts/charts.dart';
// //import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:intl/intl.dart';

// import '../LimitSetting(Demo)/Temp_demo.dart';
// import '../LimitSetting(Demo)/flow_demo.dart';
// import '../LimitSetting(Demo)/pressure_demo.dart';
// import '../LimitSetting(Demo)/purity_demo.dart';


// class LineCharWid extends StatefulWidget {
//   const LineCharWid({Key? key}) : super(key: key);

//   @override
//   State<LineCharWid> createState() => _LineCharWidState();

//   captureChartImage() {}
// }

// class ParameterData {
//   final String name;
//   final Color color;
//   int value;

//   ParameterData(this.name, this.color, this.value);
// }

// class ChartData {
//   ChartData(this.x, this.y, this.type);

//   final double x;
//   final double y;
//   final String type;
// }

// class _LineCharWidState extends State<LineCharWid> {
//   // List<OxyData> oxydata = [];
//   // StreamController<OxyData> _streamData = StreamController();
//   // StreamController<OxyData> _streamDatatemp = StreamController();
//   // StreamController<OxyData> _streamDatapurity = StreamController();
//   // StreamController<OxyData> _streamDataflow = StreamController();
//   // StreamController<OxyData> _streamDatapressure = StreamController();

//   int? Purity_maxLimit;
//   int? Purity_minLimit;
//   int? Flow_maxLimit;
//   int? Flow_minLimit;
//   int? Pressure_maxLimit;
//   int? Pressure_minLimit;
//   int? Temp_maxLimit;
//   int? Temp_minLimit;


//   List<LineSeries<ChartData, DateTime>> _getLineSeries() {
//     Map<String, List<ChartData>> groupedData = {};

//     // Find the maximum y value to normalize the data
//     double maxY =
//         chartData.map((data) => data.y).reduce((a, b) => a > b ? a : b);

//     for (var data in chartData) {
//       if (!groupedData.containsKey(data.type)) {
//         groupedData[data.type] = [];
//       }
//       groupedData[data.type]!.add(data);
//     }

//     return seriesOrder
//         .map((type) {
//           final data = groupedData[type];
//           if (data != null) {
//             final color = colorMap[type] ?? Colors.black;
//             return LineSeries<ChartData, DateTime>(
//               name: type,
//               color: color,
//               dataSource: data,
//               xValueMapper: (ChartData data, _) =>
//                   DateTime.fromMillisecondsSinceEpoch(data.x.toInt()),
//               yValueMapper: (ChartData data, _) =>
//                   (data.y / maxY) * 100, // Convert to percentage
//             );
//           }
//           return null;
//         })
//         .where((series) => series != null)
//         .cast<LineSeries<ChartData, DateTime>>()
//         .toList();
//   }

//   List<ChartData> chartData = [];
//   final StreamController<List<ChartData>> _streamController =
//       StreamController<List<ChartData>>.broadcast();

//   // Fixed color map for predefined types
//   final Map<String, Color> colorMap = {
//     'purity': const Color.fromARGB(255, 0, 34, 145),
//     'flow': Color.fromARGB(182, 241, 193, 48),
//     'pressure': Colors.red,
//     'temp': const Color.fromARGB(255, 44, 238, 144),
   
//   };

//   // Fixed order of types for series
//   final List<String> seriesOrder = [
//     'purity',
//     'flow',
//     'pressure',
//     'temp',
//   ];

  
//   void _updateData(List<dynamic> data) {
//     double x = DateTime.now().millisecondsSinceEpoch.toDouble();
//     print('Received Data: $data');
//     List<ChartData> newData = [];
//     for (var entry in data) {
//       newData.add(ChartData(x, entry['value'].toDouble(), entry['type']));
//     }

//     print('New Data: $newData');

//     // Combine new data with existing data and keep only the most recent 60 data points
//     setState(() {
//       chartData.addAll(newData);
//       if (chartData.length > 60) {
//         chartData = chartData.sublist(chartData.length - 60);
//       }

//       // Add the updated data to the stream
//       _streamController.add(List.from(chartData));
//     });
//   }
// void _navigateToDetailPage(int index) {
//     if (index == 0) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PurityDemo()),
//       );
//     } else if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => FlowDemo()),
//       );
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PressureDemo()),
//       );
//     } else if (index == 3) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => TempDemo()),
//       );
//     }
//   }

//   late StreamController<void> _updateController;
//   late StreamSubscription<void> _streamSubscription;

//   @override
//   void initState() {
//     super.initState();

//     Timer.periodic(const Duration(seconds: 1), (timer) {
//       _updateController.add(null);
//     });
//     Timer.periodic(Duration(seconds: 1), (timer) {
//       getdata();
//     });
//   }

//   @override
//   void dispose() {
//     _updateController.close(); // Close the stream controller
//     _streamSubscription.cancel(); // Cancel the subscription
//     // _streamDatatemp.close();
//     // _streamDatapurity.close();
//     // _streamDataflow.close();
//     // _streamDatapressure.close();
  
//     // _streamData.close();

//     super.dispose();
//   }

//   Map<int, String> specialValues = {
//     -333: 'Gas Not found',
//     -11: 'Not Connected',
//     -1111: 'Out of Range (Positive)',
//     -1112: 'Out of Range (Negative)',
//   };

//   Map<int, Color> specialValueColors = {
//     -333: Colors.red,
//     -11: Colors.red,
//     -1111: Colors.red,
//     -1112: Colors.red,
//   };
//   @override
//   Widget build(BuildContext context) {
//     bool isDataAvailable = chartData.isNotEmpty;
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
//     final List<Color> parameterColors = [
//        const Color.fromARGB(255, 0, 34, 145),
//     Color.fromARGB(255, 248, 213, 40),
//     const Color.fromARGB(255, 195, 0, 0),
//     const Color.fromARGB(255, 44, 238, 144)
//     ];
//     final List<Color> parameterTextColor = [
//      const Color.fromARGB(255, 255, 255, 255),
//     const Color.fromARGB(255, 255, 255, 255),
//     const Color.fromARGB(255, 255, 255, 255),
//     const Color.fromARGB(255, 0, 0, 0),
//     ];
//     List parameterUnit = [
//  "%",
//     "LPM",
//     "PSI",
//     "°C",
//     ];
//     List parameterNames = [
//     "Purity",
//     "Flow",
//     "Pressure", 
//     "Temp",
//     ];

//     return Scaffold(
//       body: Column(
//         children: [
//           Row(
//             children: [
//               // Graph on the left
//               Expanded(
//                 child: Container(
//                   height: 350, // Adjust height here
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: isDataAvailable
//                         ? SfCartesianChart(
//                             primaryXAxis: DateTimeAxis(
//                               intervalType: DateTimeIntervalType.seconds,
//                               interval: 1, // 1-second interval
//                               dateFormat: DateFormat('mm:ss'),
//                               minimum: chartData.isNotEmpty
//                                   ? DateTime.fromMillisecondsSinceEpoch(
//                                       chartData.first.x.toInt())
//                                   : DateTime.now()
//                                       .subtract(Duration(seconds: 60)),
//                               maximum: DateTime.now(),
//                             ),
//                             primaryYAxis: NumericAxis(
//                               interval: 20,
//                               minimum:
//                                   0, // Set the minimum value of y-axis to 0
//                               maximum:
//                                   100, // Set the maximum value of y-axis to 100
//                             ),
//                             legend: Legend(isVisible: true),
//                             series: _getLineSeries(),
//                           )
//                         : Center(
//                             child: CircularProgressIndicator(),
//                           ),
//                   ),
//                 ),
//               ),
//               // Parameters on the right

//               Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () => _navigateToDetailPage(0),
//                         child: Container(
//                           height: 80,
//                           width: 120,
//                           child: Card(
//                             color: parameterColors[0],
//                             elevation: 4.0,
//                             child: StreamBuilder<OxyData>(
//                               stream: _streamDatapurity.stream,
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData) {
//                                   OxyData oxyData = snapshot.data!;
//                                   String value = oxyData.value.toString();
//                                   return Padding(
//                                     padding: const EdgeInsets.all(2.0),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             if (value == '-333')
//                                               Text(
//                                                 'NC',
//                                                 style: TextStyle(
//                                                   color: parameterTextColor[0],
//                                                   fontSize: 32,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             if (value != '-333')
//                                               Text(
//                                                 value,
//                                                 style: TextStyle(
//                                                   color: parameterTextColor[0],
//                                                   fontSize: 32,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             const SizedBox(width: 15),
//                                             if (value != '-333')
//                                               Text(
//                                                 parameterUnit[0],
//                                                 style: TextStyle(
//                                                   color: parameterTextColor[0],
//                                                   fontSize: 10,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                           ],
//                                         ),
//                                         Text(
//                                           parameterNames[0],
//                                           style: TextStyle(
//                                             color: parameterTextColor[0],
//                                             fontSize: 10,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 } else {
//                                   return CircularProgressIndicator(
//                                     color: parameterTextColor[0],
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () => _navigateToDetailPage(1),
//                         child: Container(
//                           height: 80,
//                           width: 120,
//                           child: Card(
//                             color: parameterColors[1],
//                             elevation: 4.0,
//                             child: StreamBuilder<OxyData>(
//                                 stream: _streamDataflow.stream,
//                                 builder: (context, snapshot) {
//                                   if (snapshot.hasData) {
//                                     OxyData pressData = snapshot.data!;
//                                     OxyData data = pressData;
//                                     // String type = data.type;
//                                     String value = data.value.toString();
//                                     return Padding(
//                                       padding: const EdgeInsets.all(2.0),
//                                       child: Column(
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               if (value == '-333')
//                                                 Text(
//                                                   'NC',
//                                                   style: TextStyle(
//                                                     color:
//                                                         parameterTextColor[0],
//                                                     fontSize: 32,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               if (value != '-333')
//                                                 Text(
//                                                   value,
//                                                   style: TextStyle(
//                                                     color:
//                                                         parameterTextColor[0],
//                                                     fontSize: 32,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               const SizedBox(width: 15),
//                                               Text(
//                                                 parameterUnit[1],
//                                                 style: TextStyle(
//                                                   color: parameterTextColor[1],
//                                                   fontSize: 7,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           Text(
//                                             parameterNames[1],
//                                             style: TextStyle(
//                                               color: parameterTextColor[1],
//                                               fontSize: 10,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   } else {
//                                     return CircularProgressIndicator(
//                                       color: parameterTextColor[1],
//                                     );
//                                   }
//                                 }),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () => _navigateToDetailPage(2),
//                         child: Container(
//                           height: 80,
//                           width: 120,
//                           child: Card(
//                             color: parameterColors[2],
//                             elevation: 4.0,
//                             child: StreamBuilder<OxyData>(
//                                 stream: _streamDatapressure.stream,
//                                 builder: (context, snapshot) {
//                                   if (snapshot.hasData) {
//                                     OxyData oxyData = snapshot.data!;
//                                     OxyData data = oxyData;
//                                     // String type = data.type;
//                                     String value = data.value.toString();
//                                     return Padding(
//                                       padding: const EdgeInsets.all(2.0),
//                                       child: Column(
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               if (value == '-333')
//                                                 Text(
//                                                   'NC',
//                                                   style: TextStyle(
//                                                     color:
//                                                         parameterTextColor[2],
//                                                     fontSize: 32,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               if (value != '-333')
//                                                 Text(
//                                                   value,
//                                                   style: TextStyle(
//                                                     color:
//                                                         parameterTextColor[2],
//                                                     fontSize: 32,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               const SizedBox(width: 15),
//                                               Text(
//                                                 parameterUnit[2],
//                                                 style: TextStyle(
//                                                   color: parameterTextColor[2],
//                                                   fontSize: 7,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           Text(
//                                             parameterNames[2],
//                                             style: TextStyle(
//                                               color: parameterTextColor[2],
//                                               fontSize: 10,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   } else {
//                                     return CircularProgressIndicator(
//                                       color: parameterTextColor[2],
//                                     );
//                                   }
//                                 }),
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () => _navigateToDetailPage(3),
//                         child: Container(
//                           height: 80,
//                           width: 120,
//                           child: Card(
//                             color: parameterColors[3],
//                             elevation: 4.0,
//                             child: StreamBuilder<OxyData>(
//                                 stream: _streamDatatemp.stream,
//                                 builder: (context, snapshot) {
//                                   if (snapshot.hasData) {
//                                     OxyData oxyData = snapshot.data!;
//                                     OxyData data = oxyData;
//                                     // String type = data.type;
//                                     String value = data.value.toString();
//                                     return Padding(
//                                       padding: const EdgeInsets.all(2.0),
//                                       child: Column(
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               if (value == '-333')
//                                                 Text(
//                                                   'NC',
//                                                   style: TextStyle(
//                                                     color:
//                                                         parameterTextColor[3],
//                                                     fontSize: 32,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               if (value != '-333')
//                                                 Text(
//                                                   value,
//                                                   style: TextStyle(
//                                                     color:
//                                                         parameterTextColor[3],
//                                                     fontSize: 32,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               const SizedBox(width: 15),
//                                               if (value != '-333')
//                                                 Text(
//                                                   parameterUnit[3],
//                                                   style: TextStyle(
//                                                     color:
//                                                         parameterTextColor[3],
//                                                     fontSize: 7,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                           Text(
//                                             parameterNames[3],
//                                             style: TextStyle(
//                                               color: parameterTextColor[3],
//                                               fontSize: 10,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   } else {
//                                     return CircularProgressIndicator(
//                                       color: parameterTextColor[3],
//                                     );
//                                   }
//                                 }),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
                
                  
//                 ],
//               ),
//             ],
//           ),
//           Align(
//             child: Container(
//               height: 20,
//               color: Colors.grey[200], // Background color of the bar
//               padding: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Spacer(flex: 20),
//                   const Text(
//                     'SYSTEM IS RUNNING OK',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                   ),
//                   const Spacer(
//                     flex: 12,
//                   ),
//                   Positioned(
//                     right: 130,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(horizontal: 12.0),
//                         shape: RoundedRectangleBorder(
//                           side: BorderSide(
//                               style: BorderStyle.solid, color: Colors.black87),
//                           borderRadius:
//                               BorderRadius.circular(5), // Square corners
//                         ),
//                         minimumSize:
//                             Size(90, 25), // Set minimum size to maintain height
//                         backgroundColor: Color.fromARGB(255, 192, 191, 191),
//                       ),
//                       onPressed: () async {
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(builder: (context) => Setting1()),
//                         // );
//                       },
//                       child: const Text(
//                         'Settings',
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Color.fromARGB(255, 0, 0, 0),
//                           shadows: [
//                             Shadow(
//                               blurRadius: 4,
//                               color: Colors.grey,
//                               offset: Offset(2, 1.5),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12), // Add spacing between the buttons
//                   Positioned(
//                     right: 20,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(horizontal: 12.0),
//                         shape: RoundedRectangleBorder(
//                           side: BorderSide(
//                               style: BorderStyle.solid, color: Colors.black87),
//                           borderRadius:
//                               BorderRadius.circular(5), // Square corners
//                         ),
//                         minimumSize:
//                             Size(90, 25), // Set minimum size to maintain height
//                         backgroundColor: Color.fromARGB(255, 192, 191, 191),
//                       ),
//                       onPressed: () async {
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //     builder: (context) => ReportScreen(),
//                         //   ),
//                         // );
//                       },
//                       child: const Text(
//                         'Report',
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Color.fromARGB(255, 0, 0, 0),
//                           shadows: [
//                             Shadow(
//                               blurRadius: 4,
//                               color: Colors.grey,
//                               offset: Offset(2, 1.5),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Spacer(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//     // : Center(
//     //     child: Column(
//     //       mainAxisAlignment: MainAxisAlignment.center,
//     //       children: [
//     //         Icon(
//     //           Icons.wifi_off,
//     //           size: 30,
//     //         ),
//     //         Text("Internet is not connected"),
//     //       ],
//     //     ),
//     //   )
//   }

//   Future<void> getdata() async {
//     var url = Uri.parse('http://192.168.4.1/event');
//     final response = await http.get(url);

//     final data = json.decode(response.body);

//     // Debugging: Print out the type and structure of the data
//     print('Type of data: ${data.runtimeType}');
//     print('Data structure: $data');

//     // Iterate over each map in the list and create PressData objects
//     for (var jsonData in data) {
//       OxyData oxydata = OxyData.fromJson(jsonData);
//       if (oxydata.type == 'purity') {
//         _streamDatapurity.sink.add(oxydata);
//       } else if (oxydata.type == 'flow') {
//         _streamDataflow.sink.add(oxydata);
//       } else if (oxydata.type == 'pressure') {
//         _streamDatapressure.sink.add(oxydata);
//       } else if (oxydata.type == 'temp') {
//         _streamDatatemp.sink.add(oxydata);
//       }
//       _streamData.sink.add(oxydata);
//     }
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       _updateData(data);
//     } else {
//       print('Failed to load data');
//     }
//     // Delay before fetching data again (optional)
//     await Future.delayed(Duration(seconds: 1));
//   }
// }