import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Farben
class ReflectoColors {
  // Primary (Serenity Blue)
  static const Color primaryLight = Color(0xFFD6E6FF);
  static const Color primaryMid = Color(0xFF2E7DFA);
  static const Color primaryDark = Color(0xFF004FCA);

  // Secondary (Soft Sky)
  static const Color secondaryLight = Color(0xFFEAF3FF);
  static const Color secondaryMid = Color(0xFFA7C5EB);
  static const Color secondaryDark = Color(0xFF739BD5);

  // Background (Calm Base)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundMid = Color(0xFFF0F7FF);
  static const Color backgroundDark = Color(0xFFCBD7EB);

  // Success (Growth Green)
  static const Color successLight = Color(0xFFDFF3E1);
  static const Color successMid = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF2E7D32);

  // Warning (Focus Amber)
  static const Color warningLight = Color(0xFFFFE5C2);
  static const Color warningMid = Color(0xFFE57A00);
  static const Color warningDark = Color(0xFFA35600);

  // Borders (Misty Steel)
  static const Color borderLight = Color(0xFFEDF2FA);
  static const Color borderMid = Color(0xFFD9E3F0);
  static const Color borderDark = Color(0xFF9FB0C9);

  // Text
  static const Color textPrimary = Color(0xFF003366);
  static const Color textSecondary = Color(0xFF334A66);
  static const Color textDisabled = Color(0xFF98A6B8);

  // Dark mode specifics
  static const Color darkBackground = Color(0xFF0E1A26);
  static const Color darkCard = Color(0xFF1C2A3A);
  static const Color darkText = Color(0xFFEAF3FF);
  static const Color darkSecondary = Color(0xFF7FAEE2);
}

/// Reflecto Gesamt‑Theme (Material 3)
class ReflectoTheme {
  /// Beibehaltung alter Referenzen (Kompatibilität)
  static const Color primary = ReflectoColors.primaryMid;
  static const Color secondary = ReflectoColors.secondaryMid;

  /// Light Theme
  static ThemeData light() {
    // Basis ColorScheme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ReflectoColors.primaryMid,
      brightness: Brightness.light,
    ).copyWith(
      primary: ReflectoColors.primaryMid,
      onPrimary: Colors.white,
      secondary: ReflectoColors.secondaryMid,
      onSecondary: ReflectoColors.textPrimary,
      surface: ReflectoColors.backgroundMid,
      onSurface: ReflectoColors.textPrimary,
      error: ReflectoColors.warningMid,
      onError: Colors.white,
      outline: ReflectoColors.borderMid,
    );

    // Typografie
    final inter = GoogleFonts.interTextTheme();
    final lexend = GoogleFonts.lexendTextTheme();
    final textTheme = inter
        .copyWith(
          headlineLarge: lexend.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
          headlineMedium: lexend.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
          titleLarge: lexend.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
          titleMedium: lexend.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          bodyLarge: inter.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
          bodyMedium: inter.bodyMedium?.copyWith(fontSize: 15, height: 1.5),
          bodySmall: inter.bodySmall?.copyWith(
            fontSize: 13,
            height: 1.4,
            color: ReflectoColors.textSecondary,
          ),
        )
        .apply(
          bodyColor: ReflectoColors.textPrimary,
          displayColor: ReflectoColors.textPrimary,
        );

