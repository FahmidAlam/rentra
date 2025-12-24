import 'package:flutter/material.dart';
import 'package:rentra/UI/Screens/auth_screens/auth_gate.dart';
import 'package:rentra/Application/auth_controller.dart';


class RoleSelectScreen extends StatefulWidget {
  final String userId;
  const RoleSelectScreen({super.key, required this.userId});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  final AuthController _authController = AuthController();
  bool _loading = false;

  Future<void> _selectRole(String role) async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      await _authController.saveUserRole(
        userId: widget.userId,
        role: role,
      );

      if (!mounted) return;

      // 🔑 Return control to AuthGate
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save role: $e')),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => _selectRole('owner'),
                    child: const Text('Owner'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _selectRole('tenant'),
                    child: const Text('Tenant'),
                  ),
                ],
              ),
      ),
    );
  }
}
