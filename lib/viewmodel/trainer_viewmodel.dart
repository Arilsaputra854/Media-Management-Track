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

  Future<List<User>> fetchUsers() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .get()
        .timeout(const Duration(seconds: 10));

    final users = snapshot.docs.map((doc) {
      return User.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();

    return users
        .where((user) => user.role == 'trainer' && user.status == 'accepted')
        .toList();
  } catch (e) {
    log.e(e.toString());
    rethrow;
  }
}

}
