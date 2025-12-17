import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/habit.dart';
import '../../../providers/habit_providers.dart';

/// Dialog zum Bestätigen des Löschens eines Habits
class HabitDeleteDialog extends ConsumerWidget {
  final Habit habit;

  const HabitDeleteDialog({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Habit löschen?'),
      content: Text(
        'Möchtest du "${habit.title}" wirklich löschen?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () async {
            ref.read(habitNotifierProvider.notifier).deleteHabit(habit.id);
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Löschen'),
        ),
      ],
    );
  }
}

/// Helper-Funktion zum Anzeigen des Delete Dialogs
void showHabitDeleteDialog(BuildContext context, Habit habit) {
  showDialog(
    context: context,
    builder: (_) => HabitDeleteDialog(habit: habit),
  );
}
