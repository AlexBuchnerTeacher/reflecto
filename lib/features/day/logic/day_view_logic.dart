import 'package:flutter/foundation.dart';

/// Snapshot der Bewertungswerte für einen gegebenen Tag.
@immutable
class DayRatingsSnapshot {
  final int? morningMood;
  final int? morningEnergy;
  final int? morningFocus;
  final int? eveningMood;
  final int? eveningEnergy;
  final int? eveningFocus;
  final int? eveningHappiness;

  const DayRatingsSnapshot({
    required this.morningMood,
    required this.morningEnergy,
    required this.morningFocus,
    required this.eveningMood,
    required this.eveningEnergy,
    required this.eveningFocus,
    required this.eveningHappiness,
  });
}

/// Snapshot der gestrigen Planung und des Erledigungszustands für den ausgewählten Tag.
@immutable
class YesterdayPlanningSnapshot {
  final List<String> goals;
  final List<String> todos;
  final List<int> visibleGoalIndices;
  final List<int> visibleTodoIndices;
  final List<bool> goalsCompletion;
  final List<bool> todosCompletion;

  const YesterdayPlanningSnapshot({
    required this.goals,
    required this.todos,
    required this.visibleGoalIndices,
    required this.visibleTodoIndices,
    required this.goalsCompletion,
    required this.todosCompletion,
  });
}

DayRatingsSnapshot extractDayRatings(Map<String, dynamic>? todayData) {
  int? readRatingIn(Map<String, dynamic>? m, String container, String key) {
    final nested = m?[container];
    if (nested is Map<String, dynamic>) {
      final v = nested[key];
      if (v is num) return v.toInt();
    }
    return null;
  }

  final morningMoodFromSnap =
      readRatingIn(todayData, 'ratingsMorning', 'mood') ??
      readRatingIn(todayData, 'ratings', 'mood');
  final morningEnergyFromSnap =
      readRatingIn(todayData, 'ratingsMorning', 'energy') ??
      readRatingIn(todayData, 'ratings', 'energy');
  final morningFocusFromSnap =
      readRatingIn(todayData, 'ratingsMorning', 'focus') ??
      readRatingIn(todayData, 'ratings', 'focus');

  final eveningMoodFromSnap =
      readRatingIn(todayData, 'ratingsEvening', 'mood') ??
      readRatingIn(todayData, 'ratings', 'mood');
  final eveningFocusFromSnap =
      readRatingIn(todayData, 'ratingsEvening', 'focus') ??
      readRatingIn(todayData, 'ratings', 'focus');
  final eveningEnergyFromSnap =
      readRatingIn(todayData, 'ratingsEvening', 'energy') ??
      readRatingIn(todayData, 'ratings', 'energy');
  final eveningHappinessFromSnap =
      readRatingIn(todayData, 'ratingsEvening', 'happiness') ??
      readRatingIn(todayData, 'ratings', 'happiness');

  return DayRatingsSnapshot(
    morningMood: morningMoodFromSnap,
    morningEnergy: morningEnergyFromSnap,
    morningFocus: morningFocusFromSnap,
    eveningMood: eveningMoodFromSnap,
    eveningEnergy: eveningEnergyFromSnap,
    eveningFocus: eveningFocusFromSnap,
    eveningHappiness: eveningHappinessFromSnap,
  );
}

YesterdayPlanningSnapshot extractYesterdayPlanning(
  Map<String, dynamic>? todayData,
) {
  List<T> readListOfString<T>(Map<String, dynamic>? map, List<String> path) {
    final raw = _readAt<List>(map, path) ?? const <dynamic>[];
    return raw.map((e) => (e?.toString() ?? '') as T).toList();
  }

  final goals = readListOfString<String>(todayData, <String>[
    'planning',
    'goals',
  ]);
  final todos = readListOfString<String>(todayData, <String>[
    'planning',
    'todos',
  ]);

  final visibleGoalIdx = List<int>.generate(
    goals.length.clamp(0, 3),
    (i) => i,
  ).where((i) => goals[i].trim().isNotEmpty).toList();
  final visibleTodoIdx = List<int>.generate(
    todos.length.clamp(0, 3),
    (i) => i,
  ).where((i) => todos[i].trim().isNotEmpty).toList();

  final completionDyn =
      _readAt<List>(todayData, <String>['evening', 'todosCompletion']) ??
      const <dynamic>[];
  final completion = completionDyn.map((e) => e == true).toList();
  final goalsCompletionDyn =
      _readAt<List>(todayData, <String>['evening', 'goalsCompletion']) ??
      const <dynamic>[];
  final goalsCompletion = goalsCompletionDyn.map((e) => e == true).toList();

  return YesterdayPlanningSnapshot(
    goals: goals,
    todos: todos,
    visibleGoalIndices: visibleGoalIdx,
    visibleTodoIndices: visibleTodoIdx,
    goalsCompletion: goalsCompletion,
    todosCompletion: completion,
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
