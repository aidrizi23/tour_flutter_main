import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized theme definitions for the application.
class AppTheme {
  /// Light [ThemeData] inspired by modern web aesthetics.
  static ThemeData light() {
    const primaryColor = Color(0xFF0D6EFD); // Bootstrap blue
    const secondaryColor = Color(0xFF6610F2); // Accent purple
    const accentColor = Color(0xFF198754); // Success green
    const backgroundColor = Color(0xFFF8F9FA);
    const surfaceColor = Color(0xFFFFFFFF);
    const cardColor = Color(0xFFFFFFFF);

    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        surfaceContainerLowest: backgroundColor,
        surfaceContainerLow: const Color(0xFFF7F9FA),
        surfaceContainer: const Color(0xFFF0F2F5),
        surfaceContainerHigh: const Color(0xFFE4E7EB),
        background: backgroundColor,
        error: const Color(0xFFD32F2F),
        outline: const Color(0xFFD1D5DB),
        onPrimary: Colors.white,
        onSurface: const Color(0xFF1A1A1A),
        onSurfaceVariant: const Color(0xFF5F6368),
        onBackground: const Color(0xFF1A1A1A),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: surfaceColor,
        surfaceTintColor: surfaceColor,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
        iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      scaffoldBackgroundColor: backgroundColor,
    );
  }

  /// Dark [ThemeData] providing a complementary palette.
  static ThemeData dark() {
    const primaryColor = Color(0xFF0D6EFD); // Same base blue
    const secondaryColor = Color(0xFF7C4DFF);
    const accentColor = Color(0xFF20C997);
    const backgroundColor = Color(0xFF121212);
    const surfaceColor = Color(0xFF1E1E1E);
    const cardColor = Color(0xFF2C2C2C);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        surfaceContainerLowest: backgroundColor,
        surfaceContainerLow: const Color(0xFF161B26),
        surfaceContainer: cardColor,
        surfaceContainerHigh: const Color(0xFF2A3142),
        surfaceContainerHighest: const Color(0xFF303749),
        background: backgroundColor,
        error: const Color(0xFFE57373),
        outline: const Color(0xFF3F4650),
        onPrimary: Colors.white,
        onSurface: const Color(0xFFE8EAED),
        onSurfaceVariant: const Color(0xFFBDC1C6),
        onBackground: const Color(0xFFE8EAED),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: surfaceColor,
        surfaceTintColor: surfaceColor,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE8EAED),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE8EAED)),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A3142),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3F4650)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3F4650)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      scaffoldBackgroundColor: backgroundColor,
    );
  }
}
