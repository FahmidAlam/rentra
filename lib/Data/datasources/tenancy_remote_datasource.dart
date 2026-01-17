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
  Future<List<Map<String, dynamic>>> fetchPendingForOwner(String ownerId);
  Future<void> approveTenancy(int tenancyId, int unitId);
  Future<void> rejectTenancy(int tenancyId);
  Future<List<Map<String, dynamic>>> fetchTenanciesForTenant(String tenantId);
}

class TenancyRemoteDataSource implements ITenancyRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> fetchPendingForOwner(
    String ownerId,
  ) async {
    try {
      final response = await SupabaseManager.supabase
          .from('tenancies')
          .select('''
            id,
            unit_id,
            tenant_id,
            status,
            created_at,
            units!inner(
              id,
              property_id,
              properties!inner(id, owner_id)
            )
          ''')
          .eq('status', 'pending');

      final data = response as List<dynamic>;

      final filtered = data.where((item) {
        try {
          final unit = item['units'] as Map?;
          if (unit == null) return false;

          final property = unit['properties'] as Map?;
          if (property == null) return false;

          final propertyOwnerId = property['owner_id'] as String?;
          return propertyOwnerId == ownerId;
        } catch (e) {
          return false;
        }
      }).toList();

      return filtered.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> approveTenancy(int tenancyId, int unitId) async {
    try {
      // 1. Approve the selected tenancy
      await SupabaseManager.supabase.from('tenancies').update({
        'status': 'approved',
        'active': true,
        'start_date': DateTime.now().toIso8601String(),
      }).eq('id', tenancyId);

      // 2. Auto-reject all other pending requests for this unit
      await SupabaseManager.supabase
          .from('tenancies')
          .update({'status': 'rejected'})
          .eq('unit_id', unitId)
          .eq('status', 'pending')
          .neq('id', tenancyId);

      // 3. Lock the unit
      await SupabaseManager.supabase
          .from('units')
          .update({'is_available': false})
          .eq('id', unitId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> rejectTenancy(int tenancyId) async {
    try {
      await SupabaseManager.supabase
          .from('tenancies')
          .update({'status': 'rejected'})
          .eq('id', tenancyId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> getTenantIdByEmail(String email) async {
    try {
      final response = await SupabaseManager.supabase
          .from('profiles')
          .select('id')
          .eq('email', email)
          .eq('role', 'tenant')
          .maybeSingle();

      if (response == null) return null;
      return response['id'] as String;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createTenancy({
    required String tenantId,
    required int unitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await SupabaseManager.supabase.from('tenancies').insert({
        'tenant_id': tenantId,
        'unit_id': unitId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': 'pending',
        'active': false,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> requestTenancy({
    required String tenantId,
    required int unitId,
  }) async {
    try {
      await SupabaseManager.supabase.from('tenancy_requests').insert({
        'tenant_id': tenantId,
        'unit_id': unitId,
        'status': 'pending',
        'active': false,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingTenanciesForOwner(
    String ownerId,
  ) async {
    return fetchPendingForOwner(ownerId);
  }

  @override
  Future<void> updateTenancyStatus({
    required int tenancyId,
    required String status,
    required int unitId,
  }) async {
    try {
      await SupabaseManager.supabase
          .from('tenancies')
          .update({'status': status, 'active': status == 'approved'})
          .eq('id', tenancyId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> lockUnit({required int unitId}) async {
    try {
      await SupabaseManager.supabase
          .from('units')
          .update({'is_available': false})
          .eq('id', unitId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createTenancyRequest({
    required String tenantId,
    required int unitId,
  }) async {
    try {
      final existing = await SupabaseManager.supabase
          .from('tenancies')
          .select('id')
          .eq('tenant_id', tenantId)
          .eq('unit_id', unitId)
          .eq('status', 'pending')
          .maybeSingle();

      if (existing != null) {
        throw Exception('You already have a pending request for this unit');
      }

      await SupabaseManager.supabase.from('tenancies').insert({
        'tenant_id': tenantId,
        'unit_id': unitId,
        'status': 'pending',
        'active': false,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTenanciesForTenant(
    String tenantId,
  ) async {
    try {
      final response = await SupabaseManager.supabase
          .from('tenancies')
          .select('''
            id,
            unit_id,
            tenant_id,
            status,
            created_at,
            units!inner(
              id,
              property_id,
              rent,
              unit_number,
              properties!inner(
                id,
                title,
                city,
                image_url,
                owner_id
              )
            )
          ''')
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }
}