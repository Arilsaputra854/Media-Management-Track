import 'package:media_management_track/auth/domain/repositories/auth_repository.dart';

class GetTokenUsecase {
  final AuthRepository repository;
  GetTokenUsecase(this.repository);

  Future<String?> call(){
    return repository.getToken();
  }
}
