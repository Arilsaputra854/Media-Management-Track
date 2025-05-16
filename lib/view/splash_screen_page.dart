import 'package:flutter/material.dart';
import 'package:media_management_track/view/dashboard_page.dart';
import 'package:media_management_track/view/login_page.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 2));

    var token;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => token != null ? DashboardPage() : LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Logo")));
  }
}
