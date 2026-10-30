import 'dart:math' as math;

import 'package:flutter/material.dart';

/// حلقه گرادیانت که برای نمایش پیشرفت تایمر/استاپ‌واچ استفاده می‌شه.
class TimerRing extends StatelessWidget {
  final double progress; // ۰.۰ تا ۱.۰
  final Color color;
  final Widget child;

  const TimerRing({
    super.key,
    required this.progress,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, color: color),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 14;
    const strokeWidth = 14.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // ─── حلقه پس‌زمینه ──────────────────────────
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color.withOpacity(0.12);
    canvas.drawCircle(center, radius, bg);

    // ─── حلقه پیشرفت ───────────────────────────
    if (progress > 0.001) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [color.withOpacity(0.7), color],
          startAngle: 0,
          endAngle: 2 * math.pi,
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect);

      canvas.drawArc(
        rect,
        -math.pi / 2, // شروع از بالا
        2 * math.pi * progress,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
