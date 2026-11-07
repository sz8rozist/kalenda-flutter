import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/features/settings/viewmodel/theme_mode_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('alapból a rendszer megjelenését követi', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('a sötét mód azonnal érvényes, és újraindítás után is megmarad', () async {
    final first = ProviderContainer();
    await first.read(themeModeProvider.notifier).select(ThemeMode.dark);
    expect(first.read(themeModeProvider), ThemeMode.dark);
    first.dispose();

    final second = ProviderContainer();
    addTearDown(second.dispose);
    second.read(themeModeProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(second.read(themeModeProvider), ThemeMode.dark);
  });

  test('a rendszerre visszaváltás törli a mentést; ismeretlen érték nem számít', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(themeModeProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(container.read(themeModeProvider), ThemeMode.light);

    await container.read(themeModeProvider.notifier).select(ThemeMode.system);
    expect((await SharedPreferences.getInstance()).getString('theme_mode'), isNull);

    SharedPreferences.setMockInitialValues({'theme_mode': 'nem-letezik'});
    final other = ProviderContainer();
    addTearDown(other.dispose);
    other.read(themeModeProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(other.read(themeModeProvider), ThemeMode.system);
  });
}
