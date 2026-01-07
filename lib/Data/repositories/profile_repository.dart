import 'package:rentra/Data/datasources/profile_remote_datasource.dart';

class ProfileRepository {
  final IProfileRemoteDataSource remoteDataSource;

  ProfileRepository(this.remoteDataSource);

  Future<Map<String, dynamic>?> getProfileById(String userId) async {
    try {
      return await remoteDataSource.fetchProfileById(userId);
    } catch (e) {
      print('❌ Repository error: $e');
      return null;
    }
  }
}