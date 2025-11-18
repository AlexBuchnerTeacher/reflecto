import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/tokens.dart';
import '../../../providers/meal_providers.dart';
import '../../../providers/card_collapse_providers.dart';
import '../../../widgets/reflecto_card.dart';

class MealTrackerCard extends ConsumerStatefulWidget {
  final DateTime date;
  const MealTrackerCard({super.key, required this.date});

  @override
  ConsumerState<MealTrackerCard> createState() => _MealTrackerCardState();
}

class _MealTrackerCardState extends ConsumerState<MealTrackerCard> {
  final _breakfastCtrl = TextEditingController();
  final _lunchCtrl = TextEditingController();
  final _dinnerCtrl = TextEditingController();

  final _breakfastNode = FocusNode();
  final _lunchNode = FocusNode();
  final _dinnerNode = FocusNode();

  Timer? _bTimer;
  Timer? _lTimer;
  Timer? _dTimer;

  String? _breakfastTime;
  String? _lunchTime;
  String? _dinnerTime;

  @override
  void dispose() {
    _bTimer?.cancel();
    _lTimer?.cancel();
    _dTimer?.cancel();
    _breakfastCtrl.dispose();
    _lunchCtrl.dispose();
    _dinnerCtrl.dispose();
    _breakfastNode.dispose();
    _lunchNode.dispose();
    _dinnerNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealAsync = ref.watch(mealForDateProvider(widget.date));
    final notifier = ref.read(mealNotifierProvider.notifier);
    final isCollapsed = ref.watch(mealTrackerCardCollapseProvider);
    final collapseNotifier = ref.read(mealTrackerCardCollapseProvider.notifier);

    return ReflectoCard(
      titleEmoji: '🍽️',
      title: 'Essen',
      isCollapsible: true,
      isCollapsed: isCollapsed,
      onCollapsedChanged: (collapsed) =>
          collapseNotifier.setCollapsed(collapsed),
      padding: const EdgeInsets.all(ReflectoSpacing.s12),
      child: mealAsync.when(
        loading: () => _buildContent(
          context,
          breakfast: false,
          lunch: false,
          dinner: false,
          breakfastNote: '',
          lunchNote: '',
          dinnerNote: '',
          onBreakfast: (_) {},
          onLunch: (_) {},
          onDinner: (_) {},
          onBreakfastNote: (_) {},
          onLunchNote: (_) {},
          onDinnerNote: (_) {},
        ),
        error: (e, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Essen'),
            const SizedBox(height: 8),
            Text('Fehler: $e'),
          ],
        ),
        data: (log) {
          final breakfast = log?.breakfast ?? false;
          final lunch = log?.lunch ?? false;
          final dinner = log?.dinner ?? false;
          final bNote = log?.breakfastNote ?? '';
          final lNote = log?.lunchNote ?? '';
          final dNote = log?.dinnerNote ?? '';

          // sync times from log
          _breakfastTime = log?.breakfastTime ?? _getDefaultTime('breakfast');
          _lunchTime = log?.lunchTime ?? _getDefaultTime('lunch');
          _dinnerTime = log?.dinnerTime ?? _getDefaultTime('dinner');

          // sync controllers if not focused
          if (!_breakfastNode.hasFocus && _breakfastCtrl.text != bNote) {
            _breakfastCtrl.text = bNote;
          }
          if (!_lunchNode.hasFocus && _lunchCtrl.text != lNote) {
            _lunchCtrl.text = lNote;
          }
          if (!_dinnerNode.hasFocus && _dinnerCtrl.text != dNote) {
            _dinnerCtrl.text = dNote;
          }
          return _buildContent(
            context,
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner,
            breakfastNote: _breakfastCtrl.text,
            lunchNote: _lunchCtrl.text,
            dinnerNote: _dinnerCtrl.text,
            onBreakfast: (v) => notifier.setBreakfast(widget.date, v),
            onLunch: (v) => notifier.setLunch(widget.date, v),
            onDinner: (v) => notifier.setDinner(widget.date, v),
            onBreakfastNote: (v) {
              _bTimer?.cancel();
              _bTimer = Timer(const Duration(milliseconds: 400), () {
                ref
                    .read(mealNotifierProvider.notifier)
                    .setBreakfastNote(widget.date, v);
              });
            },
            onLunchNote: (v) {
              _lTimer?.cancel();
              _lTimer = Timer(const Duration(milliseconds: 400), () {
                ref
                    .read(mealNotifierProvider.notifier)
                    .setLunchNote(widget.date, v);
              });
            },
            onDinnerNote: (v) {
              _dTimer?.cancel();
              _dTimer = Timer(const Duration(milliseconds: 400), () {
                ref
                    .read(mealNotifierProvider.notifier)
                    .setDinnerNote(widget.date, v);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required bool breakfast,
    required bool lunch,
    required bool dinner,
    required String breakfastNote,
    required String lunchNote,
    required String dinnerNote,
    required ValueChanged<bool> onBreakfast,
    required ValueChanged<bool> onLunch,
    required ValueChanged<bool> onDinner,
    required ValueChanged<String> onBreakfastNote,
    required ValueChanged<String> onLunchNote,
    required ValueChanged<String> onDinnerNote,
  }) {
    final theme = Theme.of(context);
    final total = 3;
    final done = (breakfast ? 1 : 0) + (lunch ? 1 : 0) + (dinner ? 1 : 0);
    final pct = total > 0 ? done / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Essen',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChip(
              context,
              icon: Icons.free_breakfast,
              label: 'Frühstück',
              selected: breakfast,
              onSelected: onBreakfast,
            ),
            const SizedBox(width: 8),
            _buildChip(
              context,
              icon: Icons.lunch_dining,
              label: 'Mittag',
              selected: lunch,
              onSelected: onLunch,
            ),
            const SizedBox(width: 8),
            _buildChip(
              context,
              icon: Icons.dinner_dining,
              label: 'Abend',
              selected: dinner,
              onSelected: onDinner,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (breakfast)
          _buildNoteFieldWithTime(
            context,
            hint: 'Was gab\'s zum Frühstück?',
            controller: _breakfastCtrl,
            focusNode: _breakfastNode,
            onChanged: onBreakfastNote,
            time: _breakfastTime ?? '06:30',
            onTimeChanged: (time) {
              setState(() => _breakfastTime = time);
              ref
                  .read(mealNotifierProvider.notifier)
                  .setBreakfastTime(widget.date, time);
            },
          ),
        if (breakfast) const SizedBox(height: 8),
        if (lunch)
          _buildNoteFieldWithTime(
            context,
            hint: 'Was gab\'s zu Mittag?',
            controller: _lunchCtrl,
            focusNode: _lunchNode,
            onChanged: onLunchNote,
            time: _lunchTime ?? '13:30',
            onTimeChanged: (time) {
              setState(() => _lunchTime = time);
              ref
                  .read(mealNotifierProvider.notifier)
                  .setLunchTime(widget.date, time);
            },
          ),
        if (lunch) const SizedBox(height: 8),
        if (dinner)
          _buildNoteFieldWithTime(
            context,
            hint: 'Was gab\'s am Abend?',
            controller: _dinnerCtrl,
            focusNode: _dinnerNode,
            onChanged: onDinnerNote,
            time: _dinnerTime ?? '19:00',
            onTimeChanged: (time) {
              setState(() => _dinnerTime = time);
              ref
                  .read(mealNotifierProvider.notifier)
                  .setDinnerTime(widget.date, time);
            },
          ),
        if (dinner) const SizedBox(height: 12),
        LinearProgressIndicator(
          value: pct,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 4),
        Text(
          '$done / $total erfasst',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNoteFieldWithTime(
    BuildContext context, {
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
    required String time,
    required ValueChanged<String> onTimeChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: OutlinedButton.icon(
            onPressed: () async {
              final parts = time.split(':');
              final initialTime = TimeOfDay(
                hour: int.tryParse(parts[0]) ?? 12,
                minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
              );
              final picked = await showTimePicker(
                context: context,
                initialTime: initialTime,
              );
              if (picked != null) {
                final formatted =
                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                onTimeChanged(formatted);
              }
            },
            icon: const Icon(Icons.access_time, size: 18),
            label: Text(time),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }

  /// Berechnet Standardzeit basierend auf Mahlzeit-Typ und Wochentag
  String _getDefaultTime(String mealType) {
    final isWeekend = widget.date.weekday >= 6; // Sa=6, So=7

    switch (mealType) {
      case 'breakfast':
        return isWeekend ? '09:00' : '06:30';
      case 'lunch':
        return isWeekend ? '14:00' : '13:30';
      case 'dinner':
        return '19:00'; // Gleich für Woche und WE
      default:
        return '12:00';
    }
  }
}
