import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDatasource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> cleanToken();
}

class AuthLocalDatasourceImpl extends AuthLocalDatasource {
  final SharedPreferences prefs;

  AuthLocalDatasourceImpl(this.prefs);

  static const _tokenKey = 'auth_token';

  @override
  Future<void> cleanToken() async {
    await prefs.remove(_tokenKey);
    print("clear Token");
  }

  @override
  Future<String?> getToken() async {
    final token = prefs.getString(_tokenKey);
    print("Get Token $token");
    return token;
  }

  @override
  Future<void> saveToken(String token) async {
    await prefs.setString(_tokenKey, token);
    print("Saved Token $token");
  }
}
