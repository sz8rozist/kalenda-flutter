import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_prefs.dart';

/// Az alkalmazás nyelve (ViewModel). `null` = a készülék nyelvét követi. A választás az eszközön marad.
class LocaleViewModel extends Notifier<Locale?> {
  static const _key = 'app_language';
  static const supported = ['hu', 'en'];

  @override
  Locale? build() {
    // A mentett érték aszinkron töltődik be; amíg nincs meg, a rendszer nyelve él.
    Future.microtask(_load);
    return null;
  }

  Future<void> _load() async {
    final prefs = await ref.read(localPrefsProvider.future);
    final code = prefs?.getString(_key);
    if (code != null && supported.contains(code) && ref.mounted) state = Locale(code);
  }

  /// A nyelv beállítása; `null` a rendszer nyelve.
  Future<void> select(Locale? locale) async {
    state = locale;
    final prefs = await ref.read(localPrefsProvider.future);
    if (locale == null) {
      await prefs?.remove(_key);
    } else {
      await prefs?.setString(_key, locale.languageCode);
    }
  }
}

final localeProvider = NotifierProvider<LocaleViewModel, Locale?>(LocaleViewModel.new);
