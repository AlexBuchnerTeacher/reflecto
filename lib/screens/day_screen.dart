import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;

import '../widgets/reflecto_card.dart';
import '../widgets/reflecto_rating_bar.dart';
import '../widgets/reflecto_snackbar.dart';
import '../providers/auth_providers.dart';
import '../providers/entry_providers.dart';
import '../services/firestore_service.dart';

class DayScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const DayScreen({super.key, this.initialDate});

  @override
  ConsumerState<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends ConsumerState<DayScreen> {
  late DateTime _selected;

  // Evening (today)
  final _eveningGoodCtrl = TextEditingController();
  final _eveningLearnedCtrl = TextEditingController();
  final _eveningBetterCtrl = TextEditingController();
  final _eveningGratefulCtrl = TextEditingController();
  final _eveningGoodNode = FocusNode();
  final _eveningLearnedNode = FocusNode();
  final _eveningBetterNode = FocusNode();
  final _eveningGratefulNode = FocusNode();

  // Morning (today)
  final _morningFeelingCtrl = TextEditingController();
  final _morningGoodCtrl = TextEditingController();
  final _morningFocusCtrl = TextEditingController();
  final _morningFeelingNode = FocusNode();
  final _morningGoodNode = FocusNode();
  final _morningFocusNode = FocusNode();

  // Planning (tomorrow)
  final List<TextEditingController> _goalCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _todoCtrls = List.generate(3, (_) => TextEditingController());
  final _attitudeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<FocusNode> _goalNodes = List.generate(3, (_) => FocusNode());
  final List<FocusNode> _todoNodes = List.generate(3, (_) => FocusNode());
  final _attitudeNode = FocusNode();
  final _notesNode = FocusNode();

  // Local checkboxes for yesterday review
  List<bool> _yesterdayGoalChecks = const [];
  List<bool> _yesterdayTodoChecks = const [];

  final Map<String, Timer> _debouncers = {};
  final Map<String, Map<String, dynamic>?> _docCache = {}; // dateId -> latest doc data
  final Set<String> _ensured = {};
  DateTime? _lastSnackAt;
  int? _ratingFocusLocal;
  int? _ratingEnergyLocal;
  int? _ratingHappinessLocal;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final init = widget.initialDate ?? now;
    _selected = DateTime(init.year, init.month, init.day);
  }

  @override
  void dispose() {
    for (final t in _debouncers.values) {
      t.cancel();
    }
    _eveningGoodCtrl.dispose();
    _eveningLearnedCtrl.dispose();
    _eveningBetterCtrl.dispose();
    _eveningGratefulCtrl.dispose();
    _morningFeelingCtrl.dispose();
    _morningGoodCtrl.dispose();
    _morningFocusCtrl.dispose();
    _eveningGoodNode.dispose();
    _eveningLearnedNode.dispose();
    _eveningBetterNode.dispose();
    _eveningGratefulNode.dispose();
    _morningFeelingNode.dispose();
    _morningGoodNode.dispose();
    _morningFocusNode.dispose();
    for (final c in _goalCtrls) {
      c.dispose();
    }
    for (final c in _todoCtrls) {
      c.dispose();
    }
    for (final n in _goalNodes) {
      n.dispose();
    }
    for (final n in _todoNodes) {
      n.dispose();
    }
    _attitudeCtrl.dispose();
    _notesCtrl.dispose();
    _attitudeNode.dispose();
    _notesNode.dispose();
    super.dispose();
  }

  String _dateId(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  void _ensureEntry(String uid, DateTime date) {
    final key = '$uid:${_dateId(date)}';
    if (_ensured.contains(key)) return;
    _ensured.add(key);
    FirestoreService().createEmptyEntry(uid, date);
  }

  void _maybeShowSavedSnack() {
    final now = DateTime.now();
    if (_lastSnackAt == null || now.difference(_lastSnackAt!).inMilliseconds > 1000) {
      _lastSnackAt = now;
      if (mounted) ReflectoSnackbar.showSaved(context);
    }
  }

  void _debouncedUpdate({
    required String uid,
    required DateTime date,
    required String fieldPath,
    required dynamic value,
    String? alsoAggregateTo,
    String Function()? aggregateBuilder,
  }) {
    final key = '${_dateId(date)}|$fieldPath';
    _debouncers[key]?.cancel();
    _debouncers[key] = Timer(const Duration(milliseconds: 500), () async {
      try {
        // Skip if value unchanged compared to latest snapshot
        if (value is! FieldValue) {
          final prev = _valueAtPath(_docCache[_dateId(date)], fieldPath);
          if (_deepEquals(prev, value)) return;
        }
        final updater = ref.read(updateDayFieldProvider);
        await updater(uid, date, fieldPath, value);
        if (alsoAggregateTo != null && aggregateBuilder != null) {
          await updater(uid, date, alsoAggregateTo, aggregateBuilder());
        }
        _maybeShowSavedSnack();
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Speichern')),
        );
      }
    });
  }

  dynamic _valueAtPath(Map<String, dynamic>? map, String fieldPath) {
    if (map == null) return null;
    final parts = fieldPath.split('.');
    dynamic cur = map;
    for (final raw in parts) {
      final idx = int.tryParse(raw);
      if (idx != null) {
        if (cur is List && idx >= 0 && idx < cur.length) {
          cur = cur[idx];
        } else {
          return null;
        }
      } else {
        if (cur is Map<String, dynamic> && cur.containsKey(raw)) {
          cur = cur[raw];
        } else {
          return null;
        }
      }
    }
    return cur;
  }

  bool _deepEquals(dynamic a, dynamic b) {
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }

  T? _readAt<T>(Map<String, dynamic>? map, List<String> path) {
    dynamic cur = map;
    for (final p in path) {
      if (cur is Map<String, dynamic> && cur.containsKey(p)) {
        cur = cur[p];
      } else {
        return null;
      }
    }
    return cur as T?;
  }

  void _setCtrl(TextEditingController c, String? v, {FocusNode? focusNode}) {
    if (v == null) return; // kein Ãœberschreiben mit leer bei fehlendem Feld
    if (focusNode != null && focusNode.hasFocus) return; // wÃ¤hrend aktiver Eingabe nicht Ã¼berschreiben
    if (c.text != v) {
      // Auswahl freundlich aktualisieren
      final selection = TextSelection.collapsed(offset: v.length);
      c.value = c.value.copyWith(text: v, selection: selection, composing: TextRange.empty);
    }
  }

  String _formatDateLabel(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(userIdProvider);
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Bitte einloggen.')));
    }

    final todayDoc = ref.watch(dayDocProvider(_selected));
    final tomorrow = _selected.add(const Duration(days: 1));
    final tDoc = ref.watch(dayDocProvider(tomorrow));

    _ensureEntry(uid, _selected);
    _ensureEntry(uid, tomorrow);

    return todayDoc.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Fehler: $e'))),
      data: (todaySnap) {
        final todayData = todaySnap.data();
        final pending = todaySnap.metadata.hasPendingWrites;
        final fromCache = todaySnap.metadata.isFromCache;

        int? readRating(Map<String, dynamic>? m, String key) {
          final nested = m?['ratings'];
          if (nested is Map<String, dynamic>) {
            final v = nested[key];
            if (v is num) return v.toInt();
          }
          final top = m?['rating${key[0].toUpperCase()}${key.substring(1)}'];
          return (top is num) ? top.toInt() : null;
        }
        final focusFromSnap = readRating(todayData, 'focus');
        final energyFromSnap = readRating(todayData, 'energy');
        final happinessFromSnap = readRating(todayData, 'happiness');

        _ratingFocusLocal ??= focusFromSnap;
        _ratingEnergyLocal ??= energyFromSnap;
        _ratingHappinessLocal ??= happinessFromSnap;
 

        // Morning/Evening current values into controllers (skip while focused)
        _setCtrl(_morningFeelingCtrl, _readAt<String>(todayData, ['morning', 'mood']) ?? _readAt<String>(todayData, ['morning', 'feeling']), focusNode: _morningFeelingNode);
        _setCtrl(_morningGoodCtrl, _readAt<String>(todayData, ['morning', 'goodThing']) ?? _readAt<String>(todayData, ['morning', 'good']), focusNode: _morningGoodNode);
        _setCtrl(_morningFocusCtrl, _readAt<String>(todayData, ['morning', 'focus']), focusNode: _morningFocusNode);

        _setCtrl(_eveningGoodCtrl, _readAt<String>(todayData, ['evening', 'good']), focusNode: _eveningGoodNode);
        _setCtrl(_eveningLearnedCtrl, _readAt<String>(todayData, ['evening', 'learned']), focusNode: _eveningLearnedNode);
        _setCtrl(_eveningBetterCtrl, _readAt<String>(todayData, ['evening', 'improve']) ?? _readAt<String>(todayData, ['evening', 'better']), focusNode: _eveningBetterNode);
        _setCtrl(_eveningGratefulCtrl, _readAt<String>(todayData, ['evening', 'gratitude']) ?? _readAt<String>(todayData, ['evening', 'grateful']), focusNode: _eveningGratefulNode);

        // Tomorrow planning into controllers
        final tData = tDoc.value?.data();
        _docCache[_dateId(_selected)] = todayData;
        _docCache[_dateId(tomorrow)] = tData;
        final goalsDyn = _readAt<List>(tData, ['planning', 'goals']);
        final todosDyn = _readAt<List>(tData, ['planning', 'todos']);
        final goals = (goalsDyn ?? const <dynamic>[]).map((e) => e?.toString() ?? '').toList();
        final todos = (todosDyn ?? const <dynamic>[]).map((e) => e?.toString() ?? '').toList();
        for (var i = 0; i < 3; i++) {
          _setCtrl(_goalCtrls[i], i < goals.length ? goals[i] : null, focusNode: _goalNodes[i]);
          _setCtrl(_todoCtrls[i], i < todos.length ? todos[i] : null, focusNode: _todoNodes[i]);
        }
        _setCtrl(_attitudeCtrl, _readAt<String>(tData, ['planning', 'reflection']), focusNode: _attitudeNode);
        _setCtrl(_notesCtrl, _readAt<String>(tData, ['planning', 'notes']), focusNode: _notesNode);

        // Review der Planung fuer den ausgewaehlten Tag
        final curGoals = (_readAt<List>(todayData, ['planning', 'goals']) ?? []).cast<String>();
        final curTodos = (_readAt<List>(todayData, ['planning', 'todos']) ?? []).cast<String>();
        final completionDyn = _readAt<List>(todayData, ['evening', 'todosCompletion']) ?? const <dynamic>[];
        final completion = completionDyn.map((e) => e == true).toList();
        _yesterdayGoalChecks = List<bool>.generate(curGoals.length.clamp(0, 3), (i) => false);
        _yesterdayTodoChecks = List<bool>.generate(curTodos.length.clamp(0, 3), (i) => i < completion.length ? completion[i] : false);

        final isToday = DateUtils.isSameDay(_selected, DateTime.now());

        return Scaffold(
          appBar: AppBar(
            title: Text('Tagesansicht - ' + _formatDateLabel(_selected) + (isToday ? ' (heute)' : '')),
            centerTitle: true,
            actions: [
              if (pending || fromCache)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    pending ? Icons.sync_rounded : Icons.cloud_off_rounded,
                    size: 20,
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: FocusTraversalGroup(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: 'Gestern',
                            onPressed: () => setState(() => _selected = _selected.subtract(const Duration(days: 1))),
                            icon: const Icon(Icons.chevron_left_rounded),
                          ),
                          if (!isToday)
                            TextButton(
                              onPressed: () {
                                final t = DateTime.now();
                                setState(() => _selected = DateTime(t.year, t.month, t.day));
                              },
                              child: const Text('Heute'),
                            ),
                          IconButton(
                            tooltip: 'Morgen',
                            onPressed: () => setState(() => _selected = _selected.add(const Duration(days: 1))),
                            icon: const Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Evening reflection (today)
                      ReflectoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('\u{1F307} Abendreflexion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            const Text('Reflektiere deinen Tag und schlie\u{00DF}e ihn bewusst ab.'),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _emojiBar(
                                  context,
                                  label: 'Stimmung',
                                  emojis: const ['\u{1F614}','\u{1F610}','\u{1F642}','\u{1F60A}','\u{1F60E}'],
                                  value: (todayData?['ratings']?['mood'] as num?)?.toInt(),
                                  onSelect: (v) {
                                    final updater = ref.read(updateDayFieldProvider);
                                    updater(uid, _selected, 'ratings.mood', v).then((_) => _maybeShowSavedSnack());
                                  },
                                ),
                                const SizedBox(height: 12),
                                _emojiBar(
                                  context,
                                  label: 'Energie',
                                  emojis: const ['\u{1F50B}','\u{1F50B}','\u{1F50B}','\u{1F50B}','\u{1F50B}'],
                                  value: (todayData?['ratings']?['energy'] as num?)?.toInt(),
                                  onSelect: (v) {
                                    final updater = ref.read(updateDayFieldProvider);
                                    updater(uid, _selected, 'ratings.energy', v).then((_) => _maybeShowSavedSnack());
                                  },
                                ),
                                const SizedBox(height: 12),
                                _emojiBar(
                                  context,
                                  label: 'Fokus',
                                  emojis: const ['\u{1F3AF}','\u{1F3AF}','\u{1F3AF}','\u{1F3AF}','\u{1F3AF}'],
                                  value: (todayData?['ratings']?['focus'] as num?)?.toInt(),
                                  onSelect: (v) {
                                    final updater = ref.read(updateDayFieldProvider);
                                    updater(uid, _selected, 'ratings.focus', v).then((_) => _maybeShowSavedSnack());
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('R\u{00FC}ckblick auf deine Planung', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            if (curGoals.isNotEmpty) ...[
                              const Text('Ziele', style: TextStyle(color: Colors.black54)),
                              const SizedBox(height: 4),
                               for (var i = 0; i < curGoals.length && i < 3; i++)
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  value: _yesterdayGoalChecks[i],
                                  onChanged: (v) => setState(() => _yesterdayGoalChecks[i] = v ?? false),
                                  title: Text(curGoals[i]),
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                            ] else const Text('Keine Ziele von gestern vorhanden.'),
                            const SizedBox(height: 8),
                            if (curTodos.isNotEmpty) ...[
                              const Text('To-dos', style: TextStyle(color: Colors.black54)),
                              const SizedBox(height: 4),
                               for (var i = 0; i < curTodos.length && i < 3; i++)
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  value: _yesterdayTodoChecks[i],
                                  onChanged: (v) async {
                                    final val = v ?? false;
                                    setState(() => _yesterdayTodoChecks[i] = val);
                                    try {
                                      await FirestoreService.instance.updateTodoCompletion(uid, _selected, i, val);
                                      _maybeShowSavedSnack();
                                    } catch (_) {}
                                  },
                                  title: Opacity(
                                    opacity: _yesterdayTodoChecks[i] ? 0.6 : 1.0,
                                    child: Text(curTodos[i]),
                                  ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                            ] else const Text('Keine To-dos von gestern vorhanden.'),
                            const SizedBox(height: 12),

                            _labeledField('Was lief heute gut?', _eveningGoodCtrl, focusNode: _eveningGoodNode, onChanged: (v) {
                              _debouncedUpdate(
                                uid: uid,
                                date: _selected,
                                fieldPath: 'evening.good',
                                value: v.isEmpty ? null : v,
                                alsoAggregateTo: 'evening.summary',
                                aggregateBuilder: _aggregateEvening,
                              );
                            }),
                            const SizedBox(height: 8),
                            _labeledField('Was habe ich gelernt oder erkannt?', _eveningLearnedCtrl, focusNode: _eveningLearnedNode, onChanged: (v) {
                              _debouncedUpdate(
                                uid: uid,
                                date: _selected,
                                fieldPath: 'evening.learned',
                                value: v.isEmpty ? null : v,
                                alsoAggregateTo: 'evening.summary',
                                aggregateBuilder: _aggregateEvening,
                              );
                            }),
                            const SizedBox(height: 8),
                            _labeledField('Was h\u{00E4}tte besser laufen k\u{00F6}nnen?', _eveningBetterCtrl, focusNode: _eveningBetterNode, onChanged: (v) {
                              _debouncedUpdate(
                                uid: uid,
                                date: _selected,
                                fieldPath: 'evening.improve',
                                value: v.isEmpty ? null : v,
                                alsoAggregateTo: 'evening.summary',
                                aggregateBuilder: _aggregateEvening,
                              );
                            }),
                            const SizedBox(height: 8),
                            _labeledField('Wof\u{00FC}r bin ich dankbar?', _eveningGratefulCtrl, focusNode: _eveningGratefulNode, onChanged: (v) {
                              _debouncedUpdate(
                                uid: uid,
                                date: _selected,
                                fieldPath: 'evening.gratitude',
                                value: v.isEmpty ? null : v,
                                alsoAggregateTo: 'evening.summary',
                                aggregateBuilder: _aggregateEvening,
                              );
                            }),
                            const SizedBox(height: 12),
                            ReflectoRatingBar(
  focus: (_ratingFocusLocal ?? focusFromSnap),
  energy: (_ratingEnergyLocal ?? energyFromSnap),
  happiness: (_ratingHappinessLocal ?? happinessFromSnap),
                              onFocus: (v) {
                                setState(() => _ratingFocusLocal = v);
                                final updater = ref.read(updateDayFieldProvider);
                                updater(uid, _selected, 'ratings.focus', v)
                                    .then((_) => _maybeShowSavedSnack())
                                    .catchError((_) {});
                              },
                              onEnergy: (v) {
                                setState(() => _ratingEnergyLocal = v);
                                final updater = ref.read(updateDayFieldProvider);
                                updater(uid, _selected, 'ratings.energy', v)
                                    .then((_) => _maybeShowSavedSnack())
                                    .catchError((_) {});
                              },
                              onHappiness: (v) {
                                setState(() => _ratingHappinessLocal = v);
                                final updater = ref.read(updateDayFieldProvider);
                                updater(uid, _selected, 'ratings.happiness', v)
                                    .then((_) => _maybeShowSavedSnack())
                                    .catchError((_) {});
                              },
),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Planning for tomorrow
                      ReflectoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('\u{1F5D3} Planung f\u{00FC}r morgen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            const Text('Definiere klare Ziele und einen ruhigen Fokus fÃ¼r morgen.'),
                            const SizedBox(height: 12),
                            const Text('Drei Hauptziele', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            for (var i = 0; i < 3; i++) ...[
                              _labeledField('Ziel ${i + 1}', _goalCtrls[i], maxLines: 1, focusNode: _goalNodes[i], onChanged: (v) {
                                _saveGoals(uid, tomorrow);
                              }),
                              const SizedBox(height: 8),
                            ],
                            const SizedBox(height: 4),
                            const Text('Drei To-dos', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            for (var i = 0; i < 3; i++) ...[
                              _labeledField('To-do ${i + 1}', _todoCtrls[i], maxLines: 1, focusNode: _todoNodes[i], onChanged: (v) {
                                _saveTodos(uid, tomorrow);
                              }),
                              const SizedBox(height: 8),
                            ],
                            _labeledField('Reflexion', _attitudeCtrl, maxLines: 1, focusNode: _attitudeNode, onChanged: (v) {
                              _debouncedUpdate(
                                uid: uid,
                                date: tomorrow,
                                fieldPath: 'planning.reflection',
                                value: v.isEmpty ? null : v,
                              );
                            }),
                            const SizedBox(height: 8),
                            _labeledField('Freies Notizfeld', _notesCtrl, maxLines: null, focusNode: _notesNode, onChanged: (v) {
                              _debouncedUpdate(
                                uid: uid,
                                date: tomorrow,
                                fieldPath: 'planning.notes',
                                value: v.isEmpty ? null : v,
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Morning reflection
                      ReflectoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('\u{1F305} Morgenreflexion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            const Text('Starte bewusst und fokussiert in den Tag.'),
                            const SizedBox(height: 12),
                            _labeledField('Wie f\u{00FC}hle ich mich heute?', _morningFeelingCtrl, focusNode: _morningFeelingNode, onChanged: (v) {
                              _debouncedUpdate(
                                uid: uid,
                                date: _selected,
                                fieldPath: 'morning.mood',
                                value: v.isEmpty ? null : v,
                                alsoAggregateTo: 'morning.summary',
                                aggregateBuilder: _aggregateMorning,
                              );
                            }),
                            const SizedBox(height: 8),
                            _labeledField('Was macht den Tag heute gut?', _morningGoodCtrl, focusNode: _morningGoodNode, onChanged: (v) {
                              _debouncedUpdate(
                                uid: uid,
                                date: _selected,
                                fieldPath: 'morning.goodThing',
                                value: v.isEmpty ? null : v,
                                alsoAggregateTo: 'morning.summary',
                                aggregateBuilder: _aggregateMorning,
                              );
                            }),
                            const SizedBox(height: 8),
                            _labeledField('Worauf will ich heute besonders achten?', _morningFocusCtrl, focusNode: _morningFocusNode, onChanged: (v) {
                              _debouncedUpdate(
                                uid: uid,
                                date: _selected,
                                fieldPath: 'morning.focus',
                                value: v.isEmpty ? null : v,
                                alsoAggregateTo: 'morning.summary',
                                aggregateBuilder: _aggregateMorning,
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _labeledField(String label, TextEditingController controller, {int? maxLines = 1, FocusNode? focusNode, required ValueChanged<String> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          textInputAction: (maxLines != null && maxLines == 1) ? TextInputAction.next : TextInputAction.newline,
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _aggregateEvening() {
    String part(String title, String v) => v.isEmpty ? '' : '$title: $v';
    final parts = [
      part('Gut', _eveningGoodCtrl.text.trim()),
      part('Gelernt', _eveningLearnedCtrl.text.trim()),
      part('Besser', _eveningBetterCtrl.text.trim()),
      part('Dankbar', _eveningGratefulCtrl.text.trim()),
    ].where((e) => e.isNotEmpty).toList();
    return parts.join(' | ');
  }

  
  Widget _emojiBar(BuildContext context, {required String label, required List<String> emojis, required int? value, required ValueChanged<int> onSelect}) {
    const active = Color(0xFF2E7DFA);
    const inactive = Color(0xFFD9E3F0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (var i = 1; i <= emojis.length; i++)
              GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  opacity: (value ?? 0) >= i ? 1.0 : 0.6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: (value ?? 0) >= i ? active.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: (value ?? 0) >= i ? active : inactive),
                    ),
                    child: Text(emojis[i-1], style: const TextStyle(fontSize: 18, fontFamilyFallback: ['Segoe UI Emoji','Apple Color Emoji','Noto Color Emoji'])),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _aggregateMorning() {
    String part(String title, String v) => v.isEmpty ? '' : '$title: $v';
    final parts = [
      part('GefÃ¼hl', _morningFeelingCtrl.text.trim()),
      part('Gut heute', _morningGoodCtrl.text.trim()),
      part('Fokus', _morningFocusCtrl.text.trim()),
    ].where((e) => e.isNotEmpty).toList();
    return parts.join(' | ');
  }

  void _saveGoals(String uid, DateTime date) {
    final list = _goalCtrls.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList();
    _debouncedUpdate(
      uid: uid,
      date: date,
      fieldPath: 'planning.goals',
      value: list.isEmpty ? null : list,
    );
  }

  void _saveTodos(String uid, DateTime date) {
    final list = _todoCtrls.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList();
    _debouncedUpdate(
      uid: uid,
      date: date,
      fieldPath: 'planning.todos',
      value: list.isEmpty ? null : list,
    );
  }
}














