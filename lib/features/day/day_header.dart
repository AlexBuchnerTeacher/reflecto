import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayHeader extends StatelessWidget {
  final DateTime selected;
  final void Function(DateTime) onSelected;

  const DayHeader({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekWindow(DateTime center, {int radius = 3}) {
      final base = DateTime(center.year, center.month, center.day);
      return List.generate(
        radius * 2 + 1,
        (i) => base.add(Duration(days: i - radius)),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final days = weekWindow(selected);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final d in days)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Builder(
                builder: (context) {
                  final isSel = DateUtils.isSameDay(d, selected);
                  final isToday = DateUtils.isSameDay(d, DateTime.now());
                  return ChoiceChip(
                    selected: isSel,
                    side: isToday && !isSel
                        ? BorderSide(color: cs.secondary)
                        : null,
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isToday)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSel
                                  ? cs.onPrimaryContainer
                                  : cs.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (isToday) const SizedBox(height: 2),
                        Text(DateFormat.E('de_DE').format(d)),
                        const SizedBox(height: 2),
                        Text('${d.day}'),
                      ],
                    ),
                    selectedColor: cs.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSel ? cs.onPrimaryContainer : null,
                      fontWeight: isToday ? FontWeight.w600 : null,
                    ),
                    onSelected: (_) {
                      final normalized = DateTime(d.year, d.month, d.day);
                      onSelected(normalized);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
