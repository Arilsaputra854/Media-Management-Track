import 'package:media_management_track/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({String? name, required String email, required String role})
    : super(name: name, email: email, role: role);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      role: json['role'],
      name: json['name'],
    );
  }
}
