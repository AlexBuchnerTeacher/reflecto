/// Constants for debouncing text input to reduce Firestore writes
/// and improve UX performance
class DebounceConstants {
  /// Standard debounce duration for text field changes
  ///
  /// Used for:
  /// - DayScreen text inputs (morning, evening, planning)
  /// - MealTrackerCard note fields
  /// - Any other text input that triggers Firestore writes
  ///
  /// Reasoning: 300ms provides good balance between:
  /// - User feels immediate feedback (not too slow)
  /// - Reduces Firestore writes significantly (not too fast)
  /// - Prevents race conditions
  static const Duration textFieldDebounce = Duration(milliseconds: 300);

  /// No debounce - instant feedback for boolean state
  ///
  /// Used for:
  /// - Checkboxes (habit completion)
  /// - Switches (meal tracker boolean)
  /// - Ratings (emoji selections)
  /// - Any boolean state that should feel snappy
  static const Duration instantFeedback = Duration.zero;
}
