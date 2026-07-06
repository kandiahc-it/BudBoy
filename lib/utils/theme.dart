import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  static const Color primary = Color(0xFF7C3AED); // Electric Purple
  static const Color secondary = Color(0xFF0D9488); // Neon Teal

  // Category Configuration
  static final Map<String, _CategoryStyle> _predefinedStyles = {
    'Food': _CategoryStyle(Icons.restaurant_rounded, const Color(0xFFF59E0B)),     // Amber
    'Transport': _CategoryStyle(Icons.directions_car_rounded, const Color(0xFF0D9488)), // Teal
    'Stationery': _CategoryStyle(Icons.edit_note_rounded, const Color(0xFF7C3AED)),   // Purple
    'Other': _CategoryStyle(Icons.category_rounded, const Color(0xFFEF4444)),      // Red/Orange
  };

  // List of colors to cycle through for user-specified custom categories
  static const List<Color> _accentColors = [
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF10B981), // Emerald
    Color(0xFF8B5CF6), // Indigo
    Color(0xFFF43F5E), // Rose
    Color(0xFFEAB308), // Yellow
  ];

  static IconData getCategoryIcon(String category) {
    final cleanCategory = category.trim();
    if (_predefinedStyles.containsKey(cleanCategory)) {
      return _predefinedStyles[cleanCategory]!.icon;
    }
    return Icons.star_rounded; // Flashy icon for custom category
  }

  static Color getCategoryColor(String category) {
    final cleanCategory = category.trim();
    if (_predefinedStyles.containsKey(cleanCategory)) {
      return _predefinedStyles[cleanCategory]!.color;
    }
    // Deterministic color generation based on category name hash
    final index = cleanCategory.hashCode.abs() % _accentColors.length;
    return _accentColors[index];
  }

  // Dark Theme Definition
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkCard,
        error: Color(0xFFEF4444),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        floatingLabelStyle: const TextStyle(color: primary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        headlineMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 24),
        titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 14),
      ),
    );
  }

  // Light Theme Definition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: lightCard,
        error: Color(0xFFEF4444),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: lightTextSecondary),
        floatingLabelStyle: const TextStyle(color: primary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        headlineMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 24),
        titleLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 14),
      ),
    );
  }
}

class _CategoryStyle {
  final IconData icon;
  final Color color;

  _CategoryStyle(this.icon, this.color);
}
