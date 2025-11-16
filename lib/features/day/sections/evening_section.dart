import 'package:flutter/material.dart';

import '../widgets/emoji_bar.dart';
import '../widgets/labeled_field.dart';
import '../../../widgets/reflecto_card.dart';
import '../../../theme/tokens.dart';

class EveningSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggleExpanded;

  final TextEditingController goodCtrl;
  final TextEditingController learnedCtrl;
  final TextEditingController betterCtrl;
  final TextEditingController gratefulCtrl;

  final FocusNode goodNode;
  final FocusNode learnedNode;
  final FocusNode betterNode;
  final FocusNode gratefulNode;

  final int? mood;
  final int? energy;
  final int? happiness;

  final List<String> curGoals;
  final List<String> curTodos;
  final List<int> visibleGoalIndices;
  final List<int> visibleTodoIndices;

  final List<bool> goalChecks;
  final List<bool> todoChecks;

  final void Function(String fieldPath, int value) onRatingChanged;
  final void Function(String fieldPath, String value) onTextChanged;
  final Future<void> Function(int index, bool value) onGoalCheckChanged;
  final Future<void> Function(int index, bool value) onTodoCheckChanged;
  final Future<void> Function(int index) onMoveGoalToTomorrow;
  final Future<void> Function(int index) onMoveTodoToTomorrow;

  const EveningSection({
    super.key,
    required this.expanded,
    required this.onToggleExpanded,
    required this.goodCtrl,
    required this.learnedCtrl,
    required this.betterCtrl,
    required this.gratefulCtrl,
    required this.goodNode,
    required this.learnedNode,
    required this.betterNode,
    required this.gratefulNode,
    required this.mood,
    required this.energy,
    required this.happiness,
    required this.curGoals,
    required this.curTodos,
    required this.visibleGoalIndices,
    required this.visibleTodoIndices,
    required this.goalChecks,
    required this.todoChecks,
    required this.onRatingChanged,
    required this.onTextChanged,
    required this.onGoalCheckChanged,
    required this.onTodoCheckChanged,
    required this.onMoveGoalToTomorrow,
    required this.onMoveTodoToTomorrow,
  });

  @override
  Widget build(BuildContext context) {
    final goalsChecked = visibleGoalIndices
        .where((i) => i < goalChecks.length && goalChecks[i])
        .length;
    final todosChecked = visibleTodoIndices
        .where((i) => i < todoChecks.length && todoChecks[i])
        .length;

    final fieldsFilled = [
      goodCtrl.text.trim(),
      learnedCtrl.text.trim(),
      betterCtrl.text.trim(),
      gratefulCtrl.text.trim(),
    ].where((e) => e.isNotEmpty).length;

    return ReflectoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '\u{1F307} Abendreflexion',
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
              const SizedBox(width: ReflectoSpacing.s8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _progressChip(
                    context,
                    'Ziele $goalsChecked/${visibleGoalIndices.length}'
                    ' · To-dos $todosChecked/${visibleTodoIndices.length}'
                    ' · Felder $fieldsFilled/4',
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
          const SizedBox(height: 4),
          AnimatedCrossFade(
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reflektiere deinen Tag und schlie\u00DFe ihn bewusst ab.',
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 8),
                const Text(
                  'R\u00FCckblick auf deine Planung',
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
                  for (final i in visibleGoalIndices)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: i < goalChecks.length ? goalChecks[i] : false,
                      onChanged: (v) {
                        onGoalCheckChanged(i, v ?? false);
                      },
                      title: Opacity(
                        opacity: i < goalChecks.length && goalChecks[i]
                            ? 0.6
                            : 1.0,
                        child: Text(curGoals[i]),
                      ),
                      secondary: (i >= goalChecks.length || !goalChecks[i])
                          ? IconButton(
                              tooltip: 'F\u00FCr morgen \u00FCbernehmen',
                              icon: const Icon(Icons.redo_rounded),
                              onPressed: () {
                                onMoveGoalToTomorrow(i);
                              },
                            )
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                ] else ...[
                  const Text('Keine Ziele von gestern vorhanden.'),
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
                  for (final i in visibleTodoIndices)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: i < todoChecks.length ? todoChecks[i] : false,
                      onChanged: (v) {
                        onTodoCheckChanged(i, v ?? false);
                      },
                      title: Opacity(
                        opacity: i < todoChecks.length && todoChecks[i]
                            ? 0.6
                            : 1.0,
                        child: Text(curTodos[i]),
                      ),
                      secondary: (i >= todoChecks.length || !todoChecks[i])
                          ? IconButton(
                              tooltip: 'F\u00FCr morgen \u00FCbernehmen',
                              icon: const Icon(Icons.redo_rounded),
                              onPressed: () {
                                onMoveTodoToTomorrow(i);
                              },
                            )
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                ] else ...[
                  const Text('Keine To-dos von gestern vorhanden.'),
                ],
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Was lief heute gut?',
                  controller: goodCtrl,
                  minLines: 1,
                  maxLines: 2,
                  focusNode: goodNode,
                  onChanged: (v) => onTextChanged('evening.good', v),
                ),
                const SizedBox(height: 8),
                LabeledField(
                  label: 'Was habe ich gelernt oder erkannt?',
                  controller: learnedCtrl,
                  minLines: 1,
                  maxLines: 2,
                  focusNode: learnedNode,
                  onChanged: (v) => onTextChanged('evening.learned', v),
                ),
                const SizedBox(height: 8),
                LabeledField(
                  label: 'Was h\u00E4tte besser laufen k\u00F6nnen?',
                  controller: betterCtrl,
                  minLines: 1,
                  maxLines: 2,
                  focusNode: betterNode,
                  onChanged: (v) => onTextChanged('evening.improve', v),
                ),
                const SizedBox(height: 8),
                LabeledField(
                  label: 'Wof\u00FCr bin ich dankbar?',
                  controller: gratefulCtrl,
                  minLines: 1,
                  maxLines: 2,
                  focusNode: gratefulNode,
                  onChanged: (v) => onTextChanged('evening.gratitude', v),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 8),
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
                  onSelect: (v) => onRatingChanged('ratingsEvening.mood', v),
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
                  onSelect: (v) => onRatingChanged('ratingsEvening.energy', v),
                ),
                const SizedBox(height: 12),
                EmojiBar(
                  label: 'Zufriedenheit',
                  emojis: const [
                    '\u{2B50}',
                    '\u{2B50}',
                    '\u{2B50}',
                    '\u{2B50}',
                    '\u{2B50}',
                  ],
                  value: happiness,
                  onSelect: (v) =>
                      onRatingChanged('ratingsEvening.happiness', v),
                ),
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
