import 'package:flutter/material.dart';

class AppTheme {
  // Get light ThemeData for the app
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        // Primary colors - Modern teal
        primary: Color(0xFF00897B),
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF4DB6AC),
        onPrimaryContainer: Colors.white,

        // Secondary colors - Warm coral
        secondary: Color(0xFFFF6B6B),
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFFF8E8E),
        onSecondaryContainer: Colors.white,

        // Tertiary colors - Accent green
        tertiary: Color(0xFF4CAF50),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFA5D6A7),
        onTertiaryContainer: Colors.white,

        // Status colors
        error: Color(0xFFE53935),
        onError: Colors.white,
        errorContainer: Color(0xFFFFCDD2),
        onErrorContainer: Color(0xFFE53935),

        // Additional colors
        onSurfaceVariant: Color(0xFF666666),
        outlineVariant: Colors.black,

        // Accent colors
        surfaceTint: Color(0xFFD32F2F),
        surfaceBright: Color(0xFF1976D2),

        // Complementary colors
        scrim: Color(0xFF0288D1),
        surfaceContainer: Color(0xFF388E3C),
        inverseSurface: Color(0xFF1A1A1A),
        onInverseSurface: Colors.white,
        inversePrimary: Color(0xFF4DB6AC),

        // Base colors
        surface: Color(0xFFF8F9FA),
        onSurface: Color(0xFF1A1A1A),
        surfaceContainerHighest: Color(0xFFE8E8E8),

        // Outline and shadow
        outline: Color(0xFFE0E0E0),
        shadow: Colors.black.withOpacity(0.08),

        brightness: Brightness.light,
      ),

      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.5,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        isDense: false,
        isCollapsed: false,
        alignLabelWithHint: true,
      ),

      // Text selection theme
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Color(0xFF00897B).withOpacity(0.2),
        selectionHandleColor: Color(0xFF00897B),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
        shape: CircleBorder(),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 16,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ListTile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        horizontalTitleGap: 16,
        minVerticalPadding: 8,
        dense: false,
        visualDensity: VisualDensity.standard,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Color(0xFF00897B).withOpacity(0.1);
          }
          return Colors.transparent;
        }),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Color(0xFF00897B);
          }
          return Colors.grey[400];
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Color(0xFF00897B);
          }
          return Colors.grey[400];
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actionsPadding: const EdgeInsets.all(16),
      ),
    );
  }

  // Get dark ThemeData for the app
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        // Primary colors - Modern teal
        primary: Color(0xFF00897B),
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF4DB6AC),
        onPrimaryContainer: Colors.white,

        // Secondary colors - Warm coral
        secondary: Color(0xFFFF6B6B),
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFFF8E8E),
        onSecondaryContainer: Colors.white,

        // Tertiary colors - Accent green
        tertiary: Color(0xFF4CAF50),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFF2E7D32),
        onTertiaryContainer: Colors.white,

        // Status colors
        error: Color(0xFFE53935),
        onError: Colors.white,
        errorContainer: Color(0xFFB71C1C),
        onErrorContainer: Color(0xFFE53935),

        // Additional colors
        onSurfaceVariant: Color(0xFFE0E0E0),
        outlineVariant: Colors.black,

        // Accent colors
        surfaceTint: Color(0xFFD32F2F),
        surfaceBright: Color(0xFF1976D2),

        // Complementary colors
        scrim: Color(0xFF0288D1),
        surfaceContainer: Color(0xFF388E3C),
        inverseSurface: Colors.white,
        onInverseSurface: Color(0xFF121212),
        inversePrimary: Color(0xFF00695C),

        // Base colors
        surface: Color(0xFF121212),
        onSurface: Colors.white,
        surfaceContainerHighest: Color(0xFF2C2C2C),

        // Outline and shadow
        outline: Color(0xFF444444),
        shadow: Colors.black.withOpacity(0.2),

        brightness: Brightness.dark,
      ),

      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.5,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        isDense: false,
        isCollapsed: false,
        alignLabelWithHint: true,
      ),

      // Text selection theme
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Color(0xFF00897B).withOpacity(0.2),
        selectionHandleColor: Color(0xFF00897B),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
        shape: CircleBorder(),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 16,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ListTile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        horizontalTitleGap: 16,
        minVerticalPadding: 8,
        dense: false,
        visualDensity: VisualDensity.standard,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Color(0xFF00897B).withOpacity(0.1);
          }
          return Colors.transparent;
        }),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Color(0xFF00897B);
          }
          return Colors.grey[600];
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Color(0xFF00897B);
          }
          return Colors.grey[600];
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actionsPadding: const EdgeInsets.all(16),
      ),
    );
  }

  // Get theme based on brightness
  static ThemeData getTheme({required Brightness brightness}) {
    return brightness == Brightness.light ? getLightTheme() : getDarkTheme();
  }
}