import 'package:rentra/Data/datasources/profile_remote_datasource.dart';
import 'package:rentra/core/models/user_profile.dart';

class ProfileRepository {
  final IProfileRemoteDataSource remoteDataSource;
  
  ProfileRepository(this.remoteDataSource);
  
  Future<UserProfile?> getProfileById(String userId) async {
    try {
      final data = await remoteDataSource.fetchProfileById(userId);
      if (data == null) return null;
      return UserProfile.fromMap(data);
    } catch (e) {
      print('❌ Repository error: $e');
      return null;
    }
  }
  
  Future<bool> updateProfile(String userId, {
    String? fullName,
    String? phone,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      
      if (updates.isEmpty) return false;
      
      return await remoteDataSource.updateProfile(userId, updates);
    } catch (e) {
      print('❌ Repository error updating profile: $e');
      return false;
    }
  }
}