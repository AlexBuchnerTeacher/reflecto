import 'package:flutter/material.dart';

class ReflectoRatingBar extends StatelessWidget {
  final int? focus;
  final int? energy;
  final int? happiness;
  final ValueChanged<int> onFocus;
  final ValueChanged<int> onEnergy;
  final ValueChanged<int> onHappiness;

  const ReflectoRatingBar({
    super.key,
    required this.focus,
    required this.energy,
    required this.happiness,
    required this.onFocus,
    required this.onEnergy,
    required this.onHappiness,
  });

  @override
  Widget build(BuildContext context) {
    const inactive = Color(0xFFD9E3F0);
    const active = Color(0xFF2E7DFA);

    Widget row(String label, int? value, ValueChanged<int> onChanged) {
      return Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          for (var i = 1; i <= 5; i++)
            IconButton(
              tooltip: '$label: $i',
              icon: Icon(i <= (value ?? 0) ? Icons.star_rounded : Icons.star_border_rounded),
              color: i <= (value ?? 0) ? active : inactive,
              onPressed: () => onChanged(i),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row('Fokus', focus, onFocus),
        row('Energie', energy, onEnergy),
        row('Zufriedenheit', happiness, onHappiness),
      ],
    );
  }
}

