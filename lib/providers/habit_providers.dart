import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';
import 'auth_providers.dart';

/// Service-Provider für HabitService
final habitServiceProvider = Provider<HabitService>((ref) {
  return HabitService();
});

/// StreamProvider für alle Habits des aktuellen Users
final habitsProvider = StreamProvider.autoDispose<List<Habit>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) {
    return Stream.value([]);
  }

  final service = ref.watch(habitServiceProvider);
  return service.watchHabits(uid);
});

/// Provider für Sync-Status (prüft ob pending writes existieren)
final habitsSyncStatusProvider = StreamProvider.autoDispose<bool>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) {
    return Stream.value(true); // synced wenn nicht eingeloggt
  }

  final service = ref.watch(habitServiceProvider);
  return service.watchHabitsSyncStatus(uid);
});

/// Provider für ein einzelnes Habit
final habitProvider = StreamProvider.autoDispose.family<Habit?, String>((
  ref,
  habitId,
) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) {
    return Stream.value(null);
  }

  final service = ref.watch(habitServiceProvider);
  return service.watchHabits(uid).map((habits) {
    try {
      return habits.firstWhere((h) => h.id == habitId);
    } catch (_) {
      return null;
    }
  });
});

/// AsyncNotifier für Habit-CRUD-Operationen
class HabitNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Keine initiale Daten-Ladung nötig
  }

  /// Neues Habit erstellen
  Future<String?> createHabit({
    required String title,
    required String category,
    required String color,
    required String frequency,
    String? reminderTime,
    List<int>? weekdays,
    int? weeklyTarget,
    int? monthlyTarget,
    int? sortIndex,
  }) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return null;

    state = const AsyncLoading();
    try {
      final service = ref.read(habitServiceProvider);
      final id = await service.createHabit(
        uid: uid,
        title: title,
        category: category,
        color: color,
        frequency: frequency,
        reminderTime: reminderTime,
        weekdays: weekdays,
        weeklyTarget: weeklyTarget,
        monthlyTarget: monthlyTarget,
        sortIndex: sortIndex,
      );
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// Habit aktualisieren
  Future<void> updateHabit({
    required String habitId,
    String? title,
    String? category,
    String? color,
    String? frequency,
    String? reminderTime,
    List<int>? weekdays,
    int? weeklyTarget,
    int? monthlyTarget,
    int? sortIndex,
  }) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;

    state = const AsyncLoading();
    try {
      final service = ref.read(habitServiceProvider);
      await service.updateHabit(
        uid: uid,
        habitId: habitId,
        title: title,
        category: category,
        color: color,
        frequency: frequency,
        reminderTime: reminderTime,
        weekdays: weekdays,
        weeklyTarget: weeklyTarget,
        monthlyTarget: monthlyTarget,
        sortIndex: sortIndex,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Habit löschen
  Future<void> deleteHabit(String habitId) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;

    state = const AsyncLoading();
    try {
      final service = ref.read(habitServiceProvider);
      await service.deleteHabit(uid, habitId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Habit als completed markieren
  Future<void> markCompleted(String habitId, DateTime date) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;

    state = const AsyncLoading();
    try {
      final service = ref.read(habitServiceProvider);
      await service.markCompleted(uid: uid, habitId: habitId, date: date);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Habit als uncompleted markieren
  Future<void> markUncompleted(String habitId, DateTime date) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;

    state = const AsyncLoading();
    try {
      final service = ref.read(habitServiceProvider);
      await service.markUncompleted(uid: uid, habitId: habitId, date: date);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Provider für HabitNotifier
final habitNotifierProvider =
    AutoDisposeAsyncNotifierProvider<HabitNotifier, void>(HabitNotifier.new);
