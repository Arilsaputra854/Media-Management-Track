import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      User? user = FirebaseAuth.instance.currentUser;
      Future.delayed(const Duration(seconds: 2), () async {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (user != null) {
            context.go('/dashboard');
          } else {
            context.go('/login');
          }
        });
      });
    });

    return const Scaffold(body: Center(child: Text("Logo")));
  }
}
