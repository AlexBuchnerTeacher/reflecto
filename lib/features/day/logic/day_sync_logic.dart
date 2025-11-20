import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/entry_providers.dart';
import '../../../services/firestore_service.dart';

class DaySyncLogic {
  final Map<String, Timer> _debouncers = {};
  final Map<String, Map<String, dynamic>?> _docCache =
      {}; // dateId -> latest doc data
  final Set<String> _ensured = {};

  void dispose() {
    for (final t in _debouncers.values) {
      t.cancel();
    }
  }

  String _dateId(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  void updateDocCache(DateTime date, Map<String, dynamic>? data) {
    _docCache[_dateId(date)] = data;
  }

  void ensureEntry(String uid, DateTime date) {
    final key = '$uid:${_dateId(date)}';
    if (_ensured.contains(key)) return;
    _ensured.add(key);
    FirestoreService().createEmptyEntry(uid, date);
  }

  void debouncedUpdate({
    required WidgetRef ref,
    required String uid,
    required DateTime date,
    required String fieldPath,
    required dynamic value,
    String? alsoAggregateTo,
    String Function()? aggregateBuilder,
    required void Function() onSuccess,
    required void Function() onError,
  }) {
    final key = '${_dateId(date)}|$fieldPath';
    _debouncers[key]?.cancel();
    _debouncers[key] = Timer(const Duration(milliseconds: 300), () async {
      try {
        if (value is! FieldValue) {
          final prev = _valueAtPath(_docCache[_dateId(date)], fieldPath);
          if (_deepEquals(prev, value)) return;
        }
        final updater = ref.read(updateDayFieldProvider);
        await updater(uid, date, fieldPath, value);
        if (alsoAggregateTo != null && aggregateBuilder != null) {
          await updater(uid, date, alsoAggregateTo, aggregateBuilder());
        }
        onSuccess();
      } catch (_) {
        onError();
      }
    });
  }

  Future<bool> completeEveningIfNeeded({
    required String uid,
    required DateTime date,
    required bool alreadyCompleted,
    required int goalsChecked,
    required int todosChecked,
  }) async {
    if (alreadyCompleted) return false;
    if (goalsChecked < 1 || todosChecked < 1) return false;
    try {
      await FirestoreService().markEveningCompletedAndUpdateStreak(uid, date);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateTodoCompletion(
    String uid,
    DateTime date,
    int index,
    bool value,
  ) {
    return FirestoreService().updateTodoCompletion(uid, date, index, value);
  }

  Future<void> updateGoalCompletion(
    String uid,
    DateTime date,
    int index,
    bool value,
  ) {
    return FirestoreService().updateGoalCompletion(uid, date, index, value);
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
}
