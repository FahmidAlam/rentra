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
}