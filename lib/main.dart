import 'package:flutter/material.dart';
import 'package:media_management_track/view/splash_screen_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  runApp(
    MaterialApp(
      home: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreenPage());
  }
}
