import 'package:flutter/material.dart';
import 'package:rentra/Application/auth_controller.dart';
import 'package:rentra/core/models/user_profile.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';

/// ✅ ProfileScreen - Uses NEW getUserProfile() method
///
/// Changes from old version:
/// - Uses getUserProfile() instead of fetchUserProfile()
/// - Gets UserProfile object directly (type-safe)
/// - Uses updateUserProfile() for editing
/// - Everything else stays the same

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authController = AuthController();
  UserProfile? _profile;
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
        _isLoading = false;
      });
      return;
    }

    try {
      // ✅ NEW: Use getUserProfile() for typed response
      final profile = await _authController.getUserProfile(user.id);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading profile: $e');
      if (mounted) {
        setState(() {
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

  void _showEditDialog() {
    final nameController = TextEditingController(text: _profile?.fullName);
    final phoneController = TextEditingController(text: _profile?.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                border: OutlineInputBorder(),
              ),
            ),
            const VSpace(16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter your phone number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // ✅ NEW: Use updateUserProfile() method
              final success = await _authController.updateUserProfile(
                userId: _profile!.id,
                fullName: nameController.text.trim().isEmpty 
                    ? null 
                    : nameController.text.trim(),
                phone: phoneController.text.trim().isEmpty 
                    ? null 
                    : phoneController.text.trim(),
              );

              if (!mounted) return;
              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadUserProfile(); // Reload profile
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update profile'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RentraColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          if (_profile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditDialog,
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(RentraColors.darkTeal),
              ),
            )
          : _profile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: RentraColors.error,
                      ),
                      const VSpace(16),
                      Text(
                        'Failed to load profile',
                        style: TextStyle(
                          fontSize: 16,
                          color: RentraColors.darkText,
                        ),
                      ),
                      const VSpace(24),
                      RentraDangerButton(
                        label: 'Logout',
                        icon: Icons.logout,
                        onPressed: _logout,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ✅ PROFILE HEADER
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
                                _profile!.displayName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const VSpace(4),
                              Text(
                                _profile!.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const VSpace(24),

                        // ✅ PROFILE COMPLETION STATUS
                        if (!_profile!.isComplete)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: RentraColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: RentraColors.warning.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: RentraColors.warning,
                                  size: 20,
                                ),
                                const HSpace(8),
                                Expanded(
                                  child: Text(
                                    'Complete your profile for better experience',
                                    style: TextStyle(
                                      color: RentraColors.warning,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _showEditDialog,
                                  child: const Text('Update'),
                                ),
                              ],
                            ),
                          ),

                        if (!_profile!.isComplete) const VSpace(16),

                        // ✅ PROFILE INFO
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
                                icon: Icons.person,
                                label: 'Full Name',
                                value: _profile!.fullName ?? 'Not set',
                              ),
                              const VSpace(16),
                              Divider(color: RentraColors.divider, height: 1),
                              const VSpace(16),
                              RentraInfoRow(
                                icon: Icons.email,
                                label: 'Email',
                                value: _profile!.email,
                              ),
                              const VSpace(16),
                              Divider(color: RentraColors.divider, height: 1),
                              const VSpace(16),
                              RentraInfoRow(
                                icon: Icons.phone,
                                label: 'Phone',
                                value: _profile!.phone ?? 'Not set',
                              ),
                              const VSpace(16),
                              Divider(color: RentraColors.divider, height: 1),
                              const VSpace(16),
                              RentraInfoRow(
                                icon: Icons.badge,
                                label: 'Role',
                                value: _profile!.role.toUpperCase(),
                              ),
                              const VSpace(16),
                              Divider(color: RentraColors.divider, height: 1),
                              const VSpace(16),
                              RentraInfoRow(
                                icon: Icons.calendar_today,
                                label: 'Member Since',
                                value: _formatDate(_profile!.createdAt),
                              ),
                            ],
                          ),
                        ),

                        const VSpace(48),

                        // ✅ LOGOUT BUTTON
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

  @override
  void dispose() {
    super.dispose();
  }
}