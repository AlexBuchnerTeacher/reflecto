import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

/// Key constants for SharedPreferences
class CardCollapseKeys {
  static const habitInsightsCard = 'collapse_habit_insights_card';
  static const mealTrackerCard = 'collapse_meal_tracker_card';
}

/// Base class for card collapse state notifiers
abstract class CardCollapseNotifier extends StateNotifier<bool> {
  final SharedPreferences prefs;
  final String prefKey;
  final BuildContext? context;

  CardCollapseNotifier({
    required this.prefs,
    required this.prefKey,
    this.context,
  }) : super(_getInitialState(prefs, prefKey, context));

  /// Get initial state: Check SharedPreferences first, then adaptive default
  static bool _getInitialState(
    SharedPreferences prefs,
    String prefKey,
    BuildContext? context,
  ) {
    // Check if user has saved a preference
    if (prefs.containsKey(prefKey)) {
      return prefs.getBool(prefKey) ?? false;
    }

    // Adaptive default: Collapse on mobile (<600px), expand on tablet/desktop
    if (context != null) {
      final width = MediaQuery.of(context).size.width;
      return width < 600; // Mobile breakpoint
    }

    // Fallback: Collapse by default (mobile-first)
    return true;
  }

  /// Toggle collapse state and persist to SharedPreferences
  Future<void> toggle() async {
    state = !state;
    await prefs.setBool(prefKey, state);
  }

  /// Set collapse state explicitly
  Future<void> setCollapsed(bool collapsed) async {
    if (state != collapsed) {
      state = collapsed;
      await prefs.setBool(prefKey, collapsed);
    }
  }
}

/// Notifier for HabitInsightsCard collapse state
class HabitInsightsCardCollapseNotifier extends CardCollapseNotifier {
  HabitInsightsCardCollapseNotifier({required super.prefs, super.context})
    : super(prefKey: CardCollapseKeys.habitInsightsCard);
}

/// Notifier for MealTrackerCard collapse state
class MealTrackerCardCollapseNotifier extends CardCollapseNotifier {
  MealTrackerCardCollapseNotifier({required super.prefs, super.context})
    : super(prefKey: CardCollapseKeys.mealTrackerCard);
}

/// Provider for HabitInsightsCard collapse state
final habitInsightsCardCollapseProvider =
    StateNotifierProvider<HabitInsightsCardCollapseNotifier, bool>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return HabitInsightsCardCollapseNotifier(prefs: prefs);
    });

/// Provider for MealTrackerCard collapse state
final mealTrackerCardCollapseProvider =
    StateNotifierProvider<MealTrackerCardCollapseNotifier, bool>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return MealTrackerCardCollapseNotifier(prefs: prefs);
    });
