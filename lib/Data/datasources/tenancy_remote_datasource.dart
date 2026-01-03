import 'package:rentra/core/supabase_client.dart';

abstract class ITenancyRemoteDataSource {
  Future<String?> getTenantIdByEmail(String email);
  Future<void> createTenancy({
    required String tenantId,
    required int unitId,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<void> requestTenancy({required String tenantId, required int unitId});
  Future<List<Map<String, dynamic>>> getPendingTenanciesForOwner(
    String ownerId,
  );
  Future<void> updateTenancyStatus({
    required int tenancyId,
    required String status,
    required int unitId,
  });
  Future<void> lockUnit({required int unitId});
  Future<void> createTenancyRequest({
    required String tenantId,
    required int unitId,
  });
  Future<List<Map<String, dynamic>>> fetchPendingForOwner(
    String ownerId,
  );
  Future<void> approveTenancy(int tenancyId, int unitId);
  Future<void> rejectTenancy(int tenancyId);
}

class TenancyRemoteDataSource implements ITenancyRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> fetchPendingForOwner(
    String ownerId,
  ) async {
    return await SupabaseManager.supabase
        .from('tenancies')
        .select('id, unit_id, tenant_id, created_at, units!inner(property_id)')
        .eq('status', 'pending')
        .eq('units.properties.owner_id', ownerId);
  }
  @override
  Future<void> approveTenancy(int tenancyId, int unitId) async {
    await SupabaseManager.supabase.from('tenancies').update({
      'status': 'approved',
      'active': true,
      'start_date': DateTime.now().toIso8601String(),
    }).eq('id', tenancyId);

    await SupabaseManager.supabase
        .from('units')
        .update({'is_available': false})
        .eq('id', unitId);
  }
  @override
  Future<void> rejectTenancy(int tenancyId) async {
    await SupabaseManager.supabase
        .from('tenancies')
        .update({'status': 'rejected'})
        .eq('id', tenancyId);
  }
  @override
  Future<String?> getTenantIdByEmail(String email) async {
    // Requires 'email' column in public.profiles table
    final response = await SupabaseManager.supabase
        .from('profiles')
        .select('id')
        .eq('email', email)
        .eq('role', 'tenant') // Ensure we only find tenants
        .maybeSingle();

    if (response == null) return null;
    return response['id'] as String;
  }

  @override
  Future<void> createTenancy({
    required String tenantId,
    required int unitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await SupabaseManager.supabase.from('tenancies').insert({
      'tenant_id': tenantId,
      'unit_id': unitId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': 'pending',
      'active': false,
    });
  }

  @override
  Future<void> requestTenancy({
    required String tenantId,
    required int unitId,
  }) async {
    await SupabaseManager.supabase.from('tenancy_requests').insert({
      'tenant_id': tenantId,
      'unit_id': unitId,
      'status': 'pending',
      'active': false,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingTenanciesForOwner(
    String ownerId,
  ) async {
    final response = await SupabaseManager.supabase
        .from('tenancies')
        .select('''
          id,
          unit_id,
          tenant_id,
          status,
          active,
          profiles!tenancies_tenant_id_fkey(email),
          units!inner(property_id),
          properties!inner(owner_id)
        ''')
        .eq('status', 'pending')
        .eq('units.owner_id', ownerId);

    final data = response as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<void> updateTenancyStatus({
    required int tenancyId,
    required String status,
    required int unitId,
  }) async {
    await SupabaseManager.supabase
        .from('tenancies')
        .update({'status': status, 'active': status == 'approved'})
        .eq('id', tenancyId);
  }

  @override
  Future<void> lockUnit({required int unitId}) async {
    await SupabaseManager.supabase
        .from('units')
        .update({'is_available': false})
        .eq('id', unitId);
  }

  @override
  Future<void> createTenancyRequest({
    required String tenantId,
    required int unitId,
  }) async {
    await SupabaseManager.supabase.from('tenancies').insert({
      'tenant_id': tenantId,
      'unit_id': unitId,
      'status': 'pending',
      'active': false,
    });
  }
}
