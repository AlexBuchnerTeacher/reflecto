import 'package:flutter/material.dart';

import '../../../widgets/reflecto_card.dart';
import '../../../theme/tokens.dart';
import '../../../models/journal_entry.dart';

/// Tagesdetail-Karte für ausgewählten Tag im Wochenkarussell.
///
/// Zeigt Zusammenfassung eines Tages:
/// - Morgen-/Abend-Ratings (Fokus, Energie, Zufriedenheit)
/// - Geplante Ziele und To-dos mit Erledigungsstatus
/// - Navigationsmöglichkeit zum vollständigen Tag
class WeekDayDetailCard extends StatelessWidget {
  final DateTime date;
  final JournalEntry? entry;
  final VoidCallback? onTapNavigate;

  const WeekDayDetailCard({
    super.key,
    required this.date,
    this.entry,
    this.onTapNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateStr = _formatDate(date);
    final weekday = _formatWeekday(date);

    // Wenn kein Entry vorhanden: Placeholder
    if (entry == null) {
      return ReflectoCard(
        titleEmoji: '📅',
        title: '$weekday, $dateStr',
        subtitle: 'Noch keine Daten',
        padding: const EdgeInsets.all(ReflectoSpacing.s16),
        onTap: onTapNavigate,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: ReflectoSpacing.s16),
            child: Text(
              'Tippe hier, um den Tag zu öffnen',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    final focus = entry!.ratingFocus;
    final energy = entry!.ratingEnergy;
    final happiness = entry!.ratingHappiness;

    final goals = entry!.planning.goals
        .where((g) => g.trim().isNotEmpty)
        .toList();
    final todos = entry!.planning.todos
        .where((t) => t.trim().isNotEmpty)
        .toList();
    final todosCompletion = entry!.evening.todosCompletion;

    // Note: goalsCompletion ist in Firestore aber nicht im JournalEntry-Model
    // Für diese Karte zeigen wir nur Ziel-Count ohne Completion-Status
    final goalsCompleted = 0; // Placeholder, da goalsCompletion nicht verfügbar
    final todosCompleted = todos
        .asMap()
        .entries
        .where((e) => e.key < todosCompletion.length && todosCompletion[e.key])
        .length;

    return ReflectoCard(
      titleEmoji: '📅',
      title: '$weekday, $dateStr',
      padding: const EdgeInsets.all(ReflectoSpacing.s16),
      onTap: onTapNavigate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ratings
          if (focus != null || energy != null || happiness != null) ...[
            Row(
              children: [
                if (focus != null) _ratingChip(context, '🎯', focus),
                if (focus != null && (energy != null || happiness != null))
                  const SizedBox(width: ReflectoSpacing.s8),
                if (energy != null) _ratingChip(context, '⚡', energy),
                if (energy != null && happiness != null)
                  const SizedBox(width: ReflectoSpacing.s8),
                if (happiness != null) _ratingChip(context, '😊', happiness),
              ],
            ),
            const SizedBox(height: ReflectoSpacing.s12),
          ],

          // Ziele & To-dos
          if (goals.isNotEmpty || todos.isNotEmpty) ...[
            Row(
              children: [
                if (goals.isNotEmpty) ...[
                  Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: ReflectoSpacing.s4),
                  Text(
                    'Ziele: $goalsCompleted/${goals.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (goals.isNotEmpty && todos.isNotEmpty)
                  const SizedBox(width: ReflectoSpacing.s16),
                if (todos.isNotEmpty) ...[
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: ReflectoSpacing.s4),
                  Text(
                    'To-dos: $todosCompleted/${todos.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
            const SizedBox(height: ReflectoSpacing.s8),
          ] else ...[
            Text(
              'Keine Ziele oder To-dos geplant',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: ReflectoSpacing.s8),
          ],

          // Navigation-Hinweis
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onTapNavigate,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Details öffnen'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingChip(BuildContext context, String emoji, int value) {
    final cs = Theme.of(context).colorScheme;
    final color = _getRatingColor(value, cs);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ReflectoSpacing.s8,
        vertical: ReflectoSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: ReflectoSpacing.s4),
          Text(
            '$value',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int value, ColorScheme cs) {
    if (value >= 4) return Colors.green;
    if (value >= 3) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day.$month.';
  }

  String _formatWeekday(DateTime d) {
    const weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    return weekdays[d.weekday - 1];
  }
}
