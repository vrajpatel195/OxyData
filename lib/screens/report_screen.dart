import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxydata/Report_screens/daily_report.dart';
import 'package:oxydata/Report_screens/monthly_report.dart';
import 'package:oxydata/Report_screens/weekly_report.dart';
import 'package:oxydata/Report_screens/current_report.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.data});
  final List<Map<String, dynamic>> data;
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  TextEditingController _remarkController = TextEditingController();
  DateTime? _selectedDate;
  String? _weekRange;
  DateTime now = DateTime.now();
  DateTime startDate = DateTime.now().subtract(Duration(days: 90));
  String? _selectedMonth;

  Future<void> _showMonthSelector(BuildContext context) async {
    List<String> months = [];

    // Generate the last three months
    for (int i = 2; i >= 0; i--) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat('MMMM yyyy').format(date));
    }

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: months.map((month) {
              return ListTile(
                title: Text(month),
                onTap: () {
                  setState(() {
                    _selectedMonth = month;
                  });
                  Navigator.pop(context); // Close the bottom sheet
                },
              );
            }).toList(),
          ),
        );
      },
    );
    _showRemarkDialog();
  }

  Future<void> _selectDateAndCalculateWeek(BuildContext context) async {
    // 3 months ago
    DateTime endDate = now; // Current date

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: startDate,
      lastDate: endDate,
    );

    if (picked != null) {
      // Calculate the start (Sunday) and end (Saturday) of the week
      DateTime startOfWeek =
          picked.subtract(Duration(days: picked.weekday % 7));
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

      // Format the dates
      String formattedStart = DateFormat('yyyy-MM-dd').format(startOfWeek);
      String formattedEnd = DateFormat('yyyy-MM-dd').format(endOfWeek);

      setState(() {
        _weekRange = '$formattedStart to $formattedEnd';
      });
    }
    _showRemarkDialog();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: startDate,
      lastDate: now,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
    _showRemarkDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Report"),
        ),
        toolbarHeight: 40,
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.612),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            // First part
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Current Report',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue, // Text color
                        shadowColor: Colors.blueAccent, // Shadow color
                        elevation: 10, // Elevation
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30.0), // Rounded corners
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        _showRemarkDialog();
                      },
                      child: Text('Current Report'),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 2, // Width of the vertical line
              color: Colors.black, // Color of the vertical line
              // Adjust the height to match the height of the largest child
              height: MediaQuery.of(context).size.height - 50,
            ),
            // Second part
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Old Report',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue, // Text color
                        shadowColor: Colors.blueAccent, // Shadow color
                        elevation: 10, // Elevation
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30.0), // Rounded corners
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        _selectDate(context);
                      },
                      child: Text('   Daily Report   '),
                    ),
                    _selectedDate == null
                        ? SizedBox(height: 20)
                        : Text(
                            'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue, // Text color
                        shadowColor: Colors.blueAccent, // Shadow color
                        elevation: 10, // Elevation
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30.0), // Rounded corners
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        _selectDateAndCalculateWeek(context);
                      },
                      child: Text(' Weekly Report '),
                    ),
                    _weekRange == null
                        ? SizedBox(height: 20)
                        : Text(
                            'Selected Week: $_weekRange',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: Colors.blue, // Text color
                        shadowColor: Colors.blueAccent, // Shadow color
                        elevation: 10, // Elevation
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30.0), // Rounded corners
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        _showMonthSelector(context);
                      },
                      child: Text('Monthly Report'),
                    ),
                    _selectedMonth == null
                        ? Text("")
                        : Text(
                            'Selected Month: $_selectedMonth',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                                if (_selectedDate != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DailyReport(
                                        selectedDate: _selectedDate,
                                        remark: _remarkController.text,
                                      ),
                                    ),
                                  );
                                } else if (_weekRange != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WeeklyReport(
                                        weekRange: _weekRange,
                                      ),
                                    ),
                                  );
                                } else if (_selectedMonth != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MonthlyReport(
                                        selectedMonth: _selectedMonth,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GraphReport(
                                        data: widget.data,
                                        remark: _remarkController.text,
                                      ),
                                    ),
                                  );
                                }
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
