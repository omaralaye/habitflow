import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;

  bool get isSignedIn => _user != null;
  User? get user => _user;

  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, {String? name, String? emoji}) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(email: email, password: password);
      if (response.user != null) {
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'name': name ?? '',
          'email': email,
          'emoji': emoji ?? '🦊',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> signInWithGoogle() async {
    throw UnimplementedError('Google Sign-In requires additional configuration.');
  }

  Future<void> signInWithApple() async {
    throw UnimplementedError('Apple Sign-In requires additional configuration.');
  }
}
