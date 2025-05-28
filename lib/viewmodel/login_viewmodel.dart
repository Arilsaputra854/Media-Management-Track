import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:media_management_track/model/user.dart';
import 'package:media_management_track/storage/prefs.dart';

class LoginViewmodel extends ChangeNotifier {
  Logger logger = Logger();

  bool _loading = false;
  String? _errorMsg;

  String? get errorMsg => _errorMsg;
  bool get loading => _loading;

  Prefs prefs;

  LoginViewmodel(this.prefs);

  Future<bool> login(String email, String password) async {
    _loading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final userCrendential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      _loading = false;

      if (userCrendential.user != null) {
        final uid = userCrendential.user!.uid;
        final docSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null) {
            prefs.saveUser(User.fromJson(data));
          } else {
            _errorMsg = "Data user di Firestore kosong.";
            logger.e(_errorMsg);
            return false;
          }
        } else {
          _errorMsg = "Akun belum terdaftar di Firestore.";
          logger.e(_errorMsg);
          return false;
        }
      }

      logger.d("Login berhasil :${FirebaseAuth.instance.currentUser?.email}");
      notifyListeners();
      return true;
    } catch (e) {
      _errorMsg = "Login Gagal ${e.toString()}";
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
