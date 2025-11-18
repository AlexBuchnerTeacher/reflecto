import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';

class LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final double? focusOrder;

  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.focusOrder,
  });

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      controller: controller,
      focusNode: focusNode,
      minLines: minLines,
      maxLines: maxLines,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textInputAction: (maxLines != null && maxLines == 1)
          ? TextInputAction.next
          : TextInputAction.newline,
      onChanged: onChanged,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: ReflectoSpacing.s8),
        focusOrder != null
            ? FocusTraversalOrder(
                order: NumericFocusOrder(focusOrder!),
                child: textField,
              )
            : textField,
      ],
    );
  }
}
