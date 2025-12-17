import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// Empty State Widget wenn noch keine Habits erstellt wurden
class HabitEmptyState extends StatelessWidget {
  const HabitEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: ReflectoSpacing.s16),
          Text(
            'Noch keine Gewohnheiten',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: ReflectoSpacing.s8),
          Text(
            'Erstelle dein erstes Habit mit dem + Button',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
