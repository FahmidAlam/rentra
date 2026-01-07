import 'package:flutter/material.dart';
import 'package:rentra/Application/auth_controller.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';

/// ✅ REFACTORED ProfileScreen
/// 
/// Changes made:
/// - Removed all hardcoded colors
/// - AppBar uses theme automatically
/// - Uses RentraInfoRow instead of custom _buildInfoCard
/// - Uses RentraDangerButton for logout
/// - Uses VSpace for spacing
/// - Removed custom color definitions
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
      setState(() {
        _email = 'Not signed in';
        _role = 'N/A';
        _isLoading = false;
      });
      return;
    }

    try {
      final role = await _authController.fetchUserRole(user.id);
      if (mounted) {
        setState(() {
          _email = user.email;
          _role = role ?? 'Unknown';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _email = user.email;
          _role = 'Error loading role';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authController.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RentraColors.background,
      // ✅ AppBar uses theme automatically - no custom styling needed
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(RentraColors.darkTeal),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ✅ PROFILE HEADER with theme colors
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: RentraColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 48,
                              color: RentraColors.darkTeal,
                            ),
                          ),
                          const VSpace(12),
                          Text(
                            _email ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const VSpace(32),

                    // ✅ PROFILE INFO using RentraInfoRow
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: RentraColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: RentraColors.divider),
                      ),
                      child: Column(
                        children: [
                          RentraInfoRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: _email ?? 'N/A',
                          ),
                          const VSpace(16),
                          Divider(color: RentraColors.divider, height: 1),
                          const VSpace(16),
                          RentraInfoRow(
                            icon: Icons.badge,
                            label: 'Role',
                            value: _role ?? 'Unknown',
                          ),
                        ],
                      ),
                    ),
                    const VSpace(48),

                    // ✅ LOGOUT BUTTON using RentraDangerButton
                    RentraDangerButton(
                      label: 'Logout',
                      icon: Icons.logout,
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/* ❌ REMOVED: Custom _buildInfoCard widget
 * 
 * The old implementation had:
 * - Hardcoded Colors.grey, Colors.blue
 * - SizedBox for spacing
 * - Custom styling
 * 
 * Now we use RentraInfoRow which is:
 * - Consistent across the app
 * - Uses theme colors
 * - Less code to maintain
 */