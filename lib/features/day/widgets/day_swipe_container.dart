import 'package:flutter/material.dart';

class DaySwipeContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const DaySwipeContainer({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final double? velocity = details.primaryVelocity;
        if (velocity == null) {
          return;
        }
        if (velocity < 0) {
          onSwipeLeft();
        } else if (velocity > 0) {
          onSwipeRight();
        }
      },
      child: child,
    );
  }
}
