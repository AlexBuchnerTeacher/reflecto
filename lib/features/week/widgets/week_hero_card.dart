import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../widgets/reflecto_card.dart';
import '../../../theme/tokens.dart';

/// Hero Card mit zirkulärem Fortschritt für die Wochenübersicht.
///
/// Zeigt einen großen kreisförmigen Progress-Indikator mit Prozentsatz
/// der Wochenvervollständigung (basierend auf Habits, To-dos, Journal).
class WeekHeroCard extends StatelessWidget {
  final double completionPercent; // 0.0 - 1.0
  final String weekLabel; // z.B. "KW 46"
  final String dateRange; // z.B. "13.11. - 19.11."

  const WeekHeroCard({
    super.key,
    required this.completionPercent,
    required this.weekLabel,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percent = (completionPercent * 100).clamp(0, 100).toInt();

    return ReflectoCard(
      padding: const EdgeInsets.all(ReflectoSpacing.s24),
      child: Column(
        children: [
          // Kreisförmiger Fortschritt
          SizedBox(
            width: 180,
            height: 180,
            child: CustomPaint(
              painter: _CircularProgressPainter(
                progress: completionPercent,
                backgroundColor: cs.surfaceContainerHighest,
                progressColor: cs.primary,
                textColor: cs.onSurface,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                    ),
                    Text(
                      'vervollständigt',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: ReflectoSpacing.s16),

          // Motivationstext
          Text(
            _getMotivationText(percent),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  String _getMotivationText(int percent) {
    if (percent >= 80) return 'Fantastische Woche! 🌟';
    if (percent >= 60) return 'Du machst große Fortschritte! 💪';
    if (percent >= 40) return 'Weiter so, du bist auf dem Weg! 🚀';
    if (percent >= 20) return 'Jeder Schritt zählt! 🌱';
    return 'Die Woche hat gerade erst begonnen! ✨';
  }
}

/// CustomPainter für kreisförmigen Fortschrittsindikator.
class _CircularProgressPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final Color backgroundColor;
  final Color progressColor;
  final Color textColor;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;

    // Hintergrund-Kreis
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Fortschritts-Bogen
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start oben
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}
