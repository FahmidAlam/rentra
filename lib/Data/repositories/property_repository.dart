import 'package:rentra/Data/datasources/property_remote_datasource.dart';
import 'package:rentra/core/models/property.dart';

abstract class IPropertyRepository {
  Future<List<Property>> getAllProperties();
  Future<Property?> getPropertyById(int id);
  Future<void> addProperty({
    required String ownerId,
    required String title,
    required String address,
    required String city,
    required String description,
    required String coverImageUrl,
    required List<String> galleryImages,
  });
  Future<void> updateProperty(
    int propertyId, {
    String? title,
    String? address,
    String? city,
    String? description,
    String? imageUrl,
  });  
  Future<void> deleteProperty(int propertyId);
}

class PropertyRepository implements IPropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;

  PropertyRepository(this.remoteDataSource);
  
  @override
  Future<List<Property>> getAllProperties() async {
    try {
      return await remoteDataSource.fetchAllProperties();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<Property?> getPropertyById(int id) async {
    try {
      return await remoteDataSource.fetchPropertyById(id);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
  @override
  Future<void> addProperty({
    required String ownerId,
    required String title,
    required String address,
    required String city,
    required String description,
    required String coverImageUrl,
    required List<String> galleryImages,
  }) async {
    final propertyId = await remoteDataSource.insertProperty(
      ownerId: ownerId,
      title: title,
      address: address,
      city: city,
      description: description,
      coverImageUrl: coverImageUrl,
    );

    await remoteDataSource.insertPropertyImages(
      propertyId: propertyId,
      imageUrls: galleryImages,
    );
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
    try {
      await remoteDataSource.updateProperty(
        propertyId,
        title: title,
        address: address,
        city: city,
        description: description,
        imageUrl: imageUrl,
      );
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
  @override
  Future<void> deleteProperty(int propertyId) async {
    try {
      await remoteDataSource.deleteProperty(propertyId);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}