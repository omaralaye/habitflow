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

  bool get isSignedIn => _supabase.auth.currentSession != null;
  User? get user => _user ?? _supabase.auth.currentUser;

  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, {String? name, String? emoji}) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'emoji': emoji,
        },
      );

      if (res.user != null) {
        // In Supabase, we can also use a trigger to create a profile in a public table.
        // For simplicity here, we'll assume the metadata is enough or handle it via a profiles table if needed.
        // Let's also insert into a profiles table if it exists.
        try {
          await _supabase.from('profiles').upsert({
            'id': res.user!.id,
            'full_name': name,
            'emoji': emoji,
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          // profiles table might not exist yet, metadata is our fallback
          debugPrint('Failed to update profiles table: $e');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> signInWithApple() async {
    await _supabase.auth.signInWithOAuth(OAuthProvider.apple);
  }
}
