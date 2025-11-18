import 'package:cloud_firestore/cloud_firestore.dart';

/// Migriert alte Kategorien zu Emoji-Versionen
class HabitMigration {
  final FirebaseFirestore _firestore;

  HabitMigration({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _categoryMap = {
    'GESUNDHEIT': '🔥 GESUNDHEIT',
    'Gesundheit': '🔥 GESUNDHEIT',
    'SPORT': '🚴 SPORT',
    'Sport': '🚴 SPORT',
    'LERNEN': '📘 LERNEN',
    'Lernen': '📘 LERNEN',
    'KREATIVITÄT': '⚡ KREATIVITÄT',
    'Kreativität': '⚡ KREATIVITÄT',
    'PRODUKTIVITÄT': '📈 PRODUKTIVITÄT',
    'Produktivität': '📈 PRODUKTIVITÄT',
    'SOZIALES': '🤝 SOZIALES',
    'Soziales': '🤝 SOZIALES',
    'ACHTSAMKEIT': '🧘 ACHTSAMKEIT',
    'Achtsamkeit': '🧘 ACHTSAMKEIT',
    'SONSTIGES': '🔧 SONSTIGES',
    'Sonstiges': '🔧 SONSTIGES',
  };

  Future<int> migrateUserHabits(String uid) async {
    final habitsRef =
        _firestore.collection('users').doc(uid).collection('habits');

    final snapshot = await habitsRef.get();
    int updated = 0;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final oldCategory = data['category'] as String?;
      if (oldCategory != null && _categoryMap.containsKey(oldCategory)) {
        final newCategory = _categoryMap[oldCategory]!;
        batch.update(doc.reference, {
          'category': newCategory,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        updated++;
      }
    }

    if (updated > 0) {
      await batch.commit();
    }

    return updated;
  }
}
