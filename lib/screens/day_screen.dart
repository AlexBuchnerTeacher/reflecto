import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;

import '../widgets/reflecto_card.dart';
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
  bool _expMorning = false;
  // ignore: unused_field
  bool _expPlanning = false;
  bool _expEvening = false;

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
    _setDefaultExpandedForDate();
  }

  void _setDefaultExpandedForDate() {
    final today = DateTime.now();
    final selected = _selected;
    final isToday = DateUtils.isSameDay(selected, today);
    final isFuture = selected.isAfter(DateTime(today.year, today.month, today.day));
    if (isFuture) {
      _expMorning = false;
      _expEvening = false;
      _expPlanning = true;
    } else if (isToday) {
      if (DateTime.now().hour < 12) {
        _expMorning = true;
        _expPlanning = false;
        _expEvening = false;
      } else {
        _expMorning = false;
        _expPlanning = false;
        _expEvening = true;
      }
    } else {
      _expMorning = false;
      _expPlanning = false;
      _expEvening = true;
    }
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
    if (cur is T) return cur;
    return null;
  }

  List<String> _normalizeStringSlots(dynamic src, {int len = 3}) {
    final out = List<String>.filled(len, '');
    if (src is List) {
      for (var i = 0; i < len && i < src.length; i++) {
        out[i] = src[i]?.toString() ?? '';
      }
    } else if (src is Map) {
      for (var i = 0; i < len; i++) {
        final v = src['$i'];
        if (v != null) out[i] = v.toString();
      }
    }
    return out;
  }

  List<bool> _normalizeBoolSlots(dynamic src, {int len = 3}) {
    final out = List<bool>.filled(len, false);
    if (src is List) {
      for (var i = 0; i < len && i < src.length; i++) {
        out[i] = src[i] == true;
      }
    } else if (src is Map) {
      for (var i = 0; i < len; i++) {
        final v = src['$i'];
        out[i] = v == true;
      }
    }
    return out;
  }

  void _setCtrl(TextEditingController c, String? v, {FocusNode? focusNode}) {
    if (v == null) return; // kein Ãœberschreiben mit leer bei fehlendem Feld
    if (focusNode != null && focusNode.hasFocus) return; // wÃ¤hrend aktiver Eingabe nicht Ã¼berschreiben
    if (c.text != v) {
      final selection = TextSelection.collapsed(offset: v.length);
      c.value = c.value.copyWith(text: v, selection: selection, composing: TextRange.empty);
    }
  }

  String _formatDateLabel(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}';
  }

  Widget _statusChip({required bool pending, required bool fromCache}) {
    String text;
    Color color;
    if (pending) {
      text = 'Synchronisiereâ€¦';
      color = const Color(0xFF2E7DFA).withValues(alpha: 0.10);
    } else if (fromCache) {
      text = 'Offline';
      color = const Color(0xFFE57A00).withValues(alpha: 0.10);
    } else {
      text = 'âœ“ Gespeichert';
      color = const Color(0xFF4CAF50).withValues(alpha: 0.10);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E3F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamilyFallback: ['Segoe UI Emoji','Apple Color Emoji','Noto Color Emoji'],
        ),
      ),
    );
  }

  Widget _progressChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E3F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamilyFallback: ['Segoe UI Emoji','Apple Color Emoji','Noto Color Emoji'],
        ),
      ),
    );
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

        int? readRatingIn(Map<String, dynamic>? m, String container, String key) {
          final nested = m?[container];
          if (nested is Map<String, dynamic>) {
            final v = nested[key];
            if (v is num) return v.toInt();
          }
          return null;
        }
        final morningMoodFromSnap =
            readRatingIn(todayData, 'ratingsMorning', 'mood') ?? readRatingIn(todayData, 'ratings', 'mood');
        final morningEnergyFromSnap =
            readRatingIn(todayData, 'ratingsMorning', 'energy') ?? readRatingIn(todayData, 'ratings', 'energy');
        final morningFocusFromSnap =
            readRatingIn(todayData, 'ratingsMorning', 'focus') ?? readRatingIn(todayData, 'ratings', 'focus');

        final eveningMoodFromSnap =
            readRatingIn(todayData, 'ratingsEvening', 'mood') ?? readRatingIn(todayData, 'ratings', 'mood');
        final eveningFocusFromSnap =
            readRatingIn(todayData, 'ratingsEvening', 'focus') ?? readRatingIn(todayData, 'ratings', 'focus');
        final eveningEnergyFromSnap =
            readRatingIn(todayData, 'ratingsEvening', 'energy') ?? readRatingIn(todayData, 'ratings', 'energy');
        final eveningHappinessFromSnap =
            readRatingIn(todayData, 'ratingsEvening', 'happiness') ?? readRatingIn(todayData, 'ratings', 'happiness');

        _ratingFocusLocal ??= eveningFocusFromSnap;
        _ratingEnergyLocal ??= eveningEnergyFromSnap;
        _ratingHappinessLocal ??= eveningHappinessFromSnap;

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
        final tPending = tDoc.value?.metadata.hasPendingWrites ?? false;
        final tFromCache = tDoc.value?.metadata.isFromCache ?? false;

        // Migrations: normalize arrays to fixed 3-slot shape (only when not pending & not yet migrated)
        final migratedV1 = (todayData?['migratedV1'] == true);
        if (!pending && !migratedV1) {
          final gSrc = _readAt<dynamic>(todayData, ['planning', 'goals']);
          final gNorm = _normalizeStringSlots(gSrc);
          final gAllEmpty = gNorm.every((e) => e.isEmpty);
          _debouncedUpdate(
            uid: uid,
            date: _selected,
            fieldPath: 'planning.goals',
            value: gAllEmpty ? null : gNorm,
          );

          final tSrc = _readAt<dynamic>(todayData, ['planning', 'todos']);
          final tNorm = _normalizeStringSlots(tSrc);
          final tAllEmpty = tNorm.every((e) => e.isEmpty);
          _debouncedUpdate(
            uid: uid,
            date: _selected,
            fieldPath: 'planning.todos',
            value: tAllEmpty ? null : tNorm,
          );

          final ecSrc = _readAt<dynamic>(todayData, ['evening', 'todosCompletion']);
          final ecNorm = _normalizeBoolSlots(ecSrc);
          _debouncedUpdate(
            uid: uid,
            date: _selected,
            fieldPath: 'evening.todosCompletion',
            value: ecNorm,
          );

          final gcSrc = _readAt<dynamic>(todayData, ['evening', 'goalsCompletion']);
          final gcNorm = _normalizeBoolSlots(gcSrc);
          _debouncedUpdate(
            uid: uid,
            date: _selected,
            fieldPath: 'evening.goalsCompletion',
            value: gcNorm,
          );
          // mark as migrated
          _debouncedUpdate(
            uid: uid,
            date: _selected,
            fieldPath: 'migratedV1',
            value: true,
          );
        }

        final tMigratedV1 = (tData?['migratedV1'] == true);
        if (!tPending && !tMigratedV1) {
          final tgSrc = _readAt<dynamic>(tData, ['planning', 'goals']);
          final tgNorm = _normalizeStringSlots(tgSrc);
          final tgAllEmpty = tgNorm.every((e) => e.isEmpty);
          _debouncedUpdate(
            uid: uid,
            date: tomorrow,
            fieldPath: 'planning.goals',
            value: tgAllEmpty ? null : tgNorm,
          );

          final ttSrc = _readAt<dynamic>(tData, ['planning', 'todos']);
          final ttNorm = _normalizeStringSlots(ttSrc);
          final ttAllEmpty = ttNorm.every((e) => e.isEmpty);
          _debouncedUpdate(
            uid: uid,
            date: tomorrow,
            fieldPath: 'planning.todos',
            value: ttAllEmpty ? null : ttNorm,
          );
          // mark as migrated on tomorrow doc as well
          _debouncedUpdate(
            uid: uid,
            date: tomorrow,
            fieldPath: 'migratedV1',
            value: true,
          );
        }
        final goalsDyn = _readAt<List>(tData, ['planning', 'goals']);
        final todosDyn = _readAt<List>(tData, ['planning', 'todos']);
        final goals = (goalsDyn ?? const <dynamic>[]).map((e) => e?.toString() ?? '').toList();
        final todos = (todosDyn ?? const <dynamic>[]).map((e) => e?.toString() ?? '').toList();
        for (var i = 0; i < 3; i++) {
          _setCtrl(_goalCtrls[i], i < goals.length ? goals[i] : '', focusNode: _goalNodes[i]);
          _setCtrl(_todoCtrls[i], i < todos.length ? todos[i] : '', focusNode: _todoNodes[i]);
        }
        _setCtrl(_attitudeCtrl, _readAt<String>(tData, ['planning', 'reflection']), focusNode: _attitudeNode);
        _setCtrl(_notesCtrl, _readAt<String>(tData, ['planning', 'notes']), focusNode: _notesNode);

        // Review der Planung fÃ¼r den ausgewÃ¤hlten Tag
        final curGoals = (_readAt<List>(todayData, ['planning', 'goals']) ?? []).cast<String>();
        final curTodos = (_readAt<List>(todayData, ['planning', 'todos']) ?? []).cast<String>();
        final completionDyn = _readAt<List>(todayData, ['evening', 'todosCompletion']) ?? const <dynamic>[];
        final completion = completionDyn.map((e) => e == true).toList();
        final goalsCompletionDyn = _readAt<List>(todayData, ['evening', 'goalsCompletion']) ?? const <dynamic>[];
        final goalsCompletion = goalsCompletionDyn.map((e) => e == true).toList();
        final desiredGoalLen = curGoals.length.clamp(0, 3);
        if (_yesterdayGoalChecks.isEmpty || _yesterdayGoalChecks.length != desiredGoalLen) {
          _yesterdayGoalChecks = List<bool>.generate(desiredGoalLen, (i) => i < goalsCompletion.length ? goalsCompletion[i] : false);
        } else if (!pending) {
          // Snapshot dominiert bei nicht-pendenden Writes: synchronisiere Werte live (Cross-Device-Updates)
          for (var i = 0; i < desiredGoalLen; i++) {
            final snapVal = i < goalsCompletion.length ? goalsCompletion[i] : false;
            if (_yesterdayGoalChecks[i] != snapVal) {
              _yesterdayGoalChecks[i] = snapVal;
            }
          }
        }
        final desiredTodoLen = curTodos.length.clamp(0, 3);
        if (_yesterdayTodoChecks.isEmpty || _yesterdayTodoChecks.length != desiredTodoLen) {
          _yesterdayTodoChecks = List<bool>.generate(desiredTodoLen, (i) => i < completion.length ? completion[i] : false);
        } else if (!pending) {
          for (var i = 0; i < desiredTodoLen; i++) {
            final snapVal = i < completion.length ? completion[i] : false;
            if (_yesterdayTodoChecks[i] != snapVal) {
              _yesterdayTodoChecks[i] = snapVal;
            }
          }
        }

        // Sichtbare Indizes nur fÃ¼r nicht-leere Ziele/To-dos (max 3)
        final visibleGoalIdx = List<int>.generate(desiredGoalLen, (i) => i)
            .where((i) => curGoals[i].trim().isNotEmpty)
            .toList();
        final visibleTodoIdx = List<int>.generate(desiredTodoLen, (i) => i)
            .where((i) => curTodos[i].trim().isNotEmpty)
            .toList();

        final isToday = DateUtils.isSameDay(_selected, DateTime.now());

        final aggPending = pending || tPending;
        final aggFromCache = fromCache && tFromCache;

        return Scaffold(
          appBar: AppBar(
            title: Text('Tagesansicht - ${_formatDateLabel(_selected)}${isToday ? ' (heute)' : ''}'),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _statusChip(pending: aggPending, fromCache: aggFromCache),
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
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Gestern',
                              onPressed: () => setState(() {
                                _selected = _selected.subtract(const Duration(days: 1));
                                _setDefaultExpandedForDate();
                              }),
                              icon: const Icon(Icons.chevron_left_rounded),
                            ),
                            if (!isToday)
                              TextButton(
                                onPressed: () {
                                  final t = DateTime.now();
                                  setState(() {
                                    _selected = DateTime(t.year, t.month, t.day);
                                    _setDefaultExpandedForDate();
                                  });
                                },
                                child: const Text('Heute'),
                              ),
                            IconButton(
                              tooltip: 'Morgen',
                              onPressed: () => setState(() {
                                _selected = _selected.add(const Duration(days: 1));
                                _setDefaultExpandedForDate();
                              }),
                              icon: const Icon(Icons.chevron_right_rounded),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Morning reflection (today)
                        ReflectoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'ðŸŒ… Morgenreflexion',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        fontFamilyFallback: ['Segoe UI Emoji','Apple Color Emoji','Noto Color Emoji'],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: _progressChip(
                                      'Felder '
                                      '${[_morningFeelingCtrl.text.trim(), _morningGoodCtrl.text.trim(), _morningFocusCtrl.text.trim()].where((e) => e.isNotEmpty).length}/3'
                                      ' Â· Ratings '
                                      '${[morningMoodFromSnap, morningEnergyFromSnap, morningFocusFromSnap].where((e) => e != null).length}/3',
                                      ),
                                    ),
                                  ),
                                  // Statuschip entfÃ¤llt (nur noch global in AppBar)
                                  IconButton(
                                    tooltip: _expMorning ? 'Einklappen' : 'Aufklappen',
                                    icon: Icon(_expMorning ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                                    onPressed: () => setState(() => _expMorning = !_expMorning),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              AnimatedCrossFade(
                                crossFadeState: _expMorning ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                duration: const Duration(milliseconds: 200),
                                firstChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 12),
                                    _emojiBar(
                                      context,
                                      label: 'Stimmung',
                                      emojis: const ['ðŸ˜”','ðŸ˜','ðŸ™‚','ðŸ˜Š','ðŸ˜Ž'],
                                      value: morningMoodFromSnap,
                                      onSelect: (v) {
                                        final updater = ref.read(updateDayFieldProvider);
                                        updater(uid, _selected, 'ratingsMorning.mood', v).then((_) => _maybeShowSavedSnack());
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _emojiBar(
                                      context,
                                      label: 'Energie',
                                      emojis: const ['ðŸ”‹','ðŸ”‹','ðŸ”‹','ðŸ”‹','ðŸ”‹'],
                                      value: morningEnergyFromSnap,
                                      onSelect: (v) {
                                        final updater = ref.read(updateDayFieldProvider);
                                        updater(uid, _selected, 'ratingsMorning.energy', v).then((_) => _maybeShowSavedSnack());
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _emojiBar(
                                      context,
                                      label: 'Fokus',
                                      emojis: const ['ðŸŽ¯','ðŸŽ¯','ðŸŽ¯','ðŸŽ¯','ðŸŽ¯'],
                                      value: morningFocusFromSnap,
                                      onSelect: (v) {
                                        final updater = ref.read(updateDayFieldProvider);
                                        updater(uid, _selected, 'ratingsMorning.focus', v).then((_) => _maybeShowSavedSnack());
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _labeledField('Wie fÃ¼hle ich mich heute?', _morningFeelingCtrl, minLines: 1, maxLines: 2, expandable: true, focusNode: _morningFeelingNode, onChanged: (v) {
                                      _debouncedUpdate(
                                        uid: uid,
                                        date: _selected,
                                        fieldPath: 'morning.mood',
                                        value: v,
                                        alsoAggregateTo: 'morningAggregate',
                                        aggregateBuilder: _aggregateMorning,
                                      );
                                    }),
                                    const SizedBox(height: 12),
                                    _labeledField('Was macht den Tag heute gut?', _morningGoodCtrl, minLines: 1, maxLines: 2, expandable: true, focusNode: _morningGoodNode, onChanged: (v) {
                                      _debouncedUpdate(
                                        uid: uid,
                                        date: _selected,
                                        fieldPath: 'morning.goodThing',
                                        value: v,
                                        alsoAggregateTo: 'morningAggregate',
                                        aggregateBuilder: _aggregateMorning,
                                      );
                                    }),
                                    const SizedBox(height: 12),
                                  _labeledField('Worauf will ich heute besonders achten?', _morningFocusCtrl, minLines: 1, maxLines: 2, expandable: true, focusNode: _morningFocusNode, onChanged: (v) {
                                    _debouncedUpdate(
                                      uid: uid,
                                      date: _selected,
                                      fieldPath: 'morning.focus',
                                      value: v,
                                      alsoAggregateTo: 'morningAggregate',
                                      aggregateBuilder: _aggregateMorning,
                                    );
                                  }),
                                  const SizedBox(height: 12),
                                  const Text('Tagesziele und To-dos', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 12),
                                  if (visibleGoalIdx.isNotEmpty) ...[
                                    const Text('Ziele', style: TextStyle(color: Colors.black54)),
                                    const SizedBox(height: 4),
                                    for (final i in visibleGoalIdx)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text('â€¢ ${curGoals[i]}'),
                                      ),
                                  ] else ...[
                                    const Text('Keine Ziele vorhanden.', style: TextStyle(color: Colors.black54)),
                                  ],
                                  const SizedBox(height: 12),
                                  if (visibleTodoIdx.isNotEmpty) ...[
                                    const Text('To-dos', style: TextStyle(color: Colors.black54)),
                                    const SizedBox(height: 4),
                                    for (final i in visibleTodoIdx)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text('â€¢ ${curTodos[i]}'),
                                      ),
                                  ] else ...[
                                    const Text('Keine To-dos vorhanden.', style: TextStyle(color: Colors.black54)),
                                  ],
                                ],
                              ),
                              secondChild: const SizedBox.shrink(),
                            ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Evening reflection (today)
                        ReflectoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'ðŸŒ‡ Abendreflexion',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        fontFamilyFallback: ['Segoe UI Emoji','Apple Color Emoji','Noto Color Emoji'],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: _progressChip(
                                        'Ziele '
                                        '${visibleGoalIdx.where((i) => _yesterdayGoalChecks[i]).length}/${visibleGoalIdx.length}'
                                        ' Â· To-dos '
                                        '${visibleTodoIdx.where((i) => _yesterdayTodoChecks[i]).length}/${visibleTodoIdx.length}'
                                        ' Â· Felder '
                                        '${[_eveningGoodCtrl.text.trim(), _eveningLearnedCtrl.text.trim(), _eveningBetterCtrl.text.trim(), _eveningGratefulCtrl.text.trim()].where((e) => e.isNotEmpty).length}/4',
                                      ),
                                    ),
                                  ),
                                  // Statuschip entfÃ¤llt (nur noch global in AppBar)
                                  IconButton(
                                    tooltip: _expEvening ? 'Einklappen' : 'Aufklappen',
                                    icon: Icon(_expEvening ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                                    onPressed: () => setState(() => _expEvening = !_expEvening),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const SizedBox(height: 4),
                              AnimatedCrossFade(
                                crossFadeState: _expEvening ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                duration: const Duration(milliseconds: 200),
                                firstChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Reflektiere deinen Tag und schlieÃŸe ihn bewusst ab.'),
                                    const SizedBox(height: 12),
                                     const SizedBox(height: 12),
                                    const Text('RÃ¼ckblick auf deine Planung', style: TextStyle(fontWeight: FontWeight.w600)),
                                     const SizedBox(height: 12),
                                    if (curGoals.isNotEmpty) ...[
                                      const Text('Ziele', style: TextStyle(color: Colors.black54)),
                                      const SizedBox(height: 4),
                                      for (var i = 0; i < curGoals.length && i < 3; i++)
                                        CheckboxListTile(
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                          value: _yesterdayGoalChecks[i],
                                          onChanged: (v) async {
                                            final val = v ?? false;
                                            setState(() => _yesterdayGoalChecks[i] = val);
                                            try {
                                              final updater = ref.read(updateDayFieldProvider);
                                              await updater(uid, _selected, 'evening.goalsCompletion', List<bool>.from(_yesterdayGoalChecks));
                                              _maybeShowSavedSnack();
                                            } catch (_) {}
                                          },
                                          title: Text(curGoals[i]),
                                          controlAffinity: ListTileControlAffinity.leading,
                                        ),
                                    ] else
                                      const Text('Keine Ziele von gestern vorhanden.'),
                                  const SizedBox(height: 12),
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
                                              final updater = ref.read(updateDayFieldProvider);
                                              await updater(uid, _selected, 'evening.todosCompletion', List<bool>.from(_yesterdayTodoChecks));
                                              _maybeShowSavedSnack();
                                            } catch (_) {}
                                          },
                                          title: Opacity(
                                            opacity: _yesterdayTodoChecks[i] ? 0.6 : 1.0,
                                            child: Text(curTodos[i]),
                                          ),
                                          controlAffinity: ListTileControlAffinity.leading,
                                        ),
                                    ] else
                                      const Text('Keine To-dos von gestern vorhanden.'),
                                    const SizedBox(height: 12),

                                    _labeledField('Was lief heute gut?', _eveningGoodCtrl, minLines: 1, maxLines: 2, expandable: true, focusNode: _eveningGoodNode, onChanged: (v) {
                                      _debouncedUpdate(
                                        uid: uid,
                                        date: _selected,
                                        fieldPath: 'evening.good',
                                        value: v.isEmpty ? null : v,
                                        alsoAggregateTo: 'evening.summary',
                                        aggregateBuilder: _aggregateEvening,
                                      );
                                    }),
                                    const SizedBox(height: 12),
                                    _labeledField('Was habe ich gelernt oder erkannt?', _eveningLearnedCtrl, minLines: 1, maxLines: 2, expandable: true, focusNode: _eveningLearnedNode, onChanged: (v) {
                                      _debouncedUpdate(
                                        uid: uid,
                                        date: _selected,
                                        fieldPath: 'evening.learned',
                                        value: v.isEmpty ? null : v,
                                        alsoAggregateTo: 'evening.summary',
                                        aggregateBuilder: _aggregateEvening,
                                      );
                                    }),
                                    const SizedBox(height: 12),
                                    _labeledField('Was hÃ¤tte besser laufen kÃ¶nnen?', _eveningBetterCtrl, minLines: 1, maxLines: 2, expandable: true, focusNode: _eveningBetterNode, onChanged: (v) {
                                      _debouncedUpdate(
                                        uid: uid,
                                        date: _selected,
                                        fieldPath: 'evening.improve',
                                        value: v.isEmpty ? null : v,
                                        alsoAggregateTo: 'evening.summary',
                                        aggregateBuilder: _aggregateEvening,
                                      );
                                    }),
                                    const SizedBox(height: 12),
                                    _labeledField('WofÃ¼r bin ich dankbar?', _eveningGratefulCtrl, minLines: 1, maxLines: 2, expandable: true, focusNode: _eveningGratefulNode, onChanged: (v) {
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
                                    _emojiBar(
                                      context,
                                      label: 'Stimmung',
                                      emojis: const ['ðŸ˜”','ðŸ˜','ðŸ™‚','ðŸ˜Š','ðŸ˜Ž'],
                                      value: eveningMoodFromSnap,
                                      onSelect: (v) {
                                        final updater = ref.read(updateDayFieldProvider);
                                        updater(uid, _selected, 'ratingsEvening.mood', v)
                                            .then((_) => _maybeShowSavedSnack());
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _emojiBar(
                                      context,
                                      label: 'Energie',
                                      emojis: const ['ðŸ”‹','ðŸ”‹','ðŸ”‹','ðŸ”‹','ðŸ”‹'],
                                      value: eveningEnergyFromSnap,
                                      onSelect: (v) {
                                        final updater = ref.read(updateDayFieldProvider);
                                        updater(uid, _selected, 'ratingsEvening.energy', v)
                                            .then((_) => _maybeShowSavedSnack());
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _emojiBar(
                                      context,
                                      label: 'Zufriedenheit',
                                      emojis: const ['â­','â­','â­','â­','â­'],
                                      value: eveningHappinessFromSnap,
                                      onSelect: (v) {
                                        final updater = ref.read(updateDayFieldProvider);
                                        updater(uid, _selected, 'ratingsEvening.happiness', v)
                                            .then((_) => _maybeShowSavedSnack());
                                      },
                                    ),
                                  ],
                                ),
                                secondChild: const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // Planning for tomorrow (collapsible)
                        ReflectoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      '\u{1F5D3} Planung fÃ¼r morgen',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        fontFamilyFallback: ['Segoe UI Emoji','Apple Color Emoji','Noto Color Emoji'],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: _progressChip(
                                        'Ziele '
                                        '${_goalCtrls.map((c)=>c.text.trim()).where((e)=>e.isNotEmpty).length}/3'
                                        ' Â· To-dos '
                                        '${_todoCtrls.map((c)=>c.text.trim()).where((e)=>e.isNotEmpty).length}/3',
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      final todayGoalsSrc = _readAt<List>(todayData, ['planning', 'goals']) ?? const [];
                                      final todayTodosSrc = _readAt<List>(todayData, ['planning', 'todos']) ?? const [];
                                      final todayGoals = _normalizeStringSlots(todayGoalsSrc);
                                      final todayTodos = _normalizeStringSlots(todayTodosSrc);
                                      setState(() {
                                        for (var i = 0; i < 3; i++) {
                                          _goalCtrls[i].text = todayGoals[i];
                                          _todoCtrls[i].text = todayTodos[i];
                                        }
                                      });
                                      _saveGoals(uid, tomorrow);
                                      _saveTodos(uid, tomorrow);
                                    },
                                    icon: const Icon(Icons.content_copy_rounded, size: 18),
                                    label: const Text('Aus heute übernehmen'),
                                  ),
                                  IconButton(
                                    tooltip: _expPlanning ? 'Einklappen' : 'Aufklappen',
                                    icon: Icon(_expPlanning ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                                    onPressed: () => setState(() => _expPlanning = !_expPlanning),
                                  ),
                                ],
                              ),
                              AnimatedCrossFade(
                                crossFadeState: _expPlanning ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                duration: const Duration(milliseconds: 200),
                                firstChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    const Text('Definiere klare Ziele und einen ruhigen Fokus fÃ¼r morgen.'),
                                    const SizedBox(height: 12),
                                    const Text('Drei Hauptziele', style: TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 12),
                                    _labeledField('Ziel 1', _goalCtrls[0], minLines: 1, maxLines: 2, focusNode: _goalNodes[0], onChanged: (v) {
                                      _saveGoals(uid, tomorrow);
                                    }),
                                    const SizedBox(height: 12),
                                    _labeledField('Ziel 2', _goalCtrls[1], minLines: 1, maxLines: 2, focusNode: _goalNodes[1], onChanged: (v) {
                                      _saveGoals(uid, tomorrow);
                                    }),
                                    const SizedBox(height: 12),
                                    _labeledField('Ziel 3', _goalCtrls[2], minLines: 1, maxLines: 2, focusNode: _goalNodes[2], onChanged: (v) {
                                      _saveGoals(uid, tomorrow);
                                    }),
                                    const SizedBox(height: 4),
                                    const Text('Drei To-dos', style: TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 12),
                                    _labeledField('To-do 1', _todoCtrls[0], minLines: 1, maxLines: 2, focusNode: _todoNodes[0], onChanged: (v) {
                                      _saveTodos(uid, tomorrow);
                                    }),
                                    const SizedBox(height: 12),
                                    _labeledField('To-do 2', _todoCtrls[1], minLines: 1, maxLines: 2, focusNode: _todoNodes[1], onChanged: (v) {
                                      _saveTodos(uid, tomorrow);
                                    }),
                                    const SizedBox(height: 12),
                                    _labeledField('To-do 3', _todoCtrls[2], minLines: 1, maxLines: 2, focusNode: _todoNodes[2], onChanged: (v) {
                                      _saveTodos(uid, tomorrow);
                                    }),
                                    const SizedBox(height: 12),
                                    _labeledField('Reflexion', _attitudeCtrl, minLines: 1, maxLines: 2, expandable: true, focusNode: _attitudeNode, onChanged: (v) {
                                      _debouncedUpdate(
                                        uid: uid,
                                        date: tomorrow,
                                        fieldPath: 'planning.reflection',
                                        value: v.isEmpty ? null : v,
                                      );
                                    }),
                                    const SizedBox(height: 12),
                                    _labeledField('Freies Notizfeld', _notesCtrl, minLines: 1, maxLines: 2, expandable: true, focusNode: _notesNode, onChanged: (v) {
                                      _debouncedUpdate(
                                        uid: uid,
                                        date: tomorrow,
                                        fieldPath: 'planning.notes',
                                        value: v.isEmpty ? null : v,
                                      );
                                    }),
                                  ],
                                ),
                                secondChild: const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
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

  final Map<TextEditingController, bool> _expandedFields = {};

  Widget _labeledField(String label, TextEditingController controller, {int? maxLines = 1, int? minLines, int? maxLength, bool expandable = false, FocusNode? focusNode, required ValueChanged<String> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        if (expandable)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: const Size(0, 0)),
              onPressed: () => setState(() => _expandedFields[controller] = !(_expandedFields[controller] ?? false)),
              child: Builder(
                builder: (context) {
                  final expanded = _expandedFields[controller] ?? false;
                  final textLen = controller.text.trim().length;
                  final show = textLen >= 50 || expanded;
                  return show ? Text(expanded ? 'Weniger anzeigen' : 'Mehr anzeigen') : const SizedBox.shrink();
                },
              ),
            ),
          ),
        TextField(
          controller: controller,
          focusNode: focusNode,
          minLines: minLines,
          maxLines: (expandable && (_expandedFields[controller] ?? false)) ? null : maxLines,
          maxLength: maxLength,
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
              Semantics(
                label: '$label: $i von ${emojis.length}',
                button: true,
                selected: (value ?? 0) >= i,
                child: GestureDetector(
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
                      child: Text(
                        emojis[i - 1],
                        style: const TextStyle(fontSize: 18, fontFamilyFallback: ['Segoe UI Emoji','Apple Color Emoji','Noto Color Emoji']),
                      ),
                    ),
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
    final list = List<String>.generate(3, (i) => _goalCtrls[i].text.trim());
    final allEmpty = list.every((e) => e.isEmpty);
    _debouncedUpdate(
      uid: uid,
      date: date,
      fieldPath: 'planning.goals',
      value: allEmpty ? null : list,
    );
  }

  void _saveTodos(String uid, DateTime date) {
    final list = List<String>.generate(3, (i) => _todoCtrls[i].text.trim());
    final allEmpty = list.every((e) => e.isEmpty);
    _debouncedUpdate(
      uid: uid,
      date: date,
      fieldPath: 'planning.todos',
      value: allEmpty ? null : list,
    );
  }
}
