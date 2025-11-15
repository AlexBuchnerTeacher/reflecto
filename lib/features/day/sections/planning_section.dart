import 'package:flutter/material.dart';

import '../widgets/labeled_field.dart';
import '../../../widgets/reflecto_card.dart';

class PlanningSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggleExpanded;

  final List<TextEditingController> goalCtrls;
  final List<TextEditingController> todoCtrls;
  final TextEditingController attitudeCtrl;
  final TextEditingController notesCtrl;

  final List<FocusNode> goalNodes;
  final List<FocusNode> todoNodes;
  final FocusNode attitudeNode;
  final FocusNode notesNode;

  final VoidCallback onAddGoal;
  final void Function(int index) onRemoveGoal;
  final VoidCallback onAddTodo;
  final void Function(int index) onRemoveTodo;

  final VoidCallback onGoalsChanged;
  final VoidCallback onTodosChanged;
  final void Function(String value) onReflectionChanged;
  final void Function(String value) onNotesChanged;

  const PlanningSection({
    super.key,
    required this.expanded,
    required this.onToggleExpanded,
    required this.goalCtrls,
    required this.todoCtrls,
    required this.attitudeCtrl,
    required this.notesCtrl,
    required this.goalNodes,
    required this.todoNodes,
    required this.attitudeNode,
    required this.notesNode,
    required this.onAddGoal,
    required this.onRemoveGoal,
    required this.onAddTodo,
    required this.onRemoveTodo,
    required this.onGoalsChanged,
    required this.onTodosChanged,
    required this.onReflectionChanged,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final nonEmptyGoals = goalCtrls
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .length;
    final nonEmptyTodos = todoCtrls
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .length;

    return ReflectoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '\u{1F5D3} Planung für morgen',
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
                    'Ziele $nonEmptyGoals/${goalCtrls.length} · To-dos $nonEmptyTodos/${todoCtrls.length}',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text(
                  'Definiere klare Ziele und einen ruhigen Fokus für morgen.',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ziele',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...List.generate(goalCtrls.length, (i) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i == goalCtrls.length - 1 ? 0 : 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: LabeledField(
                            label: 'Ziel ${i + 1}',
                            controller: goalCtrls[i],
                            minLines: 1,
                            maxLines: 2,
                            focusNode: i < goalNodes.length
                                ? goalNodes[i]
                                : null,
                            onChanged: (_) => onGoalsChanged(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (goalCtrls.length > 3)
                          IconButton(
                            tooltip: 'Ziel entfernen',
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => onRemoveGoal(i),
                          ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onAddGoal,
                    icon: const Icon(Icons.add),
                    label: const Text('Ziel hinzufügen'),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'To-dos',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...List.generate(todoCtrls.length, (i) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i == todoCtrls.length - 1 ? 0 : 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: LabeledField(
                            label: 'To-do ${i + 1}',
                            controller: todoCtrls[i],
                            minLines: 1,
                            maxLines: 2,
                            focusNode: i < todoNodes.length
                                ? todoNodes[i]
                                : null,
                            onChanged: (_) => onTodosChanged(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (todoCtrls.length > 3)
                          IconButton(
                            tooltip: 'To-do entfernen',
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => onRemoveTodo(i),
                          ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onAddTodo,
                    icon: const Icon(Icons.add),
                    label: const Text('To-do hinzufügen'),
                  ),
                ),
                const SizedBox(height: 8),
                LabeledField(
                  label: 'Reflexion',
                  controller: attitudeCtrl,
                  minLines: 1,
                  maxLines: 2,
                  focusNode: attitudeNode,
                  onChanged: onReflectionChanged,
                ),
                const SizedBox(height: 8),
                LabeledField(
                  label: 'Freies Notizfeld',
                  controller: notesCtrl,
                  minLines: 1,
                  maxLines: 2,
                  focusNode: notesNode,
                  onChanged: onNotesChanged,
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
