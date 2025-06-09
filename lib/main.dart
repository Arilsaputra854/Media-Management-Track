import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/firebase_options.dart';
import 'package:media_management_track/model/user.dart';
import 'package:media_management_track/storage/prefs.dart';
import 'package:media_management_track/view/borrow_media_page.dart';
import 'package:media_management_track/view/borrow_request_page.dart';
import 'package:media_management_track/view/dashboard_page.dart';
import 'package:media_management_track/view/history_borrow_page.dart';
import 'package:media_management_track/view/login_page.dart';
import 'package:media_management_track/view/register_page.dart';
import 'package:media_management_track/view/splash_screen_page.dart';
import 'package:media_management_track/view/trainer_detail_page.dart';
import 'package:media_management_track/viewmodel/borrow_media_viewmodel.dart';
import 'package:media_management_track/viewmodel/borrow_request_viewmodel.dart';
import 'package:media_management_track/viewmodel/dashboard_viewmodel.dart';
import 'package:media_management_track/viewmodel/history_viewmodel.dart';
import 'package:media_management_track/viewmodel/login_viewmodel.dart';
import 'package:media_management_track/viewmodel/media_viewmodel.dart';
import 'package:media_management_track/viewmodel/register_viewmodel.dart';
import 'package:media_management_track/viewmodel/school_viewmodel.dart';
import 'package:media_management_track/viewmodel/trainer_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Prefs prefs = Prefs(sharedPreferences);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginViewmodel(prefs)),
        ChangeNotifierProvider(create: (_) => RegisterViewmodel()),
        ChangeNotifierProvider(create: (_) => DashboardViewmodel(prefs)),
        ChangeNotifierProvider(create: (_) => TrainerViewmodel()),
        ChangeNotifierProvider(create: (_) => MediaViewmodel()),
        ChangeNotifierProvider(create: (_) => HistoryViewmodel()),
        ChangeNotifierProvider(create: (_) => BorrowMediaViewModel()),
        ChangeNotifierProvider(create: (_) => SchoolViewmodel()),
        ChangeNotifierProvider(create: (_) => BorrowRequestViewmodel()),
      ],
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
    GoRoute(path: '/borrow', builder: (context, state) => BorrowMediaPage()),
    GoRoute(path: '/schools', builder: (context, state) => BorrowMediaPage()),
    GoRoute(path: '/request-become-trainer', builder: (context, state) => BorrowMediaPage()),
    GoRoute(path: '/request-borrow-media', builder: (context, state) => BorrowRequestPage()),
    GoRoute(
      path: '/trainer',
      builder: (context, state) {
        final user = state.extra as User;
        return TrainerDetailPage(user: user);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) {
        return HistoryBorrowPage();
      },
    ),
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
