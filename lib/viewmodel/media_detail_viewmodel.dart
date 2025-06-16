import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:media_management_track/model/media.dart';

class DetailMediaViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> addNewItem(
      {required String documentId, required String newItemId}) async {
    _setLoading(true);
    _setError(null);

    final newItem = MediaItem(
      id: newItemId,
      status: MediaStatus.ready,
      borrowedAt: null,
      borrowedBy: null,
      returnedAt: null,
    );

    try {
      final mediaDocRef = _firestore.collection('media_kit').doc(documentId);

      await mediaDocRef.update({
        'items': FieldValue.arrayUnion([newItem.toJson()])
      });

      _setLoading(false);
      return true; // Berhasil
    } catch (e) {
      _setError('Gagal menambahkan item baru: ${e.toString()}');
      _setLoading(false);
      return false; // Gagal
    }
  }
}
