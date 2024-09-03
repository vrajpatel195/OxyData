import 'package:flutter/material.dart';
import 'package:oxydata/screens/main_page.dart';
import 'package:oxydata/screens/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Database/db/app_db.dart';
// Import your home screen or main screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    _navigateToHome();
  }

  _navigateToHome() async {
    final db = await AppDbSingleton().database;

    // Delete data older than 3 months
    await db.deleteDataOlderThanThreeMonths();
    await Future.delayed(Duration(seconds: 5), () {});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
    print("first runnnnn: $isFirstRun");

    if (!isFirstRun) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                RegistrationScreen()), // Replace HomeScreen with your main screen
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/oxy_logo.png', width: 100, height: 100),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "From",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Image.asset('assets/wave_logo.png',
                        width: 100, height: 100),
                  ]), // Add your logo here
              SizedBox(height: 20),
              CircularProgressIndicator(), // Optional: Add a loading indicator
            ],
          ),
        ),
      ),
    );
  }
}
