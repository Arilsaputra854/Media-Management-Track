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

  Stream<List<BorrowRequest>> get requestStream {
    return _db.collection('borrow_requests').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BorrowRequest.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> approveRequest(BorrowRequest request, BuildContext context) async {
  final mediaRef = _db.collection('media_kit').doc(request.mediaId);
  final requestRef = _db.collection('borrow_requests').doc(request.id);

  try {
    await _db.runTransaction((transaction) async {
      final mediaSnap = await transaction.get(mediaRef);

      if (!mediaSnap.exists) {
        throw Exception('Media tidak ditemukan');
      }

      final data = mediaSnap.data();
      final List<dynamic> items = data?['items'] ?? [];

      // Hitung item dengan status ready
      final readyItems = items.where((item) => item['status'] == 'ready').toList();

      if (readyItems.length < request.pcs) {
        throw Exception('Stok tidak mencukupi');
      }

      // Tandai sejumlah item sebagai borrowed
      for (int i = 0; i < request.pcs; i++) {
        readyItems[i]['status'] = 'borrow';
        readyItems[i]['borrowed_at'] = Timestamp.now();
        readyItems[i]['borrowed_by'] = request.userId;
      }

      // Update item di media
      transaction.update(mediaRef, {'items': items});

      // Update status permintaan
      transaction.update(requestRef, {
        'status': 'approved',
        'accept_at': Timestamp.now(),
      });

      // Tambah ke history
      final historyRef = _db.collection('history').doc();
      transaction.set(historyRef, {
        'user_id': request.userId,
        'school_id': request.schoolId,
        'media_id': request.mediaId,
        'media_name': request.mediaName,
        'pcs': request.pcs,
        'status': 'borrow',
        'borrow_at': Timestamp.now(),
        'return_at': null,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permintaan disetujui.')),
    );
  } catch (e, stackTrace) {
    debugPrint('❌ Error approving request: $e');
    debugPrint('📄 StackTrace:\n$stackTrace');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menyetujui: ${e.toString()}')),
    );
  }
}


  /// Tolak permintaan peminjaman
  Future<void> declineRequest(
    BorrowRequest request,
    BuildContext context,
  ) async {
    try {
      await _db.collection('borrow_requests').doc(request.id).update({
        'status': 'declined',
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Permintaan ditolak.')));
    } catch (e) {
      debugPrint('Error declining request: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menolak: ${e.toString()}')));
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

  Future<String> getMediaNameById(String mediaId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('media_kit')
              .doc(mediaId)
              .get();
      if (doc.exists) {
        return doc.data()?['name'] ?? 'Tidak diketahui';
      } else {
        return 'Media tidak ditemukan';
      }
    } catch (e) {
      debugPrint('Error: $e');
      return 'Error mengambil media';
    }
  }
}
