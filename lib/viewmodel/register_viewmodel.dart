import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/web.dart';

class RegisterViewmodel extends ChangeNotifier {
  Logger logger = Logger();
  String? _errorMsg;
  bool _loading = false;

  String? get errorMsg => _errorMsg;
  bool get loading => _loading;

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String institution,
  }) async {
    _errorMsg = null;
    _loading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user?.uid != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'email': email,
              'name': name,
              'role': "trainer",
              'status': "requested",
              'institution': institution,
              'createdAt': FieldValue.serverTimestamp(),
              'updateAt': FieldValue.serverTimestamp(),
            });

        await FirebaseAuth.instance.signOut();
        logger.d(
          "Create Account Successfully With Email ${userCredential.user!.email}",
        );

        _loading = false;
        notifyListeners();
        return true;
      } else {
        _errorMsg = "Tidak dapat menyimpan data";
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      logger.e("Error Register ${e.toString()}");
      _errorMsg = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<String>> getInstitutions() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("institutions").get();
    List<String> tempList = [];

    for (var doc in snapshot.docs) {
      tempList.add(doc['name']);
    }

    return tempList;
  }
}
