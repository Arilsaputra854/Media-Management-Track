import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:media_management_track/model/media.dart';

class MediaViewmodel extends ChangeNotifier{
  List<Media> _media = [];
  List<Media> get media => _media;

  Future<void> fetchMedia() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('media_kit').get();

    List<Media> mediaKitsSnapshot = snapshot.docs.map((doc) {
      return Media.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();


    _media = mediaKitsSnapshot.toList();
    notifyListeners();
  }

  Future<bool> addMedia(Media media) async {
    try {
      await FirebaseFirestore.instance.collection('media_kit').add(media.toJson());

      await fetchMedia();
      return true;
    } catch (e) {
      debugPrint('Error adding media: $e');
      return false;
    }

  }
}