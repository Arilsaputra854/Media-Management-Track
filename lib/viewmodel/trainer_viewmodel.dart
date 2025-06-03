import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, QuerySnapshot;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:media_management_track/model/user.dart' show User;

class TrainerViewmodel extends ChangeNotifier {
  Logger log = Logger();
  List<User> _users = [];
  List<User> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<User> usersSnapshot =
          snapshot.docs.map((doc) {
            return User.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

      _users = usersSnapshot.where((user) => user.role == 'trainer').toList();
      notifyListeners();
    } catch (e) {
      log.e(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
