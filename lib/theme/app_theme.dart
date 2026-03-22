import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// RescueHub app theme - cohesive color scheme for disaster response app
class AppTheme {
  // Brand colors - trust, safety, urgency
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryBlueDark = Color(0xFF0D47A1);
  static const Color accentAmber = Color(0xFFFF8F00);
  static const Color accentCoral = Color(0xFFE65100);
  static const Color dangerRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color surfaceLight = Color(0xFFF5F7FA);
  static const Color cardWhite = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentAmber,
        error: dangerRed,
        surface: surfaceLight,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.outfitTextTheme(),
      scaffoldBackgroundColor: surfaceLight,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: cardWhite,
        foregroundColor: Colors.black87,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardWhite,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
