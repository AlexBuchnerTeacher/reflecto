import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/tokens.dart';
import '../../../providers/streak_providers.dart';
import '../controllers/day_controllers.dart';
import '../sections/morning_section.dart';
import '../sections/evening_section.dart';
import '../sections/planning_section.dart';
import '../widgets/day_streak_widget.dart';
import '../widgets/day_week_carousel.dart';
import '../widgets/day_swipe_container.dart';

class DayShellProps {
  final DateTime selected;
  final DateTime tomorrow;
  final bool pending;

  final int? morningMood;
  final int? morningEnergy;
  final int? morningFocus;

  final int? eveningMood;
  final int? eveningEnergy;
  final int? eveningHappiness;

  final List<String> curGoals;
  final List<String> curTodos;
  final List<int> visibleGoalIndices;
  final List<int> visibleTodoIndices;
  final List<bool> goalChecks;
  final List<bool> todoChecks;

  final DayControllers controllers;

  final VoidCallback onToggleMorning;
  final VoidCallback onToggleEvening;
  final VoidCallback onTogglePlanning;

  final bool expMorning;
  final bool expEvening;
  final bool expPlanning;

  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final ValueChanged<DateTime> onDateSelected;

  final void Function(String field, int value) onMorningRatingChanged;
  final void Function(String field, String value) onMorningTextChanged;

  final void Function(String field, int value) onEveningRatingChanged;
  final void Function(String field, String value) onEveningTextChanged;
  final Future<void> Function(int index, bool value) onGoalCheckChanged;
  final Future<void> Function(int index, bool value) onTodoCheckChanged;
  final Future<void> Function(int index) onMoveGoalToTomorrow;
  final Future<void> Function(int index) onMoveTodoToTomorrow;

  final VoidCallback onAddGoal;
  final void Function(int index) onRemoveGoal;
  final VoidCallback onAddTodo;
  final void Function(int index) onRemoveTodo;
  final void Function(int oldIndex, int newIndex) onReorderGoals;
  final void Function(int oldIndex, int newIndex) onReorderTodos;
  final VoidCallback onGoalsChanged;
  final VoidCallback onTodosChanged;
  final void Function(String value) onReflectionChanged;
  final void Function(String value) onNotesChanged;

  const DayShellProps({
    required this.selected,
    required this.tomorrow,
    required this.pending,
    required this.morningMood,
    required this.morningEnergy,
    required this.morningFocus,
    required this.eveningMood,
    required this.eveningEnergy,
    required this.eveningHappiness,
    required this.curGoals,
    required this.curTodos,
    required this.visibleGoalIndices,
    required this.visibleTodoIndices,
    required this.goalChecks,
    required this.todoChecks,
    required this.controllers,
    required this.onToggleMorning,
    required this.onToggleEvening,
    required this.onTogglePlanning,
    required this.expMorning,
    required this.expEvening,
    required this.expPlanning,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onDateSelected,
    required this.onMorningRatingChanged,
    required this.onMorningTextChanged,
    required this.onEveningRatingChanged,
    required this.onEveningTextChanged,
    required this.onGoalCheckChanged,
    required this.onTodoCheckChanged,
    required this.onMoveGoalToTomorrow,
    required this.onMoveTodoToTomorrow,
    required this.onAddGoal,
    required this.onRemoveGoal,
    required this.onAddTodo,
    required this.onRemoveTodo,
    required this.onReorderGoals,
    required this.onReorderTodos,
    required this.onGoalsChanged,
    required this.onTodosChanged,
    required this.onReflectionChanged,
    required this.onNotesChanged,
  });
}

class DayShell extends StatelessWidget {
  final DayShellProps props;

  const DayShell({super.key, required this.props});

