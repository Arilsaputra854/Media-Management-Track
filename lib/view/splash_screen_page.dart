import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () async {
        //String? token = await getToken();
        // if (token != null) {
        //   context.go('/dashboard');
        // } else {
        //   context.go('/login');
        // }
          context.go('/login');
      });
    });

    return const Scaffold(body: Center(child: Text("Logo")));
  }
}
