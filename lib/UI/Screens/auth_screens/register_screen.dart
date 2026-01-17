import 'package:flutter/material.dart';
import 'package:rentra/Application/auth_controller.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';
import 'package:flutter/gestures.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = AuthController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final fullNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  String _selectedRole = 'tenant';
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    final fullName = fullNameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        fullName.isEmpty ||
        phone.isEmpty) {
      _showErrorSnackBar('All fields are required');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await _authController.register(email, password);

      if (res.user == null) {
        throw Exception('Registration failed');
      }

      await _authController.saveUserProfile(
        userId: res.user!.id,
        email: email,
        fullName: fullName,
        phone: phone,
        role: _selectedRole,
      );

      if (!mounted) return;

      _showSuccessSnackBar('Registration successful!');

      emailCtrl.clear();
      passwordCtrl.clear();
      fullNameCtrl.clear();
      phoneCtrl.clear();

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Registration failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: RentraColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: RentraColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    fullNameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ! RESPONSIVE SIZING with tighter controls for form-heavy page
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final isVerySmallScreen = screenHeight < 650;
    final isTinyScreen = screenHeight < 550;
    
    // Even tighter spacing for register due to more fields
    final logoSize = isTinyScreen ? 70.0 : (isVerySmallScreen ? 80.0 : 100.0);
    final logoIconSize = isTinyScreen ? 35.0 : (isVerySmallScreen ? 40.0 : 50.0);
    final topSpacing = isTinyScreen ? 12.0 : (isVerySmallScreen ? 16.0 : 24.0);
    final middleSpacing = isTinyScreen ? 12.0 : (isVerySmallScreen ? 16.0 : 24.0);
    final bottomSpacing = isTinyScreen ? 12.0 : (isVerySmallScreen ? 16.0 : 24.0);
    final fieldSpacing = isTinyScreen ? 12.0 : 16.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: RentraColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: isTinyScreen ? 12 : 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VSpace(topSpacing),

                    // LOGO SECTION
                    Column(
                      children: [
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.home,
                              size: logoIconSize,
                              color: RentraColors.darkTeal,
                            ),
                          ),
                        ),
                        VSpace(isTinyScreen ? 8 : 12),
                        Text(
                          'Rentra',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTinyScreen ? 24 : (isVerySmallScreen ? 28 : null),
                              ),
                        ),
                        VSpace(isTinyScreen ? 4 : 6),
                        Text(
                          'Create Your Account',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: isTinyScreen ? 12 : null,
                              ),
                        ),
                      ],
                    ),

                    VSpace(middleSpacing),

                    // FORM CONTAINER with max-width
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth > 600 ? 500 : double.infinity,
                      ),
                      padding: EdgeInsets.all(isTinyScreen ? 16 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // EMAIL
                          Text(
                            'Email Address',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: isTinyScreen ? 14 : null,
                            ),
                          ),
                          const VSpace(8),
                          TextField(
                            controller: emailCtrl,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: 'your@email.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              prefixIconColor: RentraColors.darkTeal,
                              contentPadding: isTinyScreen 
                                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                                : null,
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          VSpace(fieldSpacing),

                          // FULL NAME
                          Text(
                            'Full Name',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: isTinyScreen ? 14 : null,
                            ),
                          ),
                          const VSpace(8),
                          TextField(
                            controller: fullNameCtrl,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: 'Your Full Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              prefixIconColor: RentraColors.darkTeal,
                              contentPadding: isTinyScreen 
                                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                                : null,
                            ),
                          ),
                          VSpace(fieldSpacing),

                          // PHONE
                          Text(
                            'Phone Number',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: isTinyScreen ? 14 : null,
                            ),
                          ),
                          const VSpace(8),
                          TextField(
                            controller: phoneCtrl,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: '01234567890',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              prefixIconColor: RentraColors.darkTeal,
                              contentPadding: isTinyScreen 
                                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                                : null,
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          VSpace(fieldSpacing),

                          // PASSWORD
                          Text(
                            'Password',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: isTinyScreen ? 14 : null,
                            ),
                          ),
                          const VSpace(8),
                          TextField(
                            controller: passwordCtrl,
                            enabled: !_isLoading,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Min 6 characters',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              prefixIconColor: RentraColors.darkTeal,
                              contentPadding: isTinyScreen 
                                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                                : null,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: RentraColors.darkTeal,
                                ),
                              ),
                            ),
                          ),
                          VSpace(isTinyScreen ? 16 : 20),

                          // ROLE SELECTION
                          Text(
                            'Select Your Role',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: isTinyScreen ? 14 : null,
                            ),
                          ),
                          VSpace(isTinyScreen ? 8 : 12),

                          Row(
                            children: [
                              // Owner Option
                              Expanded(
                                child: GestureDetector(
                                  onTap: _isLoading
                                      ? null
                                      : () => setState(() => _selectedRole = 'owner'),
                                  child: Container(
                                    padding: EdgeInsets.all(isTinyScreen ? 12 : 16),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == 'owner'
                                          ? RentraColors.darkTeal
                                          : RentraColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedRole == 'owner'
                                            ? RentraColors.darkTeal
                                            : RentraColors.divider,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.home,
                                          color: _selectedRole == 'owner'
                                              ? Colors.white
                                              : RentraColors.darkTeal,
                                          size: isTinyScreen ? 24 : 28,
                                        ),
                                        VSpace(isTinyScreen ? 6 : 8),
                                        Text(
                                          'Property Owner',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                color: _selectedRole == 'owner'
                                                    ? Colors.white
                                                    : RentraColors.darkText,
                                                fontWeight: FontWeight.w600,
                                                fontSize: isTinyScreen ? 11 : null,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const HSpace(12),

                              // Tenant Option
                              Expanded(
                                child: GestureDetector(
                                  onTap: _isLoading
                                      ? null
                                      : () => setState(() => _selectedRole = 'tenant'),
                                  child: Container(
                                    padding: EdgeInsets.all(isTinyScreen ? 12 : 16),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == 'tenant'
                                          ? RentraColors.limeGreen
                                          : RentraColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedRole == 'tenant'
                                            ? RentraColors.limeGreen
                                            : RentraColors.divider,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: _selectedRole == 'tenant'
                                              ? Colors.white
                                              : RentraColors.limeGreen,
                                          size: isTinyScreen ? 24 : 28,
                                        ),
                                        VSpace(isTinyScreen ? 6 : 8),
                                        Text(
                                          'Tenant',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                color: _selectedRole == 'tenant'
                                                    ? Colors.white
                                                    : RentraColors.darkText,
                                                fontWeight: FontWeight.w600,
                                                fontSize: isTinyScreen ? 11 : null,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          VSpace(isTinyScreen ? 16 : 20),

                          // REGISTER BUTTON
                          RentraPrimaryButton(
                            label: 'Create Account',
                            icon: Icons.check_circle_outline,
                            isLoading: _isLoading,
                            isEnabled: !_isLoading,
                            onPressed: _register,
                          ),

                          VSpace(isTinyScreen ? 12 : 16),

                          // LOGIN LINK
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: isTinyScreen ? 12 : null,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: RentraColors.darkTeal,
                                          fontWeight: FontWeight.w600,
                                          fontSize: isTinyScreen ? 12 : null,
                                        ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    VSpace(bottomSpacing),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}