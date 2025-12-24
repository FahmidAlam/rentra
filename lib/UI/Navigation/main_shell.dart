import 'package:flutter/material.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/Data/datasources/property_remote_datasource.dart';
import 'package:rentra/Data/repositories/property_repository.dart';
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
        selectedItemColor: Colors.blue, 
        unselectedItemColor: const Color.fromARGB(255, 233, 76, 37),       
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
          BottomNavigationBarItem(icon:   Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        // Home -> Public Properties
        return PropertyListScreen(
          propertyController: propertyController,
        );

      case 1:
        // Placeholder (will become role-based)
        return const Center(
          child: Text(
            'Properties (Coming Soon)',
            style: TextStyle(fontSize: 18,color: Colors.blue),
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
      case 3:
        // Placeholder
        return const Center(
          child: Text(
            'Settings (Coming Soon)',
            style: TextStyle(fontSize: 18),
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
