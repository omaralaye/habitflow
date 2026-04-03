import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  void signIn() {
    _isSignedIn = true;
    notifyListeners();
  }

  void signOut() {
    _isSignedIn = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    signIn();
  }

  Future<void> signInWithApple() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    signIn();
  }
}
