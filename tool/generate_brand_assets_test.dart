// A márka PNG-ket (app-ikon, splash-logó) a vektoros `AppLogo`-ból állítja elő, hogy ne kézzel kelljen rajzolni:
//
//   flutter test tool/generate_brand_assets_test.dart
//
// Kimenet: assets/brand/logo.png (átlátszó sarkokkal), icon_foreground.png (adaptív ikon előtere),
// icon_ios.png (teljes felületű, alfa nélkül). Utána: dart run flutter_launcher_icons és dart run flutter_native_splash:create.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/shared/ui/app_logo.dart';

Future<void> _write(String path, int size, void Function(Canvas canvas, double size) draw) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  draw(canvas, size.toDouble());
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
  File(path).writeAsBytesSync(bytes.buffer.asUint8List());
}

void main() {
  test('márka-állományok előállítása', () async {
    Directory('assets/brand').createSync(recursive: true);

    // Teljes logó, átlátszó sarkokkal (splash, régi Android-ikon).
    await _write('assets/brand/logo.png', 1024, (c, s) => const LogoPainter().paint(c, Size.square(s)));

    // Adaptív ikon előtér: csak a naptár-jel, a biztonságos zónán belül (a 108 dp-s vászon közepén ~60%).
    await _write('assets/brand/icon_foreground.png', 1024, (c, s) {
      c.save();
      c.translate(s * 0.2, s * 0.2);
      const LogoPainter(markOnly: true).paint(c, Size.square(s * 0.6));
      c.restore();
    });

    // iOS: alfa nélküli, teljes felületű, lapos márkaszínű négyzet (a webes design), középen a jel.
    await _write('assets/brand/icon_ios.png', 1024, (c, s) {
      c.drawRect(Rect.fromLTWH(0, 0, s, s), Paint()..color = const Color(0xFF086288));
      c.save();
      c.translate(s * 0.17, s * 0.17);
      const LogoPainter(markOnly: true).paint(c, Size.square(s * 0.66));
      c.restore();
    });

    expect(File('assets/brand/logo.png').existsSync(), isTrue);
  });
}
