import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/entry_providers.dart';
import '../controllers/day_controllers.dart';
import '../logic/day_state_manager.dart';
import '../logic/day_callbacks.dart';
import '../logic/day_sync_logic.dart';
import '../logic/day_view_logic.dart';
import '../ui/day_shell.dart';

class DayScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const DayScreen({super.key, this.initialDate});
  @override
  ConsumerState<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends ConsumerState<DayScreen> {
  late DateTime _selected;
  final DayControllers _controllers = DayControllers();
  final DayStateManager _stateManager = DayStateManager();
  final DaySyncLogic _syncLogic = DaySyncLogic();
  DateTime? _lastPlanningDate;

  DateTime? _lastSnackAt;
  int? _ratingFocusLocal;
  int? _ratingEnergyLocal;
  int? _ratingHappinessLocal;

  // Abend (heute)
  TextEditingController get _eveningGoodCtrl => _controllers.eveningGoodCtrl;
  TextEditingController get _eveningLearnedCtrl =>
      _controllers.eveningLearnedCtrl;
  TextEditingController get _eveningBetterCtrl =>
      _controllers.eveningBetterCtrl;
  TextEditingController get _eveningGratefulCtrl =>
      _controllers.eveningGratefulCtrl;
  FocusNode get _eveningGoodNode => _controllers.eveningGoodNode;
  FocusNode get _eveningLearnedNode => _controllers.eveningLearnedNode;
  FocusNode get _eveningBetterNode => _controllers.eveningBetterNode;
  FocusNode get _eveningGratefulNode => _controllers.eveningGratefulNode;

  // Morgen (heute)
  TextEditingController get _morningFeelingCtrl =>
      _controllers.morningFeelingCtrl;
  TextEditingController get _morningGoodCtrl => _controllers.morningGoodCtrl;
  TextEditingController get _morningFocusCtrl => _controllers.morningFocusCtrl;
  FocusNode get _morningFeelingNode => _controllers.morningFeelingNode;
  FocusNode get _morningGoodNode => _controllers.morningGoodNode;
  FocusNode get _morningFocusNode => _controllers.morningFocusNode;

  // Planung (morgen)
  List<TextEditingController> get _goalCtrls => _controllers.goalCtrls;
  List<TextEditingController> get _todoCtrls => _controllers.todoCtrls;
  TextEditingController get _attitudeCtrl => _controllers.attitudeCtrl;
  TextEditingController get _notesCtrl => _controllers.notesCtrl;
  List<FocusNode> get _goalNodes => _controllers.goalNodes;
  List<FocusNode> get _todoNodes => _controllers.todoNodes;
  FocusNode get _attitudeNode => _controllers.attitudeNode;
  FocusNode get _notesNode => _controllers.notesNode;

  /* Future<void> _carryOverOne({
    required String uid,
    required bool isGoal,
    required String text,
  }) async {
    final t = text.trim();
    if (t.isEmpty) return;
    final ctrls = isGoal ? _goalCtrls : _todoCtrls;
    final existing = ctrls.map((c) => c.text.trim()).toList();
    if (!existing.contains(t)) {
      final emptyIdx = ctrls.indexWhere((c) => c.text.trim().isEmpty);
      if (emptyIdx != -1) {
        ctrls[emptyIdx].text = t;
      } else if (ctrls.isNotEmpty) {
        ctrls[ctrls.length - 1].text = t; // fallback: überschreibe letzten Slot
      }
    }
    final out = ctrls
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final updater = ref.read(updateDayFieldProvider);
    {
      final next = DateTime(
        _selected.year,
        _selected.month,
        _selected.day,
      ).add(const Duration(days: 1));
      await updater(
        uid,
        next,
        isGoal ? 'planning.goals' : 'planning.todos',
        out,
      );
    }
    _maybeShowSavedSnack();
  }
*/

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final init = widget.initialDate ?? now;
    _selected = DateTime(init.year, init.month, init.day);
    _setDefaultExpandedForDate();
  }

  void _setDefaultExpandedForDate() {
    _stateManager.setDefaultExpansionForDate(_selected);
  }

  @override
  void dispose() {
    _syncLogic.dispose();
    _stateManager.dispose();
    _controllers.dispose();
    super.dispose();
  }

  void _maybeShowSavedSnack() {
    final now = DateTime.now();
    if (_lastSnackAt == null ||
        now.difference(_lastSnackAt!).inMilliseconds > 500) {
      _lastSnackAt = now;
      // Aktuell kein visuelles Status-Chip-Feedback mehr hier
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
    _syncLogic.debouncedUpdate(
      ref: ref,
      uid: uid,
      date: date,
      fieldPath: fieldPath,
      value: value,
      alsoAggregateTo: alsoAggregateTo,
      aggregateBuilder: aggregateBuilder,
      onSuccess: _maybeShowSavedSnack,
      onError: () {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Fehler beim Speichern')));
      },
    );
  }

  T? _readAt<T>(Map<String, dynamic>? map, List<String> path) {
    if (map == null) return null;
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

  List<bool> _boolListFromDynamic(dynamic value) {
    if (value is List) {
      return value.map((e) => e == true).toList();
    }
    if (value is Map) {
      final map = value;
      var maxIndex = -1;
      final entries = <int, bool>{};
      for (final entry in map.entries) {
        final keyStr = entry.key.toString();
        final idx = int.tryParse(keyStr);
        if (idx == null || idx < 0) continue;
        entries[idx] = entry.value == true;
        if (idx > maxIndex) {
          maxIndex = idx;
        }
      }
      if (maxIndex < 0) return <bool>[];
      final list = List<bool>.filled(maxIndex + 1, false);
      entries.forEach((idx, val) {
        if (idx >= 0 && idx < list.length) {
          list[idx] = val;
        }
      });
      return list;
    }
    return <bool>[];
  }

  void _setCtrl(TextEditingController c, String? v, {FocusNode? focusNode}) {
    if (v == null) return; // kein Überschreiben mit leer bei fehlendem Feld
    if (focusNode != null && focusNode.hasFocus) {
      return; // während aktiver Eingabe nicht überschreiben
    }
    if (c.text != v) {
      final selection = TextSelection.collapsed(offset: v.length);
      c.value = c.value.copyWith(
        text: v,
        selection: selection,
        composing: TextRange.empty,
      );
    }
  }

  // ignore: unused_element
  String _formatDateLabel(DateTime d) {
    // Deutsches Langformat, z. B. "Freitag, 8. November 2025"
    try {
      // Lazy import via intl already in pubspec
      // Using DateFormat here to avoid extra utils dependency in this file
      // while keeping behavior localized.
      // If intl locale data not initialized, fall back to dd.MM.yyyy
      return DateFormat.yMMMMEEEEd('de_DE').format(d);
    } catch (_) {
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(d.day)}.${two(d.month)}.${d.year}';
    }
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

    _syncLogic.ensureEntry(uid, _selected);
    _syncLogic.ensureEntry(uid, tomorrow);

    return todayDoc.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Fehler: $e'))),
      data: (todaySnap) {
        final todayData = todaySnap.data();
        final pending = todaySnap.metadata.hasPendingWrites;

        final ratings = extractDayRatings(todayData);
        final morningMoodFromSnap = ratings.morningMood;
        final morningEnergyFromSnap = ratings.morningEnergy;
        final morningFocusFromSnap = ratings.morningFocus;
        final eveningMoodFromSnap = ratings.eveningMood;
        final eveningFocusFromSnap = ratings.eveningFocus;
        final eveningEnergyFromSnap = ratings.eveningEnergy;
        final eveningHappinessFromSnap = ratings.eveningHappiness;

        _ratingFocusLocal ??= eveningFocusFromSnap;
        _ratingEnergyLocal ??= eveningEnergyFromSnap;
        _ratingHappinessLocal ??= eveningHappinessFromSnap;

        // Morgen/Abend: aktuelle Werte in Controller schreiben (bei Fokus nicht überschreiben)
        _setCtrl(
          _morningFeelingCtrl,
          _readAt<String>(todayData, ['morning', 'mood']) ??
              _readAt<String>(todayData, ['morning', 'feeling']),
          focusNode: _morningFeelingNode,
        );
        _setCtrl(
          _morningGoodCtrl,
          _readAt<String>(todayData, ['morning', 'goodThing']) ??
              _readAt<String>(todayData, ['morning', 'good']),
          focusNode: _morningGoodNode,
        );
        _setCtrl(
          _morningFocusCtrl,
          _readAt<String>(todayData, ['morning', 'focus']),
          focusNode: _morningFocusNode,
        );

        _setCtrl(
          _eveningGoodCtrl,
          _readAt<String>(todayData, ['evening', 'good']),
          focusNode: _eveningGoodNode,
        );
        _setCtrl(
          _eveningLearnedCtrl,
          _readAt<String>(todayData, ['evening', 'learned']),
          focusNode: _eveningLearnedNode,
        );
        _setCtrl(
          _eveningBetterCtrl,
          _readAt<String>(todayData, ['evening', 'improve']) ??
              _readAt<String>(todayData, ['evening', 'better']),
          focusNode: _eveningBetterNode,
        );
        _setCtrl(
          _eveningGratefulCtrl,
          _readAt<String>(todayData, ['evening', 'gratitude']) ??
              _readAt<String>(todayData, ['evening', 'grateful']),
          focusNode: _eveningGratefulNode,
        );

        // Planung für morgen in Controller schreiben
        final tData = tDoc.value?.data();
        _syncLogic.updateDocCache(_selected, todayData);
        _syncLogic.updateDocCache(tomorrow, tData);

        final goalsDyn = _readAt<List>(tData, ['planning', 'goals']);
        final todosDyn = _readAt<List>(tData, ['planning', 'todos']);
        final goalsFromData = (goalsDyn ?? const <dynamic>[])
            .map((e) => e?.toString().trim() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
        final todosFromData = (todosDyn ?? const <dynamic>[])
            .map((e) => e?.toString().trim() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();

        const minGoals = 1;
        const minTodos = 2;

        final planningDateChanged = _lastPlanningDate == null ||
            !DateUtils.isSameDay(_lastPlanningDate!, tomorrow);
        if (planningDateChanged) {
          // Neues "morgen": alte Planung (Controller-Inhalt) wird verworfen.
          for (final c in _goalCtrls) {
            c.dispose();
          }
          for (final n in _goalNodes) {
            n.dispose();
          }
          for (final c in _todoCtrls) {
            c.dispose();
          }
          for (final n in _todoNodes) {
            n.dispose();
          }
          _goalCtrls.clear();
          _goalNodes.clear();
          _todoCtrls.clear();
          _todoNodes.clear();
        }
        _lastPlanningDate = tomorrow;

        final desiredGoalsLenFromData =
            goalsFromData.isEmpty ? minGoals : goalsFromData.length;
        final desiredTodosLenFromData =
            todosFromData.isEmpty ? minTodos : todosFromData.length;

        final goalsLen = planningDateChanged
            ? desiredGoalsLenFromData
            : (_goalCtrls.length > desiredGoalsLenFromData
                ? _goalCtrls.length
                : desiredGoalsLenFromData);
        final todosLen = planningDateChanged
            ? desiredTodosLenFromData
            : (_todoCtrls.length > desiredTodosLenFromData
                ? _todoCtrls.length
                : desiredTodosLenFromData);

        while (_goalCtrls.length > goalsLen) {
          _goalCtrls.removeLast().dispose();
        }
        while (_goalNodes.length > goalsLen) {
          _goalNodes.removeLast().dispose();
        }
        while (_todoCtrls.length > todosLen) {
          _todoCtrls.removeLast().dispose();
        }
        while (_todoNodes.length > todosLen) {
          _todoNodes.removeLast().dispose();
        }

        _controllers.ensureGoalsLen(goalsLen);
        _controllers.ensureTodosLen(todosLen);

        for (var i = 0; i < goalsLen; i++) {
          if (i < goalsFromData.length) {
            _setCtrl(
              _goalCtrls[i],
              goalsFromData[i],
              focusNode: i < _goalNodes.length ? _goalNodes[i] : null,
            );
          } else if (!(_goalNodes.length > i && _goalNodes[i].hasFocus)) {
            // Zusätzliche Felder ohne gespeicherte Daten: leer halten.
            if (_goalCtrls[i].text.isNotEmpty) {
              _goalCtrls[i].clear();
            }
          }
        }
        for (var i = 0; i < todosLen; i++) {
          if (i < todosFromData.length) {
            _setCtrl(
              _todoCtrls[i],
              todosFromData[i],
              focusNode: i < _todoNodes.length ? _todoNodes[i] : null,
            );
          } else if (!(_todoNodes.length > i && _todoNodes[i].hasFocus)) {
            if (_todoCtrls[i].text.isNotEmpty) {
              _todoCtrls[i].clear();
            }
          }
        }
        _setCtrl(
          _attitudeCtrl,
          _readAt<String>(tData, ['planning', 'reflection']),
          focusNode: _attitudeNode,
        );
        _setCtrl(
          _notesCtrl,
          _readAt<String>(tData, ['planning', 'notes']),
          focusNode: _notesNode,
        );

        // Review der Planung für den ausgewählten Tag
        final curGoals = (_readAt<List>(todayData, ['planning', 'goals']) ?? [])
            .cast<String>();
        final curTodos = (_readAt<List>(todayData, ['planning', 'todos']) ?? [])
            .cast<String>();
        final visibleGoalIdx = List<int>.generate(
          curGoals.length.clamp(0, 3),
          (i) => i,
        ).where((i) => curGoals[i].trim().isNotEmpty).toList();
        final visibleTodoIdx = List<int>.generate(
          curTodos.length.clamp(0, 3),
          (i) => i,
        ).where((i) => curTodos[i].trim().isNotEmpty).toList();
        final completionDyn = _readAt<dynamic>(todayData, [
          'evening',
          'todosCompletion',
        ]);
        final completion = _boolListFromDynamic(completionDyn);
        final goalsCompletionDyn = _readAt<dynamic>(todayData, [
          'evening',
          'goalsCompletion',
        ]);
        final goalsCompletion = _boolListFromDynamic(goalsCompletionDyn);

        // Checkbox-Status aus Firestore-Daten synchronisieren
        final desiredGoalLen = curGoals.length.clamp(0, 3);
        final goalCheckData = List<bool>.generate(
          desiredGoalLen,
          (i) => i < goalsCompletion.length ? goalsCompletion[i] : false,
        );
        _stateManager.syncGoalCheckboxes(
          goalCheckData,
          hasPendingWrites: pending,
        );

        final desiredTodoLen = curTodos.length.clamp(0, 3);
        final todoCheckData = List<bool>.generate(
          desiredTodoLen,
          (i) => i < completion.length ? completion[i] : false,
        );
        _stateManager.syncTodoCheckboxes(
          todoCheckData,
          hasPendingWrites: pending,
        );

        // final isToday = DateUtils.isSameDay(_selected, DateTime.now());

        // Aggregierter Pending-/Cache-Status wird aktuell nicht verwendet

        // Callback-Helfer bündeln (Auslagerung der Handler aus dem Widget-State)
        final callbacks = DayCallbacks.build(
          ref: ref,
          uid: uid,
          stateManager: _stateManager,
          controllers: _controllers,
          syncLogic: _syncLogic,
          getSelected: () => _selected,
          setSelected: (d) => _selected = d,
          setState: (fn) => setState(fn),
          debouncedUpdate: ({
            required uid,
            required date,
            required fieldPath,
            required value,
            alsoAggregateTo,
            aggregateBuilder,
          }) =>
              _debouncedUpdate(
            uid: uid,
            date: date,
            fieldPath: fieldPath,
            value: value,
            alsoAggregateTo: alsoAggregateTo,
            aggregateBuilder: aggregateBuilder,
          ),
          aggregateMorning: _aggregateMorning,
          saveGoals: _saveGoals,
          saveTodos: _saveTodos,
          showSavedSnack: _maybeShowSavedSnack,
        );

        final props = DayShellProps(
          selected: _selected,
          tomorrow: tomorrow,
          pending: pending,
          morningMood: morningMoodFromSnap,
          morningEnergy: morningEnergyFromSnap,
          morningFocus: morningFocusFromSnap,
          eveningMood: eveningMoodFromSnap,
          eveningEnergy: eveningEnergyFromSnap,
          eveningHappiness: eveningHappinessFromSnap,
          curGoals: curGoals,
          curTodos: curTodos,
          visibleGoalIndices: visibleGoalIdx,
          visibleTodoIndices: visibleTodoIdx,
          goalChecks: _stateManager.yesterdayGoalChecks,
          todoChecks: _stateManager.yesterdayTodoChecks,
          controllers: _controllers,
          expMorning: callbacks.expMorning,
          expEvening: callbacks.expEvening,
          expPlanning: callbacks.expPlanning,
          onToggleMorning: callbacks.onToggleMorning,
          onToggleEvening: callbacks.onToggleEvening,
          onTogglePlanning: callbacks.onTogglePlanning,
          onSwipeLeft: callbacks.onSwipeLeft,
          onSwipeRight: callbacks.onSwipeRight,
          onDateSelected: callbacks.onDateSelected,
          onMorningRatingChanged: callbacks.onMorningRatingChanged,
          onMorningTextChanged: callbacks.onMorningTextChanged,
          onEveningRatingChanged: callbacks.onEveningRatingChanged,
          onEveningTextChanged: callbacks.onEveningTextChanged,
          onGoalCheckChanged: callbacks.onGoalCheckChanged,
          onTodoCheckChanged: callbacks.onTodoCheckChanged,
          onMoveGoalToTomorrow: callbacks.onMoveGoalToTomorrow,
          onMoveTodoToTomorrow: callbacks.onMoveTodoToTomorrow,
          onAddGoal: callbacks.onAddGoal,
          onRemoveGoal: callbacks.onRemoveGoal,
          onAddTodo: callbacks.onAddTodo,
          onRemoveTodo: callbacks.onRemoveTodo,
          onReorderGoals: callbacks.onReorderGoals,
          onReorderTodos: callbacks.onReorderTodos,
          onGoalsChanged: callbacks.onGoalsChanged,
          onTodosChanged: callbacks.onTodosChanged,
          onReflectionChanged: callbacks.onReflectionChanged,
          onNotesChanged: callbacks.onNotesChanged,
        );

        return DayShell(props: props);
      },
    );
  }

  String _aggregateMorning() {
    String part(String title, String v) => v.isEmpty ? '' : '$title: $v';
    final parts = [
      part('Gef\u00FChl', _morningFeelingCtrl.text.trim()),
      part('Gut heute', _morningGoodCtrl.text.trim()),
      part('Fokus', _morningFocusCtrl.text.trim()),
    ].where((e) => e.isNotEmpty).toList();
    return parts.join(' | ');
  }

  void _saveGoals(String uid, DateTime date) {
    final list = _goalCtrls
        .map((c) => c.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    _debouncedUpdate(
      uid: uid,
      date: date,
      fieldPath: 'planning.goals',
      value: list,
    );
  }

  void _saveTodos(String uid, DateTime date) {
    final list = _todoCtrls
        .map((c) => c.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    _debouncedUpdate(
      uid: uid,
      date: date,
      fieldPath: 'planning.todos',
      value: list,
    );
  }
}
