import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rentra/Application/auth_controller.dart';
import 'package:rentra/UI/Screens/auth_screens/login_screen.dart';
import 'package:rentra/UI/Screens/property_list_screen.dart';
import 'package:rentra/core/app_dependencies.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthController _authController = AuthController();

  Widget? _destination;

  @override
  void initState() {
    super.initState();
    _resolveAuth();
  }

  Future<void> _resolveAuth() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      if (!mounted) return;
      setState(() {
        _destination = const LoginScreen();
      });
      return;
    }

    try {
      await _authController.fetchUserRole(session.user.id);

      if (!mounted) return;
      setState(() {
        _destination = PropertyListScreen(
          propertyController: AppDependencies.propertyController,
        );
      });
    } catch (err) {
      if (!mounted) return;
      // If role fetch fails, fall back to property list (or adjust as needed)
      setState(() {
        _destination = PropertyListScreen(
          propertyController: AppDependencies.propertyController,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_destination == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _destination!;
  }
}
