import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_management_track/auth/data/datasources/auth_local_datasource.dart';
import 'package:media_management_track/auth/data/datasources/auth_remote_datasource.dart';
import 'package:media_management_track/auth/data/repositories/auth_repository_impl.dart';
import 'package:media_management_track/auth/domain/usecases/login_usecase.dart';
import 'package:media_management_track/auth/domain/usecases/register_usecase.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_bloc.dart';
import 'package:media_management_track/auth/presentation/pages/login_page.dart';
import 'package:media_management_track/splashscreen/presentation/splash_screen_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  final authRepository = AuthRepositoryImpl(
    AuthRemoteDatasourceImpl(),
    AuthLocalDatasourceImpl(pref),
  );
  final loginUsecase = LoginUsecase(authRepository);
  final registerUsecase = RegisterUsecase(authRepository);

  runApp(
    MaterialApp(
      home: BlocProvider(
        create:
            (_) => AuthBloc(
              loginUsecase: loginUsecase,
              registerUsecase: registerUsecase,
              authRepository: authRepository,
            ),
        child: MyApp(authRepository: authRepository,),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;

  const MyApp({super.key, required this.authRepository});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreenPage(authRepository));
  }
}
