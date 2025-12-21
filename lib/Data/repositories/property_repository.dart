import 'package:rentra/Data/datasources/property_remote_datasource.dart';
import 'package:rentra/core/models/property.dart';

abstract class IPropertyRepository {
  Future<List<Property>> getAllProperties();
  Future<Property?> getPropertyById(int id);
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
}