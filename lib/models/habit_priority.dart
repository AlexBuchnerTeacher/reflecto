/// Prioritätsstufe für Smart Habits
enum HabitPriority {
  high, // 🔥 Hohe Priorität
  medium, // ⬆️ Mittlere Priorität
  low, // ⬇️ Niedrige Priorität
}

/// Erweiterungen für HabitPriority
extension HabitPriorityExtension on HabitPriority {
  /// Icon-Emoji für die Priorität
  String get icon {
    switch (this) {
      case HabitPriority.high:
        return '🔥';
      case HabitPriority.medium:
        return '⬆️';
      case HabitPriority.low:
        return '⬇️';
    }
  }

  /// Beschreibung der Priorität
  String get label {
    switch (this) {
      case HabitPriority.high:
        return 'Hoch';
      case HabitPriority.medium:
        return 'Mittel';
      case HabitPriority.low:
        return 'Niedrig';
    }
  }
}

/// Ergebnis der Prioritätsberechnung
class HabitPriorityScore {
  final HabitPriority priority;
  final double score;

  const HabitPriorityScore({required this.priority, required this.score});
}
