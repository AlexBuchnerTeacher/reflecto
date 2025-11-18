import 'package:flutter/material.dart';

/// Fixed color mapping for habit categories
///
/// Categories are identified by their emoji prefix and have
/// fixed colors across the entire app. This ensures consistency
/// in UI representation and prevents color confusion.
class CategoryColors {
  /// Map of category names to their fixed hex color codes
  static const Map<String, String> _colorMap = {
    '🔥 GESUNDHEIT': '#34C759',
    '🚴 SPORT': '#FF3B30',
    '📘 LERNEN': '#0A84FF',
    '⚡ KREATIVITÄT': '#FFCC00',
    '📈 PRODUKTIVITÄT': '#5856D6',
    '😌 ACHTSAMKEIT': '#FF2D92',
    '🎯 PERSÖNLICHE ENTWICKLUNG': '#FF9500',
    '🏠 HAUSHALT': '#AF52DE',
    '💼 ARBEIT': '#5AC8FA',
    '👥 SOZIALES': '#32ADE6',
  };

  /// Get the fixed color for a category
  ///
  /// Returns the category-specific color or a default purple if category not found.
  static String getColorForCategory(String category) {
    return _colorMap[category] ?? '#5B50FF'; // Default purple
  }

  /// Get all available categories with their colors
  static List<CategoryEntry> getAllCategories() {
    return _colorMap.entries
        .map((e) => CategoryEntry(name: e.key, color: e.value))
        .toList();
  }

  /// Convert hex color string to Flutter Color object
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Get Flutter Color object for a category
  static Color getFlutterColorForCategory(String category) {
    final hex = getColorForCategory(category);
    return hexToColor(hex);
  }

  /// Check if a category exists in the predefined list
  static bool isCategoryKnown(String category) {
    return _colorMap.containsKey(category);
  }

  /// Get all category names
  static List<String> getAllCategoryNames() {
    return _colorMap.keys.toList();
  }
}

/// Data class for category entries
class CategoryEntry {
  final String name;
  final String color;

  const CategoryEntry({required this.name, required this.color});

  Color get flutterColor => CategoryColors.hexToColor(color);
}
