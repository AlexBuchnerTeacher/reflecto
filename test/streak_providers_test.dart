import 'package:flutter_test/flutter_test.dart';
import 'package:reflecto/providers/streak_providers.dart';

void main() {
  group('streakInfoFromData', () {
    test('returns null for null data', () {
      expect(streakInfoFromData(null), isNull);
    });

    test('maps current and longest when present', () {
      final info = streakInfoFromData({
        'streakCount': 7,
        'longestStreak': 10,
        'lastEntryDate': '2025-11-08',
      });
      expect(info, isNotNull);
      expect(info!.current, 7);
      expect(info.longest, 10);
      expect(info.lastDate, '2025-11-08');
    });

    test('uses current when longest missing', () {
      final info = streakInfoFromData({'streakCount': 3});
      expect(info, isNotNull);
      expect(info!.current, 3);
      expect(info.longest, 3);
      expect(info.lastDate, isNull);
    });
  });
}
