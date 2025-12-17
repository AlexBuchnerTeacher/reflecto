import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
import '../features/day/widgets/day_week_carousel.dart';

/// Hauptscreen für Habit-Tracking
class HabitScreen extends ConsumerStatefulWidget {
  const HabitScreen({super.key});

  @override
  ConsumerState<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends ConsumerState<HabitScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final theme = Theme.of(context);

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

          // Berechne Tages-Fortschritt (nur für gewähltes Datum fällige Habits)
          final service = ref.watch(habitServiceProvider);
          final dueHabits = habits
              .where((h) => service.isScheduledOnDate(h, _selectedDate))
              .toList();
          final completedToday = dueHabits
              .where((h) => service.isCompletedOnDate(h, _selectedDate))
              .length;
          final totalHabits = dueHabits.length;
          final progressPercent = totalHabits > 0
              ? (completedToday / totalHabits * 100).round()
              : 0;

          return CustomScrollView(
            slivers: [
              // Date Carousel
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: ReflectoSpacing.s8),
                  child: Align(
                    alignment: Alignment.center,
                    child: DayWeekCarousel(
                      selected: _selectedDate,
                      onSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // Mini-Analytics Karte
              SliverToBoxAdapter(
                child: HabitInsightsCard(
                    habits: habits, service: service, today: _selectedDate),
              ),

              // Fortschritts-Header
              SliverToBoxAdapter(
                child: Container(
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
                            DateUtils.isSameDay(_selectedDate, DateTime.now())
                                ? 'Heute'
                                : DateFormat('EEE, d. MMM', 'de_DE')
                                    .format(_selectedDate),
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
                        value:
                            totalHabits > 0 ? completedToday / totalHabits : 0,
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
              ),

              // Habit-Liste
              SliverFillRemaining(
                child: _HabitGroupedList(
                  habits: habits,
                  today: _selectedDate,
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
  final DateTime today;

  const _HabitGroupedList({
    required this.habits,
    required this.today,
  });

  @override
  ConsumerState<_HabitGroupedList> createState() => _HabitGroupedListState();
}

class _HabitGroupedListState extends ConsumerState<_HabitGroupedList> {
  List<Habit> _openHabits = [];
  List<Habit> _completedHabits = [];

  @override
  void didUpdateWidget(_HabitGroupedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habits != oldWidget.habits || widget.today != oldWidget.today) {
      _updateHabitGroups();
    }
  }

  @override
  void initState() {
    super.initState();
    _updateHabitGroups();
  }

  void _updateHabitGroups() {
    final service = ref.read(habitServiceProvider);

    // 1. Nur fällige Habits für den gewählten Tag
    final dueHabits = widget.habits
        .where((h) => service.isScheduledOnDate(h, widget.today))
        .toList();

    // 2. In zwei Gruppen aufteilen: offen vs. erledigt
    final open = <Habit>[];
    final completed = <Habit>[];

    for (final habit in dueHabits) {
      if (service.hasReachedGoal(habit, widget.today)) {
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
