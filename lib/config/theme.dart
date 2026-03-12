import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color black = Color(0xFF1A1A1A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F8FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // Status colors
  static const Color statusPending = Color(0xFF9E9E9E);
  static const Color statusInProgress = Color(0xFF1565C0);
  static const Color statusCompleted = Color(0xFF2E7D32);
  static const Color statusCancelled = Color(0xFFC62828);
  static const Color urgentRed = Color(0xFFD32F2F);

  // Spacing scale (4px base)
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 20;
  static const double spacingXxl = 24;

  static const TextTheme _textTheme = TextTheme(
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: black),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: black),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: black),
    bodyLarge: TextStyle(fontSize: 15, color: black),
    bodyMedium: TextStyle(fontSize: 14, color: black),
    bodySmall: TextStyle(fontSize: 12, color: textSecondary),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        onPrimary: white,
        surface: surface,
        onSurface: black,
      ),
      textTheme: _textTheme,
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(fontSize: 14, color: textSecondary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: white,
        elevation: 0,
        indicatorColor: primaryBlue.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1, space: 1),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: divider),
      ),
    );
  }
}
