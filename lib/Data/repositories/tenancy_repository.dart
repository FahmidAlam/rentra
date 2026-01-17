import 'package:rentra/Data/datasources/tenancy_remote_datasource.dart';
import 'package:rentra/core/models/tenancy.dart';

class TenancyRepository {
  final ITenancyRemoteDataSource remote;
  TenancyRepository(this.remote);

  // Tenant requests a tenancy
  Future<void> requestTenancy({
    required String tenantId,
    required int unitId,
  }) {
    return remote.createTenancyRequest(
      tenantId: tenantId,
      unitId: unitId,
    );
  }

  // Get pending tenancies for owner
  Future<List<Tenancy>> getPendingTenanciesForOwner(
    String ownerId,
  ) async {
    final data = await remote.getPendingTenanciesForOwner(ownerId);
    return data.map((json) => Tenancy.fromJson(json)).toList();
  }

  // Get pending requests for owner (returns raw data)
  Future<List<Map<String, dynamic>>> getPendingRequests(
    String ownerId,
  ) {
    return remote.fetchPendingForOwner(ownerId);
  }

  // Update tenancy status
  Future<void> updateTenancyStatus({
    required int tenancyId,
    required String status,
    required int unitId,
  }) async {
    await remote.updateTenancyStatus(
      tenancyId: tenancyId,
      status: status,
      unitId: unitId,
    );
    if (status == 'approved') {
      await remote.lockUnit(unitId: unitId);
    }
  }

  // Approve tenancy
  Future<void> approve(int tenancyId, int unitId) {
    return remote.approveTenancy(tenancyId, unitId);
  }

  // Reject tenancy
  Future<void> reject(int tenancyId) {
    return remote.rejectTenancy(tenancyId);
  }
  // Get tenancies for a specific tenant
  Future<List<Map<String, dynamic>>> getTenanciesForTenant(
    String tenantId,
  ) async {
    try {
      return await remote.fetchTenanciesForTenant(tenantId);
    } catch (e) {
      print('Repository error: $e');
      rethrow;
    }
  }
}