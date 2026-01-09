import 'package:flutter/material.dart';
import 'package:rentra/Data/repositories/unit_repository.dart';
import 'package:rentra/core/models/unit.dart';
import 'package:rentra/core/supabase_client.dart';

class UnitController extends ChangeNotifier {
  final UnitRepository repository;

  UnitController(this.repository);

  bool _isLoading = false;
  List<Unit> _units = [];

  bool get isLoading => _isLoading;
  List<Unit> get units => _units;

  Future<void> loadUnits(int propertyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _units = await repository.getUnitsByProperty(propertyId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUnit({
    required int propertyId,
    required String unitNumber,
    required double rent,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.addUnit(
        propertyId: propertyId,
        unitNumber: unitNumber,
        rent: rent,
      );
      await loadUnits(propertyId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(Unit unit) async {
    try {
      // SAFETY CHECK: Prevent marking available if tenant is active
      if (!unit.isAvailable) {
        // Trying to mark as available - check for active tenancy
        final activeTenancy = await SupabaseManager.supabase
            .from('tenancies')
            .select('id, tenant_id')
            .eq('unit_id', unit.id)
            .eq('active', true)
            .maybeSingle();

        if (activeTenancy != null) {
          throw Exception(
            'Cannot make unit available: An active tenant is currently living here',
          );
        }
      }

      // Safe to toggle
      await repository.setAvailability(unit.id, !unit.isAvailable);
      notifyListeners();
    } catch (e) {
      print('Error toggling availability: $e');
      rethrow;
    }
  }
}
