import 'package:flutter/material.dart';

class MonthlyReport extends StatefulWidget {
  MonthlyReport({super.key, required this.selectedMonth});
  String? selectedMonth;
  @override
  State<MonthlyReport> createState() => _MonthlyReportState();
}

class _MonthlyReportState extends State<MonthlyReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
