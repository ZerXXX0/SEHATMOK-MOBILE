import 'package:flutter/material.dart';

class AppTheme {
  // Colors - Material Design 3 Color Scheme
  static const Color primary = Color(0xFF176a21);
  static const Color primaryDim = Color(0xFF025d16);
  static const Color primaryContainer = Color(0xFF9df197);
  static const Color primaryFixed = Color(0xFF9df197);
  static const Color primaryFixedDim = Color(0xFF90e28a);
  
  static const Color secondary = Color(0xFF874e00);
  static const Color secondaryDim = Color(0xFF764400);
  static const Color secondaryContainer = Color(0xFFffc791);
  static const Color secondaryFixed = Color(0xFFffc791);
  static const Color secondaryFixedDim = Color(0xFFffb467);
  
  static const Color tertiary = Color(0xFF006760);
  static const Color tertiaryDim = Color(0xFF005a54);
  static const Color tertiaryContainer = Color(0xFF7fe6db);
  static const Color tertiaryFixed = Color(0xFF7fe6db);
  static const Color tertiaryFixedDim = Color(0xFF71d7cd);
  
  static const Color error = Color(0xFFb02500);
  static const Color errorDim = Color(0xFFb92902);
  static const Color errorContainer = Color(0xFFf95630);
  
  static const Color surface = Color(0xFFf5f7f5);
  static const Color surfaceDim = Color(0xFFd1d5d3);
  static const Color surfaceBright = Color(0xFFf5f7f5);
  static const Color surfaceContainer = Color(0xFFe6e9e7);
  static const Color surfaceContainerLow = Color(0xFFeff1ef);
  static const Color surfaceContainerHigh = Color(0xFFe0e3e1);
  static const Color surfaceContainerHighest = Color(0xFFd9dedb);
  static const Color surfaceContainerLowest = Color(0xFFffffff);
  static const Color surfaceTint = Color(0xFF176a21);
  
  static const Color background = Color(0xFFf5f7f5);
  static const Color inverseSurface = Color(0xFF0b0f0e);
  static const Color inverseOnSurface = Color(0xFF9b9d9c);
  static const Color inversePrimary = Color(0xFF9df197);
  
  static const Color onPrimary = Color(0xFFd1ffc8);
  static const Color onPrimaryContainer = Color(0xFF005c15);
  static const Color onPrimaryFixed = Color(0xFF00460e);
  static const Color onPrimaryFixedVariant = Color(0xFF12661e);
  
  static const Color onSecondary = Color(0xFFfff0e5);
  static const Color onSecondaryContainer = Color(0xFF6a3c00);
  static const Color onSecondaryFixed = Color(0xFF4f2c00);
  static const Color onSecondaryFixedVariant = Color(0xFF774400);
  
  static const Color onTertiary = Color(0xFFbffff7);
  static const Color onTertiaryContainer = Color(0xFF00534d);
  static const Color onTertiaryFixed = Color(0xFF003e39);
  static const Color onTertiaryFixedVariant = Color(0xFF005d57);
  
  static const Color onError = Color(0xFFffefec);
  static const Color onErrorContainer = Color(0xFF520c00);
  
  static const Color onSurface = Color(0xFF2c2f2e);
  static const Color onBackground = Color(0xFF2c2f2e);
  static const Color onSurfaceVariant = Color(0xFF595c5b);
  
  static const Color outline = Color(0xFF747776);
  static const Color outlineVariant = Color(0xFFabaeac);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        tertiary: tertiary,
        tertiaryContainer: tertiaryContainer,
        error: error,
        errorContainer: errorContainer,
        surface: surface,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onTertiary: onTertiary,
        onError: onError,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 57,
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 45,
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 6,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainer,
        selectedColor: primary,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: outline),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        tertiary: tertiary,
        tertiaryContainer: tertiaryContainer,
        error: error,
        errorContainer: errorContainer,
        surface: surface,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onTertiary: onTertiary,
        onError: onError,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      fontFamily: 'Inter',
    );
  }
}
