import 'package:flutter/material.dart';

class RentraColors {
  // Primary Colors
  static const Color darkTeal = Color(0xFF006B7A); // Dark teal from house
  static const Color lightTeal = Color(0xFF00A8BF); // Light teal from house
  static const Color limeGreen = Color(0xFF7CB342); // Green from arrow
  static const Color brightLime = Color(0xFF9CCC65); // Bright green accent

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF8F9FA); // Light gray
  static const Color surface = Colors.white;
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color lightText = Color(0xFF666666);
  static const Color divider = Color(0xFFE0E0E0);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color pending = Color(0xFFFF9800);

  // Gradient
  static LinearGradient primaryGradient = LinearGradient(
    colors: [darkTeal, lightTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient = LinearGradient(
    colors: [limeGreen, brightLime],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// RENTRA App Theme
class RentraTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Primary Color
    primaryColor: RentraColors.darkTeal,
    scaffoldBackgroundColor: RentraColors.background,
    
    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: RentraColors.darkTeal,
      secondary: RentraColors.limeGreen,
      surface: RentraColors.surface,
      error: RentraColors.error,
      onSurface: RentraColors.darkText,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: RentraColors.darkTeal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Bottom Navigation Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: RentraColors.white,
      selectedItemColor: RentraColors.darkTeal,
      unselectedItemColor: RentraColors.lightText,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RentraColors.darkTeal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: RentraColors.darkTeal,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RentraColors.darkTeal,
        side: const BorderSide(color: RentraColors.darkTeal, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: RentraColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RentraColors.background,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RentraColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RentraColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RentraColors.darkTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RentraColors.error),
      ),
      labelStyle: const TextStyle(
        color: RentraColors.darkText,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: RentraColors.lightText,
      ),
    ),

    // Text Themes
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: RentraColors.darkText,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: RentraColors.darkText,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: RentraColors.darkText,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: RentraColors.darkText,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: RentraColors.darkText,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: RentraColors.darkText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: RentraColors.lightText,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: RentraColors.lightText,
      ),
    ),
  );
}