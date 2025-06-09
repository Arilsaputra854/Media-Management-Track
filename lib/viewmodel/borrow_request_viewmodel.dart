import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:media_management_track/model/borrow_request.dart';

class BorrowRequestViewmodel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<BorrowRequest> _requests = [];

  bool get isLoading => _isLoading;
  List<BorrowRequest> get requests => _requests;

  Future<String> getUserNameById(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      if (doc.exists) {
        return doc.data()?['name'] ?? 'Tidak diketahui';
      } else {
        return 'User tidak ditemukan';
      }
    } catch (e) {
      print('Error: $e');
      return 'Error mengambil user';
    }
  }

  Future<void> fetchRequests() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _db.collection('borrow_requests').get();
      _requests =
          snapshot.docs.map((doc) => BorrowRequest.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching borrow requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void approveRequest(BorrowRequest request) async {
    try {
      await FirebaseFirestore.instance
          .collection('borrow_requests')
          .doc(request.id)
          .update({'status': 'approved', 'accept_at': Timestamp.now()});
      await FirebaseFirestore.instance
          .collection('history')
          .add({
      'user_id': request.userId,
      'school_id': request.schoolId,
      'status': 'borrow',
      'borrow_at': Timestamp.now(),
      'return_at': null,
    });

      fetchRequests();
    } catch (e) {
      debugPrint('Error approving request: $e');
    }
  }

  void declineRequest(BorrowRequest request) async {
    try {
      await FirebaseFirestore.instance
          .collection('borrow_requests')
          .doc(request.id)
          .update({'status': 'declined'});

      fetchRequests();
    } catch (e) {
      debugPrint('Error declining request: $e');
    }
  }

  Future<String> getSchoolNameById(String schoolId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('school')
              .doc(schoolId)
              .get();
      if (doc.exists) {
        return doc.data()?['name'] ?? 'Tidak diketahui';
      } else {
        return 'Sekolah tidak ditemukan';
      }
    } catch (e) {
      print('Error: $e');
      return 'Error mengambil user';
    }
  }
}
