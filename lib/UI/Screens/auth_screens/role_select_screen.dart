import 'package:flutter/material.dart';
import '../../../Application/auth_controller.dart';

class RoleSelectScreen extends StatelessWidget {
  final String userId;
  RoleSelectScreen({super.key, required this.userId});

  final _authController = AuthController();

  Future<void> _selectRole(BuildContext context, String role) async {
    await _authController.saveUserRole(
      userId: userId,
      role: role,
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _selectRole(context, 'owner'),
            child: const Text('Owner'),
          ),
          ElevatedButton(
            onPressed: () => _selectRole(context, 'tenant'),
            child: const Text('Tenant'),
          ),
        ],
      ),
    );
  }
}
