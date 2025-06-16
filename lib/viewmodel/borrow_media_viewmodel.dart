import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/media.dart';
import '../model/school.dart';

class BorrowMediaViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Media> _medias = [];
  List<School> _schools = [];
  School? _selectedSchool;
  final Map<Media, int> _borrowedItems = {};

  List<Media> get medias => _medias;
  List<School> get schools => _schools;
  School? get selectedSchool => _selectedSchool;
  Map<Media, int> get borrowedItems => _borrowedItems;

  bool hasPendingRequest = false;

  bool hasActiveRequest = false;
  bool hasActiveBorrow = false;

  

  Future<bool> checkHasActiveBorrow(String userId) async {
  final borrowRequestSnapshot = await FirebaseFirestore.instance
      .collection('borrow_requests')
      .where('user_id', isEqualTo: userId)
      .where('status', whereIn: ['pending', 'requested'])
      .get();

  final historySnapshot = await FirebaseFirestore.instance
      .collection('history')
      .where('user_id', isEqualTo: userId)
      .where('status', isEqualTo: 'borrowed')
      .get();

  final result = borrowRequestSnapshot.docs.isEmpty && historySnapshot.docs.isEmpty;
  hasActiveBorrow = !result;
  notifyListeners();
  return result; // true artinya boleh pinjam
}


  Future<void> init() async {
    await _fetchMedias();
    await _fetchSchools();
  }

  Future<void> _fetchMedias() async {
    final snapshot = await _firestore.collection('media_kit').get();
    _medias =
        snapshot.docs.map((doc) => Media.fromJson(doc.data(), doc.id)).toList();
    notifyListeners();
  }

  Future<void> _fetchSchools() async {
    final snapshot = await _firestore.collection('school').get();
    _schools = snapshot.docs.map((doc) => School(doc['name'], doc.id)).toList();
    _selectedSchool = _schools.isNotEmpty ? _schools.first : null;
    notifyListeners();
  }

  Future<void> submitBorrowRequests(String userId) async {
    if (_selectedSchool == null || _borrowedItems.isEmpty) return;

    final batch = _firestore.batch();
    final borrowRequestsRef = _firestore.collection('borrow_requests');

    for (var entry in _borrowedItems.entries) {
      final media = entry.key;
      final pcs = entry.value;

      final newDoc = borrowRequestsRef.doc();

      batch.set(newDoc, {
        'user_id': userId,
        'school_id': _selectedSchool!.id,
        'media_id': media.id,
        'pcs': pcs,
        'status': 'requested',
        'request_at': Timestamp.now(),
        'accept_at': null,
      });
    }

    await batch.commit();
    _borrowedItems.clear();
    notifyListeners();
  }

  void selectSchool(School? school) {
    _selectedSchool = school;
    notifyListeners();
  }

  void setBorrowed(Media media, int pcs) {
    _borrowedItems[media] = pcs;
    notifyListeners();
  }

  void removeBorrowed(Media media) {
    borrowedItems.remove(media);
    notifyListeners();
  }
}
