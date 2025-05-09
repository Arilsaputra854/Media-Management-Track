import 'package:media_management_track/auth/domain/entities/user.dart';
import 'package:media_management_track/auth/domain/repositories/auth_repository.dart';

class RegisterUsecase {
  AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<User> call(String name, String email, String password){
    return repository.register(name, email, password);
  }
}