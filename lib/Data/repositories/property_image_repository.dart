import 'package:rentra/Data/datasources/property_image_remote_datasource.dart';
import 'package:rentra/core/models/property_image.dart';

class PropertyImageRepository {
  final IPropertyImageRemoteDataSource remoteDataSource;
  
  PropertyImageRepository(this.remoteDataSource);

  Future<List<PropertyImage>> getImagesByProperty(int propertyId) {
    return remoteDataSource.fetchImagesByProperty(propertyId);
  }
}