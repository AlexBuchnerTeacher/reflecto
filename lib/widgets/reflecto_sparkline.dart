import 'package:flutter/material.dart';

class ReflectoSparkline extends StatelessWidget {
  final List<int> points; // expected length 7, values 0..5
  final double height;
  final double width;
  final Color? color;
  final bool smooth;
  final bool showDots;

  const ReflectoSparkline({
    super.key,
    required this.points,
    this.height = 40,
    this.width = double.infinity,
    this.color,
    this.smooth = true,
    this.showDots = true,
  });

  @override
  Widget build(BuildContext context) {
    final stroke = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: _SparklinePainter(
          points: points,
          stroke: stroke,
          smooth: smooth,
          showDots: showDots,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> points;
  final Color stroke;
  final bool smooth;
  final bool showDots;

  _SparklinePainter({
    required this.points,
    required this.stroke,
    required this.smooth,
    required this.showDots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (points.isEmpty) return;
    final List<int> values =
        points.map((e) => (e.clamp(0, 5) as num).toInt()).toList();
    final maxV = 5.0;
    final minV = 0.0;
    final stepX = size.width / (values.length - 1);

    double yFor(double v) {
      final t = (v - minV) / (maxV - minV);
      return size.height - t * size.height; // invert y
    }

    if (smooth && values.length >= 3) {
      double x0 = 0, y0 = yFor(values[0].toDouble());
      path.moveTo(x0, y0);
      for (int i = 1; i < values.length; i++) {
        final x = i * stepX;
        final y = yFor(values[i].toDouble());
        final xm = (x0 + x) / 2;
        final ym = (y0 + y) / 2;
        path.quadraticBezierTo(x0, y0, xm, ym);
        x0 = x;
        y0 = y;
      }
      path.lineTo(x0, y0);
    } else {
      for (int i = 0; i < values.length; i++) {
        final x = i * stepX;
        final y = yFor(values[i].toDouble());
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, p);

    if (showDots) {
      final dotPaint = Paint()
        ..color = stroke
        ..style = PaintingStyle.fill;
      for (int i = 0; i < values.length; i++) {
        final x = i * stepX;
        final y = yFor(values[i].toDouble());
        canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.stroke != stroke ||
        oldDelegate.smooth != smooth ||
        oldDelegate.showDots != showDots;
  }
}
