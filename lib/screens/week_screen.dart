import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/journal_entry.dart';
import '../services/firestore_service.dart';
import '../services/export_import_service.dart';
import '../providers/entry_providers.dart';
import '../features/week/logic/week_stats.dart';
import '../features/week/widgets/week_navigation_bar.dart';
import '../features/week/widgets/week_stats_card.dart';
import '../features/week/widgets/week_export_card.dart';
import '../features/week/widgets/week_ai_analysis_card.dart';
import '../features/week/widgets/week_hero_card.dart';
import '../theme/tokens.dart';

/// Wochenübersicht: Statistiken, Export, KI-Auswertung
class WeekScreen extends ConsumerStatefulWidget {
  const WeekScreen({super.key});

  @override
  ConsumerState<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends ConsumerState<WeekScreen> {
  late DateTime _anchor; // beliebiger Tag in der Woche

  @override
  void initState() {
    super.initState();
    _anchor = DateTime.now();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.'
      '${d.year.toString()}';

  /// Berechnet Wochenvervollständigung basierend auf Einträgen.
  ///
  /// Kriterien:
  /// - Morgen/Abend-Texte ausgefüllt (6 Felder pro Tag)
  /// - Ratings vorhanden (3 Ratings pro Tag)
  /// - Ziele/To-dos definiert und erledigt
  double _calculateWeekCompletion(
    List<JournalEntry> entries,
    DateTimeRange range,
  ) {
    double totalScore = 0;
    const maxScorePerDay = 12.0; // 6 Textfelder + 3 Ratings + 3 für Planung

    // Erstelle Map für schnelleren Zugriff
    final entryMap = <String, JournalEntry>{};
    for (final entry in entries) {
      entryMap[entry.id] = entry;
    }

    for (var i = 0; i < 7; i++) {
      final day = range.start.add(Duration(days: i));
      final year = day.year;
      final month = day.month.toString().padLeft(2, '0');
      final dayStr = day.day.toString().padLeft(2, '0');
      final entryId = '$year-$month-$dayStr';

      // Suche Entry für diesen Tag
      final entryOrNull = entryMap[entryId];
      if (entryOrNull == null) continue;

      // Prüfe ob Entry tatsächlich Daten hat (nicht nur Placeholder)
      final hasMorningData = entryOrNull.morning.mood.trim().isNotEmpty ||
          entryOrNull.morning.goodThing.trim().isNotEmpty ||
          entryOrNull.morning.focus.trim().isNotEmpty;

      final hasEveningData = entryOrNull.evening.good.trim().isNotEmpty ||
          entryOrNull.evening.learned.trim().isNotEmpty ||
          entryOrNull.evening.improve.trim().isNotEmpty;

      final hasRatings = entryOrNull.ratingFocus != null ||
          entryOrNull.ratingEnergy != null ||
          entryOrNull.ratingHappiness != null;

      final hasPlanning =
          entryOrNull.planning.goals.any((g) => g.trim().isNotEmpty) ||
              entryOrNull.planning.todos.any((t) => t.trim().isNotEmpty);

      // Überspringe leere Placeholder-Dokumente
      if (!hasMorningData && !hasEveningData && !hasRatings && !hasPlanning) {
        continue;
      }

      double dayScore = 0;

      // Morgen (3 Felder)
      if (entryOrNull.morning.mood.trim().isNotEmpty) dayScore++;
      if (entryOrNull.morning.goodThing.trim().isNotEmpty) dayScore++;
      if (entryOrNull.morning.focus.trim().isNotEmpty) dayScore++;

      // Abend (3 Felder)
      if (entryOrNull.evening.good.trim().isNotEmpty) dayScore++;
      if (entryOrNull.evening.learned.trim().isNotEmpty) dayScore++;
      if (entryOrNull.evening.improve.trim().isNotEmpty) dayScore++;

      // Ratings (3 Ratings)
      if (entryOrNull.ratingFocus != null) dayScore++;
      if (entryOrNull.ratingEnergy != null) dayScore++;
      if (entryOrNull.ratingHappiness != null) dayScore++;

      // Planung: Ziele/To-dos (max 3 Punkte)
      final goals =
          entryOrNull.planning.goals.where((g) => g.trim().isNotEmpty).toList();
      final todos =
          entryOrNull.planning.todos.where((t) => t.trim().isNotEmpty).toList();
      if (goals.isNotEmpty || todos.isNotEmpty) {
        dayScore += 1.5; // Bonus für Planung
        final totalItems =
            todos.length; // Nur To-dos, da goalsCompletion nicht im Model
        final todosCompleted = todos
            .asMap()
            .entries
            .where(
              (e) =>
                  e.key < entryOrNull.evening.todosCompletion.length &&
                  entryOrNull.evening.todosCompletion[e.key],
            )
            .length;
        if (totalItems > 0) {
          dayScore += 1.5 * (todosCompleted / totalItems);
        }
      }

      totalScore += dayScore;
    }

    final maxTotal = 7 * maxScorePerDay;
    return (totalScore / maxTotal).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Bitte einloggen.')));
    }

    final uid = user.uid;
    final range = FirestoreService.weekRangeFrom(_anchor);
    final weekId = FirestoreService.weekIdFrom(_anchor);
    final entriesAsync = ref.watch(weekEntriesProvider(_anchor));
    final weeklyAsync = ref.watch(weeklyReflectionProvider(weekId));
    final exportSvc = ExportImportService();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.all(ReflectoSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WeekNavigationBar(
                    weekId: weekId,
                    formattedRange:
                        '${_formatDate(range.start)} - ${_formatDate(range.end)}',
                    onPrevious: () {
                      setState(() {
                        _anchor = _anchor.subtract(const Duration(days: 7));
                      });
                    },
                    onNext: () {
                      setState(() {
                        _anchor = _anchor.add(const Duration(days: 7));
                      });
                    },
                    onToday: () {
                      setState(() {
                        _anchor = DateTime.now();
                      });
                    },
                  ),
                  const SizedBox(height: ReflectoSpacing.s16),
                  Expanded(
                    child: entriesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text('Fehler: $e')),
                      data: (entries) {
                        final stats = WeekStats.aggregate(entries, range);
                        final jsonData = exportSvc.buildWeekExportJson(
                          weekId,
                          range,
                          entries,
                          stats.toJson(),
                        );

                        // Berechne Wochenvervollständigung
                        final completionPercent = _calculateWeekCompletion(
                          entries,
                          range,
                        );

                        return ListView(
                          children: [
                            // Hero Card mit Wochenübersicht
                            WeekHeroCard(
                              completionPercent: completionPercent,
                              weekLabel: weekId,
                              dateRange: '', // Nicht mehr benötigt
                            ),
                            const SizedBox(height: ReflectoSpacing.s16),

                            // Stats & Export
                            WeekStatsCard(stats: stats),
                            WeekExportCard(jsonData: jsonData),
                            weeklyAsync.when(
                              loading: () => const SizedBox(),
                              error: (e, st) => Text('Fehler: $e'),
                              data: (weeklyData) {
                                return WeekAiAnalysisCard(
                                  uid: uid,
                                  weekId: weekId,
                                  weeklyData: weeklyData,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
