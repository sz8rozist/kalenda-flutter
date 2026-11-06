import 'package:flutter/services.dart';

/// Finom rezgés-visszajelzés a fontos pillanatokhoz (választás, siker, hiba).
class Haptics {
  Haptics._();

  static void select() => HapticFeedback.selectionClick();
  static void light() => HapticFeedback.lightImpact();
  static void success() => HapticFeedback.mediumImpact();
  static void error() => HapticFeedback.heavyImpact();
}
