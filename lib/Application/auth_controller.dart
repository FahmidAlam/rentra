import "package:supabase_flutter/supabase_flutter.dart";
import 'package:rentra/core/supabase_client.dart';

class AuthController {
  final SupabaseClient _client = SupabaseManager.supabase;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> login(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> register(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<void> saveUserRole({
    required String userId,
    required String role,
  }) async {
    await _client.from('profiles').insert({'id': userId, 'role': role});
  }

  // FETCH ROLE
  Future<String?> fetchUserRole(String userId) async {
    final res = await _client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();

    return res['role'];
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
