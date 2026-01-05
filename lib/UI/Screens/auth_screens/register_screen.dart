// import 'package:flutter/material.dart';
// import '../../../Application/auth_controller.dart';
// import 'role_select_screen.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _authController = AuthController();
//   final emailCtrl = TextEditingController();
//   final passCtrl = TextEditingController();

//   Future<void> _register() async {
//     final res = await _authController.register(
//       emailCtrl.text,
//       passCtrl.text,
//     );

//     if (res.user != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => RoleSelectScreen(userId: res.user!.id),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
//             TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
//             const SizedBox(height: 20),
//             ElevatedButton(onPressed: _register, child: const Text('Register')),
//           ],
//         ),
//       ),
//     );
//   }
// }
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
      // 1. Register user
      final res = await _authController.register(email, password);

      if (res.user == null) {
        throw Exception('Registration failed');
      }

      // 2. Save user profile with all details
      await _authController.saveUserProfile(
        userId: res.user!.id,
        email: email,
        fullName: fullName,
        phone: phone,
        role: _selectedRole,
      );

      if (!mounted) return;

      _showSuccessSnackBar('Registration successful!');

      // Clear forms
      emailCtrl.clear();
      passwordCtrl.clear();
      fullNameCtrl.clear();
      phoneCtrl.clear();

      // Navigate back to login
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: RentraColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const VSpace(20),

                  // 🏠 LOGO
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.home,
                        size: 50,
                        color: RentraColors.darkTeal,
                      ),
                    ),
                  ),

                  const VSpace(16),

                  Text(
                    'Rentra',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const VSpace(8),

                  Text(
                    'Create Your Account',
                    style:
                        Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                  ),

                  const VSpace(40),

                  // ✅ FORM CONTAINER
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📧 EMAIL
                        Text(
                          'Email Address',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const VSpace(8),
                        TextField(
                          controller: emailCtrl,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: 'your@email.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            prefixIconColor: RentraColors.darkTeal,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const VSpace(16),

                        // 👤 FULL NAME
                        Text(
                          'Full Name',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const VSpace(8),
                        TextField(
                          controller: fullNameCtrl,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: 'Your Full Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            prefixIconColor: RentraColors.darkTeal,
                          ),
                        ),
                        const VSpace(16),

                        // 📱 PHONE
                        Text(
                          'Phone Number',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const VSpace(8),
                        TextField(
                          controller: phoneCtrl,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: '01234567890',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            prefixIconColor: RentraColors.darkTeal,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const VSpace(16),

                        // 🔐 PASSWORD
                        Text(
                          'Password',
                          style: Theme.of(context).textTheme.titleMedium,
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

                        // 👥 ROLE SELECTION
                        Text(
                          'Select Your Role',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const VSpace(12),

                        Row(
                          children: [
                            // Owner Option
                            Expanded(
                              child: GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () => setState(() =>
                                        _selectedRole = 'owner'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
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
                                        size: 28,
                                      ),
                                      const VSpace(8),
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
                                    : () => setState(() =>
                                        _selectedRole = 'tenant'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
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
                                        size: 28,
                                      ),
                                      const VSpace(8),
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

                        const VSpace(24),

                        // 📝 REGISTER BUTTON
                        RentraPrimaryButton(
                          label: 'Create Account',
                          icon: Icons.check_circle_outline,
                          isLoading: _isLoading,
                          isEnabled: !_isLoading,
                          onPressed: _register,
                        ),

                        const VSpace(16),

                        // 🔗 LOGIN LINK
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: RentraColors.darkTeal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  //recognizer: TapGestureRecognizer().onTap(() => Navigator.pop(context)),
                                  recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const VSpace(40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}