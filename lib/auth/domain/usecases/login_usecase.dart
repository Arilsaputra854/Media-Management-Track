import 'package:media_management_track/auth/domain/entities/user.dart';
import 'package:media_management_track/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  AuthRepository repository;

  LoginUsecase(this.repository);

  Future<User> call(String email, String password){
    return repository.login(email, password);
  }
}