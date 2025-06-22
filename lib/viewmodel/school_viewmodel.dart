import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import '../model/media.dart';
import '../model/school.dart';

class SchoolViewmodel extends ChangeNotifier {
  Logger log = Logger();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<School> _schools = [];
  School? _selectedSchool;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<School> get schools => _schools;
  School? get selectedSchool => _selectedSchool;

  Future<void> init() async {
    await _fetchSchools();
  }

  Future<void> _fetchSchools() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('school').get();
      _schools =
          snapshot.docs.map((doc) => School(doc['name'], doc.id)).toList();
      _selectedSchool = null;
      log.d("FETCH SCHOOLS : ${_schools.length}");
    } catch (e) {
      log.e(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectSchool(School? school) {
    _selectedSchool = school;
    notifyListeners();
  }

  void addSchool(String? schoolName) async {
    if (schoolName == null || schoolName.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Tambahkan ke Firestore
      await _firestore.collection('school').add({'name': schoolName});

      await _fetchSchools();

      log.i("Sekolah ditambahkan: ${schoolName}");
    } catch (e) {
      log.e("Gagal menambahkan sekolah: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeSchool(School? school) async {
    if (school == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Hapus dari Firestore
      await _firestore.collection('school').doc(school.id).delete();

      // Hapus dari list lokal
      _schools.removeWhere((s) => s.id == school.id);
      notifyListeners();

      log.i("Sekolah dihapus: ${school.name}");
    } catch (e) {
      log.e("Gagal menghapus sekolah: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSchool(School? school) async {
    if (school == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('school').doc(school.id).update({
        'name': school.name,
      });
      await _fetchSchools();


      log.i("Sekolah berhasil diupdate: ${school.name}");
    } catch (e) {
      log.e("Gagal update sekolah: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
