import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayWeekCarousel extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  const DayWeekCarousel({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  List<DateTime> _weekWindow(DateTime center, {int radius = 3}) {
    final base = DateTime(center.year, center.month, center.day);
    return List<DateTime>.generate(
      radius * 2 + 1,
      (i) => base.add(Duration(days: i - radius)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final List<DateTime> days = _weekWindow(selected);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final d in days)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Builder(
                builder: (context) {
                  final bool isSel = DateUtils.isSameDay(d, selected);
                  final bool isToday = DateUtils.isSameDay(d, DateTime.now());
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
                              color:
                                  isSel ? cs.onPrimaryContainer : cs.secondary,
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
                    onSelected: (_) =>
                        onSelected(DateTime(d.year, d.month, d.day)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
