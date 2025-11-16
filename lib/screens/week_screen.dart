import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import '../services/export_import_service.dart';
import '../providers/entry_providers.dart';
import '../features/week/logic/week_stats.dart';
import '../features/week/widgets/week_navigation_bar.dart';
import '../features/week/widgets/week_stats_card.dart';
import '../features/week/widgets/week_export_card.dart';
import '../features/week/widgets/week_ai_analysis_card.dart';
import '../features/day/widgets/day_week_carousel.dart';
import '../theme/tokens.dart';

/// Wochenübersicht: Statistiken, Export, KI-Auswertung
class WeekScreen extends ConsumerStatefulWidget {
  const WeekScreen({super.key});

  @override
  ConsumerState<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends ConsumerState<WeekScreen> {
  late DateTime _anchor; // beliebiger Tag in der Woche
  late DateTime _selectedDay; // im Karussell ausgewählter Tag

  @override
  void initState() {
    super.initState();
    _anchor = DateTime.now();
    _selectedDay = DateTime.now();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.'
      '${d.year.toString()}';

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
                        _selectedDay = range.start.subtract(
                          const Duration(days: 7),
                        );
                      });
                    },
                    onNext: () {
                      setState(() {
                        _anchor = _anchor.add(const Duration(days: 7));
                        _selectedDay = range.start.add(const Duration(days: 7));
                      });
                    },
                    onToday: () {
                      setState(() {
                        _anchor = DateTime.now();
                        _selectedDay = DateTime.now();
                      });
                    },
                    onPickDate: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _anchor,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        if (!mounted) return;
                        setState(() {
                          _anchor = picked;
                          _selectedDay = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: ReflectoSpacing.s16),
                  // Wochenkarussell (7 Tage)
                  DayWeekCarousel(
                    selected: _selectedDay,
                    onSelected: (date) {
                      setState(() {
                        _selectedDay = date;
                        // Woche wechseln wenn Tag außerhalb der aktuellen Woche
                        final currentRange = FirestoreService.weekRangeFrom(
                          _anchor,
                        );
                        if (date.isBefore(currentRange.start) ||
                            date.isAfter(currentRange.end)) {
                          _anchor = date;
                        }
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

                        return ListView(
                          children: [
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
