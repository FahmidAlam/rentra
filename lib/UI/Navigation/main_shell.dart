import 'package:flutter/material.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/Application/role_controller.dart';
import 'package:rentra/Data/datasources/property_remote_datasource.dart';
import 'package:rentra/Data/repositories/property_repository.dart';
import 'package:rentra/UI/Screens/add_prperty_screen.dart';
import 'package:rentra/UI/Screens/profile_screen.dart';
import 'package:rentra/UI/Screens/property_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // -------------------------------
  // Controllers (manual DI)
  // -------------------------------
  late final PropertyController propertyController;
  final RoleController roleController = RoleController();

  // -------------------------------
  // Role state
  // -------------------------------
  String? _role;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();

    // Property feature dependency injection
    final remoteDataSource = PropertyRemoteDataSource();
    final repository = PropertyRepository(remoteDataSource);
    propertyController = PropertyController(repository);

    // Load user role ONCE when MainShell starts
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      roleController.loadRole(user.id).then((role) {
        if (!mounted) return;
        setState(() {
          _role = role;
          _loadingRole = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // While role is loading, block UI to prevent incorrect tab rendering
    if (_loadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _buildBody(),
      // 🔹 OWNER-ONLY FAB (Add Property)
      floatingActionButton: roleController.isOwner
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddPropertyScreen(controller: propertyController),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: const Color.fromARGB(255, 233, 76, 37),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _buildNavItems(),
      ),
    );
  }

  // -------------------------------
  // Role-based BottomNavigationBar
  // -------------------------------
  List<BottomNavigationBarItem> _buildNavItems() {
    // Owner sees "My Properties"
    if (roleController.isOwner) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.apartment),
          label: 'My Properties',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }

    // Renter sees "Browse"
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  // -------------------------------
  // Role-based screen rendering
  // -------------------------------
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        // Public property listing (shared)
        return PropertyListScreen(propertyController: propertyController);

      case 1:
        // Role-specific behavior
        if (roleController.isOwner) {
          return const Center(
            child: Text(
              'Owner: Manage My Properties',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
          );
        } else {
          return const Center(
            child: Text(
              'Renter: Browse Properties',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          );
        }

      case 2:
        return const ProfileScreen();

      default:
        return const SizedBox();
    }
  }
}
