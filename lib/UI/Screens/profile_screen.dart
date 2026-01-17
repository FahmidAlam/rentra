import 'package:flutter/material.dart';
import 'package:rentra/Application/auth_controller.dart';
import 'package:rentra/core/models/user_profile.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';

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
      builder: (context) {
        // Responsive dialog
        final isSmallScreen = MediaQuery.of(context).size.height < 600;
        
        return AlertDialog(
          title: Text(
            'Edit Profile',
            style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
          ),
          contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
              VSpace(isSmallScreen ? 12 : 16),
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
                    SnackBar(
                      content: const Text('Profile updated successfully'),
                      backgroundColor: RentraColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  _loadUserProfile();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to update profile'),
                      backgroundColor: RentraColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // ! RESPONSIVE SIZING: Adapts to different screen sizes
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isTinyScreen = screenHeight < 500;

    // Dynamic sizing
    final contentPadding = isTinyScreen ? 12.0 : 16.0;
    final headerPadding = isTinyScreen ? 16.0 : 20.0;
    final profileIconSize = isTinyScreen ? 40.0 : 48.0;
    final spacing = isTinyScreen ? 16.0 : 24.0;

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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: isTinyScreen ? 48 : 64,
                          color: RentraColors.error,
                        ),
                        VSpace(isTinyScreen ? 12 : 16),
                        Text(
                          'Failed to load profile',
                          style: TextStyle(
                            fontSize: isTinyScreen ? 14 : 16,
                            color: RentraColors.darkText,
                          ),
                        ),
                        VSpace(spacing),
                        RentraDangerButton(
                          label: 'Logout',
                          icon: Icons.logout,
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth > 600 ? 600 : double.infinity,
                      ),
                      padding: EdgeInsets.all(contentPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          VSpace(isTinyScreen ? 8 : 16),

                          // PROFILE HEADER (responsive)
                          Container(
                            padding: EdgeInsets.all(headerPadding),
                            decoration: BoxDecoration(
                              gradient: RentraColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isTinyScreen ? 12 : 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: profileIconSize,
                                    color: RentraColors.darkTeal,
                                  ),
                                ),
                                VSpace(isTinyScreen ? 8 : 12),
                                Text(
                                  _profile!.displayName,
                                  style: TextStyle(
                                    fontSize: isTinyScreen ? 18 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const VSpace(4),
                                Text(
                                  _profile!.email,
                                  style: TextStyle(
                                    fontSize: isTinyScreen ? 12 : 14,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          VSpace(spacing),

                          // PROFILE COMPLETION STATUS (responsive)
                          if (!_profile!.isComplete)
                            Container(
                              padding: EdgeInsets.all(isTinyScreen ? 10 : 12),
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
                                    size: isTinyScreen ? 18 : 20,
                                  ),
                                  const HSpace(8),
                                  Expanded(
                                    child: Text(
                                      'Complete your profile for better experience',
                                      style: TextStyle(
                                        color: RentraColors.warning,
                                        fontSize: isTinyScreen ? 12 : 13,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _showEditDialog,
                                    child: Text(
                                      'Update',
                                      style: TextStyle(
                                        fontSize: isTinyScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (!_profile!.isComplete) VSpace(isTinyScreen ? 12 : 16),

                          // PROFILE INFO (responsive padding)
                          Container(
                            padding: EdgeInsets.all(isTinyScreen ? 12 : 16),
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
                                VSpace(isTinyScreen ? 12 : 16),
                                Divider(color: RentraColors.divider, height: 1),
                                VSpace(isTinyScreen ? 12 : 16),
                                RentraInfoRow(
                                  icon: Icons.email,
                                  label: 'Email',
                                  value: _profile!.email,
                                ),
                                VSpace(isTinyScreen ? 12 : 16),
                                Divider(color: RentraColors.divider, height: 1),
                                VSpace(isTinyScreen ? 12 : 16),
                                RentraInfoRow(
                                  icon: Icons.phone,
                                  label: 'Phone',
                                  value: _profile!.phone ?? 'Not set',
                                ),
                                VSpace(isTinyScreen ? 12 : 16),
                                Divider(color: RentraColors.divider, height: 1),
                                VSpace(isTinyScreen ? 12 : 16),
                                RentraInfoRow(
                                  icon: Icons.badge,
                                  label: 'Role',
                                  value: _profile!.role.toUpperCase(),
                                ),
                                VSpace(isTinyScreen ? 12 : 16),
                                Divider(color: RentraColors.divider, height: 1),
                                VSpace(isTinyScreen ? 12 : 16),
                                RentraInfoRow(
                                  icon: Icons.calendar_today,
                                  label: 'Member Since',
                                  value: _formatDate(_profile!.createdAt),
                                ),
                              ],
                            ),
                          ),

                          VSpace(isTinyScreen ? 32 : 48),

                          // LOGOUT BUTTON
                          RentraDangerButton(
                            label: 'Logout',
                            icon: Icons.logout,
                            onPressed: _logout,
                          ),

                          VSpace(isTinyScreen ? 16 : 24),
                        ],
                      ),
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
