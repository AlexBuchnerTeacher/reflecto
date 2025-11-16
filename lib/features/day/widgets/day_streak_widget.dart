import 'package:flutter/material.dart';

import '../../../widgets/reflecto_card.dart';

class DayStreakWidget extends StatelessWidget {
  final int current;
  final int longest;

  const DayStreakWidget({
    super.key,
    required this.current,
    required this.longest,
  });

  @override
  Widget build(BuildContext context) {
    if (current <= 0) {
      return const SizedBox.shrink();
    }
    final isRecord = longest > 0 && current >= longest;
    final suffix = isRecord ? ' (Rekord!)' : '';

    return ReflectoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: Text(
          '🔥 Streak: $current Tage in Folge$suffix',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
