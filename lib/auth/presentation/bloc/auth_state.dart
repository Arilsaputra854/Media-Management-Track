import 'package:equatable/equatable.dart';
import 'package:media_management_track/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable{
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState{}

class AuthLoading extends AuthState{}

class AuthLoginSuccess extends AuthState{
  final User user;

  AuthLoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthRegisterSuccess extends AuthState{
}

class AuthFailure extends AuthState{
  final String message;

  AuthFailure(this.message);

  @override  
  List<Object?> get props => [message];
}



class AuthIsLoggedIn extends AuthState {
  final String token;
  AuthIsLoggedIn(this.token);
}

class AuthLogoutSuccess extends AuthState{}