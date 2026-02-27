import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:rentra/Application/auth_controller.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = AuthController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Email and password are required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authController.login(email, password);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Login failed: $e');
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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final isVerySmallScreen = screenHeight < 600;
    final isTinyScreen = screenHeight < 500;
    
    // Dynamic sizing based on screen
    final logoSize = isTinyScreen ? 80.0 : (isVerySmallScreen ? 100.0 : 120.0);
    final logoIconSize = isTinyScreen ? 40.0 : (isVerySmallScreen ? 50.0 : 60.0);
    final topSpacing = isTinyScreen ? 16.0 : (isVerySmallScreen ? 20.0 : 40.0);
    final middleSpacing = isTinyScreen ? 20.0 : (isVerySmallScreen ? 30.0 : 50.0);
    final bottomSpacing = isTinyScreen ? 16.0 : (isVerySmallScreen ? 20.0 : 40.0);

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
                  vertical: isTinyScreen ? 16 : 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VSpace(topSpacing),

                    // LOGO SECTION with responsive sizing
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
                        VSpace(isTinyScreen ? 12 : 16),
                        Text(
                          'Rentra',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTinyScreen ? 28 : null,
                              ),
                        ),
                        VSpace(isTinyScreen ? 4 : 8),
                        Text(
                          'NextGen Rental Management',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: isTinyScreen ? 12 : null,
                              ),
                        ),
                      ],
                    ),

                    VSpace(middleSpacing),

                    // MAIN CONTENT with max-width constraint
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth > 600 ? 500 : double.infinity,
                      ),
                      padding: EdgeInsets.all(isTinyScreen ? 20 : 24),
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
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: isTinyScreen ? 20 : null,
                            ),
                          ),
                          VSpace(isTinyScreen ? 6 : 8),
                          Text(
                            'Sign in to manage your properties',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          VSpace(isTinyScreen ? 20 : 24),

                          // EMAIL FIELD
                          Text(
                            'Email',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const VSpace(8),
                          TextField(
                            controller: _emailCtrl,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              prefixIconColor: RentraColors.darkTeal,
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const VSpace(16),

                          // PASSWORD FIELD
                          Text(
                            'Password',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const VSpace(8),
                          TextField(
                            controller: _passCtrl,
                            enabled: !_isLoading,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              prefixIconColor: RentraColors.darkTeal,
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
                          VSpace(isTinyScreen ? 20 : 24),

                          // PRIMARY BUTTON
                          RentraPrimaryButton(
                            label: 'Sign In',
                            icon: Icons.login,
                            isLoading: _isLoading,
                            isEnabled: !_isLoading,
                            onPressed: _login,
                          ),
                          const VSpace(16),

                          // REGISTER LINK
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: 'Don\'t have an account? ',
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: 'Register',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: RentraColors.darkTeal,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen(),
                                            ),
                                          ),
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
