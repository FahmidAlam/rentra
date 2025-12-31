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
    // Ensure we don't error on duplicate primary key: upsert if profile exists
    try {
      final existing = await _client.from('profiles').select('id').eq('id', userId).maybeSingle();
      if (existing == null) {
        await _client.from('profiles').insert({'id': userId, 'role': role});
      } else {
        await _client.from('profiles').update({'role': role}).eq('id', userId);
      }
    } catch (e) {
      throw Exception('Failed to save user role: $e');
    }
  }

  // FETCH ROLE
  Future<String?> fetchUserRole(String userId) async {
    try {
      final res = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (res == null) return null;
      return res['role'] as String?;
    } catch (e) {
      // If the profiles table or query fails, surface a clear exception
      throw Exception('Failed to fetch user role: $e');
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
