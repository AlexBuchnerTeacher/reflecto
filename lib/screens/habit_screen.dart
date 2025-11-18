import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../providers/habit_template_providers.dart';
import '../services/habit_template_service.dart';
import '../services/habit_template_seed.dart';
import '../providers/auth_providers.dart';
import '../theme/tokens.dart';
import '../features/habits/widgets/habit_card.dart';
import '../features/habits/widgets/habit_dialog.dart';
import '../features/habits/widgets/habit_insights_card.dart';

/// Hauptscreen für Habit-Tracking
class HabitScreen extends ConsumerWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final theme = Theme.of(context);
    final showOnlyDue = ref.watch(_showOnlyDueHabitsProvider);

    return Scaffold(
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

          // Berechne Tages-Fortschritt (nur heute fällige Habits)
          final today = DateTime.now();
          final service = ref.watch(habitServiceProvider);
          final dueHabits =
              habits.where((h) => service.isScheduledOnDate(h, today)).toList();
          final completedToday = dueHabits
              .where((h) => service.isCompletedOnDate(h, today))
              .length;
          final totalHabits = dueHabits.length;
          final progressPercent = totalHabits > 0
              ? (completedToday / totalHabits * 100).round()
              : 0;

          return Column(
            children: [
              // Mini-Analytics Karte
              HabitInsightsCard(habits: habits, service: service, today: today),

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
                    Wrap(
                      spacing: ReflectoSpacing.s8,
                      children: [
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(1.0),
                          child: FilterChip(
                            label: const Text('Nur fällige'),
                            selected: showOnlyDue,
                            onSelected: (v) => ref
                                .read(
                                  _showOnlyDueHabitsProvider.notifier,
                                )
                                .state = v,
                          ),
                        ),
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(2.0),
                          child: FilterChip(
                            label: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Smart Priority '),
                                Text('🔥', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            selected: ref.watch(_useSmartOrderProvider),
                            onSelected: (v) {
                              ref.read(_useSmartOrderProvider.notifier).state =
                                  v;
                              ref
                                  .read(_showSmartPriorityProvider.notifier)
                                  .state = v;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ReflectoSpacing.s8),
                    LinearProgressIndicator(
                      value: totalHabits > 0 ? completedToday / totalHabits : 0,
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
                child: _HabitGroupedList(
                  habits: habits,
                  showOnlyDue: showOnlyDue,
                  today: today,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTemplateSheet(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Hinweis: Delete-Dialog wird in der gruppierten Liste gezeigt.

  void _showTemplateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return _TemplateSheetContent(parentContext: context);
      },
    );
  }
}

class _TemplateSheetContent extends ConsumerStatefulWidget {
  final BuildContext parentContext;
  const _TemplateSheetContent({required this.parentContext});

  @override
  ConsumerState<_TemplateSheetContent> createState() =>
      _TemplateSheetContentState();
}

class _TemplateSheetContentState extends ConsumerState<_TemplateSheetContent> {
  bool _showFallback = false;
  bool _timerStarted = false;

  void _ensureTimeoutStarted() {
    if (_timerStarted) return;
    _timerStarted = true;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showFallback = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(habitTemplatesProvider);

    return templatesAsync.when(
      loading: () {
        _ensureTimeoutStarted();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(child: CircularProgressIndicator()),
              if (_showFallback) ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: widget.parentContext,
                      builder: (_) => const HabitDialog(),
                    );
                  },
                  child: const Text('Ohne Vorlage erstellen'),
                ),
              ],
            ],
          ),
        );
      },
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vorlagen'),
            const SizedBox(height: 8),
            Text('Fehler beim Laden: $e'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: widget.parentContext,
                  builder: (_) => const HabitDialog(),
                );
              },
              child: const Text('Ohne Vorlage erstellen'),
            ),
          ],
        ),
      ),
      data: (templates) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vorlagen',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: widget.parentContext,
                        builder: (_) => const HabitDialog(),
                      );
                    },
                    child: const Text('Ohne Vorlage'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (templates.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Keine Vorlagen verfügbar.'),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final uid = ref.watch(userIdProvider);
                    if (_isAdmin(uid)) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('Vorlagen jetzt einspielen'),
                          onPressed: () async {
                            final svc = HabitTemplateService();
                            await svc.seedTemplates(
                              buildCuratedHabitTemplates(),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vorlagen eingespielt'),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ] else ...[
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: templates.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final t = templates[i];
                      return ListTile(
                        title: Text(t.title),
                        subtitle: Text(t.category),
                        leading: CircleAvatar(
                          backgroundColor: _parseHexColor(t.color),
                          child: const Icon(
                            Icons.flash_on,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        onTap: () async {
                          final notifier = ref.read(
                            habitNotifierProvider.notifier,
                          );

                          // Auto-assign sortIndex: max existing sortIndex + 10
                          final habitsAsync = ref.read(habitsProvider);
                          final maxSortIndex = habitsAsync.when(
                            data: (habits) {
                              final service = ref.read(habitServiceProvider);
                              return service.getMaxSortIndex(habits);
                            },
                            loading: () => 0,
                            error: (_, __) => 0,
                          );

                          await notifier.createHabit(
                            title: t.title,
                            category: t.category,
                            color: t.color,
                            frequency: t.frequency,
                            reminderTime: t.reminderTime,
                            weekdays: t.weekdays,
                            weeklyTarget: t.weeklyTarget,
                            sortIndex: maxSortIndex + 10,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

/// UI-Status: Filter nur fällige Habits anzeigen
final _showOnlyDueHabitsProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

/// UI-Status: Smart Priority anzeigen/anwenden
final _showSmartPriorityProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

/// UI-Status: Smart Order anwenden (sortiert Habits nach Priorität)
final _useSmartOrderProvider = StateProvider.autoDispose<bool>((ref) => false);

Color _parseHexColor(String hexString) {
  try {
    final hex = hexString.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return const Color(0xFF5B50FF);
  } catch (_) {
    return const Color(0xFF5B50FF);
  }
}

bool _isAdmin(String? uid) {
  if (uid == null) return false;
  const admins = {'your-admin-uid-here'};
  return admins.contains(uid) || kDebugMode;
}

class _HabitGroupedList extends ConsumerStatefulWidget {
  final List<Habit> habits;
  final bool showOnlyDue;
  final DateTime today;

  const _HabitGroupedList({
    required this.habits,
    required this.showOnlyDue,
    required this.today,
  });

  @override
  ConsumerState<_HabitGroupedList> createState() => _HabitGroupedListState();
}

class _HabitGroupedListState extends ConsumerState<_HabitGroupedList> {
  List<Habit> _sortedHabits = [];

  @override
  void didUpdateWidget(_HabitGroupedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habits != oldWidget.habits) {
      _updateSortedHabits();
    }
  }

  @override
  void initState() {
    super.initState();
    _updateSortedHabits();
  }

  void _updateSortedHabits() {
    final service = ref.read(habitServiceProvider);
    final useSmartOrder = ref.read(_useSmartOrderProvider);

    // Filter habits
    var filtered = widget.showOnlyDue
        ? widget.habits
            .where((h) => service.isScheduledOnDate(h, widget.today))
            .toList()
        : widget.habits.toList();

    // Apply Smart Order if enabled, otherwise sort by sortIndex
    if (useSmartOrder) {
      _sortedHabits = service.sortHabitsByPriority(
        filtered,
        referenceDate: widget.today,
      );
    } else {
      _sortedHabits = service.sortHabitsByCustomOrder(
        filtered,
        today: widget.today,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showPriority = ref.watch(_showSmartPriorityProvider);
    final useSmartOrder = ref.watch(_useSmartOrderProvider);

    // Update if order changed
    if (useSmartOrder != ref.read(_useSmartOrderProvider)) {
      _updateSortedHabits();
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(
        top: ReflectoSpacing.s16,
        bottom: ReflectoSpacing.s24,
      ),
      buildDefaultDragHandles: false,
      itemCount: _sortedHabits.length,
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex -= 1;

        setState(() {
          final item = _sortedHabits.removeAt(oldIndex);
          _sortedHabits.insert(newIndex, item);
        });

        // Update Firestore
        final uid = ref.read(userIdProvider);
        if (uid != null) {
          final svc = ref.read(habitServiceProvider);
          final updates = <({String habitId, int sortIndex})>[];
          for (int i = 0; i < _sortedHabits.length; i++) {
            updates.add((habitId: _sortedHabits[i].id, sortIndex: i * 10));
          }
          await svc.reorderHabits(uid: uid, updates: updates);
        }
      },
      itemBuilder: (context, index) {
        final habit = _sortedHabits[index];
        return ReorderableDragStartListener(
          key: ValueKey(habit.id),
          index: index,
          child: HabitCard(
            habit: habit,
            showPriority: showPriority,
            onEdit: () {
              showDialog(
                context: context,
                builder: (_) => HabitDialog(habit: habit),
              );
            },
            onDelete: () {
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
                        ref
                            .read(habitNotifierProvider.notifier)
                            .deleteHabit(habit.id);
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
            },
          ),
        );
      },
    );
  }
}
