import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../theme/tokens.dart';

/// Widget für drei radiale Progress-Indikatoren (Fokus, Energie, Zufriedenheit)
class WeekRadialStats extends StatelessWidget {
  final double focusAvg;
  final double energyAvg;
  final double happinessAvg;

  const WeekRadialStats({
    super.key,
    required this.focusAvg,
    required this.energyAvg,
    required this.happinessAvg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RadialIndicator(label: 'Fokus', value: focusAvg, color: Colors.blue),
        _RadialIndicator(
          label: 'Energie',
          value: energyAvg,
          color: Colors.green,
        ),
        _RadialIndicator(
          label: 'Zufriedenheit',
          value: happinessAvg,
          color: Colors.orange,
        ),
      ],
    );
  }
}

class _RadialIndicator extends StatelessWidget {
  final String label;
  final double value; // 0-5
  final Color color;

  const _RadialIndicator({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / 5.0).clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: _RadialPainter(percentage: percentage, color: color),
            child: Center(
              child: Text(
                value.toStringAsFixed(1),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: ReflectoSpacing.s8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double percentage;
  final Color color;

  _RadialPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background circle (gray)
    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start at top
    final sweepAngle = 2 * math.pi * percentage;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RadialPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
