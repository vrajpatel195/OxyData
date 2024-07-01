import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oxydata/LimitSetting(Demo)/Temp_demo.dart';
import 'package:oxydata/LimitSetting(Demo)/flow_demo.dart';
import 'package:oxydata/LimitSetting(Demo)/pressure_demo.dart';
import 'package:oxydata/LimitSetting(Demo)/purity_demo.dart';

// import 'package:pressdata/screens/LimitSetting(Demo)/air.dart';
// import 'package:pressdata/screens/LimitSetting(Demo)/co2.dart';
// import 'package:pressdata/screens/LimitSetting(Demo)/humi.dart';
// import 'package:pressdata/screens/LimitSetting(Demo)/n2o.dart';
// import 'package:pressdata/screens/LimitSetting(Demo)/o2-1.dart';
// import 'package:pressdata/screens/LimitSetting(Demo)/o2-2.dart';
// import 'package:pressdata/screens/LimitSetting(Demo)/temp.dart';
// import 'package:pressdata/screens/LimitSetting(Demo)/vac.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../screens/register.dart';

class LiveData {
  LiveData(
    this.time,
    this.purity,
    this.flow,
    this.pressure,
    this.temp,
  );
  final int time;
  final num purity;
  final num flow;
  final num pressure;
  final num temp;
}

class DemoWid extends StatefulWidget {
  const DemoWid({Key? key}) : super(key: key);

  @override
  State<DemoWid> createState() => _DemoWidState();
}

class ParameterData {
  final String name;
  final Color color;
  int value;

  ParameterData(this.name, this.color, this.value);
}

class _DemoWidState extends State<DemoWid> {
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController0;
  late ChartSeriesController _chartSeriesController1;
  late ChartSeriesController _chartSeriesController2;
  late ChartSeriesController _chartSeriesController3;

