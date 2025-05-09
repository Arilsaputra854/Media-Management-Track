import 'package:media_management_track/auth/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
}

class AuthRemoteDatasourceImpl extends AuthRemoteDatasource {
  @override
  Future<UserModel> login(String email, String password) async {
    if (email == "racerrobotic@gmail.com" && password == "Arilsaputra854") {
      return UserModel(email: email, role: "Admin",name: "Racer Robotic");
    } else if (email == "arilsaputra854@gmail.com" &&
        password == "Arilsaputra854") {
      return UserModel(email: email, role: "Trainer", name: "Aril Saputra");
    } else {
      throw Exception("Akun tidak ditemukan");
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    return UserModel(name: name, email: email, role: "trainer");
  }
}
