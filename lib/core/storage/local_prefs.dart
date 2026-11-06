import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Az eszközön tárolt apró beállítások (kedvencek, bevezető látva…). Ha a tár nem érhető el, `null` –
/// ilyenkor az érintett funkciók egyszerűen kimaradnak, az app használható marad.
final localPrefsProvider = FutureProvider<SharedPreferences?>((ref) async {
  try {
    return await SharedPreferences.getInstance();
  } catch (_) {
    return null;
  }
});
