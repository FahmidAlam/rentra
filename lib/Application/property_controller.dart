import 'package:rentra/Data/repositories/property_repository.dart';
import 'package:rentra/core/models/property.dart';

class PropertyController {
  final PropertyRepository repository;

  PropertyController({required this.repository});

  Future<List<Property>> fetchProperties() async {
    try {
      return await repository.getAllProperties();
    } catch (e) {
      throw Exception('Failed to fetch properties: $e');
    }
  }

  // Add more business logic here
  Future<Property?> getPropertyById(int id) async {
    return await repository.getPropertyById(id);
  }
}