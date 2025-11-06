import 'dart:convert';
import 'package:flutter/material.dart' show DateTimeRange;
import '../models/journal_entry.dart';
// Removed unused Firestore import

class ExportImportService {
  Map<String, dynamic> buildWeekExportJson(
    String weekId,
    DateTimeRange range,
    List<JournalEntry> entries,
    Map<String, dynamic> aggregates,
  ) {
    List<Map<String, dynamic>> items = [];
    for (var i = 0; i < 7; i++) {
      final day = range.start.add(Duration(days: i));
      final id =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final e = entries.firstWhere(
        (x) => x.id == id,
        orElse: () => JournalEntry(id: id),
      );
      items.add({
        'date': id,
        'planning': e.planning,
        'morning': e.morning,
        'evening': e.evening,
        'ratings': {
          'focus': e.ratingFocus,
          'energy': e.ratingEnergy,
          'happiness': e.ratingHappiness,
        },
      });
    }
    return {
      'weekId': weekId,
      'range': {
        'start': range.start.toIso8601String().substring(0, 10),
        'end': range.end.toIso8601String().substring(0, 10),
      },
      'entries': items,
      'aggregates': {
        'focusAvg': aggregates['focusAvg'],
        'energyAvg': aggregates['energyAvg'],
        'happinessAvg': aggregates['happinessAvg'],
        'moodCurve': aggregates['moodCurve'],
      },
    };
  }

  String buildMarkdownFromJson(Map<String, dynamic> jsonData) {
    final pretty = const JsonEncoder.withIndent('  ').convert(jsonData);
    return '### KI-Analyse-Prompt (Reflecto)\n'
        'Analysiere das folgende Wochenjournal und erstelle:\n'
        '1) Die 3 größten Learnings\n'
        '2) Wiederkehrende Themen (positiv/negativ)\n'
        '3) Emotionale Gesamtstimmung (Skala 1–10) mit Begründung\n'
        '4) 3 klare Handlungsempfehlungen für die kommende Woche\n'
        '5) Ein prägnantes Wochenmotto (max. 8 Wörter)\n\n'
        '#### Daten (JSON):\n'
        '```json\n$pretty\n```\n';
  }

  Map<String, dynamic>? tryParseAiAnalysis(String input) {
    try {
      final decoded = jsonDecode(input);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'text': input};
    } catch (_) {
      return {'text': input};
    }
  }
}
