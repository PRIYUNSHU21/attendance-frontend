import 'package:flutter/material.dart';

class AppTheme {
  // Professional Color Palette
  static const Color primaryColor = Color(0xFF6366F1); // Indigo 500
  static const Color primaryVariant = Color(0xFF4F46E5); // Indigo 600
  static const Color secondaryColor = Color(0xFF10B981); // Emerald 500
  static const Color accentColor = Color(0xFFF59E0B); // Amber 500

  // Neutral Colors
  static const Color surfaceColor = Color(0xFFFAFAFA); // Neutral 50
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  static const Color cardColor = Color(0xFFFFFFFF); // White
  static const Color dividerColor = Color(0xFFE5E7EB); // Gray 200

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textLight = Color(0xFF9CA3AF); // Gray 400

  // Status Colors
  static const Color successColor = Color(0xFF10B981); // Emerald 500
  static const Color warningColor = Color(0xFFF59E0B); // Amber 500
  static const Color errorColor = Color(0xFFEF4444); // Red 500
  static const Color infoColor = Color(0xFF3B82F6); // Blue 500

  // Border Radius
  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(8.0),
  );
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(12.0),
  );
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(16.0),
  );
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(50.0),
  );

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> cardShadowLarge = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Typography
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: Color(0xFFEEF2FF), // Indigo 50
        secondary: secondaryColor,
        secondaryContainer: Color(0xFFD1FAE5), // Emerald 100
        tertiary: accentColor,
        tertiaryContainer: Color(0xFFFEF3C7), // Amber 100
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
        outline: dividerColor,
        shadow: Color(0x1A000000),
      ),

      // Typography
      textTheme: const TextTheme(
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

      // App Bar Theme
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

      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
        shadowColor: const Color(0x1A000000),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: borderRadiusSmall),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 16),
        hintStyle: const TextStyle(color: textLight, fontSize: 16),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: borderRadiusFull),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        disabledColor: dividerColor,
        selectedColor: primaryColor.withOpacity(0.12),
        secondarySelectedColor: secondaryColor.withOpacity(0.12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: bodyMedium,
        secondaryLabelStyle: bodyMedium,
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(borderRadius: borderRadiusFull),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: textPrimary, size: 24),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(color: Colors.white, size: 24),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        primaryContainer: Color(0xFF3730A3), // Indigo 800
        secondary: secondaryColor,
        secondaryContainer: Color(0xFF047857), // Emerald 700
        tertiary: accentColor,
        tertiaryContainer: Color(0xFFD97706), // Amber 600
        surface: Color(0xFF1F2937), // Gray 800
        background: Color(0xFF111827), // Gray 900
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: Color(0xFFF9FAFB), // Gray 50
        onBackground: Color(0xFFF9FAFB), // Gray 50
        onError: Colors.white,
        outline: Color(0xFF374151), // Gray 700
        shadow: Color(0x3F000000),
      ),
    );
  }
}
