import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyReport extends StatefulWidget {
  WeeklyReport({super.key, required this.weekRange});
  String? weekRange;
  @override
  State<WeeklyReport> createState() => _WeeklyReportState();
}

class _WeeklyReportState extends State<WeeklyReport> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _convertWeekRangeToDateTime();
  }

  void _convertWeekRangeToDateTime() {
    List<String> dates = widget.weekRange!.split(' to ');
    if (dates.length == 2) {
      startDate = DateTime.parse(dates[0]);
      endDate = DateTime.parse(dates[1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (startDate != null && endDate != null) ...[
              Text(
                'Start Date: ${DateFormat('yyyy-MM-dd').format(startDate!)}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'End Date: ${DateFormat('yyyy-MM-dd').format(endDate!)}',
                style: TextStyle(fontSize: 16),
              ),
            ] else ...[
              Text(
                'Invalid week range',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
