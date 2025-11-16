import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/habit_providers.dart';
import '../providers/habit_template_providers.dart';
import '../services/habit_template_service.dart';
import '../services/habit_template_seed.dart';
import '../providers/auth_providers.dart';
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
    final uid = ref.watch(userIdProvider);
    final showOnlyDue = ref.watch(_showOnlyDueHabitsProvider);

    final syncStatus = ref.watch(habitsSyncStatusProvider);
    final isSynced = syncStatus.value ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Gewohnheiten'),
        actions: [
          // Sync-Status wie im HomeScreen
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSynced
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      (isSynced
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary)
                          .withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Text(
                isSynced ? '\u2713 Gespeichert' : 'Synchronisiere...',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSynced
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          if (_isAdmin(uid))
            IconButton(
              tooltip: 'Vorlagen einspielen (Debug)',
              icon: const Icon(Icons.cloud_upload_outlined),
              onPressed: () async {
                final templates = buildCuratedHabitTemplates();
                final svc = HabitTemplateService();
                await svc.seedTemplates(templates);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vorlagen eingespielt')),
                  );
                }
              },
            ),
        ],
      ),
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
          final dueHabits = habits
              .where((h) => service.isScheduledOnDate(h, today))
              .toList();
          final completedToday = dueHabits
              .where((h) => service.isCompletedOnDate(h, today))
              .length;
          final totalHabits = dueHabits.length;
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilterChip(
                        label: const Text('Nur fällige'),
                        selected: showOnlyDue,
                        onSelected: (v) =>
                            ref
                                    .read(_showOnlyDueHabitsProvider.notifier)
                                    .state =
                                v,
                      ),
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
                          await notifier.createHabit(
                            title: t.title,
                            category: t.category,
                            color: t.color,
                            frequency: t.frequency,
                            reminderTime: t.reminderTime,
                            weekdays: t.weekdays,
                            weeklyTarget: t.weeklyTarget,
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

class _HabitGroupedList extends ConsumerWidget {
  final List<dynamic> habits; // List<Habit>
  final bool showOnlyDue;
  final DateTime today;

  const _HabitGroupedList({
    required this.habits,
    required this.showOnlyDue,
    required this.today,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(habitServiceProvider);
    final filtered = showOnlyDue
        ? habits.where((h) => service.isScheduledOnDate(h, today)).toList()
        : habits.toList();

    // Group by category
    final Map<String, List<dynamic>> byCat = {};
    for (final h in filtered) {
      byCat.putIfAbsent(h.category, () => []).add(h);
    }

    // Fixed category order, unknowns appended alphabetically
    const preferred = <String>[
      '🔥 GESUNDHEIT',
      '🚴 SPORT',
      '📘 LERNEN',
      '⚡ KREATIVITÄT',
      '📈 PRODUKTIVITÄT',
      '🤝 SOZIALES',
      '🧘 ACHTSAMKEIT',
      '🔧 SONSTIGES',
    ];
    final categories = byCat.keys.toList()
      ..sort((a, b) {
        final ai = preferred.indexOf(a);
        final bi = preferred.indexOf(b);
        final aKnown = ai != -1;
        final bKnown = bi != -1;
        if (aKnown && bKnown) return ai.compareTo(bi);
        if (aKnown) return -1;
        if (bKnown) return 1;
        return a.compareTo(b);
      });

    return ListView(
      padding: const EdgeInsets.only(
        top: ReflectoSpacing.s16,
        bottom: ReflectoSpacing.s24,
      ),
      children: [
        for (final cat in categories) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(cat, style: Theme.of(context).textTheme.titleSmall),
                IconButton(
                  tooltip: 'Reihenfolge ändern',
                  icon: const Icon(Icons.swap_vert),
                  onPressed: () {
                    _showReorderDialogForCategory(
                      context,
                      ref,
                      cat,
                      byCat[cat]!.toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          Builder(
            builder: (ctx) {
              final list = byCat[cat]!
                ..sort((a, b) {
                  final ai = a.sortIndex ?? 999999;
                  final bi = b.sortIndex ?? 999999;
                  final c = ai.compareTo(bi);
                  if (c != 0) return c;
                  return a.title.compareTo(b.title);
                });
              return Column(
                children: [
                  for (final h in list)
                    HabitCard(
                      habit: h,
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (_) => HabitDialog(habit: h),
                        );
                      },
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Habit löschen?'),
                            content: Text(
                              'Möchtest du "${h.title}" wirklich löschen?',
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
                                      .deleteHabit(h.id);
                                  Navigator.of(ctx).pop();
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    ctx,
                                  ).colorScheme.error,
                                ),
                                child: const Text('Löschen'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  void _showReorderDialogForCategory(
    BuildContext context,
    WidgetRef ref,
    String category,
    List<dynamic> items,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        final list = items
          ..sort((a, b) {
            final ai = a.sortIndex ?? 999999;
            final bi = b.sortIndex ?? 999999;
            final c = ai.compareTo(bi);
            if (c != 0) return c;
            return a.title.compareTo(b.title);
          });
        return AlertDialog(
          title: Text('Reihenfolge: $category'),
          content: SizedBox(
            width: 400,
            height: 400,
            child: StatefulBuilder(
              builder: (context, setState) => ReorderableListView(
                buildDefaultDragHandles: true,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = list.removeAt(oldIndex);
                    list.insert(newIndex, item);
                  });
                },
                children: [
                  for (int i = 0; i < list.length; i++)
                    ListTile(
                      key: ValueKey(list[i].id),
                      title: Text(list[i].title),
                      subtitle: Text(list[i].frequency),
                      leading: const Icon(Icons.drag_handle),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () async {
                final uid = ref.read(userIdProvider);
                if (uid != null) {
                  final svc = ref.read(habitServiceProvider);
                  // Vergabe neuer sortIndex in 10er-Schritten
                  for (int i = 0; i < list.length; i++) {
                    final h = list[i];
                    await svc.updateHabit(
                      uid: uid,
                      habitId: h.id,
                      sortIndex: i * 10,
                    );
                  }
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }
}
