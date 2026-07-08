// lib/widgets/mosque_silhouette.dart
//
// A CustomPainter that draws a flat mosque skyline silhouette.
// Used as a background layer on the login screen and home screen header.
// Drawn in Primary Dark color at low opacity for a layered depth effect.

import 'package:flutter/material.dart';

class MosqueSilhouette extends StatelessWidget {
  final double height;
  final Color color;
  final double opacity;

  const MosqueSilhouette({
    super.key,
    this.height = 160,
    this.color = const Color(0xFF14584F),
    this.opacity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _MosquePainter(color: color),
      ),
    );
  }
}

class _MosquePainter extends CustomPainter {
  final Color color;
  const _MosquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // ── GROUND LINE ──
    // Everything sits on a base at 85% of the height
    final base = h * 0.85;

    // ── HELPER: draw a dome (arc) on top of a rectangular body ──
    void drawDomeBuilding({
      required double left,
      required double width,
      required double bodyTop,
      required double domeHeight,
    }) {
      final right = left + width;
      left + width / 2;

      // Dome (semicircle)
      final domeRect = Rect.fromLTRB(
        left, bodyTop - domeHeight, right, bodyTop,
      );
      canvas.drawArc(domeRect, 3.14159, 3.14159, true, paint);

      // Rectangular body below dome
      canvas.drawRect(Rect.fromLTRB(left, bodyTop, right, base), paint);
    }

    // ── HELPER: draw a minaret (tall thin tower with pointed tip) ──
    void drawMinaret({
      required double centerX,
      required double width,
      required double tipY,
    }) {
      final half = width / 2;

      // Pointed tip (triangle)
      final tip = Path()
        ..moveTo(centerX, tipY)
        ..lineTo(centerX - half, tipY + width * 1.2)
        ..lineTo(centerX + half, tipY + width * 1.2)
        ..close();
      canvas.drawPath(tip, paint);

      // Thin tower body
      canvas.drawRect(
        Rect.fromLTRB(
          centerX - half * 0.6,
          tipY + width * 1.2,
          centerX + half * 0.6,
          base,
        ),
        paint,
      );

      // Small balcony ring
      canvas.drawRect(
        Rect.fromLTRB(
          centerX - half,
          tipY + width * 2.2,
          centerX + half,
          tipY + width * 2.6,
        ),
        paint,
      );
    }

    // ── LAYOUT (all positions as fractions of width) ──

    // Far left small dome building
    drawDomeBuilding(
      left: w * 0.02,
      width: w * 0.10,
      bodyTop: base - h * 0.18,
      domeHeight: h * 0.09,
    );

    // Left minaret
    drawMinaret(
      centerX: w * 0.22,
      width: w * 0.04,
      tipY: h * 0.05,
    );

    // Left medium dome
    drawDomeBuilding(
      left: w * 0.18,
      width: w * 0.14,
      bodyTop: base - h * 0.22,
      domeHeight: h * 0.11,
    );

    // Central large dome (main mosque)
    drawDomeBuilding(
      left: w * 0.33,
      width: w * 0.34,
      bodyTop: base - h * 0.32,
      domeHeight: h * 0.22,
    );

    // Right minaret
    drawMinaret(
      centerX: w * 0.78,
      width: w * 0.04,
      tipY: h * 0.05,
    );

    // Right medium dome
    drawDomeBuilding(
      left: w * 0.68,
      width: w * 0.14,
      bodyTop: base - h * 0.22,
      domeHeight: h * 0.11,
    );

    // Far right small dome building
    drawDomeBuilding(
      left: w * 0.88,
      width: w * 0.10,
      bodyTop: base - h * 0.18,
      domeHeight: h * 0.09,
    );

    // Ground fill (below all buildings to screen bottom)
    canvas.drawRect(Rect.fromLTRB(0, base, w, h), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}