import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oxydata/Demo/demo_report_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'LimitSettingDemo/Temp_demo.dart';
import 'LimitSettingDemo/flow_demo.dart';
import 'LimitSettingDemo/pressure_demo.dart';
import 'LimitSettingDemo/purity_demo.dart';

class DemoWid extends StatefulWidget {
  const DemoWid({Key? key}) : super(key: key);

  @override
  State<DemoWid> createState() => _DemoWidState();
}

class _DemoWidState extends State<DemoWid> {
  double? Purity_minLimit;
  double? Purity_maxLimit;
  double? Flow_maxLimit;
  double? Flow_minLimit;
  double? Pressure_maxLimit;
  double? Pressure_minLimit;
  double? Temp_maxLimit;
  double? Temp_minLimit;

  String? Purity_maxStr;
  String? Purity_minStr;
  String? flow_maxStr;
  String? flow_minStr;
  String? pressure_maxStr;
  String? pressure_minStr;
  String? temp_maxStr;
  String? temp_minStr;

  int time = 0;
  int _currentIndex = 0;
  String _currentString = 'SYSTEM IS RUNNING OK';
  Set<String> _uniqueStrings = {};
  List<String> _uniqueStringList = [];
  List<Map<String, dynamic>> _cache = [];

  // final StreamController<List<ChartData>> _streamController =
  //     StreamController<List<ChartData>>.broadcast();

  // Fixed color map for predefined types
  final Map<String, Color> colorMap = {
    'purity': const Color.fromARGB(255, 0, 34, 145),
    'flow': Color.fromARGB(182, 241, 193, 48),
    'pressure': Colors.red,
    'temp': const Color.fromARGB(255, 44, 238, 144),
  };

  // Fixed order of types for series
  final List<String> seriesOrder = [
    'purity',
    'flow',
    'pressure',
    'temp',
  ];

