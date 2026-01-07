import 'package:flutter/material.dart';
import 'package:postgrest/postgrest.dart';
import 'package:rentra/Data/repositories/tenancy_repository.dart';
import 'package:rentra/core/models/tenancy.dart';

class TenancyController extends ChangeNotifier {
  final TenancyRepository repository;
  TenancyController(this.repository);

  bool isLoading = false;
  String? errorMessage;
  List<Tenancy> pendingTenancies = [];
  List<dynamic> tenantTenancies = []; // For tenant viewing their own requests

  /// =========================
  /// TENANT: Request tenancy
  /// =========================
  Future<bool> requestTenancy({
    required String tenantId,
    required int unitId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await repository.requestTenancy(
        tenantId: tenantId,
        unitId: unitId,
      );
      return true;
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        errorMessage = 'You already requested this unit';
      } else {
        errorMessage = 'Failed to send request';
      }
      return false;
    } catch (_) {
      errorMessage = 'Unexpected error occurred';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// OWNER: Load pending requests
  /// =========================
  Future<void> loadPendingForOwner(String ownerId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print('🔄 TenancyController: Loading pending tenancies for owner: $ownerId');
      
      // Get raw data from repository
      final rawData = await repository.getPendingRequests(ownerId);
      
      print('📊 TenancyController: Received ${rawData.length} raw tenancies');
      
      // Convert to Tenancy objects
      pendingTenancies = [];
      for (final json in rawData) {
        try {
          print('🔄 Converting JSON to Tenancy: id=${json['id']}, unit=${json['unit_id']}');
          final tenancy = Tenancy.fromJson(json);
          pendingTenancies.add(tenancy);
          print('✅ Added tenancy: id=${tenancy.id}');
        } catch (e) {
          print('❌ Failed to convert tenancy: $e');
          // Continue with other tenancies even if one fails
        }
      }

      print('✅ TenancyController: Successfully loaded ${pendingTenancies.length} tenancies');
      errorMessage = null;
    } catch (e) {
      print('❌ TenancyController: Error loading pending tenancies: $e');
      errorMessage = 'Failed to load requests: $e';
      pendingTenancies = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// OWNER: Approve tenancy
  /// =========================
  Future<void> approve(int tenancyId, int unitId) async {
    try {
      isLoading = true;
      notifyListeners();

      print('⏳ TenancyController: Approving tenancy $tenancyId for unit $unitId');
      
      await repository.approve(tenancyId, unitId);

      // Remove from list
      pendingTenancies.removeWhere((t) => t.id == tenancyId);

      print('✅ TenancyController: Tenancy $tenancyId approved');
      errorMessage = null;
    } catch (e) {
      print('❌ TenancyController: Error approving tenancy: $e');
      errorMessage = 'Failed to approve: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// OWNER: Reject tenancy
  /// =========================
  Future<void> reject(int tenancyId) async {
    try {
      isLoading = true;
      notifyListeners();

      print('⏳ TenancyController: Rejecting tenancy $tenancyId');
      
      await repository.reject(tenancyId);

      // Remove from list
      pendingTenancies.removeWhere((t) => t.id == tenancyId);

      print('✅ TenancyController: Tenancy $tenancyId rejected');
      errorMessage = null;
    } catch (e) {
      print('❌ TenancyController: Error rejecting tenancy: $e');
      errorMessage = 'Failed to reject: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  /// =========================
  /// TENANT: Load own tenancies
  /// =========================
  Future<void> loadTenanciesForTenant(String tenantId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print('🔄 TenancyController: Loading tenancies for tenant: $tenantId');

      final data = await repository.getTenanciesForTenant(tenantId);

      tenantTenancies = data;
      errorMessage = null;

      print('✅ TenancyController: Loaded ${tenantTenancies.length} tenancies');
    } catch (e) {
      print('❌ TenancyController: Error loading tenancies: $e');
      errorMessage = 'Failed to load requests: $e';
      tenantTenancies = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}