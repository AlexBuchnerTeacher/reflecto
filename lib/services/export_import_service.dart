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
        'planning': e.planning.toMap(),
        'morning': e.morning.toMap(),
        'evening': e.evening.toMap(),
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
    return 'Analysiere das folgende Wochenjournal detailliert und erstelle eine strukturierte Auswertung.\\n\\n'
        '**WICHTIG:** Gib deine komplette Antwort in einem Markdown-Code-Block zurück (```markdown ... ```), damit ich sie einfach kopieren kann.\\n\\n'
        '**Erwartetes Format:**\\n\\n'
        '```markdown\\n'
        '## Wochenrückblick\\n\\n'
        '### 🎯 Die 3 größten Learnings\\n'
        '1. [Learning mit Begründung]\\n'
        '2. [Learning mit Begründung]\\n'
        '3. [Learning mit Begründung]\\n\\n'
        '### 🔄 Wiederkehrende Muster\\n'
        '**Positiv:**\\n'
        '- [Muster 1]\\n'
        '- [Muster 2]\\n\\n'
        '**Verbesserungspotenzial:**\\n'
        '- [Muster 1]\\n'
        '- [Muster 2]\\n\\n'
        '### 💭 Emotionale Gesamtstimmung\\n'
        '**Bewertung:** [X]/10\\n'
        '**Begründung:** [Ausführliche Erklärung basierend auf Fokus, Energie, Zufriedenheit]\\n\\n'
        '### ✨ Handlungsempfehlungen für nächste Woche\\n'
        '1. [Konkrete Handlung mit Begründung]\\n'
        '2. [Konkrete Handlung mit Begründung]\\n'
        '3. [Konkrete Handlung mit Begründung]\\n\\n'
        '### 🎪 Wochenmotto\\n'
        '**"[Prägnantes Motto, max. 8 Wörter]"**\\n'
        '```\\n\\n'
        '---\\n\\n'
        '#### Journaldaten (JSON):\\n'
        '```json\\n$pretty\\n```\\n';
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
