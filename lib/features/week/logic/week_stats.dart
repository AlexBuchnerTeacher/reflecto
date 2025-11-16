import 'package:flutter/material.dart';

import '../../../models/journal_entry.dart';

/// Aggregiert Statistiken über eine Woche (7 Tage).
///
/// Liefert Min/Max/Durchschnitt für Fokus, Energie, Zufriedenheit
/// sowie einen Stimmungsverlauf (Mood Curve) für Sparkline.
class WeekStats {
  final double focusAvg;
  final double energyAvg;
  final double happinessAvg;
  final int? focusMin;
  final int? focusMax;
  final int? energyMin;
  final int? energyMax;
  final int? happinessMin;
  final int? happinessMax;
  final List<int> moodCurve; // 7 Tage, 0-5

  const WeekStats({
    required this.focusAvg,
    required this.energyAvg,
    required this.happinessAvg,
    this.focusMin,
    this.focusMax,
    this.energyMin,
    this.energyMax,
    this.happinessMin,
    this.happinessMax,
    required this.moodCurve,
  });

  /// Berechnet Statistiken aus einer Liste von Journal-Einträgen.
  ///
  /// [entries] müssen zu [range] passen (7 aufeinanderfolgende Tage).
  factory WeekStats.aggregate(List<JournalEntry> entries, DateTimeRange range) {
    int? minF, minE, minH, maxF, maxE, maxH;
    double sumF = 0, sumE = 0, sumH = 0;
    int cF = 0, cE = 0, cH = 0;

    // Mood-Kurve für 7 Tage
    final mood = List<int?>.filled(7, null);
    final byId = {for (final e in entries) e.id: e};

    for (var i = 0; i < 7; i++) {
      final day = range.start.add(Duration(days: i));
      final id =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final e = byId[id];

      if (e != null) {
        final f = e.ratingFocus;
        final en = e.ratingEnergy;
        final h = e.ratingHappiness;

        if (f != null) {
          sumF += f;
          cF++;
          minF = (minF == null) ? f : (f < minF ? f : minF);
          maxF = (maxF == null) ? f : (f > maxF ? f : maxF);
        }
        if (en != null) {
          sumE += en;
          cE++;
          minE = (minE == null) ? en : (en < minE ? en : minE);
          maxE = (maxE == null) ? en : (en > maxE ? en : maxE);
        }
        if (h != null) {
          sumH += h;
          cH++;
          minH = (minH == null) ? h : (h < minH ? h : minH);
          maxH = (maxH == null) ? h : (h > maxH ? h : maxH);
          mood[i] = h;
        }
      }
    }

    double avg(double s, int c) => c == 0 ? 0 : (s / c);

    return WeekStats(
      focusAvg: avg(sumF, cF),
      energyAvg: avg(sumE, cE),
      happinessAvg: avg(sumH, cH),
      focusMin: minF,
      focusMax: maxF,
      energyMin: minE,
      energyMax: maxE,
      happinessMin: minH,
      happinessMax: maxH,
      moodCurve: mood.map((e) => e ?? 0).toList(),
    );
  }

  /// Konvertiert die Statistik in eine Map (für JSON-Export).
  Map<String, dynamic> toJson() {
    return {
      'focusAvg': focusAvg,
      'energyAvg': energyAvg,
      'happinessAvg': happinessAvg,
      'focusMin': focusMin,
      'energyMin': energyMin,
      'happinessMin': happinessMin,
      'focusMax': focusMax,
      'energyMax': energyMax,
      'happinessMax': happinessMax,
      'moodCurve': moodCurve,
    };
  }
}
