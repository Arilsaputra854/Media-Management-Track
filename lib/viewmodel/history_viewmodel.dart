import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:media_management_track/model/borrow_request.dart';
import 'package:media_management_track/model/history.dart';

class HistoryViewmodel extends ChangeNotifier {
  Logger logger = Logger();

  bool _loading = false;
  String? _errorMsg;

  String? get errorMsg => _errorMsg;
  bool get loading => _loading;

  final firestore = FirebaseFirestore.instance;

  Stream<List<BorrowRequest>> streamRequestedList({String? id}) {
    return firestore
        .collection('borrow_requests')
        .where('status', isEqualTo: 'requested')
        .snapshots()
        .map((snapshot) {
          final result =
              snapshot.docs
                  .map((doc) => BorrowRequest.fromFirestore(doc))
                  .toList();
          logger.i(
            'streamRequestedList → ${result.length} ditemukan tanpa filter',
          );
          return result;
        });
  }

  Stream<List<History>> streamBorrowList({String? id}) {
    Query query = firestore
        .collection('history')
        .where('status', isEqualTo: 'borrow');

    if (id != null && id.isNotEmpty) {
      query = query.where('user_id', isEqualTo: id);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                History.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  Stream<List<History>> streamReturnList({String? id}) {
    Query query = firestore
        .collection('history')
        .where('status', isEqualTo: 'return');

    if (id != null && id.isNotEmpty) {
      query = query.where('user_id', isEqualTo: id);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                History.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  Future<bool> returnItem(String historyId) async {
    _loading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      await firestore.collection('history').doc(historyId).update({
        'status': 'return',
        'return_at': FieldValue.serverTimestamp(),
      });

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      logger.e("Error returnItem: $e");
      _errorMsg = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String> getUserName(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    return doc.data()?['name'] ?? 'User Tidak Dikenal';
  }

  Future<String> getSchoolName(String schoolId) async {
    final doc = await firestore.collection('school').doc(schoolId).get();
    return doc.data()?['name'] ?? 'Sekolah Tidak Dikenal';
  }

  Future<String> getMediaName(String mediaId) async {
  try {
    final doc = await firestore.collection('media_kit').doc(mediaId).get();
    return doc.data()?['name'] ?? 'Media Tidak Dikenal';
  } catch (e) {
    logger.e('Error getMediaName: $e');
    return 'Media Tidak Dikenal';
  }
}

}
