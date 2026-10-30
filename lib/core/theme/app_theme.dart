import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'design_tokens.dart';

/// Central theme configuration for PrintAssist app.
/// Glass effects are baked into the color scheme as tinted surfaces.
class AppTheme {
  AppTheme._();

  // ─── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
    );
    return base.copyWith(
      scaffoldBackgroundColor: DesignTokens.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: _titleStyle(Brightness.light),
        iconTheme: const IconThemeData(color: DesignTokens.lightOnSurface),
      ),
      cardTheme: CardThemeData(
        color: DesignTokens.lightGlassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
          side: const BorderSide(
            color: DesignTokens.lightGlassEdge,
            width: 1,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: _textTheme(Brightness.light),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DesignTokens.accent,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DesignTokens.lightGlassSurface,
        shape: const StadiumBorder(),
        side: BorderSide(color: DesignTokens.lightGlassEdge),
      ),
      dividerTheme: DividerThemeData(
        color: DesignTokens.lightDivider,
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.lightGlassSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DesignTokens.lightGlassEdge),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DesignTokens.lightGlassEdge),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DesignTokens.accent, width: 2),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
    );
    return base.copyWith(
      scaffoldBackgroundColor: DesignTokens.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: _titleStyle(Brightness.dark),
        iconTheme: const IconThemeData(color: DesignTokens.darkOnSurface),
      ),
      cardTheme: CardThemeData(
        color: DesignTokens.darkGlassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
          side: const BorderSide(
            color: DesignTokens.darkGlassEdge,
            width: 1,
          ),
        ),
      ),
      textTheme: _textTheme(Brightness.dark),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.accentDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DesignTokens.darkGlassSurface,
        shape: const StadiumBorder(),
        side: BorderSide(color: DesignTokens.darkGlassEdge),
      ),
      dividerTheme: DividerThemeData(
        color: DesignTokens.darkDivider,
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.darkGlassSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DesignTokens.darkGlassEdge),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DesignTokens.darkGlassEdge),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DesignTokens.accentDark, width: 2),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─── Color Schemes ──────────────────────────────────────────────────────────
  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: DesignTokens.accent,
    onPrimary: Colors.white,
    secondary: Color(0xFF5856D6),
    onSecondary: Colors.white,
    error: DesignTokens.error,
    onError: Colors.white,
    surface: DesignTokens.lightBackground,
    onSurface: DesignTokens.lightOnSurface,
    surfaceContainerHighest: DesignTokens.lightGlassSurface,
  );

  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: DesignTokens.accentDark,
    onPrimary: Colors.white,
    secondary: Color(0xFF7E7DFF),
    onSecondary: Colors.white,
    error: DesignTokens.errorDark,
    onError: Colors.white,
    surface: DesignTokens.darkBackground,
    onSurface: DesignTokens.darkOnSurface,
    surfaceContainerHighest: DesignTokens.darkGlassSurface,
  );

  static TextStyle _titleStyle(Brightness brightness) {
    final color = brightness == Brightness.light
        ? DesignTokens.lightOnSurface
        : DesignTokens.darkOnSurface;
    return TextStyle(
      color: color,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final color = brightness == Brightness.light
        ? DesignTokens.lightOnSurface
        : DesignTokens.darkOnSurface;
    return TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: color),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: color),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: color),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
      titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: color),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: color),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
    );
  }
}
