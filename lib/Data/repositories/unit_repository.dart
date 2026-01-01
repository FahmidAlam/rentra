import 'package:rentra/Data/datasources/unit_remote_datasource.dart';
import 'package:rentra/core/models/unit.dart';

class UnitRepository {
  final IUnitRemoteDataSource remote;

  UnitRepository(this.remote);

  Future<List<Unit>> getUnitsByProperty(int propertyId) {
    return remote.fetchUnitsByProperty(propertyId);
  }

  Future<void> addUnit({
    required int propertyId,
    required String unitNumber,
    required double rent,
  }) {
    return remote.addUnit(
      propertyId: propertyId,
      unitNumber: unitNumber,
      rent: rent,
    );
  }

  Future<void> setAvailability(int unitId, bool isAvailable) {
    return remote.updateAvailability(unitId, isAvailable);
  }
}
