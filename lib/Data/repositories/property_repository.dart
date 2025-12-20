import 'package:rentra/core/models/property.dart';
import 'package:rentra/data/datasources/property_remote_datasource.dart';

abstract class IPropertyRepository {
  Future<List<Property>> getAllProperties();
  Future<Property?> getPropertyById(int id);
}

class PropertyRepository implements IPropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;

  PropertyRepository({required this.remoteDataSource});

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