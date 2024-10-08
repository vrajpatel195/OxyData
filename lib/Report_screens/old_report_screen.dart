import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxydata/Report_screens/daily_report.dart';
import 'package:oxydata/Report_screens/monthly_report.dart';
import 'package:oxydata/Report_screens/weekly_report.dart';

class OldReportScreen extends StatefulWidget {
  OldReportScreen({super.key, required this.serialNo});
  String serialNo;
  @override
  State<OldReportScreen> createState() => _OldReportScreenState();
}

class _OldReportScreenState extends State<OldReportScreen> {
  TextEditingController _remarkController = TextEditingController();
  DateTime? _selectedDate;
  String? _weekRange;
  DateTime now = DateTime.now();
  DateTime startDate = DateTime.now().subtract(Duration(days: 90));
  String? _selectedMonth;
  DateTime? _StartMonthDate;

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
                  DateFormat dateFormat = DateFormat('MMMM yyyy');
                  DateTime parsedDate = dateFormat.parse(month);
                  _StartMonthDate =
                      DateTime(parsedDate.year, parsedDate.month, 1);
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
    _showRemarkDialog(3);
  }

  late DateTime startOfWeek;
  late DateTime endOfWeek;
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
      startOfWeek = picked.subtract(Duration(days: picked.weekday % 7));
      endOfWeek = startOfWeek.add(Duration(days: 6));

      // Format the dates
      String formattedStart = DateFormat('yyyy-MM-dd').format(startOfWeek);
      String formattedEnd = DateFormat('yyyy-MM-dd').format(endOfWeek);

      setState(() {
        _weekRange = '$formattedStart to $formattedEnd';
      });
    }
    _showRemarkDialog(2);
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
    _showRemarkDialog(1);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text("OxyData Report  ${widget.serialNo}"),
        ),
        toolbarHeight: 40,
        backgroundColor: Color.fromARGB(141, 241, 241, 241),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 40,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
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
                        style: const TextStyle(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    _selectDateAndCalculateWeek(context);
                  },
                  child: const Text(' Weekly Report '),
                ),
                _weekRange == null
                    ? const SizedBox(height: 20)
                    : Text(
                        'Selected Week: $_weekRange',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    backgroundColor: Colors.blue, // Text color
                    shadowColor: Colors.blueAccent, // Shadow color
                    elevation: 10, // Elevation
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
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
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showRemarkDialog(int reportType) async {
    print("Report Type: $reportType");
    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(12.0),
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
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Add Remarks...',
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                              ),
                            ),
                            SizedBox(width: 10),
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(null);
                              },
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              child: const Text('Submit'),
                              onPressed: () {
                                Navigator.of(context).pop(reportType);
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

    if (result != null) {
      if (result == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DailyReport(
              selectedDate: _selectedDate,
              remark: _remarkController.text,
              serialNo: widget.serialNo,
            ),
          ),
        ).then((_) {
          // Refresh the screen when coming back from DailyReport
          setState(() {
            _remarkController.clear();
            _selectedDate = null;
          });
        });
      } else if (result == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeeklyReport(
              weekRange: _weekRange,
              remark: _remarkController.text,
              startDate: startOfWeek,
              endDate: endOfWeek,
              serialNo: widget.serialNo,
            ),
          ),
        ).then((_) {
          // Refresh the screen when coming back from WeeklyReport
          setState(() {
            _remarkController.clear();
            _weekRange = null;
          });
        });
      } else if (result == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonthlyReport(
              selectedMonth: _selectedMonth,
              remark: _remarkController.text,
              startDate: _StartMonthDate,
              serialNo: widget.serialNo,
            ),
          ),
        ).then((_) {
          // Refresh the screen when coming back from MonthlyReport
          setState(() {
            _remarkController.clear();
            _selectedMonth = null;
          });
        });
      }
    }
  }
}
