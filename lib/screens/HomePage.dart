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
import 'package:oxydata/Report_screens/current_report.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
//import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

import '../Database/db/app_db.dart';
import '../LimitSetting.dart/api_service.dart';
import '../LimitSetting.dart/min_max_data.dart';
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
  List<OxyData> oxydata = [];

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

  int secondsElapsed = 0;

  int _currentIndex = 0;
  String _currentString = 'SYSTEM IS RUNNING OK';
  Set<String> _uniqueStrings = {};
  List<String> _uniqueStringList = [];

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
    bool isLoading = false;
    setState(() {
      isLoading = true;
    });
    if (index == 0) {
      var minMax = await setMinMax("O2");
      if (minMax != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PuritySetting(
              max: minMax.item1,
              min: minMax.item2,
            ),
          ),
        );

        if (result == 1) {
          _loadLimits();
        }
      }
    } else if (index == 1) {
      var minMax = await setMinMax("Flow");
      if (minMax != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlowSetting(
              max: minMax.item1,
              min: minMax.item2,
            ),
          ),
        );

        if (result == 1) {
          _loadLimits();
        }
      }
    } else if (index == 2) {
      var minMax = await setMinMax("Pr");
      if (minMax != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PressureSetting(
              max: minMax.item1,
              min: minMax.item2,
            ),
          ),
        );

        if (result == 1) {
          _loadLimits();
        }
      }
    } else if (index == 3) {
      var minMax = await setMinMax("Temp");
      if (minMax != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TempSetting(
              max: minMax.item1,
              min: minMax.item2,
            ),
          ),
        );

        if (result == 1) {
          _loadLimits();
        }
      }
    }
  }

  late StreamController<void> _updateController;
  late StreamSubscription<void> _streamSubscription;

  @override
  void initState() {
    super.initState();

    _saveLimits();

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

    Timer.periodic(const Duration(minutes: 1), (timer) {
      storeAverageData();
    });

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

  Future<Tuple2<int, int>?> setMinMax(String gasName) async {
    final data = await ApiService.fetchMinMaxData();
    switch (gasName) {
      case "O2":
        return Tuple2(int.parse(data.o2Max), int.parse(data.o2Min));

      case "Flow":
        print("Valeu Of MinMAx  ==> F ${data.flowMax}");
        return Tuple2(int.parse(data.flowMax), int.parse(data.flowMin));

      case "Pr":
        return Tuple2(int.parse(data.pressureMax), int.parse(data.pressureMin));

      case "Temp":
        return Tuple2(
            int.parse(data.temperatureMax), int.parse(data.temperatureMin));
      default:
        return null;
    }
  }

  Future<void> _saveLimits() async {
    MinMaxData data = await ApiService.fetchMinMaxData();

    final prefs = await SharedPreferences.getInstance();
    final _db = await AppDbSingleton().database;
    await _loadLimits();

    print(
        "Purity maxxxlimit ===> ${(Purity_maxLimit! * 10.0).toString()}    ${data.o2Max}");
    print(
        "Pressure maxxxlimit ===> ${(Pressure_maxLimit! * 10.0).toString()}    ${data.pressureMax}");
    if ((Purity_maxLimit! * 10.0).toStringAsFixed(0) != data.o2Max &&
        (Purity_minLimit! * 10.0).toStringAsFixed(0) != data.o2Min) {
      print(
          "Purity maxxxlimit ===> ${(Purity_maxLimit! * 10.0).toString()}    ${data.o2Max}");
      await _db.insertLimitSetting(LimitSettingsTableCompanion(
        limit_max: drift.Value(double.tryParse(data.o2Max)! / 10.0),
        limit_min: drift.Value(double.tryParse(data.o2Min)! / 10.0),
        type: drift.Value("Purity"),
        serialNo: drift.Value(data.serialNo),
        recordedAt: drift.Value(DateTime.now()),
      ));
      await prefs.setDouble('purityMax', double.tryParse(data.o2Max)! / 10.0);
      await prefs.setDouble('purityMin', double.tryParse(data.o2Min)! / 10.0);

      List<LimitSettingsTableData> storedData = await _db.getAllLimitSettings();
      print("Storedddd data =>   $storedData");
    }

    if ((Flow_maxLimit! * 10.0).toStringAsFixed(0) != data.flowMax &&
        (Flow_minLimit! * 10.0).toStringAsFixed(0) != data.flowMin) {
      await _db.insertLimitSetting(LimitSettingsTableCompanion(
        limit_max: drift.Value(double.tryParse(data.flowMax)! / 10.0),
        limit_min: drift.Value(double.tryParse(data.flowMin)! / 10.0),
        type: drift.Value("Flow"),
        serialNo: drift.Value(data.serialNo),
        recordedAt: drift.Value(DateTime.now()),
      ));
      await prefs.setDouble('flowMax', double.tryParse(data.flowMax)! / 10.0);
      await prefs.setDouble('flowMin', double.tryParse(data.flowMin)! / 10.0);

      List<LimitSettingsTableData> storedData = await _db.getAllLimitSettings();
      print("Storedddd data =>   $storedData");
    }
    print(
        "Pressure maxxxlimit ===> ${(Pressure_maxLimit! * 10.0).toString()}    ${data.pressureMax}");
    if ((Pressure_maxLimit! * 10.0).toStringAsFixed(0) != data.pressureMax &&
        (Pressure_minLimit! * 10.0).toStringAsFixed(0) != data.pressureMin) {
      await _db.insertLimitSetting(LimitSettingsTableCompanion(
        limit_max: drift.Value(double.tryParse(data.pressureMax)! / 10.0),
        limit_min: drift.Value(double.tryParse(data.pressureMin)! / 10.0),
        type: drift.Value("Pressure"),
        serialNo: drift.Value(data.serialNo),
        recordedAt: drift.Value(DateTime.now()),
      ));
      await prefs.setDouble(
          'pressureMax', double.tryParse(data.pressureMax)! / 10.0);
      await prefs.setDouble(
          'pressureMin', double.tryParse(data.pressureMin)! / 10.0);

      List<LimitSettingsTableData> storedData = await _db.getAllLimitSettings();
      print("Storedddd data =>   $storedData");
    }
    print(
        "Temp maxxxlimit ===> ${(Temp_maxLimit! * 10.0).toString()}    ${data.temperatureMax}");
    if ((Temp_maxLimit! * 10.0).toStringAsFixed(0) != data.temperatureMax &&
        (Temp_minLimit! * 10.0).toStringAsFixed(0) != data.temperatureMin) {
      print(
          "Temp maxxxlimit ===> ${(Temp_maxLimit! * 10.0).toString()}    ${data.temperatureMax}");
      await _db.insertLimitSetting(LimitSettingsTableCompanion(
        limit_max: drift.Value(double.tryParse(data.temperatureMax)! / 10.0),
        limit_min: drift.Value(double.tryParse(data.temperatureMin)! / 10.0),
        type: drift.Value("Temperature"),
        serialNo: drift.Value(data.serialNo),
        recordedAt: drift.Value(DateTime.now()),
      ));
      print(
          "Temp maxxxlimit ===> ${(Temp_maxLimit! * 10.0).toString()}    ${data.temperatureMax}");
      await prefs.setDouble(
          'tempMax', double.tryParse(data.temperatureMax)! / 10.0);
      await prefs.setDouble(
          'tempMin', double.tryParse(data.temperatureMin)! / 10.0);
      print(
          "Temp maxxxlimit ===> ${(Temp_maxLimit! * 10.0).toString()}    ${data.temperatureMax}");
      List<LimitSettingsTableData> storedData = await _db.getAllLimitSettings();
      print("Storedddd data =>   $storedData");
    }

    await prefs.setString('serialNo', data.serialNo);
    await prefs.setString('locationName', data.locationName);

    List<LimitSettingsTableData> storedData = await _db.getAllLimitSettings();
    print("Storedddd data =>   $storedData");
    _loadLimits();
  }

  Future<void> _loadLimits() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      setState(() {
        print("jijijijiji - > ${prefs.get("purityMax")}");
        Purity_maxLimit = prefs.getDouble("purityMax") ?? -1.0;

        Purity_minLimit = prefs.getDouble("purityMin") ?? -1.0;
        Flow_maxLimit = prefs.getDouble("flowMax") ?? -1.0;
        print("Flow max Load: $Flow_maxLimit");
        Flow_minLimit = prefs.getDouble("flowMin") ?? -1.0;
        Pressure_maxLimit = prefs.getDouble("pressureMax") ?? -1.0;
        Pressure_minLimit = prefs.getDouble("pressureMin") ?? -1.0;
        Temp_maxLimit = prefs.getDouble("tempMax") ?? -1.0;
        Temp_minLimit = prefs.getDouble("tempMin") ?? -1.0;
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

  void _storeAlarm(
      double value, double limitmax, double limitmin, String type) async {
    final _db = await AppDbSingleton().database;
    final entity = AlarmTableCompanion(
      value: drift.Value(value),
      limitmax: drift.Value(limitmax),
      limitmin: drift.Value(limitmin),
      type: drift.Value(type),
      serialNo: drift.Value(_serialNo!),
      recordedAt: drift.Value(DateTime.now()),
    );

    await _db.insertAlarm(entity);
    List<AlarmTableData> storedData = await _db.getAllAlarms();
    print(storedData);
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
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        // Expanded(
                        //   flex: 1,
                        //   child: Container(
                        //     //  height: screenHeight * 0.20,
                        //     child: SfCartesianChart(
                        //       plotAreaBorderWidth: 0,
                        //       // tooltipBehavior: TooltipBehavior(enable: true),
                        //       //  legend: Legend(isVisible: true),
                        //       primaryXAxis: CategoryAxis(
                        //         interval: 10,
                        //       ),
                        //       primaryYAxis: const NumericAxis(
                        //         axisLine: AxisLine(width: 0),
                        //         majorTickLines: MajorTickLines(size: 0),
                        //         title: AxisTitle(text: 'O₂%'),
                        //       ),
                        //       series: <LineSeries<_ChartData, String>>[
                        //         LineSeries<_ChartData, String>(
                        //           onRendererCreated:
                        //               (ChartSeriesController controller) {
                        //             _purityChartController = controller;
                        //           },
                        //           dataSource: _purityData,

                        //           xValueMapper: (_ChartData press, _) =>
                        //               press.time,
                        //           yValueMapper: (_ChartData press, _) =>
                        //               press.value,
                        //           //  markerSettings: const MarkerSettings(isVisible: true),
                        //           color: const Color.fromARGB(255, 0, 34, 145),
                        //           name: "Purity",
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            // height: MediaQuery.of(context).size.height * 0.21,
                            child: SfCartesianChart(
                              plotAreaBorderWidth: 0,
                              // tooltipBehavior: TooltipBehavior(enable: true),
                              //  legend: Legend(isVisible: true),
                              primaryXAxis: CategoryAxis(
                                interval: 10,
                              ),
                              primaryYAxis: const NumericAxis(
                                maximum: 100,
                                interval: 20,
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
                        ),
                        // Expanded(
                        //   flex: 1,
                        //   child: Container(
                        //     //  height: MediaQuery.of(context).size.height * 0.21,
                        //     child: SfCartesianChart(
                        //       // plotAreaBorderWidth: 0,
                        //       //tooltipBehavior: TooltipBehavior(enable: true),
                        //       //  legend: Legend(isVisible: true),
                        //       primaryXAxis: CategoryAxis(
                        //         interval: 10,
                        //       ),
                        //       primaryYAxis: const NumericAxis(
                        //         maximum: 40,
                        //         interval: 20,
                        //         axisLine: AxisLine(width: 0),
                        //         majorTickLines: MajorTickLines(size: 0),
                        //         title: AxisTitle(text: 'PSI'),
                        //       ),
                        //       series: <LineSeries<_ChartData, String>>[
                        //         LineSeries<_ChartData, String>(
                        //           onRendererCreated:
                        //               (ChartSeriesController controller) {
                        //             _pressureChartController = controller;
                        //           },
                        //           dataSource: _pressureData,
                        //           xValueMapper: (_ChartData press, _) =>
                        //               press.time,
                        //           yValueMapper: (_ChartData press, _) =>
                        //               press.value,
                        //           //markerSettings: const MarkerSettings(isVisible: true),
                        //           color: const Color.fromARGB(255, 195, 0, 0),

                        //           name: "Pressure",
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // Expanded(
                        //   flex: 1,
                        //   child: Container(
                        //       // height: MediaQuery.of(context).size.height * 0.21,
                        //       child: SfCartesianChart(
                        //     plotAreaBorderWidth: 0,
                        //     // tooltipBehavior: TooltipBehavior(enable: true),
                        //     //  legend: Legend(isVisible: true),
                        //     primaryXAxis: CategoryAxis(
                        //       interval: 10,
                        //     ),
                        //     primaryYAxis: const NumericAxis(
                        //       maximum: 50,
                        //       interval: 25,
                        //       axisLine: AxisLine(width: 0),
                        //       majorTickLines: MajorTickLines(size: 0),
                        //       title: AxisTitle(text: '°C'),
                        //     ),
                        //     series: <LineSeries<_ChartData, String>>[
                        //       LineSeries<_ChartData, String>(
                        //         onRendererCreated:
                        //             (ChartSeriesController controller) {
                        //           _temperatureChartController = controller;
                        //         },
                        //         dataSource: _temperatureData,
                        //         xValueMapper: (data, _) => data.time,
                        //         yValueMapper: (data, _) => data.value,
                        //         //markerSettings: const MarkerSettings(isVisible: true),
                        //         color: Color.fromARGB(255, 44, 238, 144),
                        //         name: "Temp",
                        //       ),
                        //     ],
                        //   )),
                        // ),
                      ],
                    ),
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
                            onTap: () async {
                              final db = await AppDbSingleton().database;
                              await db.deleteAllLimitSettings();
                              // await db.customUpdate(
                              //     'DELETE FROM sqlite_sequence WHERE name = "limit_settings_table";');
                              print("All limit settings have been deleted.");
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
                                          ReportScreen(data: _cache)));
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

  String? _serialNo;
  bool _isRunning = false;
  List<Map<String, dynamic>> _cache = [];

  Future<void> getData() async {
    print("Max purity: ${Purity_maxLimit}");
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
              'flowRate': flowRate,
              'pressure': pressure,
              'temperature': temperature,
              'timestamp': DateTime.now().toIso8601String(),
            });
          });

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
    final _db = await AppDbSingleton().database;
    List<OxyDatabaseData> storedData = await _db.getAllOxyData();
    for (var data in storedData) {
      print(
          'ID: ${data.id}, Purity: ${data.purity}, Flow Rate: ${data.flow}, Pressure: ${data.pressure}, Temperature: ${data.temp}, Serial No: ${data.serialNo}, DateTime: ${data.recordedAt}');
    }

    print('Stored Data: ${_cache.length}');
  }

  Future<void> storeAverageData() async {
    final _db = await AppDbSingleton().database;
    String? serialNo = _serialNo;
    DateTime dateTime = DateTime.now();
    var url_1m = Uri.parse('http://192.168.4.1/getdata_1m');
    try {
      final response = await http.get(url_1m);
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

          final entity = OxyDatabaseCompanion(
            purity: drift.Value(purity),
            flow: drift.Value(flowRate),
            pressure: drift.Value(pressure),
            temp: drift.Value(temperature),
            serialNo: drift.Value(serialNo!),
            recordedAt: drift.Value(dateTime),
          );

          await _db.insertOxyData(entity);
          printStoredData();
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
}

class _ChartData {
  _ChartData(this.time, this.value);
  final String time;
  final double value;
}
