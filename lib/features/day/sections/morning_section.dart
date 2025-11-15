import 'package:flutter/material.dart';

import '../widgets/emoji_bar.dart';
import '../widgets/labeled_field.dart';
import '../../../widgets/reflecto_card.dart';

class MorningSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggleExpanded;

  final TextEditingController feelingCtrl;
  final TextEditingController goodCtrl;
  final TextEditingController focusCtrl;

  final FocusNode feelingNode;
  final FocusNode goodNode;
  final FocusNode focusNode;

  final int? mood;
  final int? energy;
  final int? focusRating;

  final List<String> curGoals;
  final List<String> curTodos;

  final void Function(String fieldPath, int value) onRatingChanged;
  final void Function(String fieldPath, String value) onTextChanged;

  const MorningSection({
    super.key,
    required this.expanded,
    required this.onToggleExpanded,
    required this.feelingCtrl,
    required this.goodCtrl,
    required this.focusCtrl,
    required this.feelingNode,
    required this.goodNode,
    required this.focusNode,
    required this.mood,
    required this.energy,
    required this.focusRating,
    required this.curGoals,
    required this.curTodos,
    required this.onRatingChanged,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReflectoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '\u{1F305} Morgenreflexion',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamilyFallback: [
                      'Segoe UI Emoji',
                      'Apple Color Emoji',
                      'Noto Color Emoji',
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _progressChip(
                    context,
                    'Felder '
                    '${[feelingCtrl.text.trim(), goodCtrl.text.trim(), focusCtrl.text.trim()].where((e) => e.isNotEmpty).length}/3'
                    ' · Ratings '
                    '${[mood, energy, focusRating].where((e) => e != null).length}/3',
                  ),
                ),
              ),
              IconButton(
                tooltip: expanded ? 'Einklappen' : 'Aufklappen',
                icon: Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                onPressed: onToggleExpanded,
              ),
            ],
          ),
          AnimatedCrossFade(
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                EmojiBar(
                  label: 'Stimmung',
                  emojis: const [
                    '\u{1F61E}',
                    '\u{1F610}',
                    '\u{1F642}',
                    '\u{1F60A}',
                    '\u{1F60E}',
                  ],
                  value: mood,
                  onSelect: (v) => onRatingChanged('ratingsMorning.mood', v),
                ),
                const SizedBox(height: 12),
                EmojiBar(
                  label: 'Energie',
                  emojis: const [
                    '\u{1F50B}',
                    '\u{1F50B}',
                    '\u{1F50B}',
                    '\u{1F50B}',
                    '\u{1F50B}',
                  ],
                  value: energy,
                  onSelect: (v) => onRatingChanged('ratingsMorning.energy', v),
                ),
                const SizedBox(height: 12),
                EmojiBar(
                  label: 'Fokus',
                  emojis: const [
                    '\u{2B50}',
                    '\u{2B50}',
                    '\u{2B50}',
                    '\u{2B50}',
                    '\u{2B50}',
                  ],
                  value: focusRating,
                  onSelect: (v) => onRatingChanged('ratingsMorning.focus', v),
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Wie fühle ich mich heute?',
                  controller: feelingCtrl,
                  minLines: 1,
                  maxLines: 4,
                  focusNode: feelingNode,
                  onChanged: (v) => onTextChanged('morning.mood', v),
                ),
                const SizedBox(height: 8),
                LabeledField(
                  label: 'Was macht den Tag heute gut?',
                  controller: goodCtrl,
                  minLines: 1,
                  maxLines: 2,
                  focusNode: goodNode,
                  onChanged: (v) => onTextChanged('morning.goodThing', v),
                ),
                const SizedBox(height: 8),
                LabeledField(
                  label: 'Worauf will ich heute besonders achten?',
                  controller: focusCtrl,
                  minLines: 1,
                  maxLines: 2,
                  focusNode: focusNode,
                  onChanged: (v) => onTextChanged('morning.focus', v),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tagesziele und To-dos',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (curGoals.isNotEmpty) ...[
                  Text(
                    'Ziele',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final i in List<int>.generate(
                    curGoals.length.clamp(0, 3),
                    (i) => i,
                  ).where((i) => curGoals[i].trim().isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('\u2022 ${curGoals[i]}'),
                    ),
                ] else ...[
                  Text(
                    'Keine Ziele vorhanden.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (curTodos.isNotEmpty) ...[
                  Text(
                    'To-dos',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final i in List<int>.generate(
                    curTodos.length.clamp(0, 3),
                    (i) => i,
                  ).where((i) => curTodos[i].trim().isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('\u2022 ${curTodos[i]}'),
                    ),
                ] else ...[
                  Text(
                    'Keine To-dos vorhanden.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  static Widget _progressChip(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamilyFallback: const [
            'Segoe UI Emoji',
            'Apple Color Emoji',
            'Noto Color Emoji',
          ],
        ),
      ),
    );
  }
}
