// import 'package:flutter/material.dart';
// import 'package:rentra/Application/property_controller.dart';
// import 'package:rentra/Data/datasources/property_remote_datasource.dart';
// import 'package:rentra/Data/repositories/property_repository.dart';
// import "package:rentra/UI/Screens/property_list_screen.dart";
// import 'package:rentra/Data/datasources/property_remote_datasource.dart';

// class MainShell extends StatefulWidget {
//   const MainShell({super.key});

//   @override
//   State<MainShell> createState() => _MainShellState();
// }

// class _MainShellState extends State<MainShell> {
//   late final PropertyController propertyController;
//   @override
//   void initState() {
//     super.initState();

//     final remoteDataSource = PropertyRemoteDataSource();
//     final repository = PropertyRepository(remoteDataSource);
//     propertyController = PropertyController(repository);
//   }

//   int _currentIndex = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _buildBody(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() => _currentIndex = index);
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.apartment),
//             label: 'Properties',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }

//   Widget _buidBody() {
//     switch (_currentIndex) {
//       case 0:
//         // home -> public properties
//         return PropertyListScreen(propertyController: PropertyController);
//       case 1:
//         //temp
//         return const Center(child: Text('Properties (coming soon)'));
//       case 2:
//         // Temporary placeholder
//         return const Center(
//           child: Text('Profile (Coming Soon)', style: TextStyle(fontSize: 18)),
//         );

//       default:
//         return const SizedBox();
//     }
//   }
// }
import 'package:flutter/material.dart';

// Application layer
import 'package:rentra/Application/property_controller.dart';

// Data layer
import 'package:rentra/Data/datasources/property_remote_datasource.dart';
import 'package:rentra/Data/repositories/property_repository.dart';

// UI screens
import 'package:rentra/UI/Screens/property_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final PropertyController propertyController;

  @override
  void initState() {
    super.initState();

    // Dependency Injection (manual & clean)
    final remoteDataSource = PropertyRemoteDataSource();
    final repository = PropertyRepository( remoteDataSource);
    propertyController = PropertyController(repository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Properties',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        // Home → Public Properties
        return PropertyListScreen(
          propertyController: propertyController,
        );

      case 1:
        // Placeholder (will become role-based)
        return const Center(
          child: Text(
            'Properties (Coming Soon)',
            style: TextStyle(fontSize: 18),
          ),
        );

      case 2:
        // Placeholder
        return const Center(
          child: Text(
            'Profile (Coming Soon)',
            style: TextStyle(fontSize: 18),
          ),
        );

      default:
        return const SizedBox();
    }
  }
}
