import 'package:rentra/core/models/property.dart';
import 'package:rentra/core/supabase_client.dart';

abstract class IPropertyRemoteDataSource {
  Future<List<Property>> fetchAllProperties();
  Future<Property?> fetchPropertyById(int id);
  Future<int> insertProperty({
    required String ownerId,
    required String title,
    required String address,
    required String city,
    required String description,
    required String coverImageUrl,
  });
  Future<void> insertPropertyImages({
    required int propertyId,
    required List<String> imageUrls,
  });
  Future<void> deleteProperty(int propertyId);
  Future<void> updateProperty(
    int propertyId, {
    String? title,
    String? address,
    String? city,
    String? description,
    String? imageUrl,
  });
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

  @override
  Future<int> insertProperty({
    required String ownerId,
    required String title,
    required String address,
    required String city,
    required String description,
    required String coverImageUrl,
  }) async {
    final response = await SupabaseManager.supabase
        .from('properties')
        .insert({
          'owner_id': ownerId,
          'title': title,
          'address': address,
          'city': city,
          'description': description,
          'image_url': coverImageUrl,
        })
        .select()
        .single();

    return response['id'] as int;
  }

  @override
  Future<void> insertPropertyImages({
    required int propertyId,
    required List<String> imageUrls,
  }) async {
    if (imageUrls.isEmpty) return;

    final images = imageUrls.asMap().entries.map((entry) {
      return {
        'property_id': propertyId,
        'image_url': entry.value,
        'position': entry.key,
      };
    }).toList();

    await SupabaseManager.supabase.from('property_images').insert(images);
  }

  @override
  Future<void> deleteProperty(int propertyId) async {
    final response = await SupabaseManager.supabase
        .from('properties')
        .delete()
        .eq('id', propertyId);
    if (response == null) {
      throw Exception('Failed to delete property with id $propertyId');
    }
  }
  @override
  Future<void> updateProperty(
    int propertyId, {
    String? title,
    String? address,
    String? city,
    String? description,
    String? imageUrl,
  }) async {
    final updateData = <String, dynamic>{};

    if (title != null) updateData['title'] = title;
    if (address != null) updateData['address'] = address;
    if (city != null) updateData['city'] = city;
    if (description != null) updateData['description'] = description;
    if (imageUrl != null) updateData['image_url'] = imageUrl;

    if (updateData.isEmpty) return;

    await SupabaseManager.supabase
        .from('properties')
        .update(updateData)
        .eq('id', propertyId);
  }
}
