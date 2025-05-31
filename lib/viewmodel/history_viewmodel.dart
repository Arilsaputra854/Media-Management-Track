import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:media_management_track/model/history.dart';

class HistoryViewmodel extends ChangeNotifier {
  Logger logger = Logger();

  bool _loading = false;
  String? _errorMsg;

  String? get errorMsg => _errorMsg;
  bool get loading => _loading;

  final firestore = FirebaseFirestore.instance;

  Future<List<History>> getBorrowList() async {
    _loading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final querySnapshot =
          await firestore
              .collection('history')
              .where('status', isEqualTo: 'borrow')
              .get();

      final List<History> list =
          querySnapshot.docs
              .map((doc) => History.fromJson(doc.data()))
              .toList();

      _loading = false;
      notifyListeners();
      return list;
    } catch (e) {
      logger.e("Error getBorrowList: $e");
      _errorMsg = e.toString();
      _loading = false;
      notifyListeners();
      return [];
    }
  }

  Future<List<History>> getReturnList() async {
    _loading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final querySnapshot =
          await firestore
              .collection('history')
              .where('status', isEqualTo: 'return')
              .get();

      final List<History> list =
          querySnapshot.docs
              .map((doc) => History.fromJson(doc.data()))
              .toList();

      _loading = false;
      notifyListeners();
      return list;
    } catch (e) {
      logger.e("Error getReturnList: $e");
      _errorMsg = e.toString();
      _loading = false;
      notifyListeners();
      return [];
    }
  }

  Future<String> getUserName(String userId) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  return doc.data()?['name'] ?? 'User Tidak Dikenal';
}

Future<String> getSchoolName(String schoolId) async {
  final doc = await FirebaseFirestore.instance.collection('school').doc(schoolId).get();
  return doc.data()?['name'] ?? 'Sekolah Tidak Dikenal';
}

}
