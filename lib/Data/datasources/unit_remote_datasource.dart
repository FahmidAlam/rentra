import 'package:rentra/core/models/unit.dart';
import 'package:rentra/core/supabase_client.dart';
abstract class IUnitRemoteDataSource {
  Future<List<Unit>> fetchUnitsByProperty(int propertyId);
  Future<void> addUnit({
    required int propertyId,
    required String unitNumber,
    required double rent,
  });
  Future<void> updateAvailability(int unitId, bool isAvailable);
}



class UnitRemoteDataSource implements IUnitRemoteDataSource {
  @override
  Future<List<Unit>> fetchUnitsByProperty(int propertyId) async {
    final response = await SupabaseManager.supabase
        .from('units')
        .select()
        .eq('property_id', propertyId);

    final data = response as List<dynamic>;
    return data.map((e) => Unit.fromJson(e)).toList();
  }

  @override
  Future<void> addUnit({
    required int propertyId,
    required String unitNumber,
    required double rent,
  }) async {
    await SupabaseManager.supabase.from('units').insert({
      'property_id': propertyId,
      'unit_number': unitNumber,
      'rent': rent,
      'is_available': true,
    });
  }

  @override
  Future<void> updateAvailability(int unitId, bool isAvailable) async {
    await SupabaseManager.supabase
        .from('units')
        .update({'is_available': isAvailable})
        .eq('id', unitId);
  }
}
