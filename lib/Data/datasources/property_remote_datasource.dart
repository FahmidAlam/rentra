import 'package:rentra/core/models/property.dart';
import 'package:rentra/core/supabase_client.dart';

abstract class IPropertyRemoteDataSource {
  Future<List<Property>> fetchAllProperties();
  Future<Property?> fetchPropertyById(int id);
}

class PropertyRemoteDataSource implements IPropertyRemoteDataSource {
  @override
  Future<List<Property>> fetchAllProperties() async {
    try {
      final response = await SupabaseManager.supabase
          .from('properties')
          .select();

      final data = response as List<dynamic>;
      return data
          .map((item) => Property.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch properties: $e');
    }
  }

  @override
  Future<Property?> fetchPropertyById(int id) async {
    try {
      final response = await SupabaseManager.supabase
          .from('properties')
          .select()
          .eq('id', id)
          .single();

      return Property.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch property: $e');
    }
  }
}