import 'dart:convert';

import 'package:logger/web.dart';
import 'package:media_management_track/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  Logger log = Logger();
  final String key = "USER_PREFS";
  SharedPreferences prefs;

  Prefs(this.prefs);

  Future<void> saveUser(User user) async {
    await prefs.setString(key, jsonEncode(user.toJson()));
    log.d("SAVE USER PREF ${user.toJson}");
  }

  User? getUser()  {
    if (prefs.getString(key) != null) {
      log.d("GET USER PREF ${prefs.getString(key)}");
      return User.fromJson(jsonDecode(prefs.getString(key)!));
    } else {
      return null;
    }
  }

  Future<void> clearUser() async {
    await prefs.clear();
  }
}
