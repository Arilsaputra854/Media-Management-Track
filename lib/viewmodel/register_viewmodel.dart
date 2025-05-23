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
  }) async {
    _errorMsg = null;
    _loading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.credential != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'email': email,
              'name': name,
              'createdAt': FieldValue.serverTimestamp(),
              'updateAt': FieldValue.serverTimestamp(),
            });

        logger.d(
          "Create Account Successfully With Email ${userCredential.user!.email}",
        );

        _loading = false;
        notifyListeners();
        return true;
      } else {
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
}
