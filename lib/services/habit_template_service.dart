import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/habit_template.dart';

class HabitTemplateService {
  final FirebaseFirestore _firestore;
  HabitTemplateService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<HabitTemplate> _templatesCollection() {
    return _firestore.collection('habit_templates').withConverter(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data();
            if (data == null) {
              throw StateError('Template data is null for ${snapshot.id}');
            }
            return HabitTemplate.fromMap(snapshot.id, data);
          },
          toFirestore: (template, _) => template.toMap(),
        );
  }

  Stream<List<HabitTemplate>> watchTemplates() {
    return _templatesCollection()
        .orderBy('title')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<void> upsertTemplate(HabitTemplate template) async {
    await _templatesCollection().doc(template.id).set(template);
  }

  Future<void> seedTemplates(List<HabitTemplate> templates) async {
    final batch = _firestore.batch();
    for (final t in templates) {
      final ref = _templatesCollection().doc(t.id);
      batch.set(ref, t);
    }
    await batch.commit();
  }
}
