import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class WeeklyReflection {
  final String id; // yyyy-ww (ISO Woche)
  final String? motto;
  final String? summaryText;
  final String? aiAnalysisText;
  final Map<String, dynamic>? aiAnalysis;
  final DateTime? updatedAt;

  const WeeklyReflection({
    required this.id,
    this.motto,
    this.summaryText,
    this.aiAnalysisText,
    this.aiAnalysis,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        if (motto != null) 'motto': motto,
        if (summaryText != null) 'summaryText': summaryText,
        if (aiAnalysisText != null) 'aiAnalysisText': aiAnalysisText,
        if (aiAnalysis != null) 'aiAnalysis': aiAnalysis,
        'updatedAt': updatedAt,
      };

  factory WeeklyReflection.fromMap(String id, Map<String, dynamic> map) {
    DateTime? updated;
    final raw = map['updatedAt'];
    if (raw is Timestamp) {
      updated = raw.toDate();
    } else if (raw is DateTime) {
      updated = raw;
    } else if (raw != null) {
      updated = DateTime.tryParse(raw.toString());
    }
    return WeeklyReflection(
      id: id,
      motto: map['motto'] as String?,
      summaryText: map['summaryText'] as String?,
      aiAnalysisText: map['aiAnalysisText'] as String?,
      aiAnalysis: map['aiAnalysis'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['aiAnalysis'] as Map)
          : null,
      updatedAt: updated,
    );
  }
}
