import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Tampilkan splash screen sementara
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: Image.asset("assets/logo_racer.jpeg")));
        }

        Future.delayed(const Duration(seconds: 2), () {
          if (snapshot.data != null) {
            context.go('/dashboard');
          } else {
            context.go('/login');
          }
        });

        // Tetap tampilkan splash screen selama 2 detik
          return Scaffold(body: Center(child: Image.asset("assets/logo_racer.jpeg")));
      },
    );
  }
}
