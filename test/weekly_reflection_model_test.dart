import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reflecto/models/weekly_reflection.dart';

void main() {
  group('WeeklyReflection model', () {
    test('fromMap parses Timestamp and fields', () {
      final ts = Timestamp.fromMillisecondsSinceEpoch(1700000000000);
      final map = {
        'motto': 'Focus & Flow',
        'summaryText': 'Gute Woche mit konstantem Fokus.',
        'aiAnalysisText': 'Zusammenfassung...',
        'aiAnalysis': {
          'score': 0.87,
          'keywords': ['focus', 'energy'],
        },
        'updatedAt': ts,
      };
      final wr = WeeklyReflection.fromMap('2025-46', map);
      expect(wr.id, '2025-46');
      expect(wr.motto, 'Focus & Flow');
      expect(wr.summaryText, 'Gute Woche mit konstantem Fokus.');
      expect(wr.aiAnalysisText, 'Zusammenfassung...');
      expect(wr.aiAnalysis, isA<Map<String, dynamic>>());
      expect(wr.updatedAt, isA<DateTime>());
    });

    test('toMap serializes provided fields and updatedAt', () {
      final now = DateTime.now();
      final wr = WeeklyReflection(
        id: '2025-46',
        motto: 'Keep it simple',
        summaryText: 'Stabile Routinen.',
        aiAnalysisText: 'Kurztext',
        aiAnalysis: {'score': 0.9},
        updatedAt: now,
      );
      final m = wr.toMap();
      expect(m['motto'], 'Keep it simple');
      expect(m['summaryText'], 'Stabile Routinen.');
      expect(m['aiAnalysisText'], 'Kurztext');
      expect(m['aiAnalysis'], {'score': 0.9});
      expect(m['updatedAt'], now);
    });
  });
}
