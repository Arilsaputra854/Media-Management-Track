import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:media_management_track/model/media.dart';

class MediaViewmodel extends ChangeNotifier{
  List<Media> _media = [];
  List<Media> get media => _media;

  Future<void> fetchUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('media_kit').get();

    List<Media> mediaKitsSnapshot = snapshot.docs.map((doc) {
      return Media.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();

    _media = mediaKitsSnapshot.toList();
    notifyListeners();
  }


}