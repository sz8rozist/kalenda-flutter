import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/viewmodel/action_state.dart';
import 'package:kalenda_mobile/core/viewmodel/simple_viewmodels.dart';
import 'package:kalenda_mobile/features/auth/viewmodel/login_viewmodel.dart';
import 'package:kalenda_mobile/features/booking/viewmodel/business_viewmodels.dart';

class _Actions extends ActionNotifier {
  Future<bool> run(Future<void> Function() action, {FlashKind? success}) => perform(action, success: success);
}

final _actionsProvider = NotifierProvider.autoDispose<_Actions, ActionState>(_Actions.new);

void main() {
  group('ActionNotifier.perform', () {
    test('siker: busy lekapcsol, a kért visszajelzés beáll', () async {
      final container = ProviderContainer.test();
      container.listen(_actionsProvider, (_, _) {});

      final ok = await container.read(_actionsProvider.notifier).run(() async {}, success: FlashKind.saved);

      expect(ok, isTrue);
      expect(container.read(_actionsProvider).busy, isFalse);
      expect(container.read(_actionsProvider).flash?.kind, FlashKind.saved);
    });

    test('siker, visszajelzés nélkül: nincs flash', () async {
      final container = ProviderContainer.test();
      container.listen(_actionsProvider, (_, _) {});

      await container.read(_actionsProvider.notifier).run(() async {});

      expect(container.read(_actionsProvider).flash, isNull);
    });

    test('hiba: false, és a kivétel a flash-ben', () async {
      final container = ProviderContainer.test();
      container.listen(_actionsProvider, (_, _) {});

      final ok = await container.read(_actionsProvider.notifier).run(() async => throw StateError('rossz'), success: FlashKind.saved);

      final state = container.read(_actionsProvider);
      expect(ok, isFalse);
      expect(state.busy, isFalse);
      expect(state.flash?.kind, FlashKind.error);
      expect(state.flash?.error, isA<StateError>());
    });

    test('futás közben busy', () async {
      final container = ProviderContainer.test();
      container.listen(_actionsProvider, (_, _) {});

      final future = container.read(_actionsProvider.notifier).run(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      expect(container.read(_actionsProvider).busy, isTrue);

      await future;
      expect(container.read(_actionsProvider).busy, isFalse);
    });

    test('ha a képernyő közben megszűnt, nem dob (nincs kinek visszajelezni)', () async {
      final container = ProviderContainer.test();
      final subscription = container.listen(_actionsProvider, (_, _) {});

      final future = container.read(_actionsProvider.notifier).run(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      subscription.close(); // az autoDispose notifier megszűnik a futás alatt

      expect(await future, isTrue);
    });
  });

  group('egyszerű ViewModel-ek', () {
    test('a hét hétfőn kezdődik, és léptethető', () {
      // 2026. november 5. csütörtök → hétfő: november 2.
      expect(WeekViewModel.mondayOf(DateTime(2026, 11, 5, 15)), DateTime(2026, 11, 2));
      expect(WeekViewModel.mondayOf(DateTime(2026, 11, 8)), DateTime(2026, 11, 2)); // vasárnap
      expect(WeekViewModel.mondayOf(DateTime(2026, 11, 2)), DateTime(2026, 11, 2));

      final container = ProviderContainer.test();
      final provider = NotifierProvider<WeekViewModel, DateTime>(WeekViewModel.new);
      final start = container.read(provider);
      container.read(provider.notifier).shift(2);
      expect(container.read(provider), start.add(const Duration(days: 14)));
    });

    test('a fül kiválasztása', () {
      final container = ProviderContainer.test();
      final provider = NotifierProvider<TabIndexViewModel, int>(TabIndexViewModel.new);

      expect(container.read(provider), 0);
      container.read(provider.notifier).select(3);
      expect(container.read(provider), 3);
    });
  });

  group('linkek értelmezése', () {
    test('foglalási link vagy azonosító → slug', () {
      expect(slugFromBusinessLink('https://kalenda.example/booking/szalon'), 'szalon');
      expect(slugFromBusinessLink('https://kalenda.example/booking/szalon/'), 'szalon');
      expect(slugFromBusinessLink('  szalon '), 'szalon');
      expect(slugFromBusinessLink('/szalon/'), 'szalon');
      expect(slugFromBusinessLink('   '), isNull);
    });

    test('a QR-beolvasó csak az első kódot veszi figyelembe', () {
      final container = ProviderContainer.test();
      container.listen(scanViewModelProvider, (_, _) {});
      final scan = container.read(scanViewModelProvider.notifier);

      scan.onCode(null);
      expect(container.read(scanViewModelProvider), isNull);

      scan.onCode('https://kalenda.example/booking/elso');
      scan.onCode('https://kalenda.example/booking/masodik');
      expect(container.read(scanViewModelProvider), 'elso');
    });

    test('a levélből beillesztett belépő link → kód', () {
      expect(LoginViewModel.extractCode('https://kalenda.example/fiokom/belepes/AbC123'), 'AbC123');
      expect(LoginViewModel.extractCode('  AbC123  '), 'AbC123');
    });
  });
}
