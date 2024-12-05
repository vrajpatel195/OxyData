// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:http/http.dart' as http;

import 'package:oxydata/LimitSetting.dart/flow_setting.dart';
import 'package:oxydata/LimitSetting.dart/pressure_setting.dart';
import 'package:oxydata/LimitSetting.dart/temp_setting.dart';
import 'package:oxydata/model/model.dart';
import 'package:oxydata/Report_screens/report_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
//import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:tuple/tuple.dart';

import '../Database/db/app_db.dart';
import '../LimitSetting.dart/api_service.dart';
import '../LimitSetting.dart/min_max_data.dart';

import '../LimitSetting.dart/purity_setting.dart';
import '../Services/mqtt_connect.dart';
import '../widgets/editDetailsDialog.dart';

class LineCharWid extends StatefulWidget {
  // ignore: use_super_parameters
  LineCharWid({Key? key, required this.isInternet, this.mqttService})
      : super(key: key);
  int isInternet;
  final MqttService? mqttService;
  @override
  State<LineCharWid> createState() => _LineCharWidState();

  captureChartImage() {}
}

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

  DateTime? appStartTime;
  bool isMuted1 = true;
  int time = 0;

  bool purityAlarmTriggered = false;
  bool pressureAlarmTriggered = false;
  bool flowAlarmTriggered = false;
  bool tempAlarmTriggered = false;
  int _currentIndex = 0;
  String _currentString = 'SYSTEM IS RUNNING OK';
  final Set<String> _uniqueStrings = {};
  List<String> _uniqueStringList = [];
  final AudioPlayer bgAudio = AudioPlayer();

  late MqttService mqttService;
  int internet = 1;
  double _maxYAxisValue = 10; // Default value
  double _intervalYAxisValue = 2.5; // Default value
  String mqttPayload = " ";
  List<Map<String, dynamic>> _alarmCache = [];

  // final StreamController<List<ChartData>> _streamController =
  //     StreamController<List<ChartData>>.broadcast();

  // Fixed color map for predefined types
  final Map<String, Color> colorMap = {
    'purity': const Color.fromARGB(255, 0, 34, 145),
    'flow': const Color.fromARGB(182, 241, 193, 48),
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
      print("dscsiudcsujhgbvcs : $mqttPayload");
      var minMax = await setMinMax("O2");
      if (minMax != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PuritySetting(
              max: minMax.item1,
              min: minMax.item2,
              isInternet: widget.isInternet,
            ),
          ),
        );

        if (result == 1) {
          if (widget.isInternet == 2) {
            await mqttService.publishPuritySettings(_serialNo);
          }

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
              isInternet: widget.isInternet,
            ),
          ),
        );

        if (result == 1) {
          if (widget.isInternet == 2) {
            await mqttService.publishPuritySettings(_serialNo);
          }
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
              isInternet: widget.isInternet,
            ),
          ),
        );

        if (result == 1) {
          if (widget.isInternet == 2) {
            await mqttService.publishPuritySettings(_serialNo);
          }
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
              isInternet: widget.isInternet,
            ),
          ),
        );

        if (result == 1) {
          if (widget.isInternet == 2) {
            await mqttService.publishPuritySettings(_serialNo);
          }
          _loadLimits();
        }
      }
    }
  }

  void _showEditDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDetailsDialog();
      },
    );
  }

  late StreamController<void> _updateController;
  late StreamSubscription<void> _streamSubscription;

  @override
  void initState() {
    super.initState();
    appStartTime = DateTime.now();
    if (widget.isInternet == 3) _saveLimits();
    _initialData();
    loadMuteState();
    if (widget.isInternet == 2) {
      mqttService = widget.mqttService!;

      mqttService.messageStream.listen((message) {
        getMqttdata(message);
        _loadLimits();
      });
    }

    _updateController = StreamController<void>.broadcast();

    if (_isRunning) return;
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (widget.isInternet == 3) {
        await _saveLimits();
        await getData();
      }

      _updateController.add(null);
      time++;
      _updateCurrentString();
    });
    _isRunning = true;
    if (widget.isInternet == 3) {
      Timer.periodic(const Duration(minutes: 1), (timer) {
        storeAverageData();
      });
    }
    _getLPMValuesWithDelay(_serialNo);

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

    _streamSubscription = _updateController.stream.listen((_) {
      if (_latestPurity != null &&
          _latestFlowRate != null &&
          _latestPressure != null &&
          _latestTemperature != null) {
        _updateString();
      }
    });
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

  Future<void> _getLPMValuesWithDelay(String serialNo) async {
    // Introduce a 3-second delay

    // After the delay, update the state with new values
    setState(() {
      _maxYAxisValue = _getLPMYAxisMaxValue(serialNo);
      _intervalYAxisValue = _getLPMYAxisIntervalValue(serialNo);
    });
  }

  void _initialData() async {
    _purityData.add(_ChartData(60, -1));
    _pressureData.add(_ChartData(60, -1));
    _flowRateData.add(_ChartData(60, -1));
    _temperatureData.add(_ChartData(60, -1));
    _purityData.add(_ChartData(0, -1));
    _pressureData.add(_ChartData(0, -1));
    _flowRateData.add(_ChartData(0, -1));
    _temperatureData.add(_ChartData(0, -1));
  }

  String topic2Payload = '';

  Future<Tuple2<double, double>?> setMinMax(String gasName) async {
    Map<String, dynamic> jsonData;
    print("internettdfg: ${widget.isInternet}");
    if (widget.isInternet == 2) {
      mqttService.subscribeToTopic2(_serialNo);
      topic2Payload = widget.mqttService!.topic2Payload;
      try {
        jsonData = jsonDecode(topic2Payload);
        print("min max jsondata: $jsonData");
      } catch (e) {
        print('Error parsing topic2Payload: $e');
        return null;
      }
    } else {
      final data = await ApiService.fetchMinMaxData();
      // Map the fetched data to a similar structure for consistency
      jsonData = {
        'o2_min': data.o2Min,
        'o2_max': data.o2Max,
        'flow_min': data.flowMin,
        'flow_max': data.flowMax,
        'temperature_min': data.temperatureMin,
        'temperature_max': data.temperatureMax,
        'pressure_min': data.pressureMin,
        'pressure_max': data.pressureMax
      };
    }

    // Switch statement to return min and max values for the requested gas
    switch (gasName) {
      case "O2":
        return Tuple2(double.parse(jsonData['o2_max'].toString()),
            double.parse(jsonData['o2_min'].toString()));

      case "Flow":
        return Tuple2(double.parse(jsonData['flow_max'].toString()),
            double.parse(jsonData['flow_min'].toString()));

      case "Pr":
        return Tuple2(double.parse(jsonData['pressure_max'].toString()),
            double.parse(jsonData['pressure_min'].toString()));

      case "Temp":
        return Tuple2(double.parse(jsonData['temperature_max'].toString()),
            double.parse(jsonData['temperature_min'].toString()));

      default:
        return null;
    }
  }

  Future<void> _saveLimits() async {
    MinMaxData data = await ApiService.fetchMinMaxData();

    final prefs = await SharedPreferences.getInstance();
    final db = await AppDbSingleton().database;
    await _loadLimits();

    if ((Purity_maxLimit!).toString() != data.o2Max ||
        (Purity_minLimit!).toString() != data.o2Min) {
      try {
        await db.insertLimitSetting(LimitSettingsTableCompanion(
          limit_max: drift.Value(double.tryParse(data.o2Max)!),
          limit_min: drift.Value(double.tryParse(data.o2Min)!),
          type: const drift.Value("Purity"),
          serialNo: drift.Value(data.serialNo),
          recordedAt: drift.Value(DateTime.now()),
        ));
      } catch (e) {
        print("Error while saving data $e");
      }

      await prefs.setDouble('purityMax', double.tryParse(data.o2Max)!);
      await prefs.setDouble('purityMin', double.tryParse(data.o2Min)!);
    }

    if ((Flow_maxLimit!).toString() != data.flowMax ||
        (Flow_minLimit!).toString() != data.flowMin) {
      await db.insertLimitSetting(LimitSettingsTableCompanion(
        limit_max: drift.Value(double.tryParse(data.flowMax)!),
        limit_min: drift.Value(double.tryParse(data.flowMin)!),
        type: const drift.Value("Flow"),
        serialNo: drift.Value(data.serialNo),
        recordedAt: drift.Value(DateTime.now()),
      ));
      await prefs.setDouble('flowMax', double.tryParse(data.flowMax)!);
      await prefs.setDouble('flowMin', double.tryParse(data.flowMin)!);
    }

    if ((Pressure_maxLimit!).toString() != data.pressureMax ||
        (Pressure_minLimit!).toString() != data.pressureMin) {
      await db.insertLimitSetting(LimitSettingsTableCompanion(
        limit_max: drift.Value(double.tryParse(data.pressureMax)!),
        limit_min: drift.Value(double.tryParse(data.pressureMin)!),
        type: const drift.Value("Pressure"),
        serialNo: drift.Value(data.serialNo),
        recordedAt: drift.Value(DateTime.now()),
      ));
      await prefs.setDouble('pressureMax', double.tryParse(data.pressureMax)!);
      await prefs.setDouble('pressureMin', double.tryParse(data.pressureMin)!);
    }

    if ((Temp_maxLimit!).toString() != data.temperatureMax ||
        (Temp_minLimit!).toString() != data.temperatureMin) {
      await db.insertLimitSetting(LimitSettingsTableCompanion(
        limit_max: drift.Value(double.tryParse(data.temperatureMax)!),
        limit_min: drift.Value(double.tryParse(data.temperatureMin)!),
        type: const drift.Value("Temperature"),
        serialNo: drift.Value(data.serialNo),
        recordedAt: drift.Value(DateTime.now()),
      ));

      await prefs.setDouble('tempMax', double.tryParse(data.temperatureMax)!);
      await prefs.setDouble('tempMin', double.tryParse(data.temperatureMin)!);
    }

    await prefs.setString('serialNo', data.serialNo);
    await prefs.setString('locationName', data.locationName);

    await _loadLimits();
  }

  Future<void> _loadLimits() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      setState(() {
        Purity_maxLimit = prefs.getDouble("purityMax") ?? -1.0;

        Purity_minLimit = prefs.getDouble("purityMin") ?? -1.0;
        Flow_maxLimit = prefs.getDouble("flowMax") ?? -1.0;

        Flow_minLimit = prefs.getDouble("flowMin") ?? -1.0;
        Pressure_maxLimit = prefs.getDouble("pressureMax") ?? -1.0;
        Pressure_minLimit = prefs.getDouble("pressureMin") ?? -1.0;
        Temp_maxLimit = prefs.getDouble("tempMax") ?? -1.0;
        Temp_minLimit = prefs.getDouble("tempMin") ?? -1.0;
      });
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

  void _updateString() async {
    final db = await AppDbSingleton().database;
    final prefs = await SharedPreferences.getInstance();
    _serialNo = await prefs.getString('serialNo') ?? '';
    if ((_latestPurity! > Purity_maxLimit! ||
        _latestPurity! < Purity_minLimit!)) {
      // print("Purity max: $Purity_maxLimit");
      print("Store Alarmsdfcsfv: $_latestPurity");
      if (!purityAlarmTriggered) {
        if (widget.isInternet == 3) {
          try {
            db.insertAlarm(AlarmTableCompanion(
              value: drift.Value(_latestPurity!),
              limitmax: drift.Value(Purity_maxLimit!),
              limitmin: drift.Value(Purity_minLimit!),
              type: drift.Value("Purity"),
              serialNo: drift.Value(_serialNo),
              recordedAt: drift.Value(DateTime.now()),
            ));
            prefs.setDouble("PurityP", _latestPurity!);
            List<AlarmTableData> storedData = await db.getAllAlarms();

            print("Store Alarms: $_latestPurity");
          } catch (e) {
            print("Error to store alarms : $e");
          }
        }
        purityAlarmTriggered = true;

        _alarmCache.add({
          'Alarms': _latestPurity!,
          'limitmax': Purity_maxLimit!,
          'limitmin': Purity_minLimit!,
          'type': "Purity",
          'serialNo': _serialNo,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      if (_latestPurity! > Purity_maxLimit!) {
        _addString("Purity is Higher than Set Limit");
      } else {
        _addString("Purity is Lower than Set Limit");
      }
    } else if (_latestPurity! >= Purity_minLimit! + 1.0 &&
        _latestPurity! <= Purity_maxLimit! - 1.0) {
      // Reset the alarm flag if pressure is back in the safe range
      purityAlarmTriggered = false;

      _removeString("Purity is Higher than Set Limit");
      _removeString("Purity is Lower than Set Limit");
    } else {
      _removeString("Purity is Higher than Set Limit");
      _removeString("Purity is Lower than Set Limit");
    }
    // if (_latestPurity! >= Purity_minLimit! + 1.0 ||
    //     _latestPurity! <= Purity_maxLimit! - 1.0) {}

    if ((_latestFlowRate! > Flow_maxLimit! ||
            _latestFlowRate! < Flow_minLimit!) &&
        printvalue != 111 &&
        printvalue != 112) {
      if (!flowAlarmTriggered) {
        if (widget.isInternet == 3) {
          try {
            db.insertAlarm(AlarmTableCompanion(
              value: drift.Value(_latestFlowRate!),
              limitmax: drift.Value(Flow_maxLimit!),
              limitmin: drift.Value(Flow_minLimit!),
              type: drift.Value("Flow"),
              serialNo: drift.Value(_serialNo),
              recordedAt: drift.Value(DateTime.now()),
            ));
            prefs.setDouble("FlowP", _latestFlowRate!);
            List<AlarmTableData> storedData = await db.getAllAlarms();

            print("Store Alarms: $storedData");
          } catch (e) {
            print("Error to store alarms : $e");
          }
        }
        flowAlarmTriggered = true;
        _alarmCache.add({
          'Alarms': _latestFlowRate!,
          'limitmax': Flow_maxLimit!,
          'limitmin': Flow_minLimit!,
          'type': "Flow",
          'serialNo': _serialNo,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      if (_latestFlowRate! > Flow_maxLimit!) {
        _addString("Flow is Higher than Set Limit");
      } else {
        _addString("Flow is Lower than Set Limit");
      }
    } else if (_latestFlowRate! >= Flow_minLimit! + 1.0 &&
        _latestFlowRate! <= Flow_maxLimit! - 1.0) {
      // Reset the alarm flag if pressure is back in the safe range
      flowAlarmTriggered = false;

      _removeString("Flow is Higher than Set Limit");
      _removeString("Flow is Lower than Set Limit");
    } else {
      _removeString("Flow is Higher than Set Limit");
      _removeString("Flow is Lower than Set Limit");
    }

    if ((_latestPressure! > Pressure_maxLimit! ||
            _latestPressure! < Pressure_minLimit!) &&
        printvalue != 111) {
      // Check if the alarm has already been triggered
      if (!pressureAlarmTriggered) {
        if (widget.isInternet == 3) {
          try {
            db.insertAlarm(AlarmTableCompanion(
              value: drift.Value(_latestPressure!),
              limitmax: drift.Value(Pressure_maxLimit!),
              limitmin: drift.Value(Pressure_minLimit!),
              type: drift.Value("Pressure"),
              serialNo: drift.Value(_serialNo),
              recordedAt: drift.Value(DateTime.now()),
            ));
            prefs.setDouble("PressureP", _latestPressure!);
            List<AlarmTableData> storedData = await db.getAllAlarms();
            print("Stored Alarms: $storedData");

            // Set alarm as triggered

            print("print pressurealarmtrigger: $pressureAlarmTriggered");
          } catch (e) {
            print("Error to store alarms: $e");
          }
        }
        _alarmCache.add({
          'Alarms': _latestPressure!,
          'limitmax': Pressure_maxLimit!,
          'limitmin': Pressure_minLimit!,
          'type': "Pressure",
          'serialNo': _serialNo,
          'timestamp': DateTime.now().toIso8601String(),
        });
        pressureAlarmTriggered = true;
      }

      // Check for pressure status

      if (_latestPressure! > Pressure_maxLimit!) {
        _addString("Pressure is Higher than Set Limit");
      } else {
        _addString("Pressure is Lower than Set Limit");
      }
    } else if (_latestPressure! >= Pressure_minLimit! + 1.0 &&
        _latestPressure! <= Pressure_maxLimit! - 1.0) {
      // Reset the alarm flag if pressure is back in the safe range
      pressureAlarmTriggered = false;

      _removeString("Pressure is Higher than Set Limit");
      _removeString("Pressure is Lower than Set Limit");
    } else {
      _removeString("Pressure is Higher than Set Limit");
      _removeString("Pressure is Lower than Set Limit");
    }
    if (_latestTemperature! > Temp_maxLimit! ||
        _latestTemperature! < Temp_minLimit!) {
      if (!tempAlarmTriggered) {
        if (widget.isInternet == 3) {
          try {
            db.insertAlarm(AlarmTableCompanion(
              value: drift.Value(_latestTemperature!),
              limitmax: drift.Value(Temp_maxLimit!),
              limitmin: drift.Value(Temp_minLimit!),
              type: drift.Value("Temperature"),
              serialNo: drift.Value(_serialNo),
              recordedAt: drift.Value(DateTime.now()),
            ));
            prefs.setDouble("TempP", _latestTemperature!);
            print("Storing Temperature: $_latestTemperature");

            List<AlarmTableData> storedData = await db.getAllAlarms();
            print("Store Alarms: $storedData");
          } catch (e) {
            print("Error to store alarms : $e");
          }
        }
        _alarmCache.add({
          'Alarms': _latestTemperature!,
          'limitmax': Temp_maxLimit!,
          'limitmin': Temp_minLimit!,
          'type': "Temperature",
          'serialNo': _serialNo,
          'timestamp': DateTime.now().toIso8601String(),
        });
        tempAlarmTriggered = true;
      }

      if (_latestTemperature! > Temp_maxLimit!) {
        _addString("Temperature is Higher than Set Limit");
      } else {
        _addString("Temperature is Lower than Set Limit");
      }
    } else if (_latestTemperature! >= Temp_minLimit! + 1.0 &&
        _latestTemperature! <= Temp_maxLimit! - 1.0) {
      tempAlarmTriggered = false;
      _removeString("Temperature is Higher than Set Limit");
      _removeString("Temperature is Lower than Set Limit");
    } else {
      _removeString("Temperature is Higher than Set Limit");
      _removeString("Temperature is Lower than Set Limit");
    }

    if (_latestPurity! > Purity_maxLimit! ||
        _latestPurity! < Purity_minLimit! ||
        _latestFlowRate! > Flow_maxLimit! ||
        _latestFlowRate! < Flow_minLimit! ||
        _latestPressure! > Pressure_maxLimit! ||
        _latestPressure! < Pressure_minLimit! ||
        _latestTemperature! > Temp_maxLimit! ||
        _latestTemperature! < Temp_minLimit!) {
      if (!isMuted1) {
        playBackgroundMusic();
      } else {
        stopBackgroundMusic();
      }
    } else {
      stopBackgroundMusic();
    }
  }

  double _getLPMYAxisMaxValue(String serialNo) {
    print("serial numberfbajhbj: $serialNo");
    switch (serialNo.substring(0, 3)) {
      // Switch on the first 3 characters
      case 'OP1':
        return 100;

      case 'OP2':
        return 200;

      case 'OP5':
        return 500;

      case 'OP9':
        return 999;

      default:
        return 10; // Default value if no match
    }
  }

  double _getLPMYAxisIntervalValue(String serialNo) {
    switch (serialNo.substring(0, 3)) {
      // Switch on the first 3 characters
      case 'OP1':
        return 25;

      case 'OP2':
        return 50;

      case 'OP5':
        return 125;

      case 'OP9':
        return 250;

      default:
        return 2.5; // Default value if no match
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

  Future<void> loadMuteState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isMuted1 = prefs.getBool('isMuted1') ?? false;
    });
  }

  Future<void> saveMuteState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isMuted1', value);
  }

  void playBackgroundMusic() {
    bgAudio.play(
      AssetSource('beep.mp3'),
      volume: isMuted1 ? 0.0 : 1.0,
    );
  }

  void stopBackgroundMusic() {
    print("Stopinng background sound");
    bgAudio.stop();
  }

  void toggleMute() {
    setState(() {
      isMuted1 = !isMuted1;
      saveMuteState(isMuted1);

      if (isMuted1) {
        bgAudio.setVolume(0.0);
      } else {
        playBackgroundMusic();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    final List<Color> parameterColors = [
      const Color.fromARGB(255, 0, 34, 145),
      const Color.fromARGB(255, 204, 148, 7),
      const Color.fromARGB(255, 195, 0, 0),
      const Color.fromARGB(255, 3, 161, 84)
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
      "Temperature",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
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
                    padding: const EdgeInsets.only(right: 2),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
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
                                  return ChartAxisLabel(
                                      formattedTime, TextStyle(fontSize: 0));
                                },
                              ),
                              primaryYAxis: const NumericAxis(
                                minimum: 0,
                                maximum: 100,
                                interval: 25,
                                axisLine: AxisLine(width: 0),
                                majorTickLines: MajorTickLines(size: 0),
                                title: AxisTitle(text: 'O₂%'),
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
                                  color: const Color.fromARGB(255, 0, 34, 145),
                                  name: "Purity",
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            // height: MediaQuery.of(context).size.height * 0.21,
                            child: SfCartesianChart(
                              plotAreaBorderWidth: 0,

                              // tooltipBehavior: TooltipBehavior(enable: true),
                              //  legend: Legend(isVisible: true),
                              primaryXAxis: NumericAxis(
                                interval: 10,
                                labelFormat: '{value}',
                                labelStyle:
                                    TextStyle(color: Colors.transparent),
                                axisLabelFormatter:
                                    (AxisLabelRenderDetails details) {
                                  int value = details.value.toInt();
                                  int minutes = value ~/ 60;
                                  int seconds = value % 60;
                                  String formattedTime =
                                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                                  return ChartAxisLabel(
                                      formattedTime,
                                      TextStyle(
                                        fontSize: 0,
                                      ));
                                },
                              ),

                              primaryYAxis: NumericAxis(
                                maximum: _maxYAxisValue,
                                minimum: 0,
                                interval: _intervalYAxisValue,
                                axisLine: AxisLine(width: 0),
                                majorTickLines: MajorTickLines(size: 0),
                                title: AxisTitle(text: 'LPM'),
                                axisLabelFormatter:
                                    (AxisLabelRenderDetails details) {
                                  int value = details.value.toInt();
                                  String formattedValue;

                                  if (value == 0) {
                                    formattedValue =
                                        '0'; // Single zero for minimum value
                                  } else {
                                    // Format other values to include leading zero
                                    formattedValue =
                                        value.toString().padLeft(3, '  ');
                                  }

                                  return ChartAxisLabel(formattedValue,
                                      TextStyle(color: Colors.black));
                                },
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
                                  color: Color.fromARGB(255, 204, 148, 7),
                                  name: "Flow",
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
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
                                  return ChartAxisLabel(
                                      formattedTime, TextStyle(fontSize: 0));
                                },
                              ),
                              primaryYAxis: NumericAxis(
                                maximum: _serialNo.startsWith('ODC') ? 20 : 100,
                                minimum: 0,
                                interval: _serialNo.startsWith('ODC') ? 5 : 25,
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
                          flex: 5,
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
                            primaryYAxis: NumericAxis(
                              maximum: 50,
                              interval: 12.5,
                              minimum: 0,
                              axisLine: AxisLine(width: 0),
                              majorTickLines: MajorTickLines(size: 0),
                              title: AxisTitle(text: '°C'),
                              labelFormat: '{value}', // Default label format
                              axisLabelFormatter:
                                  (AxisLabelRenderDetails details) {
                                int value = details.value.toInt();
                                String formattedValue;

                                if (value == 0) {
                                  formattedValue =
                                      '0'; // Single zero for minimum value
                                } else {
                                  // Format other values to include leading zero
                                  formattedValue =
                                      value.toString().padLeft(3, '  ');
                                }

                                return ChartAxisLabel(formattedValue,
                                    TextStyle(color: Colors.black));
                              },
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
                                              (_latestPurity != null
                                                  ? _latestPurity!
                                                      .toStringAsFixed(1)
                                                  : '0.0'),
                                              style: TextStyle(
                                                color: parameterTextColor[0],
                                                fontSize: screenWidth / 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
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
                            onTap: () {
                              if (printvalue != 111) _navigateToDetailPage(2);
                            },
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
                                            ((printvalue == 111)
                                                ? "---"
                                                : _latestPressure != null
                                                    ? _latestPressure!
                                                        .toStringAsFixed(1)
                                                    : "0.0"),
                                            style: TextStyle(
                                              color: parameterTextColor[2],
                                              fontSize: screenWidth / 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
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
                              _showEditDetailsDialog(context);
                              // final db = await AppDbSingleton().database;

                              // await db.deleteFirstLimitSetting();
                              // await db.deleteAllAlarms();
                              // await db.customUpdate(
                              //     'DELETE FROM sqlite_sequence WHERE name = "limit_settings_table";');
                              //  print("All limit settings have been deleted.");
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
                                          fontSize: screenHeight / 22,
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
                            onTap: () {
                              if (!(printvalue == 111 || printvalue == 112))
                                _navigateToDetailPage(1);
                            },
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
                                            ((printvalue == 112 ||
                                                    printvalue == 111)
                                                ? "---"
                                                : _latestFlowRate != null
                                                    ? _latestFlowRate! >= 100
                                                        ? _latestFlowRate!
                                                            .toStringAsFixed(0)
                                                        : _latestFlowRate!
                                                            .toStringAsFixed(1)
                                                    : "0.0"),
                                            style: TextStyle(
                                              color: parameterTextColor[0],
                                              fontSize: screenWidth / 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
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
                                            (_latestTemperature != null
                                                ? _latestTemperature!
                                                    .toStringAsFixed(1)
                                                : "0.0"),
                                            style: TextStyle(
                                              color: parameterTextColor[3],
                                              fontSize: screenWidth / 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
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
                                      builder: (context) => ReportScreen(
                                            data: _cache,
                                            serialNo: _serialNo,
                                            appStartTime: appStartTime!,
                                            alarmCache: _alarmCache,
                                            isInternet: widget.isInternet,
                                          )));
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
                                          fontSize: screenHeight / 22,
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(6), // Square corners
                        ),
                        minimumSize: Size(
                            100, 25), // Set minimum size to maintain height
                        backgroundColor: // Color when muted
                            Colors.blue, // Default color
                      ),
                      onPressed: toggleMute,
                      child: Text(
                        isMuted1 ? 'Unmute' : 'Mute',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white, // Default text color
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.blueAccent,
                              offset: Offset(2, 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(), // Spacer to push the text to the center
                    Text(
                      _currentString,
                      style: TextStyle(
                        fontSize: screenHeight / 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(), // Spacer to keep the text centered
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

  double? _latestPurity;
  double? _latestFlowRate;
  double? _latestPressure;
  double? _latestTemperature;

  String _serialNo = " ";
  bool _isRunning = false;
  List<Map<String, dynamic>> _cache = [];

  int? printvalue;

  Future<void> getData() async {
    var url = Uri.parse('http://192.168.4.1/getdata');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          Map<String, dynamic> jsonData = data[0];
          double purity = double.tryParse(jsonData['Purity'] ?? '0.0')!;
          double flowRate = double.tryParse(jsonData['Flow_Rate'] ?? '0.0')!;
          double pressure = double.tryParse(jsonData['Pressure'] ?? '0.0')!;
          double temperature =
              double.tryParse(jsonData['Temperature'] ?? '0.0')!;
          _serialNo = jsonData['serialNo'] ?? '';

          if (purity > 99.9) {
            purity = 99.9;
          }
          if (_serialNo.startsWith("ODC")) {
            if (pressure > 20.0) {
              pressure = 20.0;
            }
          } else {
            if (pressure >= 100) {
              pressure = 99.9;
            }
          }
          switch (_serialNo.substring(0, 3)) {
            // Switch on the first 3 characters of _serialNo
            case 'OP1':
              if (flowRate > 100) {
                flowRate = 100.0;
              }
              break;

            case 'OP2':
              if (flowRate > 100) {
                flowRate = 100.0;
              }
              if (flowRate > 200) {
                flowRate = 200.0;
              }
              break;

            case 'OP5':
              if (flowRate > 500.0) {
                flowRate = 500.0;
              }
              break;

            case 'OP9':
              if (flowRate > 999) {
                flowRate = 999;
              }
              break;

            default:
              if (flowRate > 10) {
                flowRate = 10.0;
              }
              break;
          }
          if (temperature > 99.9) {
            temperature = 99.9;
          }

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
          if (_serialNo.startsWith("ODG") ||
              _serialNo.startsWith("ODP") ||
              _serialNo.startsWith("ODA")) {
            printvalue = 111;
          } else if (_serialNo.startsWith("OPP") ||
              _serialNo.startsWith("OGP")) {
            printvalue = 112;
          }

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

  void getMqttdata(String payload) {
    try {
      Map<String, dynamic> jsonData = jsonDecode(payload);
      print("jsondatacdsc: $jsonData");
      double purity = double.tryParse(jsonData['Purity'] ?? '0.0')!;
      double flowRate = double.tryParse(jsonData['Flow Rate'] ?? '0.0')!;
      double pressure = double.tryParse(jsonData['Pressure'] ?? '0.0')!;
      double temperature = double.tryParse(jsonData['Temperature'] ?? '0.0')!;
      setState(() {
        _serialNo = jsonData['serialNo'] ?? '';
      });

      print("serial njkvnfjhnvud: $pressure");
      if (purity > 99.9) {
        purity = 99.9;
      }
      if (_serialNo.startsWith("ODC")) {
        if (pressure > 20.0) {
          pressure = 20.0;
        }
      } else {
        if (pressure >= 100) {
          pressure = 99.9;
        }
      }

      switch (_serialNo.substring(0, 3)) {
        case 'OP1':
          if (flowRate > 100) {
            flowRate = 100.0;
          }
          break;

        case 'OP2':
          if (flowRate > 100) {
            flowRate = 100.0;
          }
          if (flowRate > 200) {
            flowRate = 200.0;
          }
          break;

        case 'OP5':
          if (flowRate > 500.0) {
            flowRate = 500.0;
          }
          break;

        case 'OP9':
          if (flowRate > 999) {
            flowRate = 999;
          }
          break;

        default:
          if (flowRate > 10) {
            flowRate = 10.0;
          }
          break;
      }

      if (temperature > 99.9) {
        temperature = 99.9;
      }

      // Add the processed values to the respective lists
      purityList.add(purity);
      flowRateList.add(flowRate);
      pressureList.add(pressure);
      temperatureList.add(temperature);

      print("purity list:  $pressureList");

      // Update state and cache
      setState(() {
        _cache.add({
          'purity': purity,
          'flowRate': flowRate,
          'pressure': pressure,
          'temperature': temperature,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      print("cachedvkh: $_cache");

      // Determine print value based on serialNo
      if (_serialNo.startsWith("ODG") ||
          _serialNo.startsWith("ODP") ||
          _serialNo.startsWith("ODA")) {
        printvalue = 111;
      } else if (_serialNo.startsWith("OPP") || _serialNo.startsWith("OGP")) {
        printvalue = 112;
      }

      // Add data to stream controllers
      _purityController.add(purity);
      _flowRateController.add(flowRate);
      _pressureController.add(pressure);
      _temperatureController.add(temperature);
    } catch (e, stackTrace) {
      print('Error parsing MQTT data: $e');
      print("Error Stacktrace: $stackTrace");
    }
  }

  Future<void> printStoredData() async {
    final db = await AppDbSingleton().database;
    List<OxyDatabaseData> storedData = await db.getAllOxyData();
    for (var data in storedData) {
      print(
          'ID: ${data.id}, Purity: ${data.purity}, Flow Rate: ${data.flow}, Pressure: ${data.pressure}, Temperature: ${data.temp}, Serial No: ${data.serialNo}, DateTime: ${data.recordedAt}');
    }

    print('Stored Data: ${_cache.length}');
  }

  Future<void> storeAverageData() async {
    final db = await AppDbSingleton().database;
    String? serialNo = _serialNo;
    DateTime dateTime = DateTime.now();
    var url_1m = Uri.parse('http://192.168.4.1/getdata_1m');
    try {
      final response = await http.get(url_1m);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          Map<String, dynamic> jsonData = data[0];
          double purity = double.tryParse(jsonData['Purity'] ?? '0.0')!;
          double flowRate = double.tryParse(jsonData['Flow_Rate'] ?? '0.0')!;
          double pressure = double.tryParse(jsonData['Pressure'] ?? '0.0')!;
          double temperature =
              double.tryParse(jsonData['Temperature'] ?? '0.0')!;
          _serialNo = jsonData['serialNo'] ?? '';
          print("pressurejnvjvn: $pressure");
          final entity = OxyDatabaseCompanion(
            purity: drift.Value(purity),
            flow: drift.Value(flowRate),
            pressure: drift.Value(pressure),
            temp: drift.Value(temperature),
            serialNo: drift.Value(serialNo!),
            recordedAt: drift.Value(dateTime),
          );

          await db.insertOxyData(entity);
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
  final int time;
  final double value;
}
