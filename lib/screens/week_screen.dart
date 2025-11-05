import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/journal_entry.dart';
import '../services/firestore_service.dart';
import '../widgets/reflecto_card.dart';
import '../widgets/reflecto_button.dart';
import '../widgets/reflecto_sparkline.dart';
import 'package:intl/intl.dart';
import '../services/export_import_service.dart';
import '../providers/entry_providers.dart';

class WeekScreen extends ConsumerStatefulWidget {
  const WeekScreen({super.key});

  @override
  ConsumerState<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends ConsumerState<WeekScreen> {
  final _svc = FirestoreService();
  late DateTime _anchor; // any day in week
  final TextEditingController _aiCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _anchor = DateTime.now();
  }

  @override
  void dispose() {
    _aiCtrl.dispose();
    super.dispose();
  }

  // no-op

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.'
      '${d.year.toString()}';

  Map<String, dynamic> _aggregate(List<JournalEntry> entries, DateTimeRange range) {
    int? minF, minE, minH, maxF, maxE, maxH;
    double sumF = 0, sumE = 0, sumH = 0;
    int cF = 0, cE = 0, cH = 0;
    // mood curve for 7 days
    final mood = List<int?>.filled(7, null);
    final byId = {for (final e in entries) e.id: e};
    for (var i = 0; i < 7; i++) {
      final day = range.start.add(Duration(days: i));
      final id = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final e = byId[id];
      if (e != null) {
        final f = e.ratingFocus; final en = e.ratingEnergy; final h = e.ratingHappiness;
        if (f != null) { sumF += f; cF++; minF = (minF == null) ? f : (f < minF ? f : minF); maxF = (maxF == null) ? f : (f > maxF ? f : maxF); }
          if (en != null) { sumE += en; cE++; minE = (minE == null) ? en : (en < minE ? en : minE); maxE = (maxE == null) ? en : (en > maxE ? en : maxE); }
          if (h != null) { sumH += h; cH++; minH = (minH == null) ? h : (h < minH ? h : minH); maxH = (maxH == null) ? h : (h > maxH ? h : maxH); mood[i] = h; }
      }
    }
    double avg(double s, int c) => c == 0 ? 0 : (s / c);
    return {
      'focusAvg': avg(sumF, cF), 'energyAvg': avg(sumE, cE), 'happinessAvg': avg(sumH, cH),
      'focusMin': minF, 'energyMin': minE, 'happinessMin': minH,
      'focusMax': maxF, 'energyMax': maxE, 'happinessMax': maxH,
      'moodCurve': mood.map((e) => e ?? 0).toList(),
    };
  }

  final _exportSvc = ExportImportService();

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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Vorherige Woche',
                        onPressed: () { setState(() { _anchor = _anchor.subtract(const Duration(days: 7)); }); },
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Text('Woche ${FirestoreService.weekIdFrom(_anchor)} · ${_formatDate(range.start)} – ${_formatDate(range.end)}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Nächste Woche',
                        onPressed: () { setState(() { _anchor = _anchor.add(const Duration(days: 7)); }); },
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Zusatz: Datumszeile + Woche wählen + Heute-Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_formatDate(range.start)} – ${_formatDate(range.end)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () { setState(() { _anchor = DateTime.now(); }); },
                        child: const Text('Heute'),
                      ),
                      IconButton(
                        tooltip: 'Woche wählen',
                        icon: const Icon(Icons.calendar_month_outlined),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _anchor,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            if (!mounted) return;
                            setState(() { _anchor = picked; });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: entriesAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text('Fehler: $e')),
                      data: (entries) {
                        final aggr = _aggregate(entries, range);
                        final jsonData = _exportSvc.buildWeekExportJson(weekId, range, entries, aggr);

                        final nf = NumberFormat.decimalPattern();
                        nf.minimumFractionDigits = 2; nf.maximumFractionDigits = 2;
                        return ListView(
                          children: [
                            ReflectoCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Übersicht', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  Text('Fokus: Ø ${nf.format(aggr['focusAvg'])} (min ${aggr['focusMin'] ?? '-'}, max ${aggr['focusMax'] ?? '-'})'),
                                  Text('Energie: Ø ${nf.format(aggr['energyAvg'])} (min ${aggr['energyMin'] ?? '-'}, max ${aggr['energyMax'] ?? '-'})'),
                                  Text('Zufriedenheit: Ø ${nf.format(aggr['happinessAvg'])} (min ${aggr['happinessMin'] ?? '-'}, max ${aggr['happinessMax'] ?? '-'})'),
                                  const SizedBox(height: 8),
                                  const Text('Stimmungsverlauf (1–5):'),
                                  const SizedBox(height: 6),
                                  ReflectoSparkline(points: List<int>.from(aggr['moodCurve'] as List)),
                                ],
                              ),
                            ),

                            ReflectoCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Export', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    Expanded(
                                      child: ReflectoButton(
                                        text: 'JSON kopieren',
                                        onPressed: () async {
                                          final messenger = ScaffoldMessenger.of(context);
                                          await Clipboard.setData(ClipboardData(text: jsonEncode(jsonData)));
                                          if (!mounted) return;
                                          messenger.showSnackBar(const SnackBar(content: Text('JSON in Zwischenablage')));
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ReflectoButton(
                                        text: 'Markdown kopieren',
                                        onPressed: () async {
                                          final messenger = ScaffoldMessenger.of(context);
                                          final md = _exportSvc.buildMarkdownFromJson(jsonData);
                                          await Clipboard.setData(ClipboardData(text: md));
                                          if (!mounted) return;
                                          messenger.showSnackBar(const SnackBar(content: Text('Markdown in Zwischenablage')));
                                        },
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),

                            weeklyAsync.when(
                              loading: () => const ReflectoCard(child: Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))),
                              error: (e, st) => ReflectoCard(child: Padding(padding: const EdgeInsets.all(16), child: Text('Fehler: $e'))),
                              data: (data) {
                                final motto = data?['motto'] as String?;
                                final summary = data?['summaryText'] as String?;
                                final ai = data?['aiAnalysis'];
                                return ReflectoCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('KI-Auswertung / Notizen', style: Theme.of(context).textTheme.titleMedium),
                                      if (motto != null && motto.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text('Motto: $motto', style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                      if (summary != null && summary.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(summary),
                                      ],
                                      if (ai != null) ...[
                                        const SizedBox(height: 8),
                                        Text('AI-Daten vorhanden', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                      ],
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _aiCtrl,
                                        maxLines: null,
                                        decoration: const InputDecoration(
                                          hintText: 'KI-Auswertung hier einfügen (Text oder JSON)…',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(children: [
                                        Expanded(
                                          child: ReflectoButton(
                                            text: 'Importieren & Speichern',
                                            onPressed: () async {
                                              final messenger = ScaffoldMessenger.of(context);
                                              final input = _aiCtrl.text.trim();
                                              if (input.isEmpty) return;
                                              final parsed = _exportSvc.tryParseAiAnalysis(input);
                                              final toSave = parsed != null && parsed.containsKey('text')
                                                  ? {'aiAnalysisText': parsed['text']}
                                                  : {'aiAnalysis': parsed};
                                              await _svc.saveWeeklyReflection(uid, weekId, toSave);
                                              if (!mounted) return;
                                              messenger.showSnackBar(const SnackBar(content: Text('Auswertung gespeichert')));
                                              _aiCtrl.clear();
                                            },
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
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
