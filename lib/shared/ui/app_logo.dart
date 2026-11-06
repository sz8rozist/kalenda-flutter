import 'package:flutter/material.dart';

/// A Kalenda márkajele (naptár pipával) – a `branding/profile.svg` vektoros mása, így élesen skálázódik és
/// kép-állomány nélkül is rajzolható (splash, fejlécek, ikon-generálás).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.markOnly = false});

  final double size;

  /// Csak a naptár-jel (kék négyzet nélkül): kék háttérre, pl. adaptív ikonhoz.
  final bool markOnly;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: LogoPainter(markOnly: markOnly));
}

class LogoPainter extends CustomPainter {
  const LogoPainter({this.markOnly = false});

  final bool markOnly;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64; // az SVG 64×64-es koordináta-rendszere
    canvas.save();
    canvas.scale(s);

    RRect rr(double x, double y, double w, double h, double r) => RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

    if (!markOnly) {
      final background = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ).createShader(const Rect.fromLTWH(4, 4, 56, 56));
      canvas.drawRRect(rr(4, 4, 56, 56, 16), background);
    }

    final pins = Paint()..color = const Color(0xFF1E3A8A);
    canvas.drawRRect(rr(17, 0, 6, 13, 3), pins);
    canvas.drawRRect(rr(41, 0, 6, 13, 3), pins);

    canvas.drawRRect(rr(11, 15, 42, 38, 8), Paint()..color = Colors.white);

    // A naptár fejléce: felül lekerekített sáv.
    final header = Path()
      ..moveTo(11, 23)
      ..arcToPoint(const Offset(19, 15), radius: const Radius.circular(8))
      ..lineTo(45, 15)
      ..arcToPoint(const Offset(53, 23), radius: const Radius.circular(8))
      ..lineTo(53, 29)
      ..lineTo(11, 29)
      ..close();
    canvas.drawPath(header, Paint()..color = const Color(0xFF1D4ED8));

    canvas.drawCircle(const Offset(42, 41), 5.5, Paint()..color = const Color(0xFFBFDBFE));

    final check = Path()
      ..moveTo(18, 34.5)
      ..lineTo(28, 44.5)
      ..lineTo(46, 24);
    canvas.drawPath(
      check,
      Paint()
        ..color = const Color(0xFF2563EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(LogoPainter oldDelegate) => oldDelegate.markOnly != markOnly;
}
