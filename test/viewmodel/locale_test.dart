import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/features/settings/viewmodel/locale_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('alapból a rendszer nyelvét követi (null)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(localeProvider), isNull);
  });

  test('a kiválasztott nyelv azonnal érvényes, és újraindítás után is megmarad', () async {
    final first = ProviderContainer();
    await first.read(localeProvider.notifier).select(const Locale('en'));
    expect(first.read(localeProvider), const Locale('en'));
    first.dispose();

    final second = ProviderContainer();
    addTearDown(second.dispose);
    second.read(localeProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(second.read(localeProvider), const Locale('en'));
  });

  test('a rendszer nyelvére visszaváltás törli a mentést', () async {
    SharedPreferences.setMockInitialValues({'app_language': 'hu'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(localeProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(container.read(localeProvider), const Locale('hu'));

    await container.read(localeProvider.notifier).select(null);

    expect(container.read(localeProvider), isNull);
    expect((await SharedPreferences.getInstance()).getString('app_language'), isNull);
  });

  test('ismeretlen mentett nyelvkódot figyelmen kívül hagy', () async {
    SharedPreferences.setMockInitialValues({'app_language': 'xx'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(localeProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(container.read(localeProvider), isNull);
  });
}
