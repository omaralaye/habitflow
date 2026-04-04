import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  bool get isSignedIn => _user != null;
  User? get user => _user;

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> signInWithGoogle() async {
    // Note: Actual Google Sign-In requires google_sign_in package
    // For now, we'll keep it as a placeholder but using FirebaseAuth logic
    // This is often handled by a separate plugin that provides the credential
    throw UnimplementedError('Google Sign-In requires additional configuration.');
  }

  Future<void> signInWithApple() async {
    // Similar to Google Sign-In, requires sign_in_with_apple package
    throw UnimplementedError('Apple Sign-In requires additional configuration.');
  }
}
