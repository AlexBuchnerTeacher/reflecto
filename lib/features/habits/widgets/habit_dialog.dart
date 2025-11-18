import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/habit.dart';
import '../../../providers/habit_providers.dart';
import '../../../theme/tokens.dart';
import '../../../utils/category_colors.dart';

/// Dialog zum Anlegen oder Bearbeiten eines Habits
class HabitDialog extends ConsumerStatefulWidget {
  final Habit? habit; // null = neues Habit, sonst Edit-Mode

  const HabitDialog({super.key, this.habit});

  @override
  ConsumerState<HabitDialog> createState() => _HabitDialogState();
}

class _HabitDialogState extends ConsumerState<HabitDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _categoryCtrl;
  late String _frequency;
  TextEditingController? _reminderTimeCtrl;
  Set<int> _weekdays = <int>{};
  int _weeklyTarget = 3;

  // Get category color dynamically from selected category
  String get _color => CategoryColors.getColorForCategory(_categoryCtrl.text);

  // Vordefinierte Kategorien (aus CategoryColors)
  final List<String> _categories = CategoryColors.getAllCategoryNames();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.habit?.title ?? '');
    _categoryCtrl = TextEditingController(
      text: widget.habit?.category ?? '🔥 GESUNDHEIT',
    );
    _frequency = widget.habit?.frequency ?? 'daily';
    if (_frequency == 'weekly') {
      _frequency = 'weekly_days';
    }
    // Color is now derived from category via getter
    if (widget.habit?.weekdays != null) {
      _weekdays = widget.habit!.weekdays!.toSet();
    }
    if (widget.habit?.weeklyTarget != null) {
      _weeklyTarget = widget.habit!.weeklyTarget!.clamp(1, 7);
    }
    if (widget.habit?.reminderTime != null) {
      _reminderTimeCtrl = TextEditingController(
        text: widget.habit!.reminderTime,
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _reminderTimeCtrl?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(habitNotifierProvider.notifier);

    try {
      if (widget.habit == null) {
        // Neues Habit erstellen
        await notifier.createHabit(
          title: _titleCtrl.text.trim(),
          category: _categoryCtrl.text.trim(),
          color: _color,
          frequency: _frequency,
          reminderTime: _reminderTimeCtrl?.text.trim().isEmpty == true
              ? null
              : _reminderTimeCtrl?.text.trim(),
          weekdays: _frequency == 'weekly_days' ? _weekdays.toList() : null,
          weeklyTarget: _frequency == 'weekly_target' ? _weeklyTarget : null,
        );
      } else {
        // Bestehendes Habit aktualisieren
        await notifier.updateHabit(
          habitId: widget.habit!.id,
          title: _titleCtrl.text.trim(),
          category: _categoryCtrl.text.trim(),
          color: _color,
          frequency: _frequency,
          reminderTime: _reminderTimeCtrl?.text.trim().isEmpty == true
              ? null
              : _reminderTimeCtrl?.text.trim(),
          weekdays: _frequency == 'weekly_days' ? _weekdays.toList() : <int>[],
          weeklyTarget: _frequency == 'weekly_target' ? _weeklyTarget : null,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.habit != null;

    return AlertDialog(
      title: Text(isEdit ? 'Habit bearbeiten' : 'Neues Habit'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titel
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  hintText: 'z.B. 10 Minuten lesen',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte Titel eingeben';
                  }
                  return null;
                },
              ),
              const SizedBox(height: ReflectoSpacing.s16),

              // Kategorie (Dropdown)
              DropdownButtonFormField<String>(
                value: _categoryCtrl.text.isEmpty
                    ? _categories.first
                    : _categoryCtrl.text,
                decoration: const InputDecoration(
                  labelText: 'Kategorie',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _categoryCtrl.text = value;
                    });
                  }
                },
              ),
              const SizedBox(height: ReflectoSpacing.s16),

              // Frequenz
              Text('Frequenz', style: theme.textTheme.titleSmall),
              const SizedBox(height: ReflectoSpacing.s8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'daily', label: Text('Täglich')),
                  ButtonSegment(
                    value: 'weekly_days',
                    label: Text('Wochentage'),
                  ),
                  ButtonSegment(
                    value: 'weekly_target',
                    label: Text('Wochen‑Ziel'),
                  ),
                  ButtonSegment(
                    value: 'irregular',
                    label: Text('Unregelmäßig'),
                  ),
                ],
                selected: {_frequency},
                onSelectionChanged: (selected) {
                  setState(() {
                    _frequency = selected.first;
                  });
                },
              ),
              const SizedBox(height: ReflectoSpacing.s16),

              if (_frequency == 'weekly_days') ...[
                Text('Wochentage', style: theme.textTheme.titleSmall),
                const SizedBox(height: ReflectoSpacing.s8),
                Wrap(
                  spacing: ReflectoSpacing.s8,
                  runSpacing: ReflectoSpacing.s8,
                  children: List.generate(7, (index) {
                    final dayNum = index + 1; // 1..7
                    const labels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
                    final selected = _weekdays.contains(dayNum);
                    return FilterChip(
                      label: Text(labels[index]),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _weekdays.add(dayNum);
                          } else {
                            _weekdays.remove(dayNum);
                          }
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: ReflectoSpacing.s16),
              ],

              if (_frequency == 'weekly_target') ...[
                Text('Wochen‑Ziel', style: theme.textTheme.titleSmall),
                const SizedBox(height: ReflectoSpacing.s8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _weeklyTarget = (_weeklyTarget - 1).clamp(1, 7);
                        });
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$_weeklyTarget / Woche',
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _weeklyTarget = (_weeklyTarget + 1).clamp(1, 7);
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: ReflectoSpacing.s16),
              ],

              // Farbe (automatisch aus Kategorie)
              Text('Farbe (aus Kategorie)', style: theme.textTheme.titleSmall),
              const SizedBox(height: ReflectoSpacing.s8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CategoryColors.hexToColor(
                    _color,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CategoryColors.hexToColor(_color),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: CategoryColors.hexToColor(_color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Farbe wird automatisch aus der Kategorie zugewiesen',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ReflectoSpacing.s16),

              // Erinnerungszeit (optional)
              TextFormField(
                controller: _reminderTimeCtrl ??= TextEditingController(),
                decoration: const InputDecoration(
                  labelText: 'Erinnerungszeit (optional)',
                  hintText: '19:00',
                  border: OutlineInputBorder(),
                  helperText: 'Format: HH:mm',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final timeRegex = RegExp(r'^\d{2}:\d{2}$');
                  if (!timeRegex.hasMatch(value.trim())) {
                    return 'Format: HH:mm (z.B. 19:00)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEdit ? 'Speichern' : 'Erstellen'),
        ),
      ],
    );
  }
}
