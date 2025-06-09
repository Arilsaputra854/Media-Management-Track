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

  Future<void> init() async {
    await _fetchMedias();
    await _fetchSchools();
  }

  Future<void> _fetchMedias() async {
    final snapshot = await _firestore.collection('media_kit').get();
    _medias = snapshot.docs.map((doc) => Media.fromJson(doc.data())).toList();
    notifyListeners();
  }

  Future<void> _fetchSchools() async {
    final snapshot = await _firestore.collection('school').get();
    _schools = snapshot.docs.map((doc) => School(doc['name'], doc.id)).toList();
    _selectedSchool = _schools.isNotEmpty ? _schools.first : null;
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
