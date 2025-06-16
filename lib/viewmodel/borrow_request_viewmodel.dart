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
  final historyRef = _db.collection('history').doc(); // buat dokumen history
  final now = Timestamp.now();

  try {
    await _db.runTransaction((transaction) async {
      // 1. Ambil data media_kit
      final mediaSnap = await transaction.get(mediaRef);
      if (!mediaSnap.exists) {
        throw Exception('Media tidak ditemukan');
      }

      final mediaData = mediaSnap.data()!;
      final List<dynamic> items = List.from(mediaData['items'] ?? []);

      // 2. Filter item yang ready
      final readyItems = items.where((item) => item['status'] == 'ready').toList();
      if (readyItems.length < request.pcs) {
        throw Exception('Stok tidak cukup (${readyItems.length}/${request.pcs})');
      }

      // 3. Tandai sebagai dipinjam
      for (int i = 0; i < request.pcs; i++) {
        final indexInOriginal = items.indexOf(readyItems[i]);
        items[indexInOriginal]['status'] = 'borrow';
        items[indexInOriginal]['borrowed_at'] = now;
        items[indexInOriginal]['borrowed_by'] = request.userId;
      }

      // 4. Update media_kit.items
      transaction.update(mediaRef, {'items': items});

      // 5. Update status borrow_requests
      transaction.update(requestRef, {
        'status': 'approved',
        'accept_at': now,
      });

      // 6. Tambahkan history
      transaction.set(historyRef, {
        'user_id': request.userId,
        'school_id': request.schoolId,
        'media_id': request.mediaId,
        'media_name': request.mediaName ?? 'Tanpa Nama',
        'pcs': request.pcs,
        'status': 'borrow',
        'borrow_at': now,
        'return_at': null,
      });
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permintaan disetujui dan dicatat.')),
      );
    }

  } catch (e, s) {
    debugPrint('❌ Transaction Error: $e');
    debugPrint('📄 StackTrace:\n$s');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyetujui: ${e.runtimeType}: $e')),
      );
    }
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
