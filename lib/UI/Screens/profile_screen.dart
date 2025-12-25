// ui -> authcontroller -> supabase
import 'package:flutter/material.dart';
import 'package:rentra/Application/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authController = AuthController();

  String? _email;
  String? _role;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _authController.currentUser;

    if (user == null) {
      return;
    }

    final role = await _authController.fetchUserRole(user.id);

    setState(() {
      _email = user.email;
      _role = role;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await _authController.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(_email ?? 'N/A'),
          ),

          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Role'),
            subtitle: Text(_role ?? 'Unknown'),
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
