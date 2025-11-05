import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class JournalEntry {
  final String id; // yyyy-MM-dd
  final String? planning;
  final String? morning;
  final String? evening;
  final int? ratingFocus;
  final int? ratingEnergy;
  final int? ratingHappiness;
  final DateTime? updatedAt;

  JournalEntry({
    required this.id,
    this.planning,
    this.morning,
    this.evening,
    this.ratingFocus,
    this.ratingEnergy,
    this.ratingHappiness,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'planning': planning,
      'morning': morning,
      'evening': evening,
      'ratingFocus': ratingFocus,
      'ratingEnergy': ratingEnergy,
      'ratingHappiness': ratingHappiness,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(String id, Map<String, dynamic> map) {
    DateTime? updated;
    final raw = map['updatedAt'];
    if (raw is Timestamp) {
      updated = raw.toDate();
    } else if (raw is DateTime) {
      updated = raw;
    } else if (raw != null) {
      updated = DateTime.tryParse(raw.toString());
    }

    return JournalEntry(
      id: id,
      planning: map['planning'] as String?,
      morning: map['morning'] as String?,
      evening: map['evening'] as String?,
      ratingFocus: (map['ratingFocus'] as num?)?.toInt(),
      ratingEnergy: (map['ratingEnergy'] as num?)?.toInt(),
      ratingHappiness: (map['ratingHappiness'] as num?)?.toInt(),
      updatedAt: updated,
    );
  }
}
