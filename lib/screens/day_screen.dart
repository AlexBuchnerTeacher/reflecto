import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry.dart';
import '../widgets/reflecto_card.dart';
import '../providers/auth_providers.dart';
import '../providers/entry_providers.dart';

class DayScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const DayScreen({super.key, this.initialDate});

  @override
  ConsumerState<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends ConsumerState<DayScreen> {
  final _planningCtrl = TextEditingController();
  final _morningCtrl = TextEditingController();
  final _eveningCtrl = TextEditingController();

  final _debouncers = <String, Timer?>{};
  bool _saved = false;
  late DateTime _current;

  @override
  void initState() {
    super.initState();
    _debouncers['planning'] = null;
    _debouncers['morning'] = null;
    _debouncers['evening'] = null;
    final now = DateTime.now();
    final init = widget.initialDate ?? now;
    _current = DateTime(init.year, init.month, init.day);
  }

  @override
  void dispose() {
    _planningCtrl.dispose();
    _morningCtrl.dispose();
    _eveningCtrl.dispose();
    _debouncers.values.whereType<Timer>().forEach((t) => t.cancel());
    super.dispose();
  }

  void _debouncedUpdate(String field, String value, String uid, DateTime date) {
    _debouncers[field]?.cancel();
    _debouncers[field] = Timer(const Duration(milliseconds: 500), () async {
      final updater = ref.read(updateDayFieldProvider);
      await updater(uid, date, field, value.isEmpty ? null : value);
      if (!mounted) return;
      setState(() {
        _saved = true;
      });
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _saved = false);
      });
    });
  }

  Widget _ratingsRow({
    required String label,
    required int? value,
    required void Function(int) onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: '$label: $i',
            icon: Icon(i <= (value ?? 0) ? Icons.star_rounded : Icons.star_border_rounded),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => onChanged(i),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(userIdProvider);
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Bitte einloggen.')));
    }

    final docAsync = ref.watch(dayDocProvider(_current));
    final now = DateTime.now();
    final isToday = now.year == _current.year && now.month == _current.month && now.day == _current.day;

    return Scaffold(
      body: SafeArea(
        child: docAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Fehler: $e')),
          data: (snap) {
            final pending = snap.metadata.hasPendingWrites;
            final fromCache = snap.metadata.isFromCache;
            final data = snap.data();
            final entry = (data != null) ? JournalEntry.fromMap(snap.id, data) : null;

            // Update controllers only when different to avoid loops.
            if (entry != null) {
              if (_planningCtrl.text != (entry.planning ?? '')) {
                _planningCtrl.text = entry.planning ?? '';
              }
              if (_morningCtrl.text != (entry.morning ?? '')) {
                _morningCtrl.text = entry.morning ?? '';
              }
              if (_eveningCtrl.text != (entry.evening ?? '')) {
                _eveningCtrl.text = entry.evening ?? '';
              }
            }

            final maxWidth = 820.0;
            String two(int n) => n.toString().padLeft(2, '0');
            final dateLabel = '${two(_current.day)}.${two(_current.month)}.${_current.year}';

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Vorheriger Tag',
                                onPressed: () {
                                  setState(() {
                                    _current = _current.subtract(const Duration(days: 1));
                                  });
                                },
                                icon: const Icon(Icons.chevron_left_rounded),
                              ),
                              Text('Tagesansicht · $dateLabel${isToday ? ' (heute)' : ''}', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(width: 8),
                              if (!isToday)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      final t = DateTime.now();
                                      _current = DateTime(t.year, t.month, t.day);
                                    });
                                  },
                                  child: const Text('Heute'),
                                ),
                              IconButton(
                                tooltip: 'Datum wählen',
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _current,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    final d = DateTime(picked.year, picked.month, picked.day);
                                    if (!mounted) return;
                                    setState(() { _current = d; });
                                  }
                                },
                                icon: const Icon(Icons.event_outlined),
                              ),
                              IconButton(
                                tooltip: 'Nächster Tag',
                                onPressed: () {
                                  setState(() {
                                    _current = _current.add(const Duration(days: 1));
                                  });
                                },
                                icon: const Icon(Icons.chevron_right_rounded),
                              ),
                            ],
                          ),
                          Row(children: [
                            if (pending || fromCache)
                              Icon(
                                pending ? Icons.sync_rounded : Icons.cloud_off_rounded,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            if (_saved) ...[
                              const SizedBox(width: 8),
                              const Text('✓ Gespeichert', style: TextStyle(fontWeight: FontWeight.w600)),
                            ]
                          ]),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ReflectoCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Planung (Vorabend)'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _planningCtrl,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Aufgaben, Ziele, Notizen…',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              ),
                              onChanged: (v) => _debouncedUpdate('planning', v, uid, _current),
                            ),
                          ],
                        ),
                      ),

                      ReflectoCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Morgenroutine'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _morningCtrl,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Gefühl, Stimmung, Intention, Motto…',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              ),
                              onChanged: (v) => _debouncedUpdate('morning', v, uid, _current),
                            ),
                          ],
                        ),
                      ),

                      ReflectoCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Abendreflexion'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _eveningCtrl,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Was lief gut? Gelernt? Wofür dankbar?…',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              ),
                              onChanged: (v) => _debouncedUpdate('evening', v, uid, _current),
                            ),
                          ],
                        ),
                      ),

                      ReflectoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ratingsRow(
                              label: 'Fokus',
                              value: entry?.ratingFocus,
                              onChanged: (v) async {
                                final updater = ref.read(updateDayFieldProvider);
                                await updater(uid, _current, 'ratingFocus', v);
                                if (!mounted) return;
                                setState(() => _saved = true);
                                Future.delayed(const Duration(milliseconds: 1200), () {
                                  if (mounted) setState(() => _saved = false);
                                });
                              },
                            ),
                            _ratingsRow(
                              label: 'Energie',
                              value: entry?.ratingEnergy,
                              onChanged: (v) async {
                                final updater = ref.read(updateDayFieldProvider);
                                await updater(uid, _current, 'ratingEnergy', v);
                                if (!mounted) return;
                                setState(() => _saved = true);
                                Future.delayed(const Duration(milliseconds: 1200), () {
                                  if (mounted) setState(() => _saved = false);
                                });
                              },
                            ),
                            _ratingsRow(
                              label: 'Zufriedenheit',
                              value: entry?.ratingHappiness,
                              onChanged: (v) async {
                                final updater = ref.read(updateDayFieldProvider);
                                await updater(uid, _current, 'ratingHappiness', v);
                                if (!mounted) return;
                                setState(() => _saved = true);
                                Future.delayed(const Duration(milliseconds: 1200), () {
                                  if (mounted) setState(() => _saved = false);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
