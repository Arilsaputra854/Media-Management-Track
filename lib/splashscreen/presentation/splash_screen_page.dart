import 'package:flutter/material.dart';
import 'package:media_management_track/auth/domain/repositories/auth_repository.dart';
import 'package:media_management_track/auth/domain/usecases/get_token_usecase.dart';
import 'package:media_management_track/auth/presentation/pages/login_page.dart';
import 'package:media_management_track/dashboard/presentation/dashboard_page.dart';

class SplashScreenPage extends StatefulWidget {
  final AuthRepository authRepository;

  const SplashScreenPage(this.authRepository, {super.key});

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
    final usecase = GetTokenUsecase(widget.authRepository);
    final token = await usecase.call();

    await Future.delayed(Duration(seconds: 2));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => token != null ? DashboardPage() : LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Logo")),
    );
  }
}
