
import 'package:rentra/Data/datasources/tenancy_remote_datasource.dart';
import 'package:rentra/core/models/tenancy.dart';

class TenancyRepository {
  final ITenancyRemoteDataSource remote;

  TenancyRepository(this.remote);
  // ------------ used in owner dashboard -------------
  Future<void> requestTenancy({
    required String tenantId,
    required int unitId,
  }) {
    return remote.createTenancyRequest(
      tenantId: tenantId,
      unitId: unitId,
    );
  }
  Future<List<Tenancy>> getPendingTenanciesForOwner(
    String ownerId,
  )async {
    final data = await remote.getPendingTenanciesForOwner(ownerId);
    return data.map((json) => Tenancy.fromJson(json)).toList();
  }
  Future<void> updateTenancyStatus({
    required int tenancyId,
    required String status,
    required int unitId,
  })async{
    await remote.updateTenancyStatus(
      tenancyId: tenancyId,
      status: status,
      unitId: unitId,
    );
    if(status=='approved'){
      await remote.lockUnit(unitId: tenancyId);
    }
  }
  Future<List<Map<String, dynamic>>> getPendingRequests(
    String ownerId,
  ) {
    return remote.fetchPendingForOwner(ownerId);
  }

  Future<void> approve(int tenancyId, int unitId) {
    return remote.approveTenancy(tenancyId, unitId);
  }

  Future<void> reject(int tenancyId) {
    return remote.rejectTenancy(tenancyId);
  }
}