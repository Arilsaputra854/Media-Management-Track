import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoginViewmodel extends ChangeNotifier {
  Logger logger = Logger();

  bool _loading = false;
  String? _errorMsg;

  String? get errorMsg => _errorMsg;
  bool get loading => _loading;

  Future<String?> login(String email, String password) async {
    _loading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _loading = false;

      logger.d("Login Input :${email} &  ${password}");
    } catch (e) {
      _errorMsg = "Login Gagal ${e.toString()}";
      _loading = false;
    }
    notifyListeners();
  }
}
