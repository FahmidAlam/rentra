import 'package:flutter/material.dart';
import 'package:rentra/UI/Screens/auth_screens/auth_gate.dart';
import 'package:rentra/core/supabase_client.dart';
import 'package:rentra/core/theme/app_theme.dart';
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SupabaseManager.init();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: AuthGate(),
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rentra - NextGen Rental Management',
      theme: RentraTheme.lightTheme, // ✅ APPLY THEME
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}