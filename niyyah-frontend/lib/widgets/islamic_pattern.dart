// lib/widgets/islamic_pattern.dart
//
// A CustomPainter that draws a subtle repeating 8-pointed star
// Islamic geometric pattern. Used at very low opacity (0.06) as a
// texture overlay on the login/home green background sections.

import 'dart:math';
import 'package:flutter/material.dart';

class IslamicPattern extends StatelessWidget {
  final Color color;
  final double opacity;

  const IslamicPattern({
    super.key,
    this.color = Colors.white,
    this.opacity = 0.06,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: const Size(double.infinity, double.infinity),
        painter: _PatternPainter(color: color),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Color color;
  const _PatternPainter({required this.color});

  // Draws a single 8-pointed star centered at (cx, cy) with outer radius r
  void _drawStar(Canvas canvas, Paint paint, double cx, double cy, double r) {
    final inner = r * 0.5; // inner radius of the star points
    final path = Path();
    for (int i = 0; i < 8; i++) {
      // Outer point
      final outerAngle = (i * 2 * pi / 8) - pi / 8;
      final ox = cx + r * cos(outerAngle);
      final oy = cy + r * sin(outerAngle);
      // Inner point (between two outer points)
      final innerAngle = outerAngle + pi / 8;
      final ix = cx + inner * cos(innerAngle);
      final iy = cy + inner * sin(innerAngle);

      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 48.0; // distance between star centers
    const starRadius = 14.0;

    // Tile across the entire widget size
    for (double y = 0; y < size.height + spacing; y += spacing) {
      for (double x = 0; x < size.width + spacing; x += spacing) {
        // Offset every other row for a staggered grid
        final offsetX = (y / spacing % 2 == 0) ? 0.0 : spacing / 2;
        _drawStar(canvas, paint, x + offsetX, y, starRadius);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}