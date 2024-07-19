import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartExample extends StatefulWidget {
  @override
  _ChartExampleState createState() => _ChartExampleState();
}

class _ChartExampleState extends State<ChartExample> {
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

  StreamSubscription<double>? _puritySubscription;
  StreamSubscription<double>? _flowRateSubscription;
  StreamSubscription<double>? _pressureSubscription;
  StreamSubscription<double>? _temperatureSubscription;

  double _latestPurity = 0.0;
  double _latestFlowRate = 0.0;
  double _latestPressure = 0.0;
  double _latestTemperature = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDataPeriodically();
    _puritySubscription = _purityController.stream.listen((data) {
      setState(() {
        final now = DateTime.now();
        _purityData.add(_ChartData(now, data));
        if (_purityData.length > 20) _purityData.removeAt(0);
        _latestPurity = data;
      });
      _updateDataSource();
    });
    _flowRateSubscription = _flowRateController.stream.listen((data) {
      setState(() {
        final now = DateTime.now();
        _flowRateData.add(_ChartData(now, data));
        if (_flowRateData.length > 20) _flowRateData.removeAt(0);
        _latestFlowRate = data;
      });
      _updateDataSource();
    });
    _pressureSubscription = _pressureController.stream.listen((data) {
      setState(() {
        final now = DateTime.now();
        _pressureData.add(_ChartData(now, data));
        if (_pressureData.length > 20) _pressureData.removeAt(0);
        _latestPressure = data;
      });
      _updateDataSource();
    });
    _temperatureSubscription = _temperatureController.stream.listen((data) {
      setState(() {
        final now = DateTime.now();
        _temperatureData.add(_ChartData(now, data));
        if (_temperatureData.length > 20) _temperatureData.removeAt(0);
        _latestTemperature = data;
      });
      _updateDataSource();
    });
  }

  @override
  void dispose() {
    _purityController.close();
    _flowRateController.close();
    _pressureController.close();
    _temperatureController.close();
    _puritySubscription?.cancel();
    _flowRateSubscription?.cancel();
    _pressureSubscription?.cancel();
    _temperatureSubscription?.cancel();
    super.dispose();
  }

  void fetchDataPeriodically() {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      await getData();
    });
  }

  Future<void> getData() async {
    var url = Uri.parse('http://192.168.4.1/getdata');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          Map<String, dynamic> jsonData = data[0];

          _purityController.add(double.tryParse(jsonData['Purity']) ?? 0.0);
          _flowRateController
              .add(double.tryParse(jsonData['Flow_Rate']) ?? 0.0);
          _pressureController.add(double.tryParse(jsonData['Pressure']) ?? 0.0);
          _temperatureController
              .add(double.tryParse(jsonData['Temperature']) ?? 0.0);
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stream Based Charts'),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(),
                      primaryYAxis: NumericAxis(),
                      series: <LineSeries<_ChartData, DateTime>>[
                        LineSeries<_ChartData, DateTime>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            _purityChartController = controller;
                          },
                          dataSource: _purityData,
                          xValueMapper: (data, _) => data.time,
                          yValueMapper: (data, _) => data.value,
                          name: 'Purity',
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(),
                      primaryYAxis: NumericAxis(),
                      series: <LineSeries<_ChartData, DateTime>>[
                        LineSeries<_ChartData, DateTime>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            _flowRateChartController = controller;
                          },
                          dataSource: _flowRateData,
                          xValueMapper: (data, _) => data.time,
                          yValueMapper: (data, _) => data.value,
                          name: 'Flow Rate',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildCard('Purity', _latestPurity.toStringAsFixed(0)),
              _buildCard('Flow Rate', _latestFlowRate.toStringAsFixed(0)),
              _buildCard('Pressure', _latestPressure.toStringAsFixed(2)),
              _buildCard('Temperature', _latestTemperature.toStringAsFixed(0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              value,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final DateTime time;
  final double value;

  _ChartData(this.time, this.value);
}