  int? Purity_maxLimit;
  int? Purity_minLimit;
  int? Flow_maxLimit;
  int? Flow_minLimit;
  int? Pressure_maxLimit;
  int? Pressure_minLimit;
  int? Temp_maxLimit;
  int? Temp_minLimit;

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(
        0,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        1,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        2,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        3,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        4,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        5,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        6,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        7,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        8,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        9,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        10,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        11,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        12,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        13,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        14,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        15,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        16,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        17,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      ),
      LiveData(
        18,
        Random().nextInt(10) + 1,
        Random().nextInt(10) + 11,
        Random().nextInt(10) + 21,
        Random().nextInt(10) + 31,
      )
    ];
  }

  List<ParameterData> parameters = [
    ParameterData(
        "Purity", const Color.fromARGB(255, 0, 34, 145), Random().nextInt(100)),
    ParameterData(
        "Flow", Color.fromARGB(182, 241, 193, 48), Random().nextInt(100)),
    ParameterData("Pressure", Colors.red, Random().nextInt(100)),
    ParameterData(
        "TEMP", const Color.fromARGB(255, 44, 238, 144), Random().nextInt(100)),
  ];

  List parameterNames = [
    "Purity",
    "Flow",
    "Pressure", // Subscript NO₂ for NO2
    "Temp",
  ];
  List parameterUnit = [
    "%",
    "LPM",
    "PSI",
    "°C",
  ];
  final LinearGradient gradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Colors.blue, Colors.green], // Two colors for the gradient
  );

  final List<Color> parameterColors = [
    const Color.fromARGB(255, 0, 34, 145),
    Color.fromARGB(255, 248, 213, 40),
    const Color.fromARGB(255, 195, 0, 0),
    const Color.fromARGB(255, 44, 238, 144)
  ];
  final List<Color> parameterTextColor = [
    const Color.fromARGB(255, 255, 255, 255),
    const Color.fromARGB(255, 255, 255, 255),
    const Color.fromARGB(255, 255, 255, 255),
    const Color.fromARGB(255, 0, 0, 0),
  ];
  void _storeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Purity_maxLimit = prefs.getInt('Purity_maxLimit') ?? 0;
      Purity_minLimit = prefs.getInt('Purity_minLimit') ?? 0;
      Flow_maxLimit = prefs.getInt('Flow_maxLimit') ?? 0;
      Flow_minLimit = prefs.getInt('Flow_minLimit') ?? 0;
      Pressure_maxLimit = prefs.getInt('Pressure_maxLimit') ?? 0;
      Pressure_minLimit = prefs.getInt('Pressure_minLimit') ?? 0;
      Temp_maxLimit = prefs.getInt('Temp_maxLimit') ?? 0;
      Temp_minLimit = prefs.getInt('Temp_minLimit') ?? 0;
    });
    print("Flow -  $Flow_maxLimit");
  }

  void _navigateToDetailPage(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PurityDemo()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FlowDemo()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PressureDemo()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TempDemo()),
      );
    }
  }

  late StreamController<void> _updateController;
  late StreamSubscription<void> _streamSubscription;

  @override
  void initState() {
    super.initState();

    chartData = getChartData();
    Timer.periodic(Duration(seconds: 1), updateDataSource);
    _updateController = StreamController<void>.broadcast();
    _storeData();
    _streamSubscription = _updateController.stream.listen((_) {
      _updateData();
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateController.add(null);
    });
  }

  void _updateData() {
    setState(() {
      parameters = parameters.map((param) {
        if (param.name == "Purity") {
          int newvalue = Random().nextInt(10);
          if (newvalue > Purity_maxLimit! || newvalue < Purity_minLimit!) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 550),
                  content: Text('${param.name} is not in range!'),
                ),
              );
            });
            return ParameterData(param.name, Colors.red, newvalue);
          } else {
            return ParameterData(
                param.name, const Color.fromARGB(255, 0, 34, 145), newvalue);
          }
        } else if (param.name == "Flow") {
          int newvalue = Random().nextInt(10) + 11;
          if (newvalue > Flow_maxLimit! || newvalue < Flow_minLimit!) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 550),
                  content: Text('${param.name} is not in range!'),
                ),
              );
            });
            return ParameterData(param.name, Colors.red, newvalue);
          } else {
            return ParameterData(
                param.name, Color.fromARGB(255, 248, 213, 40), newvalue);
          }
        } else if (param.name == "Pressure") {
          int newvalue = Random().nextInt(10) + 21;
          if (newvalue > Pressure_maxLimit! || newvalue < Pressure_minLimit!) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${param.name} is not in range!'),
                ),
              );
            });
            return ParameterData(param.name, Colors.red, newvalue);
          } else {
            return ParameterData(
                param.name, const Color.fromARGB(255, 195, 0, 0), newvalue);
          }
        } else {
          int newvalue = Random().nextInt(10) + 71;
          if (newvalue > Temp_maxLimit! || newvalue < Temp_minLimit!) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${param.name} is not in range!'),
                ),
              );
            });
            return ParameterData(param.name, Colors.red, newvalue);
          } else {
            return ParameterData(
                param.name, const Color.fromARGB(255, 44, 238, 144), newvalue);
          }
        }
      }).toList();
    });
  }

  int time = 19;
  void updateDataSource(Timer timer) {
    chartData.add(LiveData(
      time++,
      Random().nextInt(10) + 1,
      Random().nextInt(10) + 11,
      Random().nextInt(10) + 21,
      Random().nextInt(10) + 31,
    ));
    chartData.removeAt(0);
    _chartSeriesController0.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
    _chartSeriesController1.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
    _chartSeriesController2.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
    _chartSeriesController3.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  }

  @override
  void dispose() {
    _updateController.close(); // Close the stream controller
    _streamSubscription.cancel(); // Cancel the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: RichText(
                text: const TextSpan(
                    text: 'Oxy ',
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0), fontSize: 25),
                    children: [
                      TextSpan(
                        text: 'Data -',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0), fontSize: 25),
                      ),
                      TextSpan(
                        text: ' Oxygen Data Analyser ',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0), fontSize: 20),
                      ),
                    ]),
              ),
            ),
          ],
        ),
        toolbarHeight: 35,
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.612),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => RegistrationScreen()));
          },
        ),
      ),
      body: Row(
        children: [
          SizedBox(
            height: 2,
          ),
          // Graph on the left
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  Container(
                    height: 78,
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      tooltipBehavior: TooltipBehavior(enable: true),
                      //  legend: Legend(isVisible: true),
                      primaryXAxis: const NumericAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        interval: 3,
                        // title: AxisTitle(
                        //     text: 'Reading for OxyData',
                        //     textStyle: TextStyle(fontSize: 10)),
                      ),
                      primaryYAxis: const NumericAxis(
                        axisLine: AxisLine(width: 0),
                        majorTickLines: MajorTickLines(size: 0),
                        title: AxisTitle(text: '%'),
                      ),
                      series: <LineSeries<LiveData, int>>[
                        LineSeries<LiveData, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            _chartSeriesController0 = controller;
                          },
                          dataSource: chartData,
                          xValueMapper: (LiveData press, _) => press.time,
                          yValueMapper: (LiveData press, _) => press.purity,
                          //  markerSettings: const MarkerSettings(isVisible: true),
                          color: const Color.fromARGB(255, 0, 34, 145),
                          name: "Purity",
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 78,
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      tooltipBehavior: TooltipBehavior(enable: true),
                      //  legend: Legend(isVisible: true),
                      primaryXAxis: const NumericAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        interval: 3,
                        // title: AxisTitle(
                        //     text: 'Reading for OxyData',
                        //     textStyle: TextStyle(fontSize: 10)),
                      ),
                      primaryYAxis: const NumericAxis(
                        axisLine: AxisLine(width: 0),
                        majorTickLines: MajorTickLines(size: 0),
                        title: AxisTitle(text: 'LPM'),
                      ),
                      series: <LineSeries<LiveData, int>>[
                        LineSeries<LiveData, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            _chartSeriesController1 = controller;
                          },
                          dataSource: chartData,
                          xValueMapper: (LiveData press, _) => press.time,
                          yValueMapper: (LiveData press, _) => press.flow,
                          // markerSettings: const MarkerSettings(isVisible: true),
                          color: Color.fromARGB(255, 248, 213, 40),
                          name: "Flow",
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 78,
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      tooltipBehavior: TooltipBehavior(enable: true),
                      //  legend: Legend(isVisible: true),
                      primaryXAxis: const NumericAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        interval: 3,
                        // title: AxisTitle(
                        //     text: 'Reading for OxyData',
                        //     textStyle: TextStyle(fontSize: 10)),
                      ),
                      primaryYAxis: const NumericAxis(
                        axisLine: AxisLine(width: 0),
                        majorTickLines: MajorTickLines(size: 0),
                        title: AxisTitle(text: 'PSI'),
                      ),
                      series: <LineSeries<LiveData, int>>[
                        LineSeries<LiveData, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            _chartSeriesController2 = controller;
                          },
                          dataSource: chartData,
                          xValueMapper: (LiveData press, _) => press.time,
                          yValueMapper: (LiveData press, _) => press.pressure,
                          //markerSettings: const MarkerSettings(isVisible: true),
                          color: const Color.fromARGB(255, 195, 0, 0),

                          name: "Pressure",
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 78,
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      tooltipBehavior: TooltipBehavior(enable: true),
                      //  legend: Legend(isVisible: true),
                      primaryXAxis: const NumericAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        interval: 3,
                        // title: AxisTitle(
                        //     text: 'Reading for OxyData',
                        //     textStyle: TextStyle(fontSize: 10)),
                      ),
                      primaryYAxis: const NumericAxis(
                        axisLine: AxisLine(width: 0),
                        majorTickLines: MajorTickLines(size: 0),
                        title: AxisTitle(text: '°C'),
                      ),
                      series: <LineSeries<LiveData, int>>[
                        LineSeries<LiveData, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            _chartSeriesController3 = controller;
                          },
                          dataSource: chartData,
                          xValueMapper: (LiveData press, _) => press.time,
                          yValueMapper: (LiveData press, _) => press.temp,
                          //markerSettings: const MarkerSettings(isVisible: true),
                          color: const Color.fromARGB(255, 44, 238, 144),
                          name: "Temp",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Parameters on the right
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 3.0,
                        crossAxisSpacing: 8.0,
                        childAspectRatio: 1.19 / 1,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        //  String dataValue = '';
                        // Access the data based on the index of the card

                        return GestureDetector(
                          onTap: () => _navigateToDetailPage(index),
                          child: Card(
                            color: parameters[index].color,
                            elevation: 4.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: parameters[index].color,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  children: [
                                    Text(
                                      ' ${parameters[index].value}',
                                      style: TextStyle(
                                        color: parameterTextColor[index],
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      ' ${parameterUnit[index]}',
                                      style: TextStyle(
                                        color: parameterTextColor[index],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      parameterNames[index],
                                      style: TextStyle(
                                        color: parameterTextColor[index],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
