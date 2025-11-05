import 'package:flutter/material.dart';

class RatingsRow extends StatelessWidget {
  final String label;
  final int? value;
  final ValueChanged<int> onChanged;

  const RatingsRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: '$label: $i',
            icon: Icon(i <= (value ?? 0) ? Icons.star_rounded : Icons.star_border_rounded),
            color: color,
            onPressed: () => onChanged(i),
          ),
      ],
    );
  }
}

