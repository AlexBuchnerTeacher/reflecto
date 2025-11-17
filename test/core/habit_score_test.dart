import 'package:flutter_test/flutter_test.dart';

// Beispiel-Unit-Test für eine kleine Kernlogikfunktion.
// Passe die Importe / die tatsächliche Funktion an die reale Implementierung an.

int calculateStreakScore(int streak) {
  if (streak <= 0) return 0;
  if (streak < 3) return 10;
  if (streak < 7) return 20;
  return 30;
}

void main() {
  test('calculateStreakScore returns expected values', () {
    expect(calculateStreakScore(0), 0);
    expect(calculateStreakScore(1), 10);
    expect(calculateStreakScore(3), 20);
    expect(calculateStreakScore(10), 30);
  });
}
