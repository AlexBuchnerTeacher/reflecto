import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/tokens.dart';

/// Header mit Datum und Fortschrittsanzeige für den Habit-Screen
class HabitProgressHeader extends StatelessWidget {
  final DateTime selectedDate;
  final int completedCount;
  final int totalCount;

  const HabitProgressHeader({
    super.key,
    required this.selectedDate,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercent =
        totalCount > 0 ? (completedCount / totalCount * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(ReflectoSpacing.s16),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateUtils.isSameDay(selectedDate, DateTime.now())
                    ? 'Heute'
                    : DateFormat('EEE, d. MMM', 'de_DE').format(selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completedCount / $totalCount',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: ReflectoSpacing.s8),
          LinearProgressIndicator(
            value: totalCount > 0 ? completedCount / totalCount : 0,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: ReflectoSpacing.s8),
          Text(
            '$progressPercent % erfüllt',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
