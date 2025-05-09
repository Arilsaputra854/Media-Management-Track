import 'package:media_management_track/auth/data/datasources/auth_local_datasource.dart';
import 'package:media_management_track/auth/data/datasources/auth_remote_datasource.dart';
import 'package:media_management_track/auth/domain/entities/user.dart';
import 'package:media_management_track/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl(this.remoteDatasource, this.localDatasource);

  @override
  Future<User> login(String email, String password) async {
    User user = await remoteDatasource.login(email, password);
    await localDatasource.saveToken("bearer token-${user.email}");

    return user;
  }

  @override
  Future<User> register(String name, String email, String password) {
    return remoteDatasource.register(name, email, password);
  }
  
  @override
  Future<void> logout() async {
    await localDatasource.cleanToken();
  }
  
  @override
  Future<String?> getToken() {
    return  localDatasource.getToken();
    
  }

  
}
