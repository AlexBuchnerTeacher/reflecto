import 'package:flutter/material.dart';

class LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;

  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
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
        ),
      ],
    );
  }
}
