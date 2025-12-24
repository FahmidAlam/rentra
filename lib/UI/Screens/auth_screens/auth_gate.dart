import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../Application/auth_controller.dart';
import 'login_screen.dart';

import 'package:rentra/UI/Screens/property_list_screen.dart';
import 'package:rentra/core/app_dependencies.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authController = AuthController();
  final controller = AppDependencies.propertyController;
  @override
  void initState() {
    super.initState();
    _handleAuth();
  }

  Future<void> _handleAuth() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      _go(const LoginScreen());
      return;
    }

    final role = await _authController.fetchUserRole(session.user.id);

    // if (role == 'owner') {
    //   _go(const OwnerHomeScreen());
    // } else {
    //   _go(const PropertyListScreen());
    // }
    _go(
      PropertyListScreen(propertyController: controller)
    );
  }

  void _go(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
