import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/habit.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../../theme/tokens.dart';
import 'habit_card.dart';
import 'habit_dialog.dart';

/// Gruppierte Liste von Habits mit Zwei-Gruppen-System:
/// - Offene Habits (oben, mit Drag & Drop)
/// - Erledigte Habits (unten, ohne Drag & Drop)
class HabitGroupedList extends ConsumerStatefulWidget {
  final List<Habit> habits;
  final DateTime today;

  const HabitGroupedList({
    super.key,
    required this.habits,
    required this.today,
  });

  @override
  ConsumerState<HabitGroupedList> createState() => _HabitGroupedListState();
}

class _HabitGroupedListState extends ConsumerState<HabitGroupedList> {
  List<Habit> _openHabits = [];
  List<Habit> _completedHabits = [];

  @override
  void didUpdateWidget(HabitGroupedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateHabitGroups();
  }

  @override
  void initState() {
    super.initState();
    _updateHabitGroups();
  }

  void _updateHabitGroups() {
    final service = ref.read(habitServiceProvider);

    // Aktuelle Habits direkt aus Provider lesen (nicht aus widget.habits)
    final habitsAsync = ref.read(habitsProvider);
    final currentHabits = habitsAsync.valueOrNull ?? [];

    // 1. Nur fällige Habits für den gewählten Tag
    final dueHabits = currentHabits
        .where((h) => service.isScheduledOnDate(h, widget.today))
        .toList();

    // 2. In zwei Gruppen aufteilen: offen vs. erledigt
    // Regel: Wenn heute abgehakt → erledigt, sonst offen
    final open = <Habit>[];
    final completed = <Habit>[];

    for (final habit in dueHabits) {
      final isCompletedToday = service.isCompletedOnDate(habit, widget.today);

      if (isCompletedToday) {
        completed.add(habit);
      } else {
        open.add(habit);
      }
    }

    // 3. Beide Gruppen nach sortIndex sortieren
    open.sort((a, b) {
      final aIndex = a.sortIndex ?? 999999;
      final bIndex = b.sortIndex ?? 999999;
      return aIndex.compareTo(bIndex);
    });

    completed.sort((a, b) {
      final aIndex = a.sortIndex ?? 999999;
      final bIndex = b.sortIndex ?? 999999;
      return aIndex.compareTo(bIndex);
    });

    setState(() {
      _openHabits = open;
      _completedHabits = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch habits um UI bei Änderungen neu zu bauen
    ref.watch(habitsProvider);

    final theme = Theme.of(context);
    final totalItems = _openHabits.length + _completedHabits.length;
    final hasCompleted = _completedHabits.isNotEmpty;

    if (totalItems == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(ReflectoSpacing.s24),
          child: Text('Keine Habits für diesen Tag geplant'),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Offene Habits (mit Drag & Drop)
        if (_openHabits.isNotEmpty)
          SliverReorderableList(
            itemCount: _openHabits.length,
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex -= 1;

              setState(() {
                final item = _openHabits.removeAt(oldIndex);
                _openHabits.insert(newIndex, item);
              });

              // Update Firestore: Alle Habits (open + completed) neu nummerieren
              final uid = ref.read(userIdProvider);
              if (uid != null) {
                final svc = ref.read(habitServiceProvider);
                final allHabits = [..._openHabits, ..._completedHabits];
                final updates = <({String habitId, int sortIndex})>[];
                for (int i = 0; i < allHabits.length; i++) {
                  updates.add((habitId: allHabits[i].id, sortIndex: i * 10));
                }
                await svc.reorderHabits(uid: uid, updates: updates);
              }
            },
            itemBuilder: (context, index) {
              final habit = _openHabits[index];
              return ReorderableDelayedDragStartListener(
                key: ValueKey(habit.id),
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReflectoSpacing.s16,
                    vertical: ReflectoSpacing.s4,
                  ),
                  child: HabitCard(
                    habit: habit,
                    today: widget.today,
                    showPriority: false,
                    dragHandle: Icon(
                      Icons.drag_indicator_rounded,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    onEdit: () {
                      showDialog(
                        context: context,
                        builder: (_) => HabitDialog(habit: habit),
                      );
                    },
                    onDelete: () => _showDeleteDialog(context, habit),
                  ),
                ),
              );
            },
          ),

        // Separator (wenn erledigte Habits vorhanden)
        if (hasCompleted)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ReflectoSpacing.s16,
                vertical: ReflectoSpacing.s16,
              ),
              child: Row(
                children: [
                  Expanded(child: Divider(color: theme.colorScheme.outline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ReflectoSpacing.s8,
                    ),
                    child: Text(
                      'Erledigt',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: theme.colorScheme.outline)),
                ],
              ),
            ),
          ),

        // Erledigte Habits (ohne Drag & Drop)
        if (hasCompleted)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final habit = _completedHabits[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReflectoSpacing.s16,
                    vertical: ReflectoSpacing.s4,
                  ),
                  child: HabitCard(
                    key: ValueKey(habit.id),
                    habit: habit,
                    today: widget.today,
                    showPriority: false,
                    dragHandle: null, // Kein Drag-Handle für erledigte
                    onEdit: () {
                      showDialog(
                        context: context,
                        builder: (_) => HabitDialog(habit: habit),
                      );
                    },
                    onDelete: () => _showDeleteDialog(context, habit),
                  ),
                );
              },
              childCount: _completedHabits.length,
            ),
          ),

        // Bottom Padding
        const SliverToBoxAdapter(
          child: SizedBox(height: ReflectoSpacing.s24),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Habit löschen?'),
        content: Text(
          'Möchtest du "${habit.title}" wirklich löschen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () async {
              ref.read(habitNotifierProvider.notifier).deleteHabit(habit.id);
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}
