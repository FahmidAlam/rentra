import "package:supabase_flutter/supabase_flutter.dart";
import 'package:rentra/core/supabase_client.dart';

class AuthController {
  final SupabaseClient _client = SupabaseManager.supabase;

  User? get currentUser => _client.auth.currentUser;

  /// Login user
  Future<AuthResponse> login(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Register user
  Future<AuthResponse> register(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  /// Save user profile with all details - ENHANCED
  Future<void> saveUserProfile({
    required String userId,
    required String email,
    String? fullName,
    String? phone,
    required String role,
  }) async {
    try {
      print('⏳ Saving profile for user: $userId');

      final existing =
          await _client.from('profiles').select('id').eq('id', userId).maybeSingle();

      if (existing == null) {
        // Create new profile
        await _client.from('profiles').insert({
          'id': userId,
          'email': email,
          'full_name': fullName ?? '',
          'phone': phone ?? '',
          'role': role,
        });
        print('✅ New profile created');
      } else {
        // Update existing profile
        await _client.from('profiles').update({
          'email': email,
          'full_name': fullName ?? '',
          'phone': phone ?? '',
          'role': role,
        }).eq('id', userId);
        print('✅ Profile updated');
      }
    } catch (e) {
      print('❌ Error saving profile: $e');
      throw Exception('Failed to save profile: $e');
    }
  }

  /// Save user role (legacy - kept for backward compatibility)
  Future<void> saveUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      final existing =
          await _client.from('profiles').select('id').eq('id', userId).maybeSingle();
      if (existing == null) {
        await _client.from('profiles').insert({'id': userId, 'role': role});
      } else {
        await _client.from('profiles').update({'role': role}).eq('id', userId);
      }
    } catch (e) {
      throw Exception('Failed to save user role: $e');
    }
  }

  /// Fetch user role
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
      throw Exception('Failed to fetch user role: $e');
    }
  }

  /// Fetch full user profile
  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      return await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}