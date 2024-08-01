import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oxydata/screens/splash_screen.dart';

void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  _enablePlatformOverrideForDesktop();
  runApp( MyApp(routeObserver: routeObserver));
}

class MyApp extends StatelessWidget {
  final RouteObserver<PageRoute> routeObserver;
   MyApp({super.key, required this.routeObserver});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OxyData',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}
