import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/habit.dart';
import '../../../providers/habit_providers.dart';
import '../../../theme/tokens.dart';

/// Einzelne Habit-Karte mit Checkbox, Titel, Streak und Fortschritt
class HabitCard extends ConsumerWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final service = ref.watch(habitServiceProvider);
    final today = DateTime.now();
    final isCompletedToday = service.isCompletedOnDate(habit, today);

    // Farbe aus Hex-String parsen
    final habitColor = _parseColor(habit.color);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ReflectoSpacing.s16,
        vertical: ReflectoSpacing.s8,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(ReflectoSpacing.s16),
          child: Row(
            children: [
              // Checkbox für heute
              Checkbox(
                value: isCompletedToday,
                onChanged: (value) {
                  if (value == true) {
                    ref
                        .read(habitNotifierProvider.notifier)
                        .markCompleted(habit.id, today);
                  } else {
                    ref
                        .read(habitNotifierProvider.notifier)
                        .markUncompleted(habit.id, today);
                  }
                },
              ),
              const SizedBox(width: ReflectoSpacing.s12),

              // Farb-Indikator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: habitColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: ReflectoSpacing.s12),

              // Titel und Kategorie
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: ReflectoSpacing.s4),
                    Text(
                      habit.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Streak-Anzeige
              if (habit.streak > 0) ...[
                const SizedBox(width: ReflectoSpacing.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReflectoSpacing.s8,
                    vertical: ReflectoSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: ReflectoSpacing.s4),
                      Text(
                        '${habit.streak}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Actions
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(width: ReflectoSpacing.s8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: ReflectoSpacing.s8),
                            Text('Bearbeiten'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20),
                            SizedBox(width: ReflectoSpacing.s8),
                            Text('Löschen'),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Parst Hex-Farbe zu Color (fallback: Primary-Color)
  Color _parseColor(String hexString) {
    try {
      final hex = hexString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return const Color(0xFF5B50FF); // Fallback
    } catch (_) {
      return const Color(0xFF5B50FF);
    }
  }
}
