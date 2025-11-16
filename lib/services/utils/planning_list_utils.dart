/// Hilfsfunktionen für Planung-Listen (Goals/Todos).
class PlanningListUtils {
  PlanningListUtils._();

  /// Normalisiert eine Liste: Duplikate entfernen (trim-basierend),
  /// leere Slots ans Ende verschieben.
  static List<String> dedupePreserveEmptySlots(List<String> input) {
    final seen = <String>{};
    var emptyCount = 0;
    for (final raw in input) {
      final t = raw.toString().trim();
      if (t.isEmpty) {
        emptyCount++;
        continue;
      }
      if (!seen.contains(t)) {
        seen.add(t);
      }
    }
    return [...seen, ...List.filled(emptyCount, '')];
  }

  /// Vergleicht zwei Listen auf Gleichheit (exakte element-weise Übereinstimmung).
  static bool listsEqual(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
