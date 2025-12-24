import '../Data/datasources/property_remote_datasource.dart';
import '../Data/repositories/property_repository.dart';
import '../Application/property_controller.dart';

class AppDependencies {
  static final propertyController = PropertyController(
    PropertyRepository(
      PropertyRemoteDataSource(),
    ),
  );
}
