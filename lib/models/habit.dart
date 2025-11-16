import 'package:cloud_firestore/cloud_firestore.dart';

/// Repräsentiert eine Gewohnheit / Routine, die ein Nutzer verfolgen möchte.
///
/// Ein Habit enthält:
/// - Basis-Info: title, category, color
/// - Zeitplan: frequency (daily/weekly), reminderTime
/// - Fortschritt: streak, completedDates
/// - Metadaten: createdAt, updatedAt
class Habit {
  /// Firestore-ID des Habits
  final String id;

  /// Titel der Gewohnheit (z.B. "10 Minuten lesen")
  final String title;

  /// Kategorie (z.B. "Lernen", "Sport", "Gesundheit")
  final String category;

  /// Hex-Farbe für UI-Darstellung (z.B. "#5B50FF")
  final String color;

  /// Frequenz: "daily" oder "weekly"
  final String frequency;

  /// Optional: Erinnerungszeit im Format "HH:mm" (z.B. "19:00")
  final String? reminderTime;

  /// Aktuelle Streak-Länge (aufeinanderfolgende Tage)
  final int streak;

  /// Liste der abgeschlossenen Daten im Format "yyyy-MM-dd"
  final List<String> completedDates;

  /// Erstellungszeitpunkt
  final DateTime createdAt;

  /// Letztes Update
  final DateTime updatedAt;

  const Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.color,
    required this.frequency,
    this.reminderTime,
    required this.streak,
    required this.completedDates,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Erstellt Habit aus Firestore Map
  factory Habit.fromMap(String id, Map<String, dynamic> map) {
    return Habit(
      id: id,
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? '',
      color: map['color'] as String? ?? '#5B50FF',
      frequency: map['frequency'] as String? ?? 'daily',
      reminderTime: map['reminderTime'] as String?,
      streak: map['streak'] as int? ?? 0,
      completedDates:
          (map['completedDates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Konvertiert Habit zu Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'color': color,
      'frequency': frequency,
      if (reminderTime != null) 'reminderTime': reminderTime,
      'streak': streak,
      'completedDates': completedDates,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Firestore-Converter wird im Service per Inline-Lambdas bereitgestellt

  /// Copy-with für Updates
  Habit copyWith({
    String? id,
    String? title,
    String? category,
    String? color,
    String? frequency,
    String? reminderTime,
    int? streak,
    List<String>? completedDates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      streak: streak ?? this.streak,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Habit{id: $id, title: $title, streak: $streak, completed: ${completedDates.length}}';
  }
}
