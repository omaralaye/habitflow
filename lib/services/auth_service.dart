import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/error_handler.dart';

class AuthService extends ChangeNotifier {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  // Use a factory for backward compatibility or for general use.
  factory AuthService() => instance;

  AuthService._internal() {
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  // Allow for injection in tests.
  @visibleForTesting
  static void setMockInstance(AuthService mock) {
    _instance = mock;
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;

  bool get isSignedIn => _user != null;
  User? get user => _user;

  Future<ServiceResult<void>> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure(e);
    }
  }

  Future<ServiceResult<void>> signUp(String email, String password, {String? name, String? emoji}) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name ?? '',
          'emoji': emoji ?? '🦊',
        },
      );
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure(e);
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
