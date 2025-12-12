import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reflecto/models/journal_entry.dart';
import 'package:reflecto/models/habit.dart';
import 'package:reflecto/services/export_import_service.dart';

void main() {
  group('ExportImportService', () {
    late ExportImportService service;

    setUp(() {
      service = ExportImportService();
    });

    group('buildWeekExportJson', () {
      test('creates JSON for week with all 7 days', () {
        final range = DateTimeRange(
          start: DateTime(2025, 11, 17), // Monday
          end: DateTime(2025, 11, 23), // Sunday
        );

        final entries = [
          JournalEntry(
            id: '2025-11-17',
            morning: const Morning(mood: '😊', goodThing: 'Good start'),
            ratings: const Ratings(focus: 4, energy: 5, happiness: 4),
          ),
          JournalEntry(
            id: '2025-11-18',
            evening: const Evening(good: 'Productive day'),
            ratings: const Ratings(focus: 5, energy: 4, happiness: 5),
          ),
        ];

        final aggregates = {
          'focusAvg': 4.5,
          'energyAvg': 4.5,
          'happinessAvg': 4.5,
          'moodCurve': [4, 5, 4, 3, 5, 4, 4],
        };

        final json = service.buildWeekExportJson(
          '2025-W47',
          range,
          entries,
          aggregates,
        );

        expect(json['weekId'], '2025-W47');
        expect(json['range']['start'], '2025-11-17');
        expect(json['range']['end'], '2025-11-23');
        expect(json['entries'], hasLength(7));
        expect(json['aggregates']['focusAvg'], 4.5);
      });

      test('includes all entry fields in export', () {
        final range = DateTimeRange(
          start: DateTime(2025, 11, 17),
          end: DateTime(2025, 11, 23),
        );

        final entry = JournalEntry(
          id: '2025-11-17',
          planning: const Planning(
            goals: ['Goal 1', 'Goal 2'],
            todos: ['Todo 1'],
            reflection: 'Planning reflection',
          ),
          morning: const Morning(
            mood: '🌞',
            goodThing: 'Slept well',
            focus: 'Work project',
          ),
          evening: const Evening(
            good: 'Completed tasks',
            learned: 'New pattern',
            improve: 'Start earlier',
            gratitude: 'Family time',
          ),
          ratings: const Ratings(focus: 5, energy: 4, happiness: 5),
        );

        final json = service.buildWeekExportJson(
          '2025-W47',
          range,
          [entry],
          {},
        );

        final firstEntry = json['entries'][0] as Map<String, dynamic>;
        expect(firstEntry['date'], '2025-11-17');
        expect(firstEntry['planning']['goals'], ['Goal 1', 'Goal 2']);
        expect(firstEntry['morning']['mood'], '🌞');
        expect(firstEntry['evening']['good'], 'Completed tasks');
        expect(firstEntry['ratings']['focus'], 5);
      });

      test('fills missing days with empty entries', () {
        final range = DateTimeRange(
          start: DateTime(2025, 11, 17),
          end: DateTime(2025, 11, 23),
        );

        // Only provide 2 entries, rest should be empty
        final entries = [
          JournalEntry(id: '2025-11-17'),
          JournalEntry(id: '2025-11-20'),
        ];

        final json = service.buildWeekExportJson(
          '2025-W47',
          range,
          entries,
          {},
        );

        expect(json['entries'], hasLength(7));

        // Check that all 7 days are present
        final dates =
            (json['entries'] as List).map((e) => e['date'] as String).toList();
        expect(dates, [
          '2025-11-17',
          '2025-11-18',
          '2025-11-19',
          '2025-11-20',
          '2025-11-21',
          '2025-11-22',
          '2025-11-23',
        ]);
      });

      test('handles entries with null ratings', () {
        final range = DateTimeRange(
          start: DateTime(2025, 11, 17),
          end: DateTime(2025, 11, 23),
        );

        final entry = JournalEntry(
          id: '2025-11-17',
          ratings: const Ratings(), // All null ratings
        );

        final json = service.buildWeekExportJson(
          '2025-W47',
          range,
          [entry],
          {},
        );

        final firstEntry = json['entries'][0] as Map<String, dynamic>;
        expect(firstEntry['ratings']['focus'], isNull);
        expect(firstEntry['ratings']['energy'], isNull);
        expect(firstEntry['ratings']['happiness'], isNull);
      });

      test('preserves aggregate statistics', () {
        final range = DateTimeRange(
          start: DateTime(2025, 11, 17),
          end: DateTime(2025, 11, 23),
        );

        final aggregates = {
          'focusAvg': 4.2,
          'energyAvg': 3.8,
          'happinessAvg': 4.5,
          'moodCurve': [4, 5, 3, 4, 5, 4, 4],
        };

        final json = service.buildWeekExportJson(
          '2025-W47',
          range,
          [],
          aggregates,
        );

        expect(json['aggregates']['focusAvg'], 4.2);
        expect(json['aggregates']['energyAvg'], 3.8);
        expect(json['aggregates']['happinessAvg'], 4.5);
        expect(json['aggregates']['moodCurve'], [4, 5, 3, 4, 5, 4, 4]);
      });
    });

    group('buildMarkdownFromJson', () {
      test('creates markdown prompt with JSON data', () {
        final jsonData = {
          'weekId': '2025-W47',
          'entries': [
            {'date': '2025-11-17', 'morning': {}, 'evening': {}},
          ],
        };

        final markdown = service.buildMarkdownFromJson(jsonData);

        expect(markdown, contains('Analysiere das folgende Wochenjournal'));
        expect(markdown, contains('2025-W47'));
        expect(markdown, contains('markdown'));
        expect(markdown, contains('## Wochenrückblick'));
      });

      test('includes formatted JSON in prompt', () {
        final jsonData = {
          'weekId': '2025-W47',
          'range': {
            'start': '2025-11-17',
            'end': '2025-11-23',
          },
        };

        final markdown = service.buildMarkdownFromJson(jsonData);

        // Should contain pretty-printed JSON
        expect(markdown, contains('"weekId": "2025-W47"'));
        expect(markdown, contains('"start": "2025-11-17"'));
      });

      test('includes expected format sections', () {
        final markdown = service.buildMarkdownFromJson({});

        expect(markdown, contains('### 🎯 Die 3 größten Learnings'));
        expect(markdown, contains('### 🔄 Wiederkehrende Muster'));
        expect(markdown, contains('### 💭 Emotionale Gesamtstimmung'));
        expect(markdown, contains('### ✨ Handlungsempfehlungen'));
        expect(markdown, contains('### 🎪 Wochenmotto'));
      });

      test('requests markdown code block in response', () {
        final markdown = service.buildMarkdownFromJson({});

        expect(markdown, contains('```markdown'));
        expect(
            markdown,
            contains(
                'Gib deine komplette Antwort in einem Markdown-Code-Block zurück'));
      });
    });

    group('JSON round-trip', () {
      test('exported JSON can be re-parsed', () {
        final range = DateTimeRange(
          start: DateTime(2025, 11, 17),
          end: DateTime(2025, 11, 23),
        );

        final entries = [
          JournalEntry(
            id: '2025-11-17',
            morning: const Morning(mood: '😊'),
            ratings: const Ratings(focus: 4),
          ),
        ];

        final json = service.buildWeekExportJson(
          '2025-W47',
          range,
          entries,
          {'focusAvg': 4.0},
        );

        // Verify can be encoded to JSON string
        final jsonString = jsonEncode(json);
        expect(jsonString, isA<String>());

        // Verify can be decoded back
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        expect(decoded['weekId'], '2025-W47');
        expect(decoded['entries'], hasLength(7));
      });
    });

    group('Habits in Export', () {
      test('includes habits in export when provided', () {
        final range = DateTimeRange(
          start: DateTime(2025, 11, 17),
          end: DateTime(2025, 11, 23),
        );

        final habits = [
          Habit(
            id: 'habit-1',
            title: 'Daily Reading',
            category: '📘 LERNEN',
            color: '#0A84FF',
            frequency: 'daily',
            streak: 3,
            completedDates: ['2025-11-17', '2025-11-18', '2025-11-19'],
            createdAt: DateTime(2025, 11, 1),
            updatedAt: DateTime(2025, 11, 19),
          ),
          Habit(
            id: 'habit-2',
            title: 'Workout',
            category: '🚴 SPORT',
            color: '#FF3B30',
            frequency: 'weekly_target',
            weeklyTarget: 3,
            streak: 1,
            completedDates: ['2025-11-17', '2025-11-20'],
            createdAt: DateTime(2025, 11, 1),
            updatedAt: DateTime(2025, 11, 20),
          ),
        ];

        final json = service.buildWeekExportJson(
          '2025-W47',
          range,
          [],
          {},
          habits: habits,
        );

        expect(json.containsKey('habits'), true);
        expect(json['habits']['total'], 2);
        expect(json['habits']['list'], hasLength(2));

        final habit1 = json['habits']['list'][0] as Map<String, dynamic>;
        expect(habit1['title'], 'Daily Reading');
        expect(habit1['category'], '📘 LERNEN');
        expect(habit1['completionsThisWeek'], 3);
        expect(
          habit1['completedDates'],
          ['2025-11-17', '2025-11-18', '2025-11-19'],
        );

        final habit2 = json['habits']['list'][1] as Map<String, dynamic>;
        expect(habit2['title'], 'Workout');
        expect(habit2['weeklyTarget'], 3);
        expect(habit2['completionsThisWeek'], 2);
      });

      test('omits habits when not provided', () {
        final range = DateTimeRange(
          start: DateTime(2025, 11, 17),
          end: DateTime(2025, 11, 23),
        );

        final json = service.buildWeekExportJson(
          '2025-W47',
          range,
          [],
          {},
        );

        expect(json.containsKey('habits'), false);
      });

      test('only includes completions from current week', () {
        final range = DateTimeRange(
          start: DateTime(2025, 11, 17),
          end: DateTime(2025, 11, 23),
        );

        final habit = Habit(
          id: 'habit-3',
          title: 'Meditation',
          category: '🧘 ACHTSAMKEIT',
          color: '#AF52DE',
          frequency: 'daily',
          streak: 10,
          completedDates: [
            '2025-11-10', // Previous week
            '2025-11-11', // Previous week
            '2025-11-17', // This week
            '2025-11-18', // This week
            '2025-11-24', // Next week
          ],
          createdAt: DateTime(2025, 11, 1),
          updatedAt: DateTime(2025, 11, 18),
        );

        final json = service.buildWeekExportJson(
          '2025-W47',
          range,
          [],
          {},
          habits: [habit],
        );

        final habitData = json['habits']['list'][0] as Map<String, dynamic>;
        expect(habitData['completionsThisWeek'], 2);
        expect(habitData['completedDates'], ['2025-11-17', '2025-11-18']);
      });
    });
  });
}
