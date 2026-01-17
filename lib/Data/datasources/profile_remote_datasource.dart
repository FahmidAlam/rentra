import 'package:rentra/core/supabase_client.dart';

abstract class IProfileRemoteDataSource {
  Future<Map<String, dynamic>?> fetchProfileById(String userId);
  Future<bool> updateProfile(String userId, Map<String, dynamic> updates);
}

class ProfileRemoteDataSource implements IProfileRemoteDataSource {
  @override
  Future<Map<String, dynamic>?> fetchProfileById(String userId) async {
    try {
      final response = await SupabaseManager.supabase
          .from('profiles')
          .select('id, email, full_name, phone, role, created_at')
          .eq('id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<bool> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await SupabaseManager.supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId);
      
      return true;
    } catch (e) {
      return false;
    }
  }
}