  @override
  Widget build(BuildContext context) {
    final DayControllers c = props.controllers;
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ReflectoBreakpoints.contentMax,
            ),
            child: FocusTraversalGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: DayWeekCarousel(
                      selected: props.selected,
                      onSelected: props.onDateSelected,
                    ),
                  ),
                  SizedBox(height: ReflectoSpacing.s8),
                  Expanded(
                    child: DaySwipeContainer(
                      onSwipeLeft: props.onSwipeLeft,
                      onSwipeRight: props.onSwipeRight,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          ReflectoSpacing.s12,
                          ReflectoSpacing.s8,
                          ReflectoSpacing.s12,
                          ReflectoSpacing.s12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            MorningSection(
                              expanded: props.expMorning,
                              onToggleExpanded: props.onToggleMorning,
                              feelingCtrl: c.morningFeelingCtrl,
                              goodCtrl: c.morningGoodCtrl,
                              focusCtrl: c.morningFocusCtrl,
                              feelingNode: c.morningFeelingNode,
                              goodNode: c.morningGoodNode,
                              focusNode: c.morningFocusNode,
                              mood: props.morningMood,
                              energy: props.morningEnergy,
                              focusRating: props.morningFocus,
                              curGoals: props.curGoals,
                              curTodos: props.curTodos,
                              onRatingChanged: props.onMorningRatingChanged,
                              onTextChanged: props.onMorningTextChanged,
                            ),
                            const SizedBox(height: ReflectoSpacing.s24),
                            EveningSection(
                              expanded: props.expEvening,
                              onToggleExpanded: props.onToggleEvening,
                              goodCtrl: c.eveningGoodCtrl,
                              learnedCtrl: c.eveningLearnedCtrl,
                              betterCtrl: c.eveningBetterCtrl,
                              gratefulCtrl: c.eveningGratefulCtrl,
                              goodNode: c.eveningGoodNode,
                              learnedNode: c.eveningLearnedNode,
                              betterNode: c.eveningBetterNode,
                              gratefulNode: c.eveningGratefulNode,
                              mood: props.eveningMood,
                              energy: props.eveningEnergy,
                              happiness: props.eveningHappiness,
                              curGoals: props.curGoals,
                              curTodos: props.curTodos,
                              visibleGoalIndices: props.visibleGoalIndices,
                              visibleTodoIndices: props.visibleTodoIndices,
                              goalChecks: props.goalChecks,
                              todoChecks: props.todoChecks,
                              onRatingChanged: props.onEveningRatingChanged,
                              onTextChanged: props.onEveningTextChanged,
                              onGoalCheckChanged: props.onGoalCheckChanged,
                              onTodoCheckChanged: props.onTodoCheckChanged,
                              onMoveGoalToTomorrow: props.onMoveGoalToTomorrow,
                              onMoveTodoToTomorrow: props.onMoveTodoToTomorrow,
                            ),
                            const SizedBox(height: ReflectoSpacing.s24),
                            PlanningSection(
                              expanded: props.expPlanning,
                              onToggleExpanded: props.onTogglePlanning,
                              goalCtrls: c.goalCtrls,
                              todoCtrls: c.todoCtrls,
                              attitudeCtrl: c.attitudeCtrl,
                              notesCtrl: c.notesCtrl,
                              goalNodes: c.goalNodes,
                              todoNodes: c.todoNodes,
                              attitudeNode: c.attitudeNode,
                              notesNode: c.notesNode,
                              onAddGoal: props.onAddGoal,
                              onRemoveGoal: props.onRemoveGoal,
                              onAddTodo: props.onAddTodo,
                              onRemoveTodo: props.onRemoveTodo,
                              onReorderGoals: props.onReorderGoals,
                              onReorderTodos: props.onReorderTodos,
                              onGoalsChanged: props.onGoalsChanged,
                              onTodosChanged: props.onTodosChanged,
                              onReflectionChanged: props.onReflectionChanged,
                              onNotesChanged: props.onNotesChanged,
                            ),
                            const SizedBox(height: ReflectoSpacing.s8),
                            Consumer(
                              builder:
                                  (BuildContext context, WidgetRef ref, _) {
                                    final info = ref.watch(streakInfoProvider);
                                    return DayStreakWidget(
                                      current: info?.current ?? 0,
                                      longest: info?.longest ?? 0,
                                    );
                                  },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
