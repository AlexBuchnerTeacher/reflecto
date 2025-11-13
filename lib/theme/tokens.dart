import 'package:flutter/material.dart';

// ColorScheme-Erweiterungen für Buchner Style Tokens
extension ReflectoSchemeX on ColorScheme {
  // Neutrale Kartenfläche (hell/dunkel-sensitiv)
  Color get surfaceCard => brightness == Brightness.dark
      ? surfaceContainerHighest
      : surfaceContainerHigh;

  // Sehr dezente Containerfläche
  Color get surfaceContainerSoft => brightness == Brightness.dark
      ? surfaceContainerHigh
      : surfaceContainerLowest;

  // Zurückhaltende Rahmenfarbe
  Color get borderSubtle => outlineVariant.withValues(alpha: 0.5);
}

// Spacing-Tokens (px)
class ReflectoSpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
}

// Radien-Tokens (px)
class ReflectoRadii {
  static const double input = 12;
  static const double button = 14;
  static const double card = 16;
}

// Breakpoints/Größen
class ReflectoBreakpoints {
  static const double contentMax = 820;
}

// Bewegungs-/Interaktions-Tokens
class ReflectoMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
}

// Icon-Guidelines (Platzhalter für zukünftige Konsolidierung)
class ReflectoIcons {
  // UI-Icons bevorzugt Material Symbols Rounded
  // Beispiel: static const IconData redo = Icons.redo_rounded; (import in Widgets)
  // Emojis weiterhin sparsam für Emotionen (z. B. Abschnittstitel)
}
