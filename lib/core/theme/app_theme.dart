import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const Color _primaryLight = Color(0xFF4054B2);
  static const Color _primaryVariantLight = Color(0xFF303F9F);
  static const Color _secondaryLight = Color(0xFF50C878); // Emerald green
  static const Color _backgroundLight = Color(0xFFF8F9FA);
  static const Color _surfaceLight = Colors.white;
  static const Color _errorLight = Color(0xFFE53935);
  static const Color _onPrimaryLight = Colors.white;
  static const Color _onSecondaryLight = Colors.white;
  static const Color _onBackgroundLight = Color(0xFF212121);
  static const Color _onSurfaceLight = Color(0xFF212121);
  static const Color _onErrorLight = Colors.white;

  // Dark theme colors
  static const Color _primaryDark = Color(0xFF3F51B5);
  static const Color _primaryVariantDark = Color(0xFF303F9F);
  static const Color _secondaryDark = Color(0xFF66BB6A);
  static const Color _backgroundDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _errorDark = Color(0xFFE57373);
  static const Color _onPrimaryDark = Colors.white;
  static const Color _onSecondaryDark = Colors.white;
  static const Color _onBackgroundDark = Colors.white;
  static const Color _onSurfaceDark = Colors.white;
  static const Color _onErrorDark = Colors.black;

  // Card and element colors
  static const Color _cardLight = Colors.white;
  static const Color _cardDark = Color(0xFF2C2C2C);
  static const Color _dividerLight = Color(0xFFDEE2E6);
  static const Color _dividerDark = Color(0xFF424242);

  // Text styles
  static const TextStyle _headlineLight = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF212121),
  );
  static const TextStyle _headlineDark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static const TextStyle _subtitleLight = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF616161),
  );
  static const TextStyle _subtitleDark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFFBDBDBD),
  );
  static const TextStyle _bodyLight = TextStyle(
    fontSize: 14,
    color: Color(0xFF212121),
  );
  static const TextStyle _bodyDark = TextStyle(
    fontSize: 14,
    color: Colors.white,
  );

  // Animation durations
  static const Duration _shortAnimation = Duration(milliseconds: 200);
  static const Duration _mediumAnimation = Duration(milliseconds: 300);

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        primaryContainer: _primaryVariantLight,
        secondary: _secondaryLight,
        surface: _surfaceLight,
        error: _errorLight,
        onPrimary: _onPrimaryLight,
        onSecondary: _onSecondaryLight,
        onSurface: _onSurfaceLight,
        onError: _onErrorLight,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _backgroundLight,
      cardColor: _cardLight,
      dividerColor: _dividerLight,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: _primaryLight,
        foregroundColor: _onPrimaryLight,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        displayLarge: _headlineLight,
        titleMedium: _subtitleLight,
        bodyMedium: _bodyLight,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryLight, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: _onPrimaryLight,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: Size(120, 48),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: _onPrimaryLight,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: Size(120, 48),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceLight,
        indicatorColor: _primaryLight.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: _primaryLight);
          }
          return IconThemeData(color: Colors.grey);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: _primaryLight, fontWeight: FontWeight.w500);
          }
          return TextStyle(color: Colors.grey, fontWeight: FontWeight.normal);
        }),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(
            allowEnterRouteSnapshotting: false,
          ),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        primaryContainer: _primaryVariantDark,
        secondary: _secondaryDark,
        surface: _surfaceDark,
        error: _errorDark,
        onPrimary: _onPrimaryDark,
        onSecondary: _onSecondaryDark,
        onSurface: _onSurfaceDark,
        onError: _onErrorDark,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _backgroundDark,
      cardColor: _cardDark,
      dividerColor: _dividerDark,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: _surfaceDark,
        foregroundColor: _onSurfaceDark,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        displayLarge: _headlineDark,
        titleMedium: _subtitleDark,
        bodyMedium: _bodyDark,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryDark, width: 2),
        ),
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: _onPrimaryDark,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: Size(120, 48),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: _onPrimaryDark,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: Size(120, 48),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceDark,
        indicatorColor: _primaryDark.withOpacity(0.3),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: _primaryDark);
          }
          return IconThemeData(color: Colors.grey);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: _primaryDark, fontWeight: FontWeight.w500);
          }
          return TextStyle(color: Colors.grey, fontWeight: FontWeight.normal);
        }),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(
            allowEnterRouteSnapshotting: false,
          ),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
