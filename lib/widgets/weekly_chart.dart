import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../screens/report_screen.dart';

class WeeklyChart extends StatefulWidget {
  final List<String> selectedValues;

  const WeeklyChart({super.key, required this.selectedValues});
  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Report Line Chart'),
      ),
      body: WeeklyChartScreen(
        selectedValues: widget.selectedValues,
      ),
    );
  }
}

class WeeklyChartScreen extends StatefulWidget {
  final List<String> selectedValues;
  const WeeklyChartScreen({super.key, required this.selectedValues});

  @override
  _WeeklyChartScreenState createState() => _WeeklyChartScreenState();
}

class _WeeklyChartScreenState extends State<WeeklyChartScreen> {
  final GlobalKey chartKey = GlobalKey();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final data = generateWeeklyRandomData();
    final minData = generateWeeklyConstantData(47);
    final maxData = generateWeeklyConstantData(60);
    List<CartesianSeries> seriesList = [];

    // Add selected value series
    if (widget.selectedValues.length > 1) {
      if (widget.selectedValues.contains('Purity')) {
        seriesList.add(LineSeries<ChartData, DateTime>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value,
          color: ui.Color.fromARGB(255, 188, 225, 255),
          name: 'Purity',
        ));
      }
      if (widget.selectedValues.contains('Flow')) {
        seriesList.add(LineSeries<ChartData, DateTime>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value,
          color: Colors.yellow,
          name: 'Flow',
        ));
      }
      if (widget.selectedValues.contains('Pressure')) {
        seriesList.add(LineSeries<ChartData, DateTime>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value,
          color: ui.Color.fromARGB(255, 110, 113, 116),
          name: 'Pressure',
        ));
      }
      if (widget.selectedValues.contains('Temp')) {
        seriesList.add(LineSeries<ChartData, DateTime>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value,
          color: ui.Color.fromARGB(255, 132, 200, 255),
          name: 'Temp',
        ));
      }
     
     
    }
    // Add min and max lines if only one value is selected
    if (widget.selectedValues.length == 1) {
      seriesList.add(LineSeries<ChartData, DateTime>(
        dataSource: minData,
        xValueMapper: (ChartData data, _) => data.time,
        yValueMapper: (ChartData data, _) => data.value,
        color: Colors.yellow,
        name: 'Min',
      ));
      seriesList.add(LineSeries<ChartData, DateTime>(
        dataSource: data,
        xValueMapper: (ChartData data, _) => data.time,
        yValueMapper: (ChartData data, _) => data.value,
        color: Colors.black,
        name: 'Actual Value',
      ));
      seriesList.add(LineSeries<ChartData, DateTime>(
        dataSource: maxData,
        xValueMapper: (ChartData data, _) => data.time,
        yValueMapper: (ChartData data, _) => data.value,
        color: Colors.red,
        name: 'Max',
      ));
    }

    return Column(
      children: [
        Expanded(
          child: RepaintBoundary(
            key: chartKey,
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                intervalType: DateTimeIntervalType.days,
                dateFormat: DateFormat.E(), // Short day format (Mon, Tue, etc.)
                interval: 1, // Show every day of the week
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 100,
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              legend: Legend(isVisible: true),
              series: <CartesianSeries>[
                LineSeries<ChartData, DateTime>(
                  dataSource: data,
                  xValueMapper: (ChartData data, _) => data.time,
                  yValueMapper: (ChartData data, _) => data.value,
                  color: Colors.black,
                ),
                LineSeries<ChartData, DateTime>(
                  dataSource: minData,
                  xValueMapper: (ChartData data, _) => data.time,
                  yValueMapper: (ChartData data, _) => data.value,
                  color: Colors.yellow,
                ),
                LineSeries<ChartData, DateTime>(
                  dataSource: maxData,
                  xValueMapper: (ChartData data, _) => data.time,
                  yValueMapper: (ChartData data, _) => data.value,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              _captureAndShowImage(context);
            },
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Proceed'),
          ),
        ),
      ],
    );
  }

  Future<void> _captureAndShowImage(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final RenderRepaintBoundary boundary =
          chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      Navigator.of(context).pop(); // Pop WeeklyChart page

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReportScreen(
            imageBytes: pngBytes,
          ),
        ),
      );
    } catch (e) {
      print('Error capturing image: $e');
      // Optionally show an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class ChartData {
  final DateTime time;
  final double value;

  ChartData(this.time, this.value);
}

List<ChartData> generateWeeklyRandomData() {
  final random = Random();
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  return List.generate(7 * 24, (index) {
    return ChartData(
      startOfWeek.add(Duration(hours: index)),
      50 + random.nextDouble() * 3, // Random value between 50 and 53
    );
  });
}

List<ChartData> generateWeeklyConstantData(double value) {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  return List.generate(7 * 24, (index) {
    return ChartData(
      startOfWeek.add(Duration(hours: index)),
      value,
    );
  });
}
