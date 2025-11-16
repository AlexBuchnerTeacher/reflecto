import 'package:flutter/widgets.dart';

/// Utility-Klasse für die Synchronisierung zwischen TextEditingControllern
/// und Firestore-Daten im Day-Feature.
///
/// Verhindert Überschreibungen während aktiver Eingabe und managed
/// Text-Selection korrekt.
class DayControllerSync {
  DayControllerSync._();

  /// Setzt den Wert eines TextEditingControllers nur wenn:
  /// - Der neue Wert nicht null ist
  /// - Das zugehörige FocusNode keinen Fokus hat (keine aktive Eingabe)
  /// - Der aktuelle Controller-Text vom neuen Wert abweicht
  ///
  /// Erhält die Text-Selection korrekt (Cursor am Ende).
  static void setControllerValue(
    TextEditingController controller,
    String? newValue, {
    FocusNode? focusNode,
  }) {
    if (newValue == null) {
      return; // kein Überschreiben mit null
    }
    if (focusNode != null && focusNode.hasFocus) {
      return; // während aktiver Eingabe nicht überschreiben
    }
    if (controller.text != newValue) {
      final selection = TextSelection.collapsed(offset: newValue.length);
      controller.value = controller.value.copyWith(
        text: newValue,
        selection: selection,
        composing: TextRange.empty,
      );
    }
  }

  /// Liest einen verschachtelten Wert aus einer Map mit einem Pfad.
  ///
  /// Beispiel: `readAt<String>(data, ['morning', 'mood'])` liest `data['morning']['mood']`
  ///
  /// Gibt null zurück wenn der Pfad nicht existiert oder der Typ nicht übereinstimmt.
  static T? readAt<T>(Map<String, dynamic>? map, List<String> path) {
    if (map == null) return null;
    dynamic current = map;
    for (final pathSegment in path) {
      if (current is Map<String, dynamic> && current.containsKey(pathSegment)) {
        current = current[pathSegment];
      } else {
        return null;
      }
    }
    if (current is T) return current;
    return null;
  }

  /// Konvertiert verschiedene Firestore-Bool-List-Formate in eine Dart-List&lt;bool&gt;.
  ///
  /// Unterstützt:
  /// - List-Format: `[true, false, true]`
  /// - Map-Format (Index -> Bool): `{0: true, 1: false, 2: true}`
  ///
  /// Füllt fehlende Indizes mit false auf.
  static List<bool> boolListFromDynamic(dynamic value) {
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

  /// Aggregiert Morning-Reflection-Felder zu einem einzigen String.
  ///
  /// Format: "Gefühl: X | Gut heute: Y | Fokus: Z"
  static String aggregateMorning({
    required String feeling,
    required String good,
    required String focus,
  }) {
    String part(String title, String value) =>
        value.isEmpty ? '' : '$title: $value';
    final parts = [
      part('Gefühl', feeling.trim()),
      part('Gut heute', good.trim()),
      part('Fokus', focus.trim()),
    ].where((e) => e.isNotEmpty).toList();
    return parts.join(' | ');
  }
}
