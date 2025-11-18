import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/day_controllers.dart';
import 'day_state_manager.dart';
import 'day_sync_logic.dart';
import '../../../providers/entry_providers.dart';

/// Bündelt alle UI-Callbacks des Day-Screens an einem Ort.
///
/// Ziel: `day_screen.dart` vereinfachen und die Logik der Handler klar trennen.
class DayCallbacks {
  final VoidCallback onToggleMorning;
  final VoidCallback onToggleEvening;
  final VoidCallback onTogglePlanning;

  final bool expMorning;
  final bool expEvening;
  final bool expPlanning;

  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final ValueChanged<DateTime> onDateSelected;

  final void Function(String field, int value) onMorningRatingChanged;
  final void Function(String field, String value) onMorningTextChanged;

  final void Function(String field, int value) onEveningRatingChanged;
  final void Function(String field, String value) onEveningTextChanged;

  final Future<void> Function(int index, bool value) onGoalCheckChanged;
  final Future<void> Function(int index, bool value) onTodoCheckChanged;
  final Future<void> Function(int index) onMoveGoalToTomorrow;
  final Future<void> Function(int index) onMoveTodoToTomorrow;

  final VoidCallback onAddGoal;
  final void Function(int index) onRemoveGoal;
  final VoidCallback onAddTodo;
  final void Function(int index) onRemoveTodo;
  final void Function(int oldIndex, int newIndex) onReorderGoals;
  final void Function(int oldIndex, int newIndex) onReorderTodos;
  final VoidCallback onGoalsChanged;
  final VoidCallback onTodosChanged;
  final void Function(String value) onReflectionChanged;
  final void Function(String value) onNotesChanged;

  const DayCallbacks({
    required this.onToggleMorning,
    required this.onToggleEvening,
    required this.onTogglePlanning,
    required this.expMorning,
    required this.expEvening,
    required this.expPlanning,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onDateSelected,
    required this.onMorningRatingChanged,
    required this.onMorningTextChanged,
    required this.onEveningRatingChanged,
    required this.onEveningTextChanged,
    required this.onGoalCheckChanged,
    required this.onTodoCheckChanged,
    required this.onMoveGoalToTomorrow,
    required this.onMoveTodoToTomorrow,
    required this.onAddGoal,
    required this.onRemoveGoal,
    required this.onAddTodo,
    required this.onRemoveTodo,
    required this.onReorderGoals,
    required this.onReorderTodos,
    required this.onGoalsChanged,
    required this.onTodosChanged,
    required this.onReflectionChanged,
    required this.onNotesChanged,
  });

