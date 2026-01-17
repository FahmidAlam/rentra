import 'package:flutter/material.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/Application/role_controller.dart';
import 'package:rentra/Application/auth_controller.dart';
import 'package:rentra/Data/datasources/property_remote_datasource.dart';
import 'package:rentra/Data/repositories/property_repository.dart';
import 'package:rentra/UI/Screens/add_edit_property_screen.dart';
import 'package:rentra/UI/Screens/my_properties_screen.dart';
import 'package:rentra/UI/Screens/owner_tenancy_request_screen.dart';
import 'package:rentra/UI/Screens/profile_screen.dart';
import 'package:rentra/UI/Screens/property_list_screen.dart';
import 'package:rentra/UI/Screens/tenant_request_status_screen.dart';
import 'package:rentra/core/app_dependencies.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final PropertyController propertyController;
  final RoleController roleController = RoleController();
  final AuthController authController = AuthController();

  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    final remoteDataSource = PropertyRemoteDataSource();
    final repository = PropertyRepository(remoteDataSource);
    propertyController = PropertyController(repository);
    propertyController.fetchProperties();

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      roleController.loadRole(user.id).then((_) {
        if (!mounted) return;
        setState(() {
          _loadingRole = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(RentraColors.darkTeal),
          ),
        ),
      );
    }

    return Scaffold(
      body: _buildBody(),
      floatingActionButton: (roleController.isOwner && _currentIndex == 1)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditPropertyScreen(controller: propertyController),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _buildNavItems(),
      ),
    );
  }
  List<BottomNavigationBarItem> _buildNavItems() {
    if (roleController.isOwner) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.apartment),
          label: 'My Properties',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Requests'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Search'),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment),
        label: 'My Requests',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  Widget _buildBody() {
    if (roleController.isOwner) {
      // OWNER: 4 tabs
      switch (_currentIndex) {
        case 0:
          return PropertyListScreen(propertyController: propertyController);
        case 1:
          return MyPropertiesScreen(propertyController: propertyController);
        case 2:
          return OwnerTenancyRequestsScreen(
            controller: AppDependencies.tenancyController,
          );
        case 3:
          return const ProfileScreen();
        default:
          return const SizedBox();
      }
    } else {
      // TENANT: 3 tabs
      switch (_currentIndex) {
        case 0:
          return PropertyListScreen(propertyController: propertyController);
        case 1:
          return const TenantRequestStatusScreen();
        case 2:
          return const ProfileScreen();
        default:
          return const SizedBox();
      }
    }
  }
}
