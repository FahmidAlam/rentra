import 'package:flutter/material.dart';
import 'package:rentra/UI/Screens/auth_screens/login_screen.dart';
import 'package:rentra/core/supabase_client.dart';
import 'package:rentra/Data/repositories/property_repository.dart';
import 'package:rentra/Data/datasources/property_remote_datasource.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/UI/Screens/property_list_screen.dart';
import 'package:rentra/UI/Navigation/main_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection: Create instances of each layer
    final remoteDataSource = PropertyRemoteDataSource();
    final repository = PropertyRepository(remoteDataSource);
    final controller = PropertyController(repository);
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      // title: 'Property App',
      // theme: ThemeData(primarySwatch: Colors.blue),
      // home: 
      // //PropertyListScreen(propertyController: controller),
      // const MainShell(),
      debugShowCheckedModeBanner: false,
      home: session == null
          ? const LoginScreen()
          :PropertyListScreen(propertyController:controller),

    );
  }
}


