import 'package:rentra/Application/tenancy_controller.dart';
import 'package:rentra/Data/datasources/profile_remote_datasource.dart';
import 'package:rentra/Data/datasources/tenancy_remote_datasource.dart';
import 'package:rentra/Data/repositories/profile_repository.dart' ;
import 'package:rentra/Data/repositories/tenancy_repository.dart';

import '../Data/datasources/property_remote_datasource.dart';
import '../Data/repositories/property_repository.dart';
import '../Application/property_controller.dart';

class AppDependencies {
  static final propertyController = PropertyController(
    PropertyRepository(
      PropertyRemoteDataSource(),
    ),
  );
  static final tenancyController = TenancyController(
    TenancyRepository(
      TenancyRemoteDataSource(),
    ),
  );
  static final profileRepository = ProfileRepository(
    ProfileRemoteDataSource(),
  );
}
