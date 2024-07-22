import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:oxydata/LimitSetting.dart/flow_setting.dart';
import 'package:oxydata/LimitSetting.dart/pressure_setting.dart';
import 'package:oxydata/LimitSetting.dart/temp_setting.dart';
import 'package:oxydata/model/model.dart';
import 'package:oxydata/screens/report_screen.dart';
import 'package:oxydata/widgets/graph_report.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
//import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../Database/db/app_db.dart';
import '../LimitSettingDemo/Temp_demo.dart';
import '../LimitSettingDemo/flow_demo.dart';
import '../LimitSettingDemo/pressure_demo.dart';
import '../LimitSettingDemo/purity_demo.dart';
import '../LimitSetting.dart/purity_setting.dart';

import 'demo_report_screen.dart';

class LineCharWid extends StatefulWidget {
  const LineCharWid({Key? key}) : super(key: key);

  @override
  State<LineCharWid> createState() => _LineCharWidState();

  captureChartImage() {}
}

// class ChartData {
//   ChartData(this.x, this.y, this.type);

//   final double x;
//   final double y;
//   final String type;
// }

class _LineCharWidState extends State<LineCharWid> {
  final AppDb _db = AppDb();
  List<OxyData> oxydata = [];

  int? Purity_maxLimit;
  int? Purity_minLimit;
  int? Flow_maxLimit;
  int? Flow_minLimit;
  int? Pressure_maxLimit;
  int? Pressure_minLimit;
  int? Temp_maxLimit;
  int? Temp_minLimit;

  String? Purity_maxStr;
  String? Purity_minStr;
  String? flow_maxStr;
  String? flow_minStr;
  String? pressure_maxStr;
  String? pressure_minStr;
  String? temp_maxStr;
  String? temp_minStr;

  int secondsElapsed = 0;

  int _currentIndex = 0;
  String _currentString = 'SYSTEM IS RUNNING OK';
  Set<String> _uniqueStrings = {};
  List<String> _uniqueStringList = [];

