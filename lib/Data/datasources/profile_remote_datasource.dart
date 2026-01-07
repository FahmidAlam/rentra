import 'package:rentra/core/supabase_client.dart';

abstract class IProfileRemoteDataSource {
  Future<Map<String, dynamic>?> fetchProfileById(String userId);
  Future<bool> updateProfile(String userId, Map<String, dynamic> updates);
}

class ProfileRemoteDataSource implements IProfileRemoteDataSource {
  @override
  Future<Map<String, dynamic>?> fetchProfileById(String userId) async {
    try {
      print('🔍 Fetching profile for user: $userId');
      
      final response = await SupabaseManager.supabase
          .from('profiles')
          .select('id, email, full_name, phone, role, created_at')
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) {
        print('⚠️ No profile found for user: $userId');
        return null;
      }
      
      print('✅ Profile loaded: ${response['email']}');
      return response as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return null;
    }
  }
  
  @override
  Future<bool> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      print('📝 Updating profile for user: $userId');
      
      await SupabaseManager.supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId);
      
      print('✅ Profile updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating profile: $e');
      return false;
    }
  }
}