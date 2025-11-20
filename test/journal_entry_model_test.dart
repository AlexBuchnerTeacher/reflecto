import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reflecto/models/journal_entry.dart';

void main() {
  group('JournalEntry Model', () {
    test('empty() creates entry with default values', () {
      final entry = JournalEntry.empty('2025-11-20');

      expect(entry.id, '2025-11-20');
      expect(entry.planning.goals, isEmpty);
      expect(entry.planning.todos, isEmpty);
      expect(entry.morning.mood, '');
      expect(entry.evening.good, '');
      expect(entry.ratings.focus, isNull);
    });

    test('toMap serializes all nested fields', () {
      final entry = JournalEntry(
        id: '2025-11-20',
        planning: const Planning(
          goals: ['Learn Flutter', 'Exercise'],
          todos: ['Buy groceries'],
          reflection: 'Focus on health',
          notes: 'Important meeting at 3pm',
        ),
        morning: const Morning(
          mood: '😊',
          goodThing: 'Slept well',
          focus: 'Work on project',
        ),
        evening: const Evening(
          good: 'Completed all tasks',
          learned: 'New Riverpod pattern',
          improve: 'Start earlier',
          gratitude: 'Healthy food',
          todosCompletion: [true, false, true],
        ),
        ratings: const Ratings(
          mood: 4,
          focus: 5,
          energy: 3,
          happiness: 4,
        ),
        updatedAt: DateTime(2025, 11, 20, 18, 30),
      );

      final map = entry.toMap();

      expect(map['planning']['goals'], ['Learn Flutter', 'Exercise']);
      expect(map['planning']['todos'], ['Buy groceries']);
      expect(map['morning']['mood'], '😊');
      expect(map['evening']['good'], 'Completed all tasks');
      expect(map['ratings']['focus'], 5);
      // Back-compat top-level ratings
      expect(map['ratingFocus'], 5);
      expect(map['ratingEnergy'], 3);
      expect(map['ratingHappiness'], 4);
    });

    test('fromMap parses complete entry', () {
      final map = {
        'planning': {
          'goals': ['Goal 1', 'Goal 2', 'Goal 3'],
          'todos': ['Todo 1', 'Todo 2', 'Todo 3'],
          'reflection': 'Weekly reflection',
          'notes': 'Notes here',
        },
        'morning': {
          'mood': '🌞',
          'goodThing': 'Great start',
          'focus': 'Deep work',
        },
        'evening': {
          'good': 'Productive day',
          'learned': 'Firebase patterns',
          'improve': 'Time management',
          'gratitude': 'Family time',
          'todosCompletion': [true, true, false],
        },
        'ratings': {
          'mood': 5,
          'focus': 4,
          'energy': 5,
          'happiness': 5,
        },
        'updatedAt': Timestamp.fromDate(DateTime(2025, 11, 20, 20, 0)),
      };

      final entry = JournalEntry.fromMap('2025-11-20', map);

      expect(entry.id, '2025-11-20');
      expect(entry.planning.goals.length, 3);
      expect(entry.planning.todos[0], 'Todo 1');
      expect(entry.morning.mood, '🌞');
      expect(entry.evening.good, 'Productive day');
      expect(entry.ratings.focus, 4);
      expect(entry.updatedAt, DateTime(2025, 11, 20, 20, 0));
    });

    test('fromMap handles missing optional fields', () {
      final map = <String, dynamic>{
        'planning': {'goals': <String>[], 'todos': <String>[]},
      };

      final entry = JournalEntry.fromMap('2025-11-20', map);

      expect(entry.morning.mood, '');
      expect(entry.evening.gratitude, '');
      expect(entry.ratings.focus, isNull);
      expect(entry.updatedAt, isNull);
    });

    test('fromMap uses fallback for back-compat nested ratings', () {
      final map = {
        'ratingsMorning': {
          'focus': 4,
          'energy': 5,
          'happiness': 3,
        },
        'ratingsEvening': {
          'focus': 4,
          'energy': 5,
          'happiness': 3,
        },
      };

      final entry = JournalEntry.fromMap('2025-11-20', map);

      expect(entry.ratings.focus, 4);
      expect(entry.ratings.energy, 5);
      expect(entry.ratings.happiness, 3);
    });

    test('fromMap handles legacy field names (evening.better → improve)', () {
      final map = {
        'evening': {
          'good': 'Test',
          'learned': 'Test',
          'better': 'Legacy improve field', // Old field name
          'grateful': 'Legacy gratitude field', // Old field name
        },
      };

      final entry = JournalEntry.fromMap('2025-11-20', map);

      expect(entry.evening.improve, 'Legacy improve field');
      expect(entry.evening.gratitude, 'Legacy gratitude field');
    });

    test('fromMap handles legacy field names (morning.feeling → mood)', () {
      final map = {
        'morning': {
          'feeling': 'Legacy mood field', // Old field name
          'good': 'Legacy goodThing field', // Old field name
        },
      };

      final entry = JournalEntry.fromMap('2025-11-20', map);

      expect(entry.morning.mood, 'Legacy mood field');
      expect(entry.morning.goodThing, 'Legacy goodThing field');
    });

    test('toMap/fromMap round-trip preserves all data', () {
      final original = JournalEntry(
        id: '2025-11-20',
        planning: const Planning(
          goals: ['Goal A', 'Goal B', 'Goal C'],
          todos: ['Todo X', 'Todo Y', 'Todo Z'],
          reflection: 'Weekly reflection text',
          notes: 'Important notes',
        ),
        morning: const Morning(
          mood: '😃',
          goodThing: 'Morning coffee',
          focus: 'Sprint planning',
        ),
        evening: const Evening(
          good: 'Shipped feature',
          learned: 'Testing patterns',
          improve: 'Earlier standup',
          gratitude: 'Team support',
          todosCompletion: [true, true, false],
        ),
        ratings: const Ratings(
          mood: 4,
          focus: 5,
          energy: 4,
          happiness: 5,
        ),
        updatedAt: DateTime(2025, 11, 20, 22, 15),
      );

      final map = original.toMap();
      final restored = JournalEntry.fromMap(original.id, map);

      expect(restored.id, original.id);
      expect(restored.planning.goals, original.planning.goals);
      expect(restored.planning.todos, original.planning.todos);
      expect(restored.morning.mood, original.morning.mood);
      expect(restored.evening.good, original.evening.good);
      expect(restored.ratings.focus, original.ratings.focus);
      expect(
        restored.updatedAt?.toIso8601String(),
        original.updatedAt?.toIso8601String(),
      );
    });

    test('copyWith creates modified copy', () {
      final original = JournalEntry(
        id: '2025-11-20',
        morning: const Morning(mood: 'Original'),
        ratings: const Ratings(focus: 3),
      );

      final modified = original.copyWith(
        morning: const Morning(mood: 'Modified'),
      );

      expect(modified.id, original.id);
      expect(modified.morning.mood, 'Modified');
      expect(modified.ratings.focus, 3); // Unchanged
    });
  });

  group('Planning Model', () {
    test('fromMap handles empty lists', () {
      final planning =
          Planning.fromMap({'goals': <String>[], 'todos': <String>[]});

      expect(planning.goals, isEmpty);
      expect(planning.todos, isEmpty);
      expect(planning.reflection, '');
    });

    test('copyWith preserves unchanged fields', () {
      const original = Planning(
        goals: ['Goal 1'],
        todos: ['Todo 1'],
        reflection: 'Original',
      );

      final modified = original.copyWith(reflection: 'Modified');

      expect(modified.goals, ['Goal 1']);
      expect(modified.reflection, 'Modified');
    });
  });

  group('Morning Model', () {
    test('fromMap uses field aliases for back-compat', () {
      final morning = Morning.fromMap({
        'feeling': 'Happy', // Legacy: mood
        'good': 'Coffee', // Legacy: goodThing
        'focus': 'Work',
      });

      expect(morning.mood, 'Happy');
      expect(morning.goodThing, 'Coffee');
      expect(morning.focus, 'Work');
    });
  });

  group('Evening Model', () {
    test('todosCompletion defaults to [false, false, false]', () {
      final evening = Evening.fromMap({});

      expect(evening.todosCompletion, [false, false, false]);
    });

    test('todosCompletion parses boolean list', () {
      final evening = Evening.fromMap({
        'todosCompletion': [true, false, true],
      });

      expect(evening.todosCompletion, [true, false, true]);
    });
  });

  group('Ratings Model', () {
    test('fromMap prioritizes ratings object over fallback', () {
      final ratings = Ratings.fromMap(
        {'focus': 5, 'energy': 4},
        fallback: {'ratingFocus': 2, 'ratingEnergy': 1},
      );

      expect(ratings.focus, 5); // From ratings object
      expect(ratings.energy, 4);
    });

    test('fromMap uses fallback when ratings object empty', () {
      final ratings = Ratings.fromMap(
        {},
        fallback: {
          'ratingsMorning': {'focus': 3, 'energy': 4, 'happiness': 5},
          'ratingsEvening': {'focus': 3, 'energy': 4, 'happiness': 5},
        },
      );

      expect(ratings.focus, 3);
      expect(ratings.energy, 4);
      expect(ratings.happiness, 5);
    });

    test('copyWith updates only specified fields', () {
      const original = Ratings(focus: 3, energy: 4, happiness: 5);

      final modified = original.copyWith(focus: 5);

      expect(modified.focus, 5);
      expect(modified.energy, 4); // Unchanged
      expect(modified.happiness, 5); // Unchanged
    });
  });
}
