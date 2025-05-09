import 'package:media_management_track/auth/domain/entities/user.dart';

abstract class TrainerRemoteDatasource {
  Future<List<User>> getAllUser();
}

class TrainerRemoteDatasourceImpl extends TrainerRemoteDatasource {
  @override
  Future<List<User>> getAllUser() async {
    List<User> mockUsers = [
      User(name: 'John Doe', email: 'john.doe@example.com', role: 'Trainer'),
      User(name: 'Jane Smith', email: 'jane.smith@example.com', role: 'Trainer'),
      User(name: 'Alice Brown', email: 'alice.brown@example.com', role: 'Trainer'),
    ];

    return mockUsers;
  }
}
