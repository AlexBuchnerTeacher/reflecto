import 'package:cloud_firestore/cloud_firestore.dart';

/// Einfacher Mahlzeiten-Log pro Tag
class MealLog {
  /// Dokument-ID (yyyy-MM-dd)
  final String id;

  final bool breakfast;
  final bool lunch;
  final bool dinner;

  final String? breakfastNote;
  final String? lunchNote;
  final String? dinnerNote;

  /// Zeitstempel für Mahlzeiten im Format "HH:mm"
  final String? breakfastTime;
  final String? lunchTime;
  final String? dinnerTime;

  final DateTime createdAt;
  final DateTime updatedAt;

  const MealLog({
    required this.id,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.breakfastNote,
    this.lunchNote,
    this.dinnerNote,
    this.breakfastTime,
    this.lunchTime,
    this.dinnerTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealLog.fromMap(String id, Map<String, dynamic> map) {
    return MealLog(
      id: id,
      breakfast: map['breakfast'] == true,
      lunch: map['lunch'] == true,
      dinner: map['dinner'] == true,
      breakfastNote: map['breakfastNote'] as String?,
      lunchNote: map['lunchNote'] as String?,
      dinnerNote: map['dinnerNote'] as String?,
      breakfastTime: map['breakfastTime'] as String?,
      lunchTime: map['lunchTime'] as String?,
      dinnerTime: map['dinnerTime'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      if (breakfastNote != null) 'breakfastNote': breakfastNote,
      if (lunchNote != null) 'lunchNote': lunchNote,
      if (dinnerNote != null) 'dinnerNote': dinnerNote,
      if (breakfastTime != null) 'breakfastTime': breakfastTime,
      if (lunchTime != null) 'lunchTime': lunchTime,
      if (dinnerTime != null) 'dinnerTime': dinnerTime,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MealLog copyWith({
    String? id,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
    String? breakfastNote,
    String? lunchNote,
    String? dinnerNote,
    String? breakfastTime,
    String? lunchTime,
    String? dinnerTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealLog(
      id: id ?? this.id,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      breakfastNote: breakfastNote ?? this.breakfastNote,
      lunchNote: lunchNote ?? this.lunchNote,
      dinnerNote: dinnerNote ?? this.dinnerNote,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get completedCount =>
      (breakfast ? 1 : 0) + (lunch ? 1 : 0) + (dinner ? 1 : 0);
}
