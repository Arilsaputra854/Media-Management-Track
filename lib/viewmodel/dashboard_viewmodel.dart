import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:media_management_track/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_management_track/view/borrow_media_page.dart';
import 'package:media_management_track/view/borrow_request_page.dart';
import 'package:media_management_track/view/history_borrow_page.dart';
import 'package:media_management_track/view/media_page.dart';
import 'package:media_management_track/view/request_trainer_page.dart';
import 'package:media_management_track/view/school_page.dart';
import 'package:media_management_track/view/trainer_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;


class DashboardViewmodel extends ChangeNotifier {
  User? currentUser;
  Widget? selectedPage;
  String? pageTitle;
  String? selectedKey;

  Future<void> init() async {
    // Ambil user dari auth service atau Firebase
    await getCurrentUser();

    if (selectedPage == null) {
      if (currentUser?.role == 'admin') {
        updatePage(const TrainerPage(), "Kelola Trainer", "trainer");
      } else if (currentUser?.role == 'trainer') {
        updatePage(const BorrowMediaPage(), "Pinjam Media", "borrowMedia");
      }
    }


    final prefs = await SharedPreferences.getInstance();
    pageTitle = prefs.getString('lastPageTitle') ?? 'Dashboard';
    String? lastPageKey = prefs.getString('lastPageKey');

    switch (lastPageKey) {
      case 'media':
        selectedPage = const MediaPage();
        break;
      case 'trainer':
        selectedPage = const TrainerPage();
        break;
      case 'borrowMedia':
        selectedPage = const BorrowMediaPage();
        break;
      case 'history':
        selectedPage = HistoryBorrowPage(userRole: currentUser?.role ?? '');
        break;
      case 'borrowRequest':
        selectedPage = const BorrowRequestPage();
        break;
      case 'requestTrainer':
        selectedPage = const RequestTrainerPage();
        break;
      case 'school':
        selectedPage = const SchoolPage();
        break;
      default:
        selectedPage = null;
    }

    notifyListeners();
  }

  void updatePage(Widget page, String title, String key) async {
    selectedPage = page;
    pageTitle = title;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastPageTitle', title);
    await prefs.setString('lastPageKey', key);

    notifyListeners();
  }

  void logout() async {
    await auth.FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentUser = null;
  }

  Future<void> getCurrentUser() async {
  final authUser = auth.FirebaseAuth.instance.currentUser;

  if (authUser != null) {
    final uid = authUser.uid;

    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      currentUser = User.fromJson(data, id: uid);
    } else {
      // Jika user tidak ditemukan di Firestore, bisa logout atau kasih fallback
      currentUser = User(
        id: uid,
        email: authUser.email ?? '',
        name: 'Tanpa Nama',
        role: 'trainer',
        institution: '-',
        status: 'active',
      );
    }
  }
}

}
