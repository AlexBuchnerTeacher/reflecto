import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';

/// Navigations-Header für die Wochenansicht.
///
/// Zeigt Pfeile (links/rechts), Wochennummer + Datumsbereich und Heute-Button.
class WeekNavigationBar extends StatelessWidget {
  final String weekId;
  final String formattedRange;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const WeekNavigationBar({
    super.key,
    required this.weekId,
    required this.formattedRange,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Vorherige Woche',
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                'Woche $weekId · $formattedRange',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Nächste Woche',
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: ReflectoSpacing.s8),
        Center(
          child: TextButton(
            onPressed: onToday,
            child: const Text('Zur aktuellen Woche'),
          ),
        ),
      ],
    );
  }
}
