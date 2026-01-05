// import 'package:flutter/material.dart';
// import 'package:rentra/Application/property_controller.dart';
// import 'package:rentra/Application/role_controller.dart';
// import 'package:rentra/Application/auth_controller.dart';
// import 'package:rentra/Data/datasources/property_remote_datasource.dart';
// import 'package:rentra/Data/repositories/property_repository.dart';
// import 'package:rentra/UI/Screens/add_property_screen.dart';
// import 'package:rentra/UI/Screens/my_properties_screen.dart';
// import 'package:rentra/UI/Screens/owner_tenancy_request_screen.dart';
// import 'package:rentra/UI/Screens/profile_screen.dart';
// import 'package:rentra/UI/Screens/property_list_screen.dart';
// import 'package:rentra/UI/Screens/tenant_tenancies_screen.dart';
// import 'package:rentra/core/app_dependencies.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class MainShell extends StatefulWidget {
//   const MainShell({super.key});

//   @override
//   State<MainShell> createState() => _MainShellState();
// }

// class _MainShellState extends State<MainShell> {
//   int _currentIndex = 0;
//   // -------------------------------
//   // Controllers (manual DI)
//   // -------------------------------
//   late final PropertyController propertyController;
//   final RoleController roleController = RoleController();
//   final AuthController authController = AuthController();
//   // -------------------------------
//   // Role state
//   // -------------------------------
//   String? _role;
//   bool _loadingRole = true;

//   @override
//   void initState() {
//     super.initState();
//     // Property feature dependency injection
//     final remoteDataSource = PropertyRemoteDataSource();
//     final repository = PropertyRepository(remoteDataSource);
//     propertyController = PropertyController(repository);
//     //!
//     propertyController.fetchProperties();
//     // Load user role ONCE when MainShell starts
//     final user = Supabase.instance.client.auth.currentUser;
//     if (user != null) {
//       roleController.loadRole(user.id).then((role) {
//         if (!mounted) return;
//         setState(() {
//           _role = role;
//           _loadingRole = false;
//         });
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // While role is loading, block UI to prevent incorrect tab rendering
//     if (_loadingRole) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     return Scaffold(
//       body: _buildBody(),
//       // 🔹 OWNER-ONLY FAB (Add Property): show only on "My Properties" tab (index 1)
//       floatingActionButton: (roleController.isOwner && _currentIndex == 1)
//           ? FloatingActionButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) =>
//                         AddPropertyScreen(controller: propertyController),
//                   ),
//                 );
//               },
//               child: const Icon(Icons.add),
//             )
//           : null,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: const Color.fromARGB(255, 233, 76, 37),
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: _buildNavItems(),
//       ),
//     );
//   }

//   //? UPDATED NAVIGATION BUILDER
//   List<BottomNavigationBarItem> _buildNavItems() {
//     // Owner sees 4 tabs: Home, My Properties, Requests, Profile
//     if (roleController.isOwner) {
//       return const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.apartment),
//           label: 'My Properties',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.inbox),
//           label: 'Requests',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person),
//           label: 'Profile',
//         ),
//       ];
//     }

//     //? TENANT sees 4 tabs: Home, Browse, My Requests, Profile
//     return const [
//       BottomNavigationBarItem(
//         icon: Icon(Icons.home),
//         label: 'Home',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.search),
//         label: 'Browse',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.assignment),
//         label: 'My Requests',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.person),
//         label: 'Profile',
//       ),
//     ];
//   }

//   //? UPDATED BODY BUILDER
//   Widget _buildBody() {
//     if (roleController.isOwner) {
//       // OWNER: 4 tabs
//       switch (_currentIndex) {
//         case 0:
//           return PropertyListScreen(propertyController: propertyController);
//         case 1:
//           return MyPropertiesScreen(propertyController: propertyController);
//         case 2:
//           return OwnerTenancyRequestsScreen(
//             controller: AppDependencies.tenancyController,
//           );
//         case 3:
//           return const ProfileScreen();
//         default:
//           return const SizedBox();
//       }
//     } else {
//       // TENANT: 4 tabs (changed from 3)
//       switch (_currentIndex) {
//         case 0:
//           return PropertyListScreen(propertyController: propertyController);
//         case 1:
//           return const Center(
//             child: Text(
//               'Browse Properties',
//               style: TextStyle(fontSize: 18, color: Colors.green),
//             ),
//           );
//         case 2:
//           // ✅ NEW: Tenant's own tenancy requests
//           return const TenantTenanciesScreen();
//         case 3:
//           return const ProfileScreen();
//         default:
//           return const SizedBox();
//       }
//     }
//   }
// }
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
import 'package:rentra/core/app_dependencies.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  // Controllers
  late final PropertyController propertyController;
  final RoleController roleController = RoleController();
  final AuthController authController = AuthController();
  // State
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
      // roleController.loadRole(user.id).then((role) {
      //   if (!mounted) return;
      //   setState(() {
      //     _role = role;
      //     _loadingRole = false;
      //   });
      // }
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

  // ✅ OPTIMIZED: 3 tabs for owner, 3 tabs for tenant
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

    // Tenant: 3 tabs (Home/Search, Profile, nothing else - browse is same as home)
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Search'),
      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Saved'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  // ✅ UPDATED: Different logic for owner vs tenant
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
          // Home/Search - shows all properties
          return PropertyListScreen(propertyController: propertyController);
        case 1:
          // Saved - placeholder for now
          return const Center(
            child: Text(
              '❤️ Saved Properties\n(Coming Soon)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        case 2:
          return const ProfileScreen();
        default:
          return const SizedBox();
      }
    }
  }
}