  /// Fabrik zum Erzeugen aller Handler.
  ///
  /// Die Methode kapselt notwendige Abhängigkeiten (z. B. `setState`,
  /// `debouncedUpdate`) und liefert fertig gebundene Callback-Funktionen.
  static DayCallbacks build({
    // Kontext / Zustände
    required WidgetRef ref,
    required String uid,
    required DayStateManager stateManager,
    required DayControllers controllers,
    required DaySyncLogic syncLogic,
    required DateTime Function() getSelected,
    required void Function(DateTime) setSelected,
    required void Function(void Function()) setState,

    // Helfer aus DayScreen
    required void Function({
      required String uid,
      required DateTime date,
      required String fieldPath,
      required dynamic value,
      String? alsoAggregateTo,
      String Function()? aggregateBuilder,
    }) debouncedUpdate,
    required String Function() aggregateMorning,
    required void Function(String uid, DateTime date) saveGoals,
    required void Function(String uid, DateTime date) saveTodos,
    required VoidCallback showSavedSnack,
  }) {
    // Toggles
    void onToggleMorning() {
      stateManager.toggleMorning();
      setState(() {});
    }

    void onToggleEvening() {
      stateManager.toggleEvening();
      setState(() {});
    }

    void onTogglePlanning() {
      stateManager.togglePlanning();
      setState(() {});
    }

    // Navigation Datum
    void onSwipeLeft() {
      setState(() {
        final next = getSelected().add(const Duration(days: 1));
        setSelected(next);
        stateManager.setDefaultExpansionForDate(next);
      });
    }

    void onSwipeRight() {
      setState(() {
        final prev = getSelected().subtract(const Duration(days: 1));
        setSelected(prev);
        stateManager.setDefaultExpansionForDate(prev);
      });
    }

    void onDateSelected(DateTime d) {
      setState(() {
        setSelected(d);
        stateManager.setDefaultExpansionForDate(d);
      });
    }

    // Morning
    void onMorningRatingChanged(String field, int value) {
      final updater = ref.read(updateDayFieldProvider);
      updater(uid, getSelected(), field, value).then((_) => showSavedSnack());
    }

    void onMorningTextChanged(String field, String value) {
      debouncedUpdate(
        uid: uid,
        date: getSelected(),
        fieldPath: field,
        value: value,
        alsoAggregateTo: 'morningAggregate',
        aggregateBuilder: aggregateMorning,
      );
    }

    // Evening
    void onEveningRatingChanged(String field, int value) {
      final updater = ref.read(updateDayFieldProvider);
      updater(uid, getSelected(), field, value).then((_) => showSavedSnack());
    }

    void onEveningTextChanged(String field, String value) {
      debouncedUpdate(
        uid: uid,
        date: getSelected(),
        fieldPath: field,
        value: value.isEmpty ? null : value,
      );
    }

    // Evening: Checkboxen
    Future<void> onGoalCheckChanged(int index, bool value) async {
      stateManager.updateGoalCheckbox(index, value); // Optimistisches Update
      setState(() {});
      await syncLogic.updateGoalCompletion(uid, getSelected(), index, value);
    }

    Future<void> onTodoCheckChanged(int index, bool value) async {
      stateManager.updateTodoCheckbox(index, value); // Optimistisches Update
      setState(() {});
      await syncLogic.updateTodoCompletion(uid, getSelected(), index, value);
    }

    // Platzhalter für zukünftiges Verschieben nach morgen
    Future<void> onMoveGoalToTomorrow(int index) async {}
    Future<void> onMoveTodoToTomorrow(int index) async {}

    // Planning: Items hinzufügen/entfernen
    void onAddGoal() {
      setState(() {
        controllers.ensureGoalsLen(controllers.goalCtrls.length + 1);
      });
      if (controllers.goalNodes.isNotEmpty &&
          controllers.goalNodes.length == controllers.goalCtrls.length) {
        controllers.goalNodes.last.requestFocus();
      }
    }

    void onRemoveGoal(int index) {
      setState(() {
        if (index < controllers.goalCtrls.length) {
          controllers.goalCtrls.removeAt(index).dispose();
        }
        if (index < controllers.goalNodes.length) {
          controllers.goalNodes.removeAt(index).dispose();
        }
      });
      saveGoals(uid, getSelected().add(const Duration(days: 1)));
    }

    void onAddTodo() {
      setState(() {
        controllers.ensureTodosLen(controllers.todoCtrls.length + 1);
      });
      if (controllers.todoNodes.isNotEmpty &&
          controllers.todoNodes.length == controllers.todoCtrls.length) {
        controllers.todoNodes.last.requestFocus();
      }
    }

    void onRemoveTodo(int index) {
      setState(() {
        if (index < controllers.todoCtrls.length) {
          controllers.todoCtrls.removeAt(index).dispose();
        }
        if (index < controllers.todoNodes.length) {
          controllers.todoNodes.removeAt(index).dispose();
        }
      });
      saveTodos(uid, getSelected().add(const Duration(days: 1)));
    }

    // Planning: Änderungen abspeichern
    void onGoalsChanged() {
      saveGoals(uid, getSelected().add(const Duration(days: 1)));
    }

    void onTodosChanged() {
      saveTodos(uid, getSelected().add(const Duration(days: 1)));
    }

    void onReflectionChanged(String value) {
      debouncedUpdate(
        uid: uid,
        date: getSelected().add(const Duration(days: 1)),
        fieldPath: 'planning.reflection',
        value: value.isEmpty ? null : value,
      );
    }

    void onNotesChanged(String value) {
      debouncedUpdate(
        uid: uid,
        date: getSelected().add(const Duration(days: 1)),
        fieldPath: 'planning.notes',
        value: value.isEmpty ? null : value,
      );
    }

    // Reorder
    void onReorderGoals(int oldIndex, int newIndex) {
      setState(() {
        if (newIndex > oldIndex) newIndex -= 1;
        final ctrl = controllers.goalCtrls.removeAt(oldIndex);
        controllers.goalCtrls.insert(newIndex, ctrl);
        if (controllers.goalNodes.length == controllers.goalCtrls.length) {
          final node = controllers.goalNodes.removeAt(oldIndex);
          controllers.goalNodes.insert(newIndex, node);
        }
      });
      saveGoals(uid, getSelected().add(const Duration(days: 1)));
    }

    void onReorderTodos(int oldIndex, int newIndex) {
      setState(() {
        if (newIndex > oldIndex) newIndex -= 1;
        final ctrl = controllers.todoCtrls.removeAt(oldIndex);
        controllers.todoCtrls.insert(newIndex, ctrl);
        if (controllers.todoNodes.length == controllers.todoCtrls.length) {
          final node = controllers.todoNodes.removeAt(oldIndex);
          controllers.todoNodes.insert(newIndex, node);
        }
      });
      saveTodos(uid, getSelected().add(const Duration(days: 1)));
    }

    return DayCallbacks(
      onToggleMorning: onToggleMorning,
      onToggleEvening: onToggleEvening,
      onTogglePlanning: onTogglePlanning,
      expMorning: stateManager.expMorning,
      expEvening: stateManager.expEvening,
      expPlanning: stateManager.expPlanning,
      onSwipeLeft: onSwipeLeft,
      onSwipeRight: onSwipeRight,
      onDateSelected: onDateSelected,
      onMorningRatingChanged: onMorningRatingChanged,
      onMorningTextChanged: onMorningTextChanged,
      onEveningRatingChanged: onEveningRatingChanged,
      onEveningTextChanged: onEveningTextChanged,
      onGoalCheckChanged: onGoalCheckChanged,
      onTodoCheckChanged: onTodoCheckChanged,
      onMoveGoalToTomorrow: onMoveGoalToTomorrow,
      onMoveTodoToTomorrow: onMoveTodoToTomorrow,
      onAddGoal: onAddGoal,
      onRemoveGoal: onRemoveGoal,
      onAddTodo: onAddTodo,
      onRemoveTodo: onRemoveTodo,
      onReorderGoals: onReorderGoals,
      onReorderTodos: onReorderTodos,
      onGoalsChanged: onGoalsChanged,
      onTodosChanged: onTodosChanged,
      onReflectionChanged: onReflectionChanged,
      onNotesChanged: onNotesChanged,
    );
  }
}
