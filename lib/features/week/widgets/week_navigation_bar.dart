import 'package:flutter/material.dart';

/// Navigations-Header für die Wochenansicht.
///
/// Zeigt Pfeile (links/rechts), Wochennummer + Datumsbereich, Heute-Button und Kalender-Picker.
class WeekNavigationBar extends StatelessWidget {
  final String weekId;
  final String formattedRange;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onPickDate;

  const WeekNavigationBar({
    super.key,
    required this.weekId,
    required this.formattedRange,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onPickDate,
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
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedRange,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            TextButton(onPressed: onToday, child: const Text('Heute')),
            IconButton(
              tooltip: 'Woche wählen',
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: onPickDate,
            ),
          ],
        ),
      ],
    );
  }
}