  TextEditingController _remarkController = TextEditingController();

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
        MaterialPageRoute(builder: (context) => PuritySetting()),
      );
      if (result == 1) {
        _loadLimits();
      }
    } else if (index == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FlowSetting()),
      );
      if (result == 1) {
        _loadLimits();
      }
    } else if (index == 2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PressureSetting()),
      );
      if (result == 1) {
        _loadLimits();
      }
    } else if (index == 3) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TempSetting()),
      );
      if (result == 1) {
        _loadLimits();
      }
    }
  }

  late StreamController<void> _updateController;
  late StreamSubscription<void> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _loadLimits();
    _updateController = StreamController<void>.broadcast();

    _streamSubscription = _updateController.stream.listen((_) {
      _updateString();
    });
    if (_isRunning) return;
    Timer.periodic(Duration(seconds: 1), (timer) async {
      await getData();
      _updateController.add(null);
      secondsElapsed++;
      _updateCurrentString();
    });
    _isRunning = true;

    // Timer.periodic(const Duration(minutes: 1), (timer) {
    //   storeAverageData();
    // });

    _puritySubscription = _purityController.stream.listen((data) {
      setState(() {
        _purityData.add(_ChartData(secondsToTime(secondsElapsed), data));
        if (_purityData.length > 60) _purityData.removeAt(0);
        _latestPurity = data;
      });

      _updateDataSource();
    });
    _flowRateSubscription = _flowRateController.stream.listen((data) {
      setState(() {
        _flowRateData.add(_ChartData(secondsToTime(secondsElapsed), data));
        if (_flowRateData.length > 60) _flowRateData.removeAt(0);
        _latestFlowRate = data;
      });
      _updateDataSource();
    });
    _pressureSubscription = _pressureController.stream.listen((data) {
      setState(() {
        _pressureData.add(_ChartData(secondsToTime(secondsElapsed), data));
        if (_pressureData.length > 60) _pressureData.removeAt(0);
        _latestPressure = data;
      });
      _updateDataSource();
    });
    _temperatureSubscription = _temperatureController.stream.listen((data) {
      setState(() {
        _temperatureData.add(_ChartData(secondsToTime(secondsElapsed), data));
        if (_temperatureData.length > 60) _temperatureData.removeAt(0);
        _latestTemperature = data;
      });
      _updateDataSource();
    });
  }

  String secondsToTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
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

  Future<void> _loadLimits() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      Purity_maxStr = prefs.getString('purityMax') ?? '0';
      Purity_minStr = prefs.getString('purityMin') ?? '0';
      flow_maxStr = prefs.getString('flowMax') ?? '0';
      flow_minStr = prefs.getString('flowMin') ?? '0';
      pressure_maxStr = prefs.getString('pressureMax') ?? '0';
      pressure_minStr = prefs.getString('pressureMin') ?? '0';
      temp_maxStr = prefs.getString('tempMax') ?? '0';
      temp_minStr = prefs.getString('tempMin') ?? '0';

      Purity_maxLimit = int.tryParse(Purity_maxStr!) ?? 0;
      Purity_minLimit = int.tryParse(Purity_minStr!) ?? 0;
      Flow_maxLimit = int.tryParse(flow_maxStr!) ?? 0;
      Flow_minLimit = int.tryParse(flow_minStr!) ?? 0;
      Pressure_maxLimit = int.tryParse(pressure_maxStr!) ?? 0;
      Pressure_minLimit = int.tryParse(pressure_minStr!) ?? 0;
      Temp_maxLimit = int.tryParse(temp_maxStr!) ?? 0;
      Temp_minLimit = int.tryParse(temp_minStr!) ?? 0;
    });
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
      _addString("Purity is out of range");
    } else {
      _removeString("Purity is out of range");
    }

    if (_latestFlowRate > Flow_maxLimit! || _latestFlowRate < Flow_minLimit!) {
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

  Map<int, String> specialValues = {
    -333: 'Gas Not found',
    -11: 'Not Connected',
    -1111: 'Out of Range (Positive)',
    -1112: 'Out of Range (Negative)',
  };

  Map<int, Color> specialValueColors = {
    -333: Colors.red,
    -11: Colors.red,
    -1111: Colors.red,
    -1112: Colors.red,
  };
  @override
  Widget build(BuildContext context) {
    bool isDataAvailable = _purityData.isNotEmpty;
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
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                // Graph on the left
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.19,
                          child: SfCartesianChart(
                            plotAreaBorderWidth: 0,
                            // tooltipBehavior: TooltipBehavior(enable: true),
                            //  legend: Legend(isVisible: true),
                            primaryXAxis: CategoryAxis(
                              interval: 10,
                            ),
                            primaryYAxis: const NumericAxis(
                              axisLine: AxisLine(width: 0),
                              majorTickLines: MajorTickLines(size: 0),
                              title: AxisTitle(text: 'O₂%'),
                            ),
                            series: <LineSeries<_ChartData, String>>[
                              LineSeries<_ChartData, String>(
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
                                color: const Color.fromARGB(255, 0, 34, 145),
                                name: "Purity",
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.21,
                          child: SfCartesianChart(
                            plotAreaBorderWidth: 0,
                            // tooltipBehavior: TooltipBehavior(enable: true),
                            //  legend: Legend(isVisible: true),
                            primaryXAxis: CategoryAxis(
                              interval: 10,
                            ),
                            primaryYAxis: const NumericAxis(
                              axisLine: AxisLine(width: 0),
                              majorTickLines: MajorTickLines(size: 0),
                              title: AxisTitle(text: 'LPM'),
                            ),
                            series: <LineSeries<_ChartData, String>>[
                              LineSeries<_ChartData, String>(
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
                        Container(
                          height: MediaQuery.of(context).size.height * 0.21,
                          child: SfCartesianChart(
                            // plotAreaBorderWidth: 0,
                            //tooltipBehavior: TooltipBehavior(enable: true),
                            //  legend: Legend(isVisible: true),
                            primaryXAxis: CategoryAxis(
                              interval: 10,
                            ),
                            primaryYAxis: const NumericAxis(
                              axisLine: AxisLine(width: 0),
                              majorTickLines: MajorTickLines(size: 0),
                              title: AxisTitle(text: 'PSI'),
                            ),
                            series: <LineSeries<_ChartData, String>>[
                              LineSeries<_ChartData, String>(
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
                        Container(
                            height: MediaQuery.of(context).size.height * 0.21,
                            child: SfCartesianChart(
                              plotAreaBorderWidth: 0,
                              // tooltipBehavior: TooltipBehavior(enable: true),
                              //  legend: Legend(isVisible: true),
                              primaryXAxis: CategoryAxis(
                                interval: 10,
                              ),
                              primaryYAxis: const NumericAxis(
                                maximum: 50,
                                interval: 50,
                                axisLine: AxisLine(width: 0),
                                majorTickLines: MajorTickLines(size: 0),
                                title: AxisTitle(text: '°C'),
                              ),
                              series: <LineSeries<_ChartData, String>>[
                                LineSeries<_ChartData, String>(
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _navigateToDetailPage(0),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.313,
                                width: 115,
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
                                              if (_latestPurity
                                                      .toStringAsFixed(1) ==
                                                  '-333')
                                                Text(
                                                  'NC',
                                                  style: TextStyle(
                                                    color:
                                                        parameterTextColor[0],
                                                    fontSize: 38,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              if (_latestPurity
                                                      .toStringAsFixed(1) !=
                                                  '-333')
                                                Text(
                                                  _latestPurity
                                                      .toStringAsFixed(1),
                                                  style: TextStyle(
                                                    color:
                                                        parameterTextColor[0],
                                                    fontSize: 38,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              const SizedBox(width: 10),
                                              if (_latestPurity
                                                      .toStringAsFixed(1) !=
                                                  '-333')
                                                Text(
                                                  parameterUnit[0],
                                                  style: TextStyle(
                                                    color:
                                                        parameterTextColor[0],
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
                              onTap: () => _navigateToDetailPage(1),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.313,
                                width: 115,
                                child: Card(
                                  color: parameterColors[1],
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
                                            if (_latestFlowRate
                                                    .toStringAsFixed(1) ==
                                                '-333')
                                              Text(
                                                'NC',
                                                style: TextStyle(
                                                  color: parameterTextColor[0],
                                                  fontSize: 38,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            if (_latestFlowRate
                                                    .toStringAsFixed(1) !=
                                                '-333')
                                              Text(
                                                _latestFlowRate
                                                    .toStringAsFixed(1),
                                                style: TextStyle(
                                                  color: parameterTextColor[0],
                                                  fontSize: 38,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            const SizedBox(width: 10),
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
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _navigateToDetailPage(2),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.313,
                                width: 115,
                                child: Card(
                                  color: parameterColors[2],
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
                                            if (_latestPressure
                                                    .toStringAsFixed(1) ==
                                                '-333')
                                              Text(
                                                'NC',
                                                style: TextStyle(
                                                  color: parameterTextColor[2],
                                                  fontSize: 38,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            if (_latestPressure
                                                    .toStringAsFixed(1) !=
                                                '-333')
                                              Text(
                                                _latestPressure
                                                    .toStringAsFixed(1),
                                                style: TextStyle(
                                                  color: parameterTextColor[2],
                                                  fontSize: 38,
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
                              onTap: () => _navigateToDetailPage(3),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.313,
                                width: 115,
                                child: Card(
                                  color: parameterColors[3],
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
                                            if (_latestTemperature
                                                    .toStringAsFixed(1) ==
                                                '-333')
                                              Text(
                                                'NC',
                                                style: TextStyle(
                                                  color: parameterTextColor[3],
                                                  fontSize: 38,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            if (_latestTemperature
                                                    .toStringAsFixed(1) !=
                                                '-333')
                                              Text(
                                                _latestTemperature
                                                    .toStringAsFixed(1),
                                                style: TextStyle(
                                                  color: parameterTextColor[3],
                                                  fontSize: 38,
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
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReportScreen()));
                              },
                              child: Text("Setting"),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.06,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                _showRemarkDialog();
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            child: Container(
              height: 20,
              color: _currentString == 'SYSTEM IS RUNNING OK'
                  ? Colors.grey[200]
                  : Colors.red, // Background color of the bar
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentString,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
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
  // Future<void> getdata() async {
  //   var url = Uri.parse('http://192.168.4.1/getdata');
  //   // final response = await http.get(url);

  //   try {
  //     final response = await http.get(Uri.parse(url.toString()));
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = jsonDecode(response.body);

  //       if (data.isNotEmpty) {
  //         Map<String, dynamic> jsonData = data[0];
  //         _purityController.add(double.tryParse(jsonData['Purity']) ?? 0.0);
  //         _flowRateController
  //             .add(double.tryParse(jsonData['Flow_Rate']) ?? 0.0);
  //         _pressureController.add(double.tryParse(jsonData['Pressure']) ?? 0.0);
  //         _temperatureController
  //             .add(double.tryParse(jsonData['Temperature']) ?? 0.0);

  //         _puritySubscription = _purityController.stream.listen((data) {
  //           setState(() {
  //             _purityData.add(data);
  //             if (_purityData.length > 20) _purityData.removeAt(0);
  //           });
  //         });
  //         _flowRateSubscription = _flowRateController.stream.listen((data) {
  //           setState(() {
  //             _flowRateData.add(data);
  //             if (_flowRateData.length > 20) _flowRateData.removeAt(0);
  //           });
  //         });
  //         _pressureSubscription = _pressureController.stream.listen((data) {
  //           setState(() {
  //             _pressureData.add(data);
  //             if (_pressureData.length > 20) _pressureData.removeAt(0);
  //           });
  //         });

  //         _temperatureSubscription =
  //             _temperatureController.stream.listen((data) {
  //           setState(() {
  //             _temperatureData.add(data);
  //             if (_temperatureData.length > 20) _temperatureData.removeAt(0);
  //           });
  //         });
  //         setState(() {
  //           // _purityData.add(
  //           //     _ChartData(now, double.tryParse(jsonData['Purity']) ?? 0.0));
  //           // _flowRateData.add(
  //           //     _ChartData(now, double.tryParse(jsonData['Flow_Rate']) ?? 0.0));
  //           // _pressureData.add(
  //           //     _ChartData(now, double.tryParse(jsonData['Pressure']) ?? 0.0));
  //           // _temperatureData.add(_ChartData(
  //           //     now, double.tryParse(jsonData['Temperature']) ?? 0.0));

  //           if (_purityData.isNotEmpty) {
  //             if (_purityData.length > 20) _purityData.removeAt(0);
  //           }
  //           if (_flowRateData.isNotEmpty) {
  //             if (_flowRateData.length > 20) _flowRateData.removeAt(0);
  //           }
  //           if (_pressureData.isNotEmpty) {
  //             if (_pressureData.length > 20) _pressureData.removeAt(0);
  //           }

  //           if (_purityData.isNotEmpty && _purityChartController != null) {
  //             _purityChartController?.updateDataSource(
  //               addedDataIndex: _purityData.length - 1,
  //               removedDataIndex: 0,
  //             );
  //           }
  //           if (_flowRateData.isNotEmpty && _flowRateChartController != null) {
  //             _flowRateChartController?.updateDataSource(
  //               addedDataIndex: _flowRateData.length - 1,
  //               removedDataIndex: 0,
  //             );
  //           }

  //           if (_pressureData.isNotEmpty && _pressureChartController != null) {
  //             _pressureChartController?.updateDataSource(
  //               addedDataIndex: _pressureData.length - 1,
  //               removedDataIndex: 0,
  //             );
  //           }

  //           if (_temperatureData.isNotEmpty &&
  //               _temperatureChartController != null) {
  //             _temperatureChartController?.updateDataSource(
  //               addedDataIndex: _temperatureData.length - 1,
  //               removedDataIndex: 0,
  //             );
  //           }
  //         });
  //       }
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   }

  //   await Future.delayed(Duration(seconds: 1));
  // }
  String? _serialNo;
  bool _isRunning = false;
  List<Map<String, dynamic>> _cache = [];

  Future<void> getData() async {
    var url = Uri.parse('http://192.168.4.1/getdata');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          Map<String, dynamic> jsonData = data[0];
          double purity = double.tryParse(jsonData['Purity'] ?? '0.0')! / 10.0;
          double flowRate =
              double.tryParse(jsonData['Flow_Rate'] ?? '0.0')! / 10.0;
          double pressure =
              double.tryParse(jsonData['Pressure'] ?? '0.0')! / 10.0;
          double temperature =
              double.tryParse(jsonData['Temperature'] ?? '0.0')! / 10.0;
          _serialNo = jsonData['serialNo'] ?? '';

          purityList.add(purity);
          flowRateList.add(flowRate);
          pressureList.add(pressure);
          temperatureList.add(temperature);

          // Store data in cache
          setState(() {
            _cache.add({
              'purity': purity,
              'flowRate': flowRate * 10.0,
              'pressure': pressure,
              'temperature': temperature * 2.0,
              'timestamp': DateTime.now().toIso8601String(),
            });
          });

          printStoredData();
          // Add data to stream controllers
          _purityController.add(purity);
          _flowRateController.add(flowRate);
          _pressureController.add(pressure);
          _temperatureController.add(temperature);
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e, stackTrace) {
      print('Error parsing data: $e');
      print("error=> $stackTrace");
      // Handle the error appropriately
    }
  }

  Future<void> printStoredData() async {
    // print("hii");
    // List<OxyDatabaseData> storedData = await _db.getAllOxyData();
    // for (var data in storedData) {
    //   print(
    //       'ID: ${data.id}, Purity: ${data.purity}, Flow Rate: ${data.flow}, Pressure: ${data.pressure}, Temperature: ${data.temp}, Serial No: ${data.serialNo}, DateTime: ${data.recordedAt}');
    // }

    print('Stored Data: ${_cache.length}');
  }

  Future<void> storeAverageData() async {
    print("hiiii");
    if (purityList.isNotEmpty &&
        flowRateList.isNotEmpty &&
        pressureList.isNotEmpty &&
        temperatureList.isNotEmpty) {
      double averagePurity =
          purityList.reduce((a, b) => a + b) / purityList.length;
      double averageFlowRate =
          flowRateList.reduce((a, b) => a + b) / flowRateList.length;
      double averagePressure =
          pressureList.reduce((a, b) => a + b) / pressureList.length;
      double averageTemperature =
          temperatureList.reduce((a, b) => a + b) / temperatureList.length;

      String? serialNo =
          _serialNo; // You need to fetch the actual serial number
      DateTime dateTime = DateTime.now();

      final entity = OxyDatabaseCompanion(
        purity: drift.Value(averagePurity),
        flow: drift.Value(averageFlowRate),
        pressure: drift.Value(averagePressure),
        temp: drift.Value(averageTemperature),
        serialNo: drift.Value(serialNo!),
        recordedAt: drift.Value(dateTime),
      );
      // print(
      //     'Print before store:  Purity: ${averagePurity}, Flow Rate: ${averageFlowRate}, Pressure: ${averagePressure}, Temperature: ${averageTemperature}, Serial No: ${serialNo!}, DateTime: ${dateTime}');
      // await _db.insertOxyData(entity);
      await printStoredData();

      // Clear the lists after storing data
      purityList.clear();
      flowRateList.clear();
      pressureList.clear();
      temperatureList.clear();
    }
  }

  void _showRemarkDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(12.0),
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _remarkController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Add Remarks...',
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                              ),
                            ),
                            SizedBox(width: 10),
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              child: Text('Submit'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GraphReport(
                                            data: _cache,
                                            remark: _remarkController.text)));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChartData {
  _ChartData(this.time, this.value);
  final String time;
  final double value;
}
