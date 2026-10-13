import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brew_crew/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<AppUser> user(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map(
          (snapshot) => AppUser.fromMap(uid, snapshot.data() ?? {}),
        );
  }

  Future<void> createProfile({
    required String uid,
    required String name,
    required String email,
    String role = 'customer',
  }) {
    return _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      'defaultSugars': 0,
      'defaultMilk': 'Whole milk',
    }, SetOptions(merge: true));
  }
}
