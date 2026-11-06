import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_prefs.dart';

/// Az első indításkor megjelenő bevezető (ViewModel): `true`, ha még meg kell mutatni.
/// Ha az eszköz tárolója nem érhető el, nem mutatjuk (nem akarjuk minden indításkor megjeleníteni).
class OnboardingViewModel extends AsyncNotifier<bool> {
  static const _key = 'onboarding_seen';

  @override
  Future<bool> build() async {
    final prefs = await ref.watch(localPrefsProvider.future);
    if (prefs == null) return false;
    return !(prefs.getBool(_key) ?? false);
  }

  Future<void> finish() async {
    state = const AsyncData(false);
    final prefs = await ref.read(localPrefsProvider.future);
    await prefs?.setBool(_key, true);
  }
}

final onboardingProvider = AsyncNotifierProvider<OnboardingViewModel, bool>(OnboardingViewModel.new);
