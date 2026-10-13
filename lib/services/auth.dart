import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // firebase instance in FirebaseAuth class

  // create a user object based on User from firebase_auth.dart
  UserModels? _userFromFirebase(User? user) {
    // '?' is used to make sure it is nullable
    return user != null ? UserModels(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<UserModels?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  // sign in anon
  Future<UserModels?> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;

      return _userFromFirebase(user);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  // sign in email & password
  Future<UserModels?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);

      User? user = result.user;
      return _userFromFirebase(user);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  // register with email & password
  Future<UserModels?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      User? user = result.user;

      if (user != null) {
        await UserService().createProfile(
          uid: user.uid,
          name: email.split('@').first,
          email: email,
        );
      }

      return _userFromFirebase(user);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }
}
