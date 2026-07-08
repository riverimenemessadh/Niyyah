// lib/widgets/empty_state.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitsEmptyState extends StatelessWidget {
  const HabitsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 140,
              child: CustomPaint(painter: _MosqueLinePainter()),
            ),
            const SizedBox(height: 24),
            Text(
              'No habits yet',
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '"The most beloved deeds to Allah are\nthe most consistent."',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B6B6B),
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '— Sahih Bukhari',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A7A6E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalsEmptyState extends StatelessWidget {
  const GoalsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 140,
              child: CustomPaint(painter: _KaabaLinePainter()),
            ),
            const SizedBox(height: 24),
            Text(
              'No active goals',
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '"Actions are judged by intentions."',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B6B6B),
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '— Sahih Bukhari',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4A843),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── MOSQUE PAINTER (habits) ── teal
class _MosqueLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A7A6E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final base = h * 0.78;

    canvas.drawLine(Offset(0, base), Offset(w, base), paint);

    final centerX = w * 0.5;
    final domeLeft = w * 0.25;
    final domeRight = w * 0.75;
    final domePeak = h * 0.28;
    final domeBase = h * 0.48;

    final domeRect = Rect.fromLTRB(domeLeft, domePeak, domeRight, domeBase + (domeBase - domePeak));
    canvas.drawArc(domeRect, 3.14159, 3.14159, false, paint);
    canvas.drawRect(Rect.fromLTRB(domeLeft, domeBase, domeRight, base), paint);

    final doorW = w * 0.12;
    final doorLeft = centerX - doorW / 2;
    final doorRight = centerX + doorW / 2;
    final doorBase = base;
    final doorTop = base - h * 0.16;
    final doorRect = Rect.fromLTRB(
      doorLeft,
      doorTop - (doorRight - doorLeft) / 2,
      doorRight,
      doorTop + (doorRight - doorLeft) / 2,
    );
    canvas.drawArc(doorRect, 3.14159, 3.14159, false, paint);
    canvas.drawLine(Offset(doorLeft, doorTop), Offset(doorLeft, doorBase), paint);
    canvas.drawLine(Offset(doorRight, doorTop), Offset(doorRight, doorBase), paint);

    final lmX = w * 0.2;
    final lmW = w * 0.055;
    canvas.drawRect(Rect.fromLTRB(lmX - lmW / 2, h * 0.18, lmX + lmW / 2, base), paint);
    final lmTip = Path()
      ..moveTo(lmX, h * 0.08)
      ..lineTo(lmX - lmW / 2, h * 0.18)
      ..lineTo(lmX + lmW / 2, h * 0.18)
      ..close();
    canvas.drawPath(lmTip, paint);
    canvas.drawLine(Offset(lmX - lmW * 0.9, h * 0.3), Offset(lmX + lmW * 0.9, h * 0.3), paint);

    final rmX = w * 0.8;
    final rmW = w * 0.055;
    canvas.drawRect(Rect.fromLTRB(rmX - rmW / 2, h * 0.18, rmX + rmW / 2, base), paint);
    final rmTip = Path()
      ..moveTo(rmX, h * 0.08)
      ..lineTo(rmX - rmW / 2, h * 0.18)
      ..lineTo(rmX + rmW / 2, h * 0.18)
      ..close();
    canvas.drawPath(rmTip, paint);
    canvas.drawLine(Offset(rmX - rmW * 0.9, h * 0.3), Offset(rmX + rmW * 0.9, h * 0.3), paint);

    final moonCX = w * 0.5;
    final moonCY = h * 0.06;
    final moonR = w * 0.07;
    canvas.drawCircle(Offset(moonCX, moonCY), moonR, paint);
    final cutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(moonCX + moonR * 0.55, moonCY - moonR * 0.1), moonR * 0.82, cutPaint);
    canvas.drawCircle(Offset(moonCX, moonCY), moonR, paint);

    final starPaint = Paint()
      ..color = const Color(0xFFD4A843)
      ..style = PaintingStyle.fill;

    void drawSmallStar(double cx, double cy, double r) {
      final pts = [
        Offset(cx, cy - r), Offset(cx + r * 0.3, cy - r * 0.3),
        Offset(cx + r, cy), Offset(cx + r * 0.3, cy + r * 0.3),
        Offset(cx, cy + r), Offset(cx - r * 0.3, cy + r * 0.3),
        Offset(cx - r, cy), Offset(cx - r * 0.3, cy - r * 0.3),
      ];
      final sp = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (final p in pts.skip(1)) sp.lineTo(p.dx, p.dy);
      sp.close();
      canvas.drawPath(sp, starPaint);
    }

    drawSmallStar(w * 0.34, h * 0.07, 4);
    drawSmallStar(w * 0.64, h * 0.05, 3.5);
    drawSmallStar(w * 0.72, h * 0.11, 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── KAABA PAINTER (goals) ── gold
class _KaabaLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4A843)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final base = h * 0.82;

    // ── KAABA CUBE (isometric-style front + side face) ──
    // Front face
    final fL = w * 0.22;
    final fR = w * 0.68;
    final fTop = h * 0.22;
    canvas.drawRect(Rect.fromLTRB(fL, fTop, fR, base), paint);

    // Side face (right, slight perspective)
    final sideRight = w * 0.84;
    final sideTopY = h * 0.30;
    final sidePath = Path()
      ..moveTo(fR, fTop)
      ..lineTo(sideRight, sideTopY)
      ..lineTo(sideRight, base)
      ..lineTo(fR, base)
      ..close();
    canvas.drawPath(sidePath, paint);


    // ── KISWA CLOTH BAND (horizontal stripe on front face) ──
    final bandY = fTop + (base - fTop) * 0.28;
    canvas.drawLine(Offset(fL, bandY), Offset(fR, bandY), paint);

    // Gold band (slightly thicker, same color but filled rect)
    final goldBandPaint = Paint()
      ..color = const Color(0xFFD4A843)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(fL, bandY - 1, fR, bandY + 4),
      goldBandPaint,
    );

    // ── DOOR (front face, centered) ──
    final doorW = (fR - fL) * 0.28;
    final doorCX = (fL + fR) / 2;
    final doorLeft = doorCX - doorW / 2;
    final doorRight = doorCX + doorW / 2;
    final doorTop = bandY + (base - bandY) * 0.08;
    // Door arch
    final archR = doorW / 2;
    final archCY = doorTop + archR;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(doorCX, archCY), radius: archR),
      3.14159,
      3.14159,
      false,
      paint,
    );
    canvas.drawLine(Offset(doorLeft, archCY), Offset(doorLeft, base), paint);
    canvas.drawLine(Offset(doorRight, archCY), Offset(doorRight, base), paint);

    // ── CRESCENT + STAR on top ──
    final moonCX = w * 0.38;
    final moonCY = h * 0.06;
    final moonR = w * 0.065;
    canvas.drawCircle(Offset(moonCX, moonCY), moonR, paint);
    final cutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(moonCX + moonR * 0.55, moonCY - moonR * 0.1),
      moonR * 0.82,
      cutPaint,
    );
    canvas.drawCircle(Offset(moonCX, moonCY), moonR, paint);

    // Small star next to crescent
    final starPaint = Paint()
      ..color = const Color(0xFFD4A843)
      ..style = PaintingStyle.fill;

    void drawStar(double cx, double cy, double r) {
      final pts = [
        Offset(cx, cy - r), Offset(cx + r * 0.3, cy - r * 0.3),
        Offset(cx + r, cy), Offset(cx + r * 0.3, cy + r * 0.3),
        Offset(cx, cy + r), Offset(cx - r * 0.3, cy + r * 0.3),
        Offset(cx - r, cy), Offset(cx - r * 0.3, cy - r * 0.3),
      ];
      final sp = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (final p in pts.skip(1)) sp.lineTo(p.dx, p.dy);
      sp.close();
      canvas.drawPath(sp, starPaint);
    }

    drawStar(w * 0.58, h * 0.05, 4.5);
    drawStar(w * 0.72, h * 0.10, 3);
    drawStar(w * 0.20, h * 0.10, 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}