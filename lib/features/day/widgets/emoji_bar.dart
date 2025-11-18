import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';

class EmojiBar extends StatelessWidget {
  final String label;
  final List<String> emojis;
  final int? value;
  final ValueChanged<int> onSelect;

  const EmojiBar({
    super.key,
    required this.label,
    required this.emojis,
    required this.value,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeBorder = cs.primary;
    final inactiveBorder = cs.outlineVariant;
    final activeBg = cs.primaryContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: ReflectoSpacing.s8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (var i = 1; i <= emojis.length; i++)
              GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  opacity: (value ?? 0) >= i ? 1.0 : 0.7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (value ?? 0) >= i ? activeBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            (value ?? 0) >= i ? activeBorder : inactiveBorder,
                      ),
                    ),
                    child: Text(
                      emojis[i - 1],
                      style: TextStyle(
                        fontSize: 18,
                        color: (value ?? 0) >= i ? cs.onPrimaryContainer : null,
                        fontFamilyFallback: const [
                          'Segoe UI Emoji',
                          'Apple Color Emoji',
                          'Noto Color Emoji',
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
