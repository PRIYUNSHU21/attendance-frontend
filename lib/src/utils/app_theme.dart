import 'package:flutter/material.dart';

class AppTheme {
  // Brand Color Palette - Modern Teal & Ocean Theme
  static const Color primaryColor = Color(
    0xFF0D7377,
  ); // Deep Teal - Main brand color
  static const Color primaryLight = Color(0xFF14A085); // Emerald Teal
  static const Color primaryDark = Color(0xFF065F63); // Darker Teal

  static const Color secondaryColor = Color(
    0xFF41B883,
  ); // Fresh Green - Success/Attendance
  static const Color secondaryLight = Color(0xFF68D391); // Light Green
  static const Color secondaryDark = Color(0xFF2F855A); // Dark Green

  static const Color accentColor = Color(
    0xFFFF6B6B,
  ); // Coral Red - Attention/Warning
  static const Color accentLight = Color(0xFFFF8A80); // Light Coral
  static const Color accentDark = Color(0xFFE57373); // Dark Coral

  static const Color errorColor = Color(0xFFE53E3E); // Red 500
  static const Color errorLight = Color(0xFFF56565); // Red 400
  static const Color errorDark = Color(0xFFC53030); // Red 600

  // Neutral Colors - Clean and Professional
  static const Color background = Color(0xFFF8FFFE); // Soft Off-White
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceVariant = Color(0xFFF0FDFA); // Teal Tint

  static const Color textPrimary = Color(0xFF2D3748); // Dark Gray
  static const Color textSecondary = Color(0xFF4A5568); // Medium Gray
  static const Color textTertiary = Color(0xFF718096); // Light Gray
  static const Color textDisabled = Color(0xFFA0AEC0); // Very Light Gray

  static const Color divider = Color(0xFFE2E8F0); // Light Border
  static const Color outline = Color(0xFFCBD5E0); // Medium Border

  // Status Colors
  static const Color success = Color(0xFF48BB78); // Green Success
  static const Color warning = Color(0xFFED8936); // Orange Warning
  static const Color error = Color(0xFFE53E3E); // Red Error
  static const Color info = Color(0xFF3182CE); // Blue Info

  // Legacy aliases for backward compatibility
  static const Color cardBackground = surface;
  static const Color textDark = textPrimary;
  static const Color textMedium = textSecondary;
  static const Color textLight = textTertiary;
  static const Color dividerColor = divider;
  static const Color warningColor = warning;
  static const Color successColor = success;

  // Gradients - Modern and Elegant
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Elevation and Shadows
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x19000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
  ];

  // Legacy shadow aliases
  static const List<BoxShadow> cardShadowSmall = shadowSm;
  static const List<BoxShadow> cardShadowMedium = shadowMd;
  static const List<BoxShadow> cardShadowLarge = shadowLg;
  static const List<BoxShadow> cardShadow = shadowMd;

  // Border Radius
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radius2xl = BorderRadius.all(Radius.circular(24));

  // Legacy radius aliases
  static const BorderRadius borderRadiusSmall = radiusMd;
  static const BorderRadius borderRadiusMedium = radiusLg;
  static const BorderRadius borderRadiusLarge = radiusXl;
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(50),
  );

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2xl = 48;

  // Animation Durations
  static const Duration animDurationFast = Duration(milliseconds: 200);
  static const Duration animDurationMedium = Duration(milliseconds: 300);
  static const Duration animDurationSlow = Duration(milliseconds: 500);

  // Typography - Professional and Readable
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    color: textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    color: textSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    color: textTertiary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: textTertiary,
  );

  // Legacy typography aliases
  static const TextStyle headingLarge = displayLarge;
  static const TextStyle headingMedium = displayMedium;
  static const TextStyle headingSmall = displaySmall;

  // Material Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryLight,
        secondary: secondaryColor,
        secondaryContainer: secondaryLight,
        tertiary: accentColor,
        tertiaryContainer: accentLight,
        surface: surface,
        surfaceVariant: surfaceVariant,
        background: background,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        onBackground: textPrimary,
        onError: Colors.white,
        outline: outline,
        shadow: Colors.black26,
      ),
      fontFamily: 'SF Pro Display', // System font
      textTheme: const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: radiusLg),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primaryLight,
        labelStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: radiusSm),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
