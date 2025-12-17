import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/habit_providers.dart';
import '../theme/tokens.dart';
import '../features/habits/widgets/habit_insights_card.dart';
import '../features/habits/widgets/habit_empty_state.dart';
import '../features/habits/widgets/habit_progress_header.dart';
import '../features/habits/widgets/habit_template_sheet.dart';
import '../features/habits/widgets/habit_grouped_list.dart';
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
            return const HabitEmptyState();
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
                child: HabitProgressHeader(
                  selectedDate: _selectedDate,
                  completedCount: completedToday,
                  totalCount: totalHabits,
                ),
              ),

              // Habit-Liste
              SliverFillRemaining(
                child: HabitGroupedList(
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
        return HabitTemplateSheet(parentContext: context);
      },
    );
  }
}
