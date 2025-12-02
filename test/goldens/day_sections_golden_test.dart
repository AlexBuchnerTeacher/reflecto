@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reflecto/features/day/sections/morning_section.dart';
import 'package:reflecto/features/day/sections/evening_section.dart';
import 'package:reflecto/features/day/sections/planning_section.dart';

void main() {
  group('MorningSection Golden Tests', () {
    testWidgets('MorningSection - collapsed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: MorningSection(
              expanded: false,
              onToggleExpanded: () {},
              feelingCtrl: TextEditingController(),
              goodCtrl: TextEditingController(),
              focusCtrl: TextEditingController(),
              feelingNode: FocusNode(),
              goodNode: FocusNode(),
              focusNode: FocusNode(),
              mood: null,
              energy: null,
              focusRating: null,
              curGoals: [],
              curTodos: [],
              onRatingChanged: (_, __) {},
              onTextChanged: (_, __) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MorningSection),
        matchesGoldenFile('goldens/morning_section_collapsed.png'),
      );
    });

    testWidgets('MorningSection - expanded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: MorningSection(
                expanded: true,
                onToggleExpanded: () {},
                feelingCtrl: TextEditingController(text: 'Ich fühle mich gut'),
                goodCtrl: TextEditingController(text: 'Gesunder Start'),
                focusCtrl: TextEditingController(text: 'Projekt abschließen'),
                feelingNode: FocusNode(),
                goodNode: FocusNode(),
                focusNode: FocusNode(),
                mood: 4,
                energy: 3,
                focusRating: 4,
                curGoals: ['Projekt fertigstellen', 'Sport machen'],
                curTodos: ['E-Mails beantworten', 'Meeting vorbereiten'],
                onRatingChanged: (_, __) {},
                onTextChanged: (_, __) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MorningSection),
        matchesGoldenFile('goldens/morning_section_expanded.png'),
      );
    });
  });

  group('EveningSection Golden Tests', () {
    testWidgets('EveningSection - collapsed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: EveningSection(
              expanded: false,
              onToggleExpanded: () {},
              goodCtrl: TextEditingController(),
              learnedCtrl: TextEditingController(),
              betterCtrl: TextEditingController(),
              gratefulCtrl: TextEditingController(),
              goodNode: FocusNode(),
              learnedNode: FocusNode(),
              betterNode: FocusNode(),
              gratefulNode: FocusNode(),
              mood: null,
              energy: null,
              happiness: null,
              curGoals: [],
              curTodos: [],
              visibleGoalIndices: [],
              visibleTodoIndices: [],
              goalChecks: [],
              todoChecks: [],
              onRatingChanged: (_, __) {},
              onTextChanged: (_, __) {},
              onGoalCheckChanged: (_, __) async {},
              onTodoCheckChanged: (_, __) async {},
              onMoveGoalToTomorrow: (_) async {},
              onMoveTodoToTomorrow: (_) async {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(EveningSection),
        matchesGoldenFile('goldens/evening_section_collapsed.png'),
      );
    });

    testWidgets('EveningSection - expanded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: EveningSection(
                expanded: true,
                onToggleExpanded: () {},
                goodCtrl: TextEditingController(text: 'Produktiver Tag'),
                learnedCtrl: TextEditingController(text: 'Neue Methode'),
                betterCtrl: TextEditingController(text: 'Mehr Pausen'),
                gratefulCtrl: TextEditingController(text: 'Familie'),
                goodNode: FocusNode(),
                learnedNode: FocusNode(),
                betterNode: FocusNode(),
                gratefulNode: FocusNode(),
                mood: 4,
                energy: 3,
                happiness: 5,
                curGoals: ['Projekt fertigstellen', 'Sport machen'],
                curTodos: ['E-Mails', 'Meeting', 'Einkaufen'],
                visibleGoalIndices: [0, 1],
                visibleTodoIndices: [0, 1, 2],
                goalChecks: [true, false],
                todoChecks: [true, true, false],
                onRatingChanged: (_, __) {},
                onTextChanged: (_, __) {},
                onGoalCheckChanged: (_, __) async {},
                onTodoCheckChanged: (_, __) async {},
                onMoveGoalToTomorrow: (_) async {},
                onMoveTodoToTomorrow: (_) async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(EveningSection),
        matchesGoldenFile('goldens/evening_section_expanded.png'),
      );
    });
  });

  group('PlanningSection Golden Tests', () {
    testWidgets('PlanningSection - collapsed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: PlanningSection(
              expanded: false,
              onToggleExpanded: () {},
              goalCtrls: [TextEditingController()],
              todoCtrls: [TextEditingController(), TextEditingController()],
              attitudeCtrl: TextEditingController(),
              notesCtrl: TextEditingController(),
              goalNodes: [FocusNode()],
              todoNodes: [FocusNode(), FocusNode()],
              attitudeNode: FocusNode(),
              notesNode: FocusNode(),
              onAddGoal: () {},
              onRemoveGoal: (_) {},
              onAddTodo: () {},
              onRemoveTodo: (_) {},
              onReorderGoals: (_, __) {},
              onReorderTodos: (_, __) {},
              onGoalsChanged: () {},
              onTodosChanged: () {},
              onReflectionChanged: (_) {},
              onNotesChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(PlanningSection),
        matchesGoldenFile('goldens/planning_section_collapsed.png'),
      );
    });

    testWidgets('PlanningSection - expanded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: PlanningSection(
                expanded: true,
                onToggleExpanded: () {},
                goalCtrls: [
                  TextEditingController(text: 'Meeting vorbereiten'),
                  TextEditingController(text: 'Code Review'),
                ],
                todoCtrls: [
                  TextEditingController(text: 'E-Mails checken'),
                  TextEditingController(text: 'Team-Call um 10'),
                  TextEditingController(text: 'Tests schreiben'),
                ],
                attitudeCtrl: TextEditingController(text: 'Fokussiert angehen'),
                notesCtrl: TextEditingController(text: 'Früh anfangen'),
                goalNodes: [FocusNode(), FocusNode()],
                todoNodes: [FocusNode(), FocusNode(), FocusNode()],
                attitudeNode: FocusNode(),
                notesNode: FocusNode(),
                onAddGoal: () {},
                onRemoveGoal: (_) {},
                onAddTodo: () {},
                onRemoveTodo: (_) {},
                onReorderGoals: (_, __) {},
                onReorderTodos: (_, __) {},
                onGoalsChanged: () {},
                onTodosChanged: () {},
                onReflectionChanged: (_) {},
                onNotesChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(PlanningSection),
        matchesGoldenFile('goldens/planning_section_expanded.png'),
      );
    });
  });
}
