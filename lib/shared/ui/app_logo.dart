import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A Kalenda márkajele a webes designból: naptár pipával, lekerekített négyzetben. Vektoros, így élesen skálázódik és
/// kép-állomány nélkül is rajzolható (splash, fejlécek, ikon-generálás).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.markOnly = false, this.onBrand = false});

  final double size;

  /// Csak a naptár-jel (négyzet nélkül): az adaptív ikon előteréhez, márkaszínű háttérre.
  final bool markOnly;

  /// Márkaszínű háttéren (fejléc) fehér négyzet, márkaszínű jellel; egyébként márkaszínű négyzet, fehér jellel.
  final bool onBrand;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Kalenda',
    image: true,
    child: ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: LogoPainter(markOnly: markOnly, onBrand: onBrand),
      ),
    ),
  );
}

class LogoPainter extends CustomPainter {
  const LogoPainter({this.markOnly = false, this.onBrand = false});

  final bool markOnly;
  final bool onBrand;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64; // 64×64-es koordináta-rendszer
    canvas.save();
    canvas.scale(s);

    final glyphColor = markOnly || !onBrand ? Colors.white : AppColors.brand;

    if (!markOnly) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(2, 2, 60, 60), const Radius.circular(17)),
        Paint()..color = onBrand ? Colors.white : AppColors.brand,
      );
    }

    // A jel a webes design 24×24-es ikonja (naptár pipával), a négyzet közepére skálázva.
    const scale = 1.5;
    canvas.translate((64 - 24 * scale) / 2, (64 - 24 * scale) / 2);
    canvas.scale(scale);

    final stroke = Paint()
      ..color = glyphColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(3, 5, 18, 16), const Radius.circular(3)), stroke);
    canvas.drawPath(
      Path()
        ..moveTo(8, 3)
        ..lineTo(8, 7)
        ..moveTo(16, 3)
        ..lineTo(16, 7)
        ..moveTo(3, 10)
        ..lineTo(21, 10)
        ..moveTo(9, 15)
        ..lineTo(11, 17)
        ..lineTo(15, 13),
      stroke,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(LogoPainter oldDelegate) => oldDelegate.markOnly != markOnly || oldDelegate.onBrand != onBrand;
}
