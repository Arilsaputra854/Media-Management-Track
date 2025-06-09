import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:media_management_track/model/user.dart' show User;

class RequestTrainerViewmodel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<User> requestedUsers = [];
  bool isLoading = false;

  Future<void> fetchRequestedUsers() async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('status', isEqualTo: 'requested')
          .get();

      requestedUsers = snapshot.docs
          .map((doc) => User.fromJson(doc.id, doc.data())) //TODO
          .toList();
    } catch (e) {
      print('Error fetchRequestedUsers: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> acceptUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'accepted',
      });

      requestedUsers.removeWhere((user) => user.id == userId);
      notifyListeners();
    } catch (e) {
      print('Error acceptUser: $e');
    }
  }

  Future<void> declineUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'declined',
      });

      requestedUsers.removeWhere((user) => user.id == userId);
      notifyListeners();
    } catch (e) {
      print('Error declineUser: $e');
    }
  }
}