    // Eingabefelder
    OutlineInputBorder outlineBorder(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: 1.2),
        );

    return ThemeData(
      useMaterial3: true,
      fontFamilyFallback: const [
        'Segoe UI Emoji',
        'Apple Color Emoji',
        'Noto Color Emoji',
      ],
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ReflectoColors.backgroundMid,

      /// Typografie
      textTheme: textTheme,

      /// AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: ReflectoColors.backgroundMid,
        foregroundColor: ReflectoColors.textPrimary,
        elevation: 0,
      ),

      /// Karten
      cardTheme: CardThemeData(
        color: ReflectoColors.backgroundLight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(0),
      ),

      /// Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ReflectoColors.primaryMid,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 2,
          shadowColor: ReflectoColors.primaryMid.withValues(alpha: 0.25),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      /// Eingaben
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ReflectoColors.backgroundLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        hintStyle: TextStyle(
          color: ReflectoColors.textSecondary.withValues(alpha: 0.8),
        ),
        labelStyle: const TextStyle(color: ReflectoColors.textSecondary),
        enabledBorder: outlineBorder(ReflectoColors.borderMid),
        focusedBorder: outlineBorder(ReflectoColors.primaryMid),
        errorBorder: outlineBorder(ReflectoColors.warningMid),
        focusedErrorBorder: outlineBorder(ReflectoColors.warningDark),
      ),

      /// Snackbars
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ReflectoColors.darkCard,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        actionTextColor: ReflectoColors.secondaryMid,
      ),

      /// Zusätzliche Button-Themes
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ReflectoColors.primaryMid,
          side: BorderSide(color: ReflectoColors.primaryMid, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          minimumSize: const Size.fromHeight(44),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ReflectoColors.secondaryMid,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      /// Tooltip/Divider/Switch
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ReflectoColors.darkCard,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(
        color: ReflectoColors.borderMid,
        thickness: 1,
        space: 24,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? ReflectoColors.primaryMid
              : ReflectoColors.borderDark,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? ReflectoColors.primaryMid.withValues(alpha: 0.4)
              : ReflectoColors.borderMid,
        ),
      ),

      /// BottomNavigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: ReflectoColors.primaryMid,
        unselectedItemColor: ReflectoColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Dark Theme
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ReflectoColors.primaryMid,
      brightness: Brightness.dark,
    ).copyWith(
      primary: ReflectoColors.primaryMid,
      onPrimary: Colors.white,
      secondary: ReflectoColors.darkSecondary,
      onSecondary: ReflectoColors.darkText,
      surface: ReflectoColors.darkBackground,
      onSurface: ReflectoColors.darkText,
      error: ReflectoColors.warningDark,
      onError: Colors.white,
      outline: ReflectoColors.borderDark,
    );

    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: ReflectoColors.darkText,
      displayColor: ReflectoColors.darkText,
    );

    OutlineInputBorder outlineBorder(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: 1.2),
        );

    return ThemeData(
      useMaterial3: true,
      fontFamilyFallback: const [
        'Segoe UI Emoji',
        'Apple Color Emoji',
        'Noto Color Emoji',
      ],
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ReflectoColors.darkBackground,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: ReflectoColors.darkBackground,
        foregroundColor: ReflectoColors.darkText,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: ReflectoColors.darkCard,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ReflectoColors.primaryMid,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 2,
          shadowColor: ReflectoColors.primaryMid.withValues(alpha: 0.25),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ReflectoColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        hintStyle: TextStyle(
          color: ReflectoColors.darkText.withValues(alpha: 0.7),
        ),
        labelStyle: const TextStyle(color: ReflectoColors.darkText),
        enabledBorder: outlineBorder(ReflectoColors.borderDark),
        focusedBorder: outlineBorder(ReflectoColors.primaryMid),
        errorBorder: outlineBorder(ReflectoColors.warningDark),
        focusedErrorBorder: outlineBorder(ReflectoColors.warningMid),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ReflectoColors.darkCard,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        actionTextColor: ReflectoColors.darkSecondary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: ReflectoColors.primaryMid,
        unselectedItemColor: ReflectoColors.darkSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Getter für rückwärtskompatible Verwendung (ohne Klammern)
  static ThemeData get lightTheme => light();
  static ThemeData get darkTheme => dark();

  // Rückwärtskompatible Namen
  static ThemeData get lightLegacy => light();
  static ThemeData get darkLegacy => dark();
  static ThemeData get light2 => light();
  static ThemeData get dark2 => dark();
}
