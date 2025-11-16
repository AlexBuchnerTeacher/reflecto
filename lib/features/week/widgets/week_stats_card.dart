import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widgets/reflecto_card.dart';
import '../../../widgets/reflecto_sparkline.dart';
import '../logic/week_stats.dart';
import '../../../theme/tokens.dart';

/// Übersichts-Card: zeigt Fokus/Energie/Zufriedenheit-Statistiken + Stimmungsverlauf.
class WeekStatsCard extends StatelessWidget {
  final WeekStats stats;

  const WeekStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat.decimalPattern();
    nf.minimumFractionDigits = 2;
    nf.maximumFractionDigits = 2;

    return ReflectoCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Übersicht', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: ReflectoSpacing.s8),
          Text(
            'Fokus: Ø ${nf.format(stats.focusAvg)} (min ${stats.focusMin ?? '-'}, max ${stats.focusMax ?? '-'})',
          ),
          Text(
            'Energie: Ø ${nf.format(stats.energyAvg)} (min ${stats.energyMin ?? '-'}, max ${stats.energyMax ?? '-'})',
          ),
          Text(
            'Zufriedenheit: Ø ${nf.format(stats.happinessAvg)} (min ${stats.happinessMin ?? '-'}, max ${stats.happinessMax ?? '-'})',
          ),
          const SizedBox(height: ReflectoSpacing.s8),
          const Text('Stimmungsverlauf (1–5):'),
          const SizedBox(height: ReflectoSpacing.s8),
          ReflectoSparkline(points: stats.moodCurve),
        ],
      ),
    );
  }
}
