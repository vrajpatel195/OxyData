import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../screens/demo_report_screen.dart';

class DailyChart extends StatefulWidget {
  final List<String> selectedValues;
  const DailyChart({super.key, required this.selectedValues});

  @override
  State<DailyChart> createState() => _DailyChartState();
}

class _DailyChartState extends State<DailyChart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Report Line Chart'),
      ),
      body: LineChartScreen(
        selectedValues: widget.selectedValues,
      ),
    );
  }
}

class LineChartScreen extends StatefulWidget {
  final List<String> selectedValues;
  const LineChartScreen({super.key, required this.selectedValues});

  @override
  _LineChartScreenState createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  final GlobalKey chartKey = GlobalKey();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final data =
        generateRandomData(); // Assume this generates data for O2 or CO2
    final minData = generateConstantData(47);
    final maxData = generateConstantData(60);

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

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: chartKey,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  intervalType: DateTimeIntervalType.hours,
                  dateFormat: DateFormat.Hm(),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 100,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                legend: Legend(isVisible: true),
                series: seriesList,
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
      ),
    );
  }

  Future<void> _captureAndShowImage(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 10));
    try {
      final RenderRepaintBoundary boundary =
          chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      Navigator.of(context).pop(); // Pop DailyChart page

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DemoReportScreen(
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

List<ChartData> generateRandomData() {
  final random = Random();
  final now = DateTime.now();
  return List.generate(1440, (index) {
    return ChartData(
      now.add(Duration(minutes: index)),
      50 + random.nextDouble() * 3, // Random value between 50 and 53
    );
  });
}

List<ChartData> generateConstantData(double value) {
  final now = DateTime.now();
  return List.generate(1440, (index) {
    return ChartData(
      now.add(Duration(minutes: index)),
      value,
    );
  });
}
