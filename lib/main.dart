import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/firebase_options.dart';
import 'package:media_management_track/view/dashboard_page.dart';
import 'package:media_management_track/view/login_page.dart';
import 'package:media_management_track/view/register_page.dart';
import 'package:media_management_track/view/splash_screen_page.dart';
import 'package:media_management_track/viewmodel/dashboard_viewmodel.dart';
import 'package:media_management_track/viewmodel/login_viewmodel.dart';
import 'package:media_management_track/viewmodel/register_viewmodel.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => LoginViewmodel()), ChangeNotifierProvider(create: (_)=> RegisterViewmodel(),),ChangeNotifierProvider(create: (context)=> DashboardViewmodel(context),)],
      child: MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashScreenPage()),
    GoRoute(path: '/dashboard', builder: (context, state) => DashboardPage()),
    GoRoute(path: '/register', builder: (context, state) => RegisterPage()),
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: "Media Management Track",
    );
  }
}
