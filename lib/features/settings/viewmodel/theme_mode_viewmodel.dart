import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_prefs.dart';

/// A megjelenés módja (ViewModel): rendszer / világos / sötét. A választás az eszközön marad.
class ThemeModeViewModel extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    Future.microtask(_load);
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await ref.read(localPrefsProvider.future);
    final saved = prefs?.getString(_key);
    final mode = ThemeMode.values.where((m) => m.name == saved).firstOrNull;
    if (mode != null && ref.mounted) state = mode;
  }

  Future<void> select(ThemeMode mode) async {
    state = mode;
    final prefs = await ref.read(localPrefsProvider.future);
    if (mode == ThemeMode.system) {
      await prefs?.remove(_key);
    } else {
      await prefs?.setString(_key, mode.name);
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeViewModel, ThemeMode>(ThemeModeViewModel.new);
