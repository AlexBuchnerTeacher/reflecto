import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/habit_providers.dart';
import '../theme/tokens.dart';
import '../features/habits/widgets/habit_card.dart';
import '../features/habits/widgets/habit_dialog.dart';

/// Hauptscreen für Habit-Tracking
class HabitScreen extends ConsumerWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Meine Gewohnheiten')),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: ReflectoSpacing.s16),
              Text('Fehler: $error'),
            ],
          ),
        ),
        data: (habits) {
          if (habits.isEmpty) {
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

          // Berechne Gesamt-Fortschritt (heute)
          final today = DateTime.now();
          final service = ref.watch(habitServiceProvider);
          final completedToday = habits
              .where((h) => service.isCompletedOnDate(h, today))
              .length;
          final totalHabits = habits.length;
          final progressPercent = totalHabits > 0
              ? (completedToday / totalHabits * 100).round()
              : 0;

          return Column(
            children: [
              // Fortschritts-Header
              Container(
                padding: const EdgeInsets.all(ReflectoSpacing.s16),
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Heute',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$completedToday / $totalHabits',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ReflectoSpacing.s8),
                    LinearProgressIndicator(
                      value: completedToday / totalHabits,
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
              ),

              // Habit-Liste
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: ReflectoSpacing.s16,
                    bottom: ReflectoSpacing.s24,
                  ),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return HabitCard(
                      habit: habit,
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (_) => HabitDialog(habit: habit),
                        );
                      },
                      onDelete: () {
                        _showDeleteConfirmation(
                          context,
                          ref,
                          habit.id,
                          habit.title,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const HabitDialog());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String habitId,
    String habitTitle,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Habit löschen?'),
        content: Text('Möchtest du "$habitTitle" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(habitNotifierProvider.notifier).deleteHabit(habitId);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}
