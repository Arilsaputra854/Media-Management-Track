import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/web.dart';
import 'package:media_management_track/model/user.dart';
import 'package:media_management_track/storage/prefs.dart';

class DashboardViewmodel extends ChangeNotifier {
  Logger logger = Logger();

  Prefs prefs;

  User? _currentUser;
  User? get currentUser => _currentUser;

  DashboardViewmodel(this.prefs);
  Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUser = prefs.getUser();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    prefs.clearUser();

    logger.d("LOGOUT BERHASIL");
  }
}