  void _navigateToDetailPage(int index) async {
    if (index == 0) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PurityDemo()),
      );

      if (result == 1) {
        print("returnnnnnnn");
        _storeData();
      }
    } else if (index == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FlowDemo()),
      );
      if (result == 1) {
        _storeData();
      }
    } else if (index == 2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PressureDemo()),
      );
      if (result == 1) {
        _storeData();
      }
    } else if (index == 3) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TempDemo()),
      );
      if (result == 1) {
        _storeData();
      }
    }
  }

  late StreamController<void> _updateController;
  late StreamSubscription<void> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _storeData();
    _initialData();
    _updateController = StreamController<void>.broadcast();

    _streamSubscription = _updateController.stream.listen((_) {
      _updateString();
    });
    if (_isRunning) return;
    Timer.periodic(Duration(seconds: 1), (timer) async {
      await getData();
      _updateController.add(null);
      time++;
      _updateCurrentString();
    });
    _isRunning = true;

    _puritySubscription = _purityController.stream.listen((data) {
      setState(() {
        _purityData.add(_ChartData(time, data));
        if (_purityData.length > 61) _purityData.removeAt(0);
        _latestPurity = data;
      });

      _updateDataSource();
    });
    _flowRateSubscription = _flowRateController.stream.listen((data) {
      setState(() {
        _flowRateData.add(_ChartData(time, data));
        if (_flowRateData.length > 61) _flowRateData.removeAt(0);
        _latestFlowRate = data;
      });
      _updateDataSource();
    });
    _pressureSubscription = _pressureController.stream.listen((data) {
      setState(() {
        _pressureData.add(_ChartData(time, data));
        if (_pressureData.length > 61) _pressureData.removeAt(0);
        _latestPressure = data;
      });
      _updateDataSource();
    });
    _temperatureSubscription = _temperatureController.stream.listen((data) {
      setState(() {
        _temperatureData.add(_ChartData(time, data));
        if (_temperatureData.length > 61) _temperatureData.removeAt(0);
        _latestTemperature = data;
      });
      _updateDataSource();
    });
  }

  void _initialData() {
    _purityData.add(_ChartData(60, -1));
    _pressureData.add(_ChartData(60, -1));
    _flowRateData.add(_ChartData(60, -1));
    _temperatureData.add(_ChartData(60, -1));
    _purityData.add(_ChartData(0, -1));
    _pressureData.add(_ChartData(0, -1));
    _flowRateData.add(_ChartData(0, -1));
    _temperatureData.add(_ChartData(0, -1));
  }

  void _updateDataSource() {
    _purityChartController?.updateDataSource(
      addedDataIndex: _purityData.length - 1,
      removedDataIndex: _purityData.length > 1 ? 0 : -1,
    );
    _flowRateChartController?.updateDataSource(
      addedDataIndex: _flowRateData.length - 1,
      removedDataIndex: _flowRateData.length > 1 ? 0 : -1,
    );
    _pressureChartController?.updateDataSource(
      addedDataIndex: _pressureData.length - 1,
      removedDataIndex: _pressureData.length > 1 ? 0 : -1,
    );
    _temperatureChartController?.updateDataSource(
      addedDataIndex: _temperatureData.length - 1,
      removedDataIndex: _temperatureData.length > 1 ? 0 : -1,
    );
  }

  Future<void> _storeData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      setState(() {
        Purity_maxLimit = prefs.getDouble('Purity_maxLimit') ?? 0;
        print("purityyy max data: ${Purity_maxLimit}");
        Purity_minLimit = prefs.getDouble('Purity_minLimit') ?? 0;
        Flow_maxLimit = prefs.getDouble('Flow_maxLimit') ?? 0;
        Flow_minLimit = prefs.getDouble('Flow_minLimit') ?? 0;
        Pressure_maxLimit = prefs.getDouble('Pressure_maxLimit') ?? 0;
        Pressure_minLimit = prefs.getDouble('Pressure_minLimit') ?? 0;
        Temp_maxLimit = prefs.getDouble('Temp_maxLimit') ?? 0;
        Temp_minLimit = prefs.getDouble('Temp_minLimit') ?? 0;
      });
      _updateString();
    } catch (e) {
      print("Error loading limits $e");
    }
    _updateString();
  }

  void _addString(String value) {
    setState(() {
      _uniqueStrings.add(value);
      _uniqueStringList = _uniqueStrings.toList();
      _resetIndexIfNeeded();
    });
  }

  void _removeString(String value) {
    setState(() {
      _uniqueStrings.remove(value);
      _uniqueStringList = _uniqueStrings.toList();
      _resetIndexIfNeeded();
    });
  }

  void _resetIndexIfNeeded() {
    if (_currentIndex >= _uniqueStringList.length) {
      _currentIndex = 0;
    }
  }

  void _updateCurrentString() {
    setState(() {
      if (_uniqueStringList.isNotEmpty) {
        _currentString = _uniqueStringList[_currentIndex];
        _currentIndex = (_currentIndex + 1) % _uniqueStringList.length;
      } else {
        _currentString = 'SYSTEM IS RUNNING OK';
      }
    });
  }

  void _updateString() {
    if (_latestPurity > Purity_maxLimit! || _latestPurity < Purity_minLimit!) {
      // print("Purity max: $Purity_maxLimit");
      // _storeAlarm(_latestPurity, Purity_maxLimit!, Purity_minLimit!, "Purity");
      _addString("Purity is out of range");
    } else {
      _removeString("Purity is out of range");
    }

    if (_latestFlowRate > Flow_maxLimit! || _latestFlowRate < Flow_minLimit!) {
      //  _storeAlarm(_latestFlowRate, Flow_maxLimit!, Flow_minLimit!, "Flow");
      _addString("Flow is out of range");
    } else {
      _removeString("Flow is out of range");
    }

    if (_latestPressure > Pressure_maxLimit! ||
        _latestPressure < Pressure_minLimit!) {
      _addString("Pressure is out of range");
    } else {
      _removeString("Pressure is out of range");
    }

    if (_latestTemperature > Temp_maxLimit! ||
        _latestTemperature < Temp_minLimit!) {
      _addString("Temp is out of range");
    } else {
      _removeString("Temp is out of range");
    }
  }

  @override
  void dispose() {
    _updateController.close(); // Close the stream controller
    _streamSubscription.cancel(); // Cancel the subscription

    _purityController.close();
    _flowRateController.close();
    _pressureController.close();
    _temperatureController.close();
    _puritySubscription?.cancel();
    _flowRateSubscription?.cancel();
    _pressureSubscription?.cancel();
    _temperatureSubscription?.cancel();

    setState(() {
      _isRunning = false;
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    final List<Color> parameterColors = [
      const Color.fromARGB(255, 0, 34, 145),
      Color.fromARGB(255, 204, 148, 7),
      const Color.fromARGB(255, 195, 0, 0),
      Color.fromARGB(255, 3, 161, 84)
    ];
    final List<Color> parameterTextColor = [
      const Color.fromARGB(255, 255, 255, 255),
      const Color.fromARGB(255, 255, 255, 255),
      const Color.fromARGB(255, 255, 255, 255),
      Color.fromARGB(255, 255, 255, 255),
    ];
    List parameterUnit = [
      "%",
      "LPM",
      "PSI",
      "°C",
    ];
    List parameterNames = [
      "O₂ Purity",
      "Flow",
      "Pressure",
      "Temp",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
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
                        text: ' Oxygen Data Analyser ..',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0), fontSize: 20),
                      ),
                    ]),
              ),
            ),
          ],
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.09,
        backgroundColor: Color.fromARGB(141, 241, 241, 241),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            flex: 13,
            child: Row(
              children: [
                // Graph on the left
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Stack(children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Demo",
                            style: TextStyle(
                              fontSize: 100,
                              color: Colors.black.withOpacity(0.1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              //  height: screenHeight * 0.20,
                              child: SfCartesianChart(
                                plotAreaBorderWidth: 0,
                                // tooltipBehavior: TooltipBehavior(enable: true),
                                //  legend: Legend(isVisible: true),
                                primaryXAxis: NumericAxis(
                                  interval: 10,
                                  labelFormat: '{value}',
                                  axisLabelFormatter:
                                      (AxisLabelRenderDetails details) {
                                    int value = details.value.toInt();
                                    int minutes = value ~/ 60;
                                    int seconds = value % 60;
                                    String formattedTime =
                                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                                    return ChartAxisLabel(formattedTime,
                                        TextStyle(color: Colors.black));
                                  },
                                ),
                                primaryYAxis: const NumericAxis(
                                  axisLine: AxisLine(width: 0),
                                  majorTickLines: MajorTickLines(size: 0),
                                  title: AxisTitle(text: 'O₂%'),
                                  minimum: 70,
                                  maximum: 90,
                                ),
                                series: <LineSeries<_ChartData, int>>[
                                  LineSeries<_ChartData, int>(
                                    onRendererCreated:
                                        (ChartSeriesController controller) {
                                      _purityChartController = controller;
                                    },
                                    dataSource: _purityData,

                                    xValueMapper: (_ChartData press, _) =>
                                        press.time,
                                    yValueMapper: (_ChartData press, _) =>
                                        press.value,
                                    //  markerSettings: const MarkerSettings(isVisible: true),
                                    color:
                                        const Color.fromARGB(255, 0, 34, 145),
                                    name: "Purity",
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              // height: MediaQuery.of(context).size.height * 0.21,
                              child: SfCartesianChart(
                                plotAreaBorderWidth: 0,
                                // tooltipBehavior: TooltipBehavior(enable: true),
                                //  legend: Legend(isVisible: true),
                                primaryXAxis: NumericAxis(
                                  interval: 10,
                                  labelFormat: '{value}',
                                  axisLabelFormatter:
                                      (AxisLabelRenderDetails details) {
                                    int value = details.value.toInt();
                                    int minutes = value ~/ 60;
                                    int seconds = value % 60;
                                    String formattedTime =
                                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                                    return ChartAxisLabel(formattedTime,
                                        TextStyle(color: Colors.black));
                                  },
                                ),
                                primaryYAxis: const NumericAxis(
                                  maximum: 40,
                                  interval: 20,
                                  minimum: 0,
                                  axisLine: AxisLine(width: 0),
                                  majorTickLines: MajorTickLines(size: 0),
                                  title: AxisTitle(text: 'LPM'),
                                ),
                                series: <LineSeries<_ChartData, int>>[
                                  LineSeries<_ChartData, int>(
                                    onRendererCreated:
                                        (ChartSeriesController controller) {
                                      _flowRateChartController = controller;
                                    },
                                    dataSource: _flowRateData,
                                    xValueMapper: (_ChartData press, _) =>
                                        press.time,
                                    yValueMapper: (_ChartData press, _) =>
                                        press.value,
                                    // markerSettings: const MarkerSettings(isVisible: true),
                                    color: Color.fromARGB(255, 248, 213, 40),
                                    name: "Flow",
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              //  height: MediaQuery.of(context).size.height * 0.21,
                              child: SfCartesianChart(
                                // plotAreaBorderWidth: 0,
                                //tooltipBehavior: TooltipBehavior(enable: true),
                                //  legend: Legend(isVisible: true),
                                primaryXAxis: NumericAxis(
                                  interval: 10,
                                  labelFormat: '{value}',
                                  axisLabelFormatter:
                                      (AxisLabelRenderDetails details) {
                                    int value = details.value.toInt();
                                    int minutes = value ~/ 60;
                                    int seconds = value % 60;
                                    String formattedTime =
                                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                                    return ChartAxisLabel(formattedTime,
                                        TextStyle(color: Colors.black));
                                  },
                                ),
                                primaryYAxis: const NumericAxis(
                                  maximum: 40,
                                  interval: 20,
                                  minimum: 0,
                                  axisLine: AxisLine(width: 0),
                                  majorTickLines: MajorTickLines(size: 0),
                                  title: AxisTitle(text: 'PSI'),
                                ),
                                series: <LineSeries<_ChartData, int>>[
                                  LineSeries<_ChartData, int>(
                                    onRendererCreated:
                                        (ChartSeriesController controller) {
                                      _pressureChartController = controller;
                                    },
                                    dataSource: _pressureData,
                                    xValueMapper: (_ChartData press, _) =>
                                        press.time,
                                    yValueMapper: (_ChartData press, _) =>
                                        press.value,
                                    //markerSettings: const MarkerSettings(isVisible: true),
                                    color: const Color.fromARGB(255, 195, 0, 0),

                                    name: "Pressure",
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                // height: MediaQuery.of(context).size.height * 0.21,
                                child: SfCartesianChart(
                              plotAreaBorderWidth: 0,
                              // tooltipBehavior: TooltipBehavior(enable: true),
                              //  legend: Legend(isVisible: true),
                              primaryXAxis: NumericAxis(
                                interval: 10,
                                labelFormat: '{value}',
                                axisLabelFormatter:
                                    (AxisLabelRenderDetails details) {
                                  int value = details.value.toInt();
                                  int minutes = value ~/ 60;
                                  int seconds = value % 60;
                                  String formattedTime =
                                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                                  return ChartAxisLabel(formattedTime,
                                      TextStyle(color: Colors.black));
                                },
                              ),
                              primaryYAxis: const NumericAxis(
                                maximum: 50,
                                interval: 25,
                                minimum: 0,
                                axisLine: AxisLine(width: 0),
                                majorTickLines: MajorTickLines(size: 0),
                                title: AxisTitle(text: '°C'),
                              ),
                              series: <LineSeries<_ChartData, int>>[
                                LineSeries<_ChartData, int>(
                                  onRendererCreated:
                                      (ChartSeriesController controller) {
                                    _temperatureChartController = controller;
                                  },
                                  dataSource: _temperatureData,
                                  xValueMapper: (data, _) => data.time,
                                  yValueMapper: (data, _) => data.value,
                                  //markerSettings: const MarkerSettings(isVisible: true),
                                  color: Color.fromARGB(255, 44, 238, 144),
                                  name: "Temp",
                                ),
                              ],
                            )),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
                // Parameters on the right

                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _navigateToDetailPage(0),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.313,
                              child: Card(
                                  color: parameterColors[0],
                                  elevation: 4.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _latestPurity.toStringAsFixed(1),
                                              style: TextStyle(
                                                color: parameterTextColor[0],
                                                fontSize: screenWidth / 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              parameterUnit[0],
                                              style: TextStyle(
                                                color: parameterTextColor[0],
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          parameterNames[0],
                                          style: TextStyle(
                                            color: parameterTextColor[0],
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _navigateToDetailPage(2),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.313,
                              child: Card(
                                color: parameterColors[2],
                                elevation: 4.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _latestPressure.toStringAsFixed(1),
                                            style: TextStyle(
                                              color: parameterTextColor[2],
                                              fontSize: screenWidth / 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            parameterUnit[2],
                                            style: TextStyle(
                                              color: parameterTextColor[2],
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        parameterNames[2],
                                        style: TextStyle(
                                          color: parameterTextColor[2],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {},
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.145,
                              width: double.infinity,
                              child: Card(
                                color: Colors.blue,
                                elevation: 4.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Setting",
                                        style: TextStyle(
                                          color: parameterTextColor[2],
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 0, top: 5, bottom: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _navigateToDetailPage(1),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.313,
                              child: Card(
                                color: parameterColors[1],
                                elevation: 4.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _latestFlowRate.toStringAsFixed(1),
                                            style: TextStyle(
                                              color: parameterTextColor[0],
                                              fontSize: screenWidth / 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            parameterUnit[1],
                                            style: TextStyle(
                                              color: parameterTextColor[1],
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        parameterNames[1],
                                        style: TextStyle(
                                          color: parameterTextColor[1],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _navigateToDetailPage(3),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.313,
                              child: Card(
                                color: parameterColors[3],
                                elevation: 4.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _latestTemperature
                                                .toStringAsFixed(1),
                                            style: TextStyle(
                                              color: parameterTextColor[3],
                                              fontSize: screenWidth / 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            parameterUnit[3],
                                            style: TextStyle(
                                              color: parameterTextColor[3],
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        parameterNames[3],
                                        style: TextStyle(
                                          color: parameterTextColor[3],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DemoReportScreen(data: _cache)));
                            },
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.145,
                              width: double.infinity,
                              child: Card(
                                color: Colors.blue,
                                elevation: 4.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Report",
                                        style: TextStyle(
                                          color: parameterTextColor[3],
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              child: Container(
                color: _currentString == 'SYSTEM IS RUNNING OK'
                    ? Colors.grey[200]
                    : Colors.red, // Background color of the bar
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentString,
                      style: TextStyle(
                          fontSize: screenHeight / 23,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final StreamController<double> _purityController = StreamController<double>();
  final StreamController<double> _flowRateController =
      StreamController<double>();
  final StreamController<double> _pressureController =
      StreamController<double>();
  final StreamController<double> _temperatureController =
      StreamController<double>();

  ChartSeriesController? _purityChartController;
  ChartSeriesController? _flowRateChartController;
  ChartSeriesController? _pressureChartController;
  ChartSeriesController? _temperatureChartController;

  List<_ChartData> _purityData = [];
  List<_ChartData> _flowRateData = [];
  List<_ChartData> _pressureData = [];
  List<_ChartData> _temperatureData = [];

  final List<double> purityList = [];
  final List<double> flowRateList = [];
  final List<double> pressureList = [];
  final List<double> temperatureList = [];

  StreamSubscription<double>? _puritySubscription;
  StreamSubscription<double>? _flowRateSubscription;
  StreamSubscription<double>? _pressureSubscription;
  StreamSubscription<double>? _temperatureSubscription;

  double _latestPurity = 0.0;
  double _latestFlowRate = 0.0;
  double _latestPressure = 0.0;
  double _latestTemperature = 0.0;

  bool _isRunning = false;

  Future<void> getData() async {
    try {
      double purity = 80 + Random().nextInt(10).toDouble();
      double flowRate = 10 + Random().nextInt(10).toDouble();
      double pressure = 0 + Random().nextInt(20).toDouble();
      double temperature = 30 + Random().nextInt(10).toDouble();

      purityList.add(purity);
      flowRateList.add(flowRate);
      pressureList.add(pressure);
      temperatureList.add(temperature);
      // Store data in cache
      setState(() {
        _cache.add({
          'purity': purity,
          'flowRate': flowRate,
          'pressure': pressure,
          'temperature': temperature,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });

      _purityController.add(purity);
      _flowRateController.add(flowRate);
      _pressureController.add(pressure);
      _temperatureController.add(temperature);
    } catch (e, stackTrace) {
      print('Error parsing data: $e');
      print("error=> $stackTrace");
      // Handle the error appropriately
    }
  }
}

class _ChartData {
  _ChartData(this.time, this.value);
  final int time;
  final double value;
}
