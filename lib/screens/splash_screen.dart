import 'package:flutter/material.dart';
import 'package:oxydata/screens/main_page.dart';
import 'package:oxydata/screens/register.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  String version = '';

  @override
  void initState() {
    super.initState();
    _navigateToHome();
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

  Future<String> _getAppVersion() async {
    print("Above the app");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print("I I am Below the packageInfor : $packageInfo");
    return packageInfo.version;
  }

  _navigateToHome() async {
    String fetchedVersion = await _getAppVersion();

    print("version: $fetchedVersion");

    setState(() {
      version = fetchedVersion; // Update state to trigger UI rebuild
    });
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
          builder: (context) => Dashboard(version: version),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => RegistrationScreen(
                  version: version,
                )), // Replace HomeScreen with your main screen
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
              SizedBox(height: 20),
              Text("version: $version", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
