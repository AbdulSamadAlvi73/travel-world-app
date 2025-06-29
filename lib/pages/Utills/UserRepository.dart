import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final _auth    = FirebaseAuth.instance;
  final _fireDB  = FirebaseFirestore.instance;

  /// Returns the current user's Firestore document as a Map
  Future<Map<String, dynamic>?> fetchCurrentUserDoc() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;               // not signed in

    final snap = await _fireDB.collection('users').doc(uid).get();
    if (!snap.exists) return null;              // doc not found

    return snap.data();                         // ← user fields
  }
}
