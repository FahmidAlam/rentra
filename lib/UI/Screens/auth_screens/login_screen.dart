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
    // ! RESPONSIVE SIZING: Adapts to different screen sizes
    final isSmallScreen = MediaQuery.of(context).size.height < 600;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        // ! GRADIENT BACKGROUND using Rentra colors
        decoration: BoxDecoration(gradient: RentraColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            // ! SCROLLABLE VIEW: For devices with keyboard
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // RESPONSIVE SPACING using VSpace
                    VSpace(isSmallScreen ? 20 : 40),

                    // LOGO SECTION
                    Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
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
                              size: 60,
                              color: RentraColors.darkTeal,
                            ),
                          ),
                        ),
                        const VSpace(16),
                        Text(
                          'Rentra',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const VSpace(4),
                        Text(
                          'NextGen Rental Management',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                        ),
                      ],
                    ),

                    VSpace(isSmallScreen ? 30 : 50),

                    // MAIN CONTENT in responsive container
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
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
                        children: [
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const VSpace(8),
                          Text(
                            'Sign in to manage your properties',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const VSpace(24),

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
                          const VSpace(24),

                          // ✅ PRIMARY BUTTON using reusable widget
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
                                    recognizer:
                                        TapGestureRecognizer()
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

                    VSpace(isSmallScreen ? 20 : 40),
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