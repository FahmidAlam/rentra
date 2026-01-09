import 'package:rentra/core/models/user_profile.dart';
import "package:supabase_flutter/supabase_flutter.dart";
import 'package:rentra/core/supabase_client.dart';
import 'package:rentra/Data/datasources/profile_remote_datasource.dart';
import 'package:rentra/Data/repositories/profile_repository.dart';
class AuthController {
  final SupabaseClient _client = SupabaseManager.supabase;
  

  final ProfileRepository _profileRepository = ProfileRepository(
    ProfileRemoteDataSource(),
  );

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
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        // Create new profile
        await _client.from('profiles').insert({
          'id': userId,
          'email': email,
          'full_name': fullName ?? '',
          'phone': phone ?? '',
          'role': role,
        });
      } else {
        // Update existing profile
        await _client.from('profiles').update({
          'email': email,
          'full_name': fullName ?? '',
          'phone': phone ?? '',
          'role': role,
        }).eq('id', userId);

      }
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }

  /// Save user role (legacy - kept for backward compatibility)
  Future<void> saveUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      if (existing == null) {
        await _client.from('profiles').insert({'id': userId, 'role': role});
      } else {
        await _client.from('profiles').update({'role': role}).eq('id', userId);
      }
    } catch (e) {
      throw Exception('Failed to save user role: $e');
    }
  }

  /// Fetch user role - KEPT UNCHANGED for RoleController
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

  /// Fetch full user profile - KEPT UNCHANGED (returns raw Map)
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

  /// type safe access
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      return await _profileRepository.getProfileById(userId);
    } catch (e) {
      return null;
    }
  }

  //! Update specific profile fields

  Future<bool> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
  }) async {
    try {
      return await _profileRepository.updateProfile(
        userId,
        fullName: fullName,
        phone: phone,
      );
    } catch (e) {
      return false;
    }
  }

  //! Check if profile is complete
  Future<bool> isProfileComplete(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?.isComplete ?? false;
    } catch (e) {
      return false;
    }
  }
}