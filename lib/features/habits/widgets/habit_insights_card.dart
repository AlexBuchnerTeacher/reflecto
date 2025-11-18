import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/habit.dart';
import '../../../services/habit_service.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/reflecto_card.dart';
import '../../../providers/card_collapse_providers.dart';

/// Mini-Analytics Karte für Habits
///
/// Komponenten:
/// - Tagesbilanz: X/Y erledigt + Momentum-Indikator
/// - Kategorie-Progress: Farbbalken pro Kategorie
/// - Trendkarte: Top 3 Streaks mit Trend-Icons
/// - Spotlight: Fokus-Empfehlung mit optionalem CTA
class HabitInsightsCard extends ConsumerWidget {
  final List<Habit> habits;
  final HabitService service;
  final DateTime today;

  const HabitInsightsCard({
    super.key,
    required this.habits,
    required this.service,
    required this.today,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (habits.isEmpty) return const SizedBox.shrink();

    final dueHabits =
        habits.where((h) => service.isScheduledOnDate(h, today)).toList();

    if (dueHabits.isEmpty) return const SizedBox.shrink();

    final isCollapsed = ref.watch(habitInsightsCardCollapseProvider);
    final collapseNotifier = ref.read(
      habitInsightsCardCollapseProvider.notifier,
    );

    return ReflectoCard(
      margin: const EdgeInsets.all(ReflectoSpacing.s16),
      titleEmoji: '📊',
      title: 'Habit-Insights',
      isCollapsible: true,
      isCollapsed: isCollapsed,
      onCollapsedChanged: (collapsed) =>
          collapseNotifier.setCollapsed(collapsed),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTagesbilanz(context, dueHabits),
          const SizedBox(height: ReflectoSpacing.s16),
          _buildKategorieProgress(context, dueHabits),
          const SizedBox(height: ReflectoSpacing.s16),
          _buildTrendkarte(context),
          const SizedBox(height: ReflectoSpacing.s16),
          _buildSpotlight(context, dueHabits),
        ],
      ),
    );
  }

  /// Tagesbilanz: "X von Y erledigt" + Momentum-Indikator (⭐)
  Widget _buildTagesbilanz(BuildContext context, List<Habit> dueHabits) {
    final theme = Theme.of(context);
    final completedCount =
        dueHabits.where((h) => service.isCompletedOnDate(h, today)).length;
    final totalCount = dueHabits.length;
    final progressPercent = (completedCount / totalCount * 100).round();

    // Momentum: ⭐ wenn >= 80%, sonst leer
    final momentum = progressPercent >= 80 ? '⭐' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tagesbilanz',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (momentum.isNotEmpty)
              Text(momentum, style: const TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: ReflectoSpacing.s8),
        Text(
          '$completedCount von $totalCount erledigt',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: ReflectoSpacing.s8),
        LinearProgressIndicator(
          value: completedCount / totalCount,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  /// Kategorie-Progress: Farbbalken pro Kategorie mit Werten
  Widget _buildKategorieProgress(BuildContext context, List<Habit> dueHabits) {
    final theme = Theme.of(context);

    // Gruppiere nach Kategorie
    final categoryMap = <String, List<Habit>>{};
    for (final habit in dueHabits) {
      final cat = habit.category.isEmpty ? 'Andere' : habit.category;
      categoryMap.putIfAbsent(cat, () => []).add(habit);
    }

    if (categoryMap.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategorien',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: ReflectoSpacing.s8),
        ...categoryMap.entries.map((entry) {
          final catName = entry.key;
          final catHabits = entry.value;
          final completed = catHabits
              .where((h) => service.isCompletedOnDate(h, today))
              .length;
          final total = catHabits.length;
          // Convert hex color string to int (remove # prefix if present)
          final colorStr = catHabits.first.color.replaceFirst('#', '');
          final colorInt = int.parse('FF$colorStr', radix: 16);

          return Padding(
            padding: const EdgeInsets.only(bottom: ReflectoSpacing.s8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      catName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$completed/$total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Color(colorInt),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: completed / total,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                  backgroundColor: Color(colorInt).withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(colorInt)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Trendkarte: Top 3 Habits mit höchsten Streaks + Trend-Icons (▲●▼)
  Widget _buildTrendkarte(BuildContext context) {
    final theme = Theme.of(context);

    // Sortiere nach Streak (höchste zuerst)
    final sortedByStreak = [...habits]
      ..sort((a, b) => b.streak.compareTo(a.streak));
    final top3 = sortedByStreak.take(3).toList();

    if (top3.isEmpty || top3.first.streak == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Trends',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: ReflectoSpacing.s8),
        ...top3.map((habit) {
          // Trend-Icon basierend auf Streak
          final trendIcon = habit.streak >= 7
              ? '▲' // Steigend
              : habit.streak >= 3
                  ? '●' // Stabil
                  : '▼'; // Fallend

          final trendColor = habit.streak >= 7
              ? Colors.green
              : habit.streak >= 3
                  ? Colors.orange
                  : Colors.red;

          return Padding(
            padding: const EdgeInsets.only(bottom: ReflectoSpacing.s4),
            child: Row(
              children: [
                Text(
                  trendIcon,
                  style: TextStyle(fontSize: 16, color: trendColor),
                ),
                const SizedBox(width: ReflectoSpacing.s8),
                Expanded(
                  child: Text(
                    habit.title,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${habit.streak}-Tage-Streak',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Spotlight: Fokus-Empfehlung basierend auf niedrigster Kategorie-Completion
  Widget _buildSpotlight(BuildContext context, List<Habit> dueHabits) {
    final theme = Theme.of(context);

    // Finde Kategorie mit niedrigster Completion-Rate
    final categoryMap = <String, List<Habit>>{};
    for (final habit in dueHabits) {
      final cat = habit.category.isEmpty ? 'Andere' : habit.category;
      categoryMap.putIfAbsent(cat, () => []).add(habit);
    }

    if (categoryMap.isEmpty) return const SizedBox.shrink();

    // Berechne Completion-Rate pro Kategorie
    String? lowestCat;
    double lowestRate = 1.0;
    for (final entry in categoryMap.entries) {
      final completed =
          entry.value.where((h) => service.isCompletedOnDate(h, today)).length;
      final rate = completed / entry.value.length;
      if (rate < lowestRate) {
        lowestRate = rate;
        lowestCat = entry.key;
      }
    }

    if (lowestCat == null || lowestRate >= 0.8) {
      // Alles läuft gut
      return Container(
        padding: const EdgeInsets.all(ReflectoSpacing.s12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.celebration, color: theme.colorScheme.primary),
            const SizedBox(width: ReflectoSpacing.s8),
            Expanded(
              child: Text(
                'Super! Alle Kategorien laufen gut 🎉',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Zeige Fokus-Empfehlung
    final catHabits = categoryMap[lowestCat]!;
    final completed =
        catHabits.where((h) => service.isCompletedOnDate(h, today)).length;
    final total = catHabits.length;

    return Container(
      padding: const EdgeInsets.all(ReflectoSpacing.s12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: ReflectoSpacing.s8),
              Text(
                'Spotlight',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: ReflectoSpacing.s4),
          Text(
            '$lowestCat: $completed/$total erledigt',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
