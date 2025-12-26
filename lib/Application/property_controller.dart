import 'package:rentra/Data/repositories/property_repository.dart';
import 'package:rentra/core/models/property.dart';
import 'package:rentra/core/supabase_client.dart';

class PropertyController {
  final PropertyRepository repository;

  PropertyController(this.repository);

  Future<List<Property>> fetchProperties() async {
    try {
      return await repository.getAllProperties();
    } catch (e) {
      throw Exception('Failed to fetch properties: $e');
    }
  }

  Future<Property?> getPropertyById(int id) async {
    return await repository.getPropertyById(id);
  }

  Future<void> addProperty({
    required String title,
    required String address,
    required String city,
    required String description,
    required String coverImageUrl,
    required List<String> galleryImages,
  }) async {
    final user = SupabaseManager.supabase.auth.currentUser;


    if (user == null) {
      throw Exception('User not authenticated');
    }







    await repository.addProperty(
      ownerId: user.id,
      title: title,
      address: address,
      city: city,
      description: description,
      coverImageUrl: coverImageUrl,
      galleryImages: galleryImages,
    );
  }
}

