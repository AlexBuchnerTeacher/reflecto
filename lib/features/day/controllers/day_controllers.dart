import 'package:flutter/widgets.dart';

class DayControllers {
  // Evening (today)
  final TextEditingController eveningGoodCtrl = TextEditingController();
  final TextEditingController eveningLearnedCtrl = TextEditingController();
  final TextEditingController eveningBetterCtrl = TextEditingController();
  final TextEditingController eveningGratefulCtrl = TextEditingController();
  final FocusNode eveningGoodNode = FocusNode();
  final FocusNode eveningLearnedNode = FocusNode();
  final FocusNode eveningBetterNode = FocusNode();
  final FocusNode eveningGratefulNode = FocusNode();

  // Morning (today)
  final TextEditingController morningFeelingCtrl = TextEditingController();
  final TextEditingController morningGoodCtrl = TextEditingController();
  final TextEditingController morningFocusCtrl = TextEditingController();
  final FocusNode morningFeelingNode = FocusNode();
  final FocusNode morningGoodNode = FocusNode();
  final FocusNode morningFocusNode = FocusNode();

  // Planning (tomorrow)
  // Standard: 1 Ziel, 2 To-dos
  final List<TextEditingController> goalCtrls = [TextEditingController()];
  final List<TextEditingController> todoCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];
  final TextEditingController attitudeCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();

  final List<FocusNode> goalNodes = [FocusNode()];
  final List<FocusNode> todoNodes = [FocusNode(), FocusNode()];
  final FocusNode attitudeNode = FocusNode();
  final FocusNode notesNode = FocusNode();

  void ensureGoalsLen(int len) {
    _ensureCtrlLen(goalCtrls, goalNodes, len);
  }

  void ensureTodosLen(int len) {
    _ensureCtrlLen(todoCtrls, todoNodes, len);
  }

  void _ensureCtrlLen(
    List<TextEditingController> ctrls,
    List<FocusNode> nodes,
    int len,
  ) {
    while (ctrls.length < len) {
      ctrls.add(TextEditingController());
    }
    while (nodes.length < len) {
      nodes.add(FocusNode());
    }
  }

  void dispose() {
    eveningGoodCtrl.dispose();
    eveningLearnedCtrl.dispose();
    eveningBetterCtrl.dispose();
    eveningGratefulCtrl.dispose();
    eveningGoodNode.dispose();
    eveningLearnedNode.dispose();
    eveningBetterNode.dispose();
    eveningGratefulNode.dispose();

    morningFeelingCtrl.dispose();
    morningGoodCtrl.dispose();
    morningFocusCtrl.dispose();
    morningFeelingNode.dispose();
    morningGoodNode.dispose();
    morningFocusNode.dispose();

    for (final c in goalCtrls) {
      c.dispose();
    }
    for (final c in todoCtrls) {
      c.dispose();
    }
    for (final n in goalNodes) {
      n.dispose();
    }
    for (final n in todoNodes) {
      n.dispose();
    }

    attitudeCtrl.dispose();
    notesCtrl.dispose();
    attitudeNode.dispose();
    notesNode.dispose();
  }
}
