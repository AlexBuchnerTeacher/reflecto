import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/habit.dart';
import '../../../models/habit_priority.dart';
import '../../../providers/habit_providers.dart';
import '../../../theme/tokens.dart';
import '../../../utils/category_colors.dart';

/// Einzelne Habit-Karte mit Checkbox, Titel, Streak und Fortschritt
class HabitCard extends ConsumerWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showPriority;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showPriority = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final service = ref.watch(habitServiceProvider);
    final today = DateTime.now();
    final isCompletedToday = service.isCompletedOnDate(habit, today);
    final canToggleToday = service.isScheduledOnDate(habit, today);

    // Wochenfortschritt berechnen
    final freq = habit.frequency;
    int? weeklyDone;
    int? weeklyTotal;
    String? weeklyLabel;
    if (freq == 'weekly_days' || freq == 'weekly') {
      weeklyDone = service.countPlannedCompletionsInWeek(habit, today);
      weeklyTotal = service.plannedDaysInWeek(habit);
      weeklyLabel = '$weeklyDone/$weeklyTotal';
    } else if (freq == 'weekly_target') {
      final done = service.countCompletionsInWeek(habit, today);
      final target = service.plannedDaysInWeek(habit);
      weeklyDone = done > target ? target : done;
      weeklyTotal = target;
      weeklyLabel = '$weeklyDone/$weeklyTotal';
    } else if (freq == 'irregular') {
      final done = service.countCompletionsInWeek(habit, today);
      weeklyLabel = 'Diese Woche: $done';
    }

    // Farbe aus Kategorie holen (fest zugeordnet)
    final habitColor = CategoryColors.getFlutterColorForCategory(
      habit.category,
    );
    final weekdays = habit.weekdays ?? const <int>[];

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ReflectoSpacing.s16,
        vertical: ReflectoSpacing.s8,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(ReflectoSpacing.s16),
          child: Row(
            children: [
              // Checkbox für heute
              Checkbox(
                value: isCompletedToday,
                onChanged: canToggleToday
                    ? (value) async {
                        if (value == true) {
                          await ref
                              .read(habitNotifierProvider.notifier)
                              .markCompleted(habit.id, today);
                        } else {
                          await ref
                              .read(habitNotifierProvider.notifier)
                              .markUncompleted(habit.id, today);
                        }
                      }
                    : null,
              ),
              const SizedBox(width: ReflectoSpacing.s12),

              // Farb-Indikator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: habitColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: ReflectoSpacing.s12),

              // Titel und Kategorie
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Priority Badge (wenn aktiviert)
                        if (showPriority) ...[
                          _buildPriorityBadge(context, ref),
                          const SizedBox(width: ReflectoSpacing.s8),
                        ],
                        Expanded(
                          child: Text(
                            habit.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ReflectoSpacing.s4),
                    Text(
                      habit.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (freq == 'weekly_days' || freq == 'weekly') ...[
                      const SizedBox(height: ReflectoSpacing.s8),
                      Wrap(
                        spacing: ReflectoSpacing.s8,
                        runSpacing: ReflectoSpacing.s4,
                        children: List.generate(7, (index) {
                          const labels = [
                            'Mo',
                            'Di',
                            'Mi',
                            'Do',
                            'Fr',
                            'Sa',
                            'So',
                          ];
                          final dayNum = index + 1; // 1..7
                          final planned = weekdays.contains(dayNum);
                          final isToday = today.weekday == dayNum;
                          final bg = planned
                              ? theme.colorScheme.secondaryContainer
                              : Colors.transparent;
                          final fg = planned
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onSurfaceVariant;
                          final borderColor = isToday
                              ? theme.colorScheme.primary
                              : (planned
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.outline.withValues(
                                      alpha: 0.5,
                                    ));
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ReflectoSpacing.s8,
                              vertical: ReflectoSpacing.s4,
                            ),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: Text(
                              labels[index],
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: fg,
                                fontWeight:
                                    isToday ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ),
                      // Legende entfernt (zu viel UI‑Rauschen)
                    ],
                  ],
                ),
              ),

              // Streak-Anzeige (nur daily sinnvoll)
              if (habit.streak > 0 && (freq == 'daily')) ...[
                const SizedBox(width: ReflectoSpacing.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReflectoSpacing.s8,
                    vertical: ReflectoSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: ReflectoSpacing.s4),
                      Text(
                        '${habit.streak}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Wochen-Fortschritt (für weekly_days/weekly_target/irregular)
              if (weeklyLabel != null) ...[
                const SizedBox(width: ReflectoSpacing.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReflectoSpacing.s8,
                    vertical: ReflectoSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    weeklyLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              // Actions
              if (onEdit != null) ...[
                const SizedBox(width: ReflectoSpacing.s4),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Bearbeiten',
                  visualDensity: VisualDensity.compact,
                ),
              ],
              if (onDelete != null) ...[
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Löschen',
                  visualDensity: VisualDensity.compact,
                ),
              ],
              const Icon(Icons.drag_handle, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Baut Priority Badge für Smart Habits
  Widget _buildPriorityBadge(BuildContext context, WidgetRef ref) {
    final service = ref.watch(habitServiceProvider);
    final priorityScore = service.calculateHabitPriority(habit);
    final priority = priorityScore.priority;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getPriorityColor(context, priority).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(priority.icon, style: const TextStyle(fontSize: 14)),
    );
  }

  /// Gibt Farbe für Priority-Level zurück
  Color _getPriorityColor(BuildContext context, HabitPriority priority) {
    final theme = Theme.of(context);
    switch (priority) {
      case HabitPriority.high:
        return Colors.red;
      case HabitPriority.medium:
        return Colors.orange;
      case HabitPriority.low:
        return theme.colorScheme.outline;
    }
  }
}
