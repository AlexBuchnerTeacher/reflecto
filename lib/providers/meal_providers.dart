import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal_log.dart';
import '../services/meal_service.dart';
import 'auth_providers.dart';

final mealServiceProvider = Provider<MealService>((ref) => MealService());

final mealForDateProvider =
    StreamProvider.autoDispose.family<MealLog?, DateTime>((ref, date) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return Stream.value(null);
  final service = ref.watch(mealServiceProvider);
  return service.watchMealForDate(uid, date);
});

class MealNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> setBreakfast(DateTime date, bool value) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    try {
      await ref.read(mealServiceProvider).setMealToggle(
            uid: uid,
            date: date,
            field: 'breakfast',
            value: value,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setLunch(DateTime date, bool value) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    try {
      await ref
          .read(mealServiceProvider)
          .setMealToggle(uid: uid, date: date, field: 'lunch', value: value);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setDinner(DateTime date, bool value) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    try {
      await ref
          .read(mealServiceProvider)
          .setMealToggle(uid: uid, date: date, field: 'dinner', value: value);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setBreakfastNote(DateTime date, String value) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    try {
      await ref.read(mealServiceProvider).setMealNote(
            uid: uid,
            date: date,
            field: 'breakfastNote',
            value: value,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setLunchNote(DateTime date, String value) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    try {
      await ref
          .read(mealServiceProvider)
          .setMealNote(uid: uid, date: date, field: 'lunchNote', value: value);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setDinnerNote(DateTime date, String value) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    try {
      await ref
          .read(mealServiceProvider)
          .setMealNote(uid: uid, date: date, field: 'dinnerNote', value: value);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setBreakfastTime(DateTime date, String value) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    try {
      await ref.read(mealServiceProvider).setMealNote(
            uid: uid,
            date: date,
            field: 'breakfastTime',
            value: value,
          );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setLunchTime(DateTime date, String value) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    try {
      await ref
          .read(mealServiceProvider)
          .setMealNote(uid: uid, date: date, field: 'lunchTime', value: value);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setDinnerTime(DateTime date, String value) async {
    final uid = ref.read(userIdProvider);
    if (uid == null) return;
    try {
      await ref
          .read(mealServiceProvider)
          .setMealNote(uid: uid, date: date, field: 'dinnerTime', value: value);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final mealNotifierProvider =
    AutoDisposeAsyncNotifierProvider<MealNotifier, void>(MealNotifier.new);
