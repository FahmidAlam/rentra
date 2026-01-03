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
  //? Client-side filtering approach (RELIABLE)
  Future<List<Map<String, dynamic>>> fetchPendingForOwner(
    String ownerId,
  ) async {
    try {
      print('🔍 Fetching pending tenancies for owner: $ownerId');

      // Fetch ALL pending tenancies with full relationship data
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
      print('📦 Got ${data.length} total pending tenancies from database');

      // Filter by owner_id using client-side filtering
      final filtered = data.where((item) {
        try {
          final unit = item['units'] as Map?;
          if (unit == null) {
            print('⚠️ Unit is null for item: $item');
            return false;
          }

          final property = unit['properties'] as Map?;
          if (property == null) {
            print('⚠️ Property is null for unit: $unit');
            return false;
          }

          final propertyOwnerId = property['owner_id'] as String?;
          final matches = propertyOwnerId == ownerId;
          
          if (matches) {
            print('✅ Found matching tenancy: unit=${item['unit_id']}, owner=$propertyOwnerId');
          }
          
          return matches;
        } catch (e) {
          print('❌ Error filtering item: $e, item: $item');
          return false;
        }
      }).toList();

      print('✅ Filtered to ${filtered.length} tenancies for owner: $ownerId');
      return filtered.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Critical error in fetchPendingForOwner: $e');
      return [];
    }
  }

  @override
  Future<void> approveTenancy(int tenancyId, int unitId) async {
    try {
      print('⏳ Approving tenancy $tenancyId for unit $unitId');
      
      await SupabaseManager.supabase.from('tenancies').update({
        'status': 'approved',
        'active': true,
        'start_date': DateTime.now().toIso8601String(),
      }).eq('id', tenancyId);
      
      await SupabaseManager.supabase
          .from('units')
          .update({'is_available': false})
          .eq('id', unitId);
      
      print('✅ Tenancy $tenancyId approved successfully');
    } catch (e) {
      print('❌ Error approving tenancy: $e');
      rethrow;
    }
  }

  @override
  Future<void> rejectTenancy(int tenancyId) async {
    try {
      print('⏳ Rejecting tenancy $tenancyId');
      
      await SupabaseManager.supabase
          .from('tenancies')
          .update({'status': 'rejected'})
          .eq('id', tenancyId);
      
      print('✅ Tenancy $tenancyId rejected successfully');
    } catch (e) {
      print('❌ Error rejecting tenancy: $e');
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
      print('❌ Error getting tenant ID by email: $e');
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
      print('⏳ Creating tenancy for tenant $tenantId, unit $unitId');
      
      await SupabaseManager.supabase.from('tenancies').insert({
        'tenant_id': tenantId,
        'unit_id': unitId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': 'pending',
        'active': false,
      });
      
      print('✅ Tenancy created successfully');
    } catch (e) {
      print('❌ Error creating tenancy: $e');
      rethrow;
    }
  }

  @override
  Future<void> requestTenancy({
    required String tenantId,
    required int unitId,
  }) async {
    try {
      print('⏳ Creating tenancy request for tenant $tenantId, unit $unitId');
      
      await SupabaseManager.supabase.from('tenancy_requests').insert({
        'tenant_id': tenantId,
        'unit_id': unitId,
        'status': 'pending',
        'active': false,
      });
      
      print('✅ Tenancy request created successfully');
    } catch (e) {
      print('❌ Error creating tenancy request: $e');
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
      print('⏳ Updating tenancy $tenancyId to status: $status');
      
      await SupabaseManager.supabase
          .from('tenancies')
          .update({'status': status, 'active': status == 'approved'})
          .eq('id', tenancyId);
      
      print('✅ Tenancy status updated successfully');
    } catch (e) {
      print('❌ Error updating tenancy status: $e');
      rethrow;
    }
  }

  @override
  Future<void> lockUnit({required int unitId}) async {
    try {
      print('⏳ Locking unit $unitId');
      
      await SupabaseManager.supabase
          .from('units')
          .update({'is_available': false})
          .eq('id', unitId);
      
      print('✅ Unit locked successfully');
    } catch (e) {
      print('❌ Error locking unit: $e');
      rethrow;
    }
  }

  @override
  Future<void> createTenancyRequest({
    required String tenantId,
    required int unitId,
  }) async {
    try {
      print('⏳ Creating tenancy request - tenant: $tenantId, unit: $unitId');
      
      // Insert directly into tenancies table (not tenancy_requests)
      await SupabaseManager.supabase.from('tenancies').insert({
        'tenant_id': tenantId,
        'unit_id': unitId,
        'status': 'pending',
        'active': false,
      });
      
      print('✅ Tenancy request inserted successfully into tenancies table');
    } catch (e) {
      print('❌ Error creating tenancy request: $e');
      rethrow;
    }
  }
}