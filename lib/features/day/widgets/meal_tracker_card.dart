import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/tokens.dart';
import '../../../providers/meal_providers.dart';

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

    return Card(
      child: Padding(
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
          _buildNoteField(
            context,
            hint: 'Was gab’s zum Frühstück?',
            controller: _breakfastCtrl,
            focusNode: _breakfastNode,
            onChanged: onBreakfastNote,
          ),
        if (breakfast) const SizedBox(height: 8),
        if (lunch)
          _buildNoteField(
            context,
            hint: 'Was gab’s zu Mittag?',
            controller: _lunchCtrl,
            focusNode: _lunchNode,
            onChanged: onLunchNote,
          ),
        if (lunch) const SizedBox(height: 8),
        if (dinner)
          _buildNoteField(
            context,
            hint: 'Was gab’s am Abend?',
            controller: _dinnerCtrl,
            focusNode: _dinnerNode,
            onChanged: onDinnerNote,
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

  Widget _buildNoteField(
    BuildContext context, {
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
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
}
