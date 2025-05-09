import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_management_track/auth/domain/repositories/auth_repository.dart';
import 'package:media_management_track/auth/domain/usecases/login_usecase.dart';
import 'package:media_management_track/auth/domain/usecases/register_usecase.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_event.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.registerUsecase,
    required this.loginUsecase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<AuthCheckingRequested>(_onCheckRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await loginUsecase(event.email, event.password);
      emit(AuthLoginSuccess(user));
    } catch (e) {
      emit(AuthFailure("Login Gagal : ${e.toString()}"));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await registerUsecase(event.name, event.email, event.password);
      emit(AuthRegisterSuccess());
    } catch (e) {
      emit(AuthFailure("Register Gagal : ${e.toString()}"));
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckingRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final token = await authRepository.getToken();

    if (token != null && token.isNotEmpty) {
      emit(AuthIsLoggedIn(token));
    } else {
      emit(AuthLogoutSuccess());
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.logout();
      emit(AuthLogoutSuccess());
  }
}
