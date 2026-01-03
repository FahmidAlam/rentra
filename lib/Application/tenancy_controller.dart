// import 'package:flutter/material.dart';
// import 'package:rentra/Data/repositories/tenancy_repository.dart';
// import 'package:rentra/core/models/tenancy.dart';

// class TenancyController extends ChangeNotifier {
//   final TenancyRepository repository;

//   TenancyController(this.repository);

//   bool isLoading = false;
//   List<Tenancy> tenancies = [];

//   /// Tenant action
//   Future<void> requestTenancy( int unitId,  String tenantId) async {
//     await repository.requestTenancy( unitId,  tenantId);
//   }

//   /// Owner action
//   Future<void> loadOwnerTenancies(String ownerId) async {
//     isLoading = true;
//     notifyListeners();

//     tenancies = await repository.getPendingTenanciesForOwner(ownerId);

//     isLoading = false;
//     notifyListeners();
//   }

//   Future<void> decideTenancy({
//     required int tenancyId,
//     required String status,
//     required int unitId,
//   }) async {
//     await repository.updateTenancyStatus(
//       tenancyId: tenancyId,
//       status: status,
//       unitId: unitId,
//     );

//     tenancies.removeWhere((t) => t.id == tenancyId);
//     notifyListeners();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:rentra/Data/repositories/tenancy_repository.dart';
// import 'package:rentra/core/models/tenancy.dart';

// class TenancyController extends ChangeNotifier {
//   final TenancyRepository repository;

//   TenancyController(this.repository);

//   bool isLoading = false;
//   List<Tenancy> tenancies = [];

//   /// Tenant action
//   Future<void> requestTenancy({
//     required String tenantId,
//     required int unitId,
//   }) async {
//     isLoading = true;
//     notifyListeners();

//     await repository.requestTenancy(
//       tenantId: tenantId,
//       unitId: unitId,
//     );

//     isLoading = false;
//     notifyListeners();
//   }
//   /// Owner action
//   Future<void> loadOwnerTenancies(String ownerId) async {
//     isLoading = true;
//     notifyListeners();

//     tenancies = await repository.getPendingTenanciesForOwner(ownerId);

//     isLoading = false;
//     notifyListeners();
//   }

//   Future<void> decideTenancy({
//     required int tenancyId,
//     required String status,
//     required int unitId,
//   }) async {
//     await repository.updateTenancyStatus(
//       tenancyId: tenancyId,
//       status: status,
//       unitId: unitId,
//     );

//     tenancies.removeWhere((t) => t.id == tenancyId);
//     notifyListeners();
//   }
//     Future<void> loadPending(String ownerId) async {
//     isLoading = true;
//     notifyListeners();

//     isLoading = false;
//     notifyListeners();
//   }

//   Future<void> approveRequest(int tenancyId, int unitId) async {
//     await repository.approve(tenancyId, unitId);
//     tenancies.removeWhere((e) => e.id == tenancyId);
//     notifyListeners();
//   }

//   Future<void> rejectRequest(int tenancyId) async {
//     await repository.reject(tenancyId);
//     tenancies.removeWhere((e) => e.id == tenancyId);
//     notifyListeners();
//   }
// }
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
  /// OWNER: Load pending
  /// =========================
  Future<void> loadPendingForOwner(String ownerId) async {
    isLoading = true;
    notifyListeners();

    pendingTenancies =
        await repository.getPendingTenanciesForOwner(ownerId);

    isLoading = false;
    notifyListeners();
  }

  /// =========================
  /// OWNER: Approve / Reject
  /// =========================
  Future<void> approve(int tenancyId, int unitId) async {
    await repository.approve(tenancyId, unitId);
    pendingTenancies.removeWhere((t) => t.id == tenancyId);
    notifyListeners();
  }

  Future<void> reject(int tenancyId) async {
    await repository.reject(tenancyId);
    pendingTenancies.removeWhere((t) => t.id == tenancyId);
    notifyListeners();
  }
}
