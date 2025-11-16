import 'package:flutter/material.dart';

import '../../../widgets/reflecto_card.dart';
import '../../../widgets/reflecto_sparkline.dart';
import '../logic/week_stats.dart';
import '../../../theme/tokens.dart';
import 'week_radial_stats.dart';

/// Übersichts-Card: zeigt Fokus/Energie/Zufriedenheit-Statistiken + Stimmungsverlauf.
class WeekStatsCard extends StatelessWidget {
  final WeekStats stats;

  const WeekStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return ReflectoCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Übersicht', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: ReflectoSpacing.s16),

          // Radiale Progress-Indikatoren
          WeekRadialStats(
            focusAvg: stats.focusAvg,
            energyAvg: stats.energyAvg,
            happinessAvg: stats.happinessAvg,
          ),

          const SizedBox(height: ReflectoSpacing.s16),
          const Divider(),
          const SizedBox(height: ReflectoSpacing.s8),

          const Text('Stimmungsverlauf (1–5):'),
          const SizedBox(height: ReflectoSpacing.s8),
          ReflectoSparkline(points: stats.moodCurve),
        ],
      ),
    );
  }
}
