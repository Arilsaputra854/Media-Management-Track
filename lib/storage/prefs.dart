import 'dart:convert';

import 'package:logger/web.dart';
import 'package:media_management_track/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  Logger log = Logger();
  final String key = "USER_PREFS";

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(user.toJson()));
    log.d("SAVE USER PREF ${user.toJson}");
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(key) != null) {
      log.d("GET USER PREF ${prefs.getString(key)}");
      return User.fromJson(jsonDecode(prefs.getString(key)!));
    } else {
      return null;
    }
  }
}
