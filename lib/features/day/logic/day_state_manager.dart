import 'package:flutter/material.dart';

/// State-Management für DayScreen Expansion-States und Checkbox-States.
///
/// Managed:
/// - Expansion-States (Morning, Planning, Evening)
/// - Yesterday Review Checkboxes (Goals, Todos)
/// - Auto-Expansion basierend auf Datum/Uhrzeit
class DayStateManager extends ChangeNotifier {
  bool _expMorning = false;
  bool _expPlanning = false;
  bool _expEvening = false;

  List<bool> _yesterdayGoalChecks = const [];
  List<bool> _yesterdayTodoChecks = const [];

  bool get expMorning => _expMorning;
  bool get expPlanning => _expPlanning;
  bool get expEvening => _expEvening;

  List<bool> get yesterdayGoalChecks => _yesterdayGoalChecks;
  List<bool> get yesterdayTodoChecks => _yesterdayTodoChecks;

  /// Setzt Default-Expansion basierend auf dem ausgewählten Datum.
  ///
  /// Logik:
  /// - Zukunft: Nur Planning expanded
  /// - Heute (vor 12 Uhr): Morning expanded
  /// - Heute (nach 12 Uhr): Evening expanded
  /// - Vergangenheit: Evening expanded
  void setDefaultExpansionForDate(DateTime selected) {
    final today = DateTime.now();
    final isToday = DateUtils.isSameDay(selected, today);
    final isFuture = selected.isAfter(
      DateTime(today.year, today.month, today.day),
    );

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
    notifyListeners();
  }

  void toggleMorning() {
    _expMorning = !_expMorning;
    notifyListeners();
  }

  void togglePlanning() {
    _expPlanning = !_expPlanning;
    notifyListeners();
  }

  void toggleEvening() {
    _expEvening = !_expEvening;
    notifyListeners();
  }

  /// Initialisiert Goal-Checkboxes basierend auf Firestore-Daten.
  ///
  /// Synchronisiert nur wenn keine pending writes vorliegen (Cross-Device-Updates).
  void syncGoalCheckboxes(
    List<bool> firestoreData, {
    bool hasPendingWrites = false,
  }) {
    final desiredLen = firestoreData.length;
    if (_yesterdayGoalChecks.isEmpty ||
        _yesterdayGoalChecks.length != desiredLen) {
      _yesterdayGoalChecks = List<bool>.from(firestoreData);
      notifyListeners();
    } else if (!hasPendingWrites) {
      // Snapshot dominiert bei nicht-pendenden Writes
      var changed = false;
      for (var i = 0; i < desiredLen; i++) {
        if (_yesterdayGoalChecks[i] != firestoreData[i]) {
          _yesterdayGoalChecks[i] = firestoreData[i];
          changed = true;
        }
      }
      if (changed) notifyListeners();
    }
  }

  /// Initialisiert Todo-Checkboxes basierend auf Firestore-Daten.
  void syncTodoCheckboxes(
    List<bool> firestoreData, {
    bool hasPendingWrites = false,
  }) {
    final desiredLen = firestoreData.length;
    if (_yesterdayTodoChecks.isEmpty ||
        _yesterdayTodoChecks.length != desiredLen) {
      _yesterdayTodoChecks = List<bool>.from(firestoreData);
      notifyListeners();
    } else if (!hasPendingWrites) {
      var changed = false;
      for (var i = 0; i < desiredLen; i++) {
        if (_yesterdayTodoChecks[i] != firestoreData[i]) {
          _yesterdayTodoChecks[i] = firestoreData[i];
          changed = true;
        }
      }
      if (changed) notifyListeners();
    }
  }

  /// Optimistic Update: Ändert einen Goal-Checkbox-Wert sofort (vor Firestore-Sync).
  void updateGoalCheckbox(int index, bool value) {
    if (index >= 0 && index < _yesterdayGoalChecks.length) {
      _yesterdayGoalChecks[index] = value;
      notifyListeners();
    }
  }

  /// Optimistic Update: Ändert einen Todo-Checkbox-Wert sofort (vor Firestore-Sync).
  void updateTodoCheckbox(int index, bool value) {
    if (index >= 0 && index < _yesterdayTodoChecks.length) {
      _yesterdayTodoChecks[index] = value;
      notifyListeners();
    }
  }
}
