import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/providers.dart';
import 'package:kalenda_mobile/features/app_lock/data/app_lock_repository.dart';
import 'package:kalenda_mobile/features/app_lock/viewmodel/app_lock_viewmodel.dart';

import '../support/fakes.dart';

void main() {
  late DateTime now;

  ProviderContainer container({required FakeAppLockRepository repository, String? customerToken, String? staffToken}) {
    now = DateTime(2026, 11, 5, 12);
    final c = ProviderContainer.test(overrides: [
      appLockRepositoryProvider.overrideWithValue(repository),
      tokenStoreProvider.overrideWithValue(FakeTokenStore(customer: customerToken, staff: staffToken)),
      appLockClockProvider.overrideWithValue(() => now),
    ]);
    c.listen(appLockProvider, (_, _) {});
    return c;
  }

  group('indításkori zárolás', () {
    test('bekapcsolva, támogatva és belépett fiókkal: zárolt', () async {
      final c = container(repository: FakeAppLockRepository(enabled: true), customerToken: 'tok');
      final state = await c.read(appLockProvider.future);

      expect(state.locked, isTrue);
    });

    test('a munkatársi belépés is számít', () async {
      final c = container(repository: FakeAppLockRepository(enabled: true), staffToken: 'tok');
      expect((await c.read(appLockProvider.future)).locked, isTrue);
    });

    test('belépett fiók nélkül nincs mit védeni', () async {
      final c = container(repository: FakeAppLockRepository(enabled: true));
      expect((await c.read(appLockProvider.future)).locked, isFalse);
    });

    test('kikapcsolva vagy nem támogatott eszközön nem zárol', () async {
      final off = container(repository: FakeAppLockRepository(enabled: false), customerToken: 'tok');
      expect((await off.read(appLockProvider.future)).locked, isFalse);

      final unsupported = container(repository: FakeAppLockRepository(enabled: true, supported: false), customerToken: 'tok');
      expect((await unsupported.read(appLockProvider.future)).locked, isFalse);
    });
  });

  group('háttérből visszatérés', () {
    test('a türelmi idő alatt nem zárol', () async {
      final c = container(repository: FakeAppLockRepository(enabled: true), customerToken: 'tok');
      final notifier = c.read(appLockProvider.notifier);
      await c.read(appLockProvider.future);
      await notifier.unlock('ok'); // feloldjuk az indításkori zárat

      notifier.onBackgrounded();
      now = now.add(const Duration(seconds: 10));
      await notifier.onResumed();

      expect(c.read(appLockProvider).value!.locked, isFalse);
    });

    test('a türelmi idő után zárol', () async {
      final c = container(repository: FakeAppLockRepository(enabled: true), customerToken: 'tok');
      final notifier = c.read(appLockProvider.notifier);
      await c.read(appLockProvider.future);
      await notifier.unlock('ok');

      notifier.onBackgrounded();
      now = now.add(AppLockViewModel.gracePeriod + const Duration(seconds: 1));
      await notifier.onResumed();

      expect(c.read(appLockProvider).value!.locked, isTrue);
    });

    test('kikapcsolt zárnál soha nem zárol', () async {
      final c = container(repository: FakeAppLockRepository(enabled: false), customerToken: 'tok');
      final notifier = c.read(appLockProvider.notifier);
      await c.read(appLockProvider.future);

      notifier.onBackgrounded();
      now = now.add(const Duration(hours: 1));
      await notifier.onResumed();

      expect(c.read(appLockProvider).value!.locked, isFalse);
    });
  });

  group('feloldás és beállítás', () {
    test('sikeres azonosítás feloldja', () async {
      final c = container(repository: FakeAppLockRepository(enabled: true), customerToken: 'tok');
      await c.read(appLockProvider.future);

      await c.read(appLockProvider.notifier).unlock('ok');

      final state = c.read(appLockProvider).value!;
      expect(state.locked, isFalse);
      expect(state.failed, isFalse);
    });

    test('sikertelen azonosítás zárolva hagyja, és jelzi', () async {
      final c = container(repository: FakeAppLockRepository(enabled: true, authenticates: false), customerToken: 'tok');
      await c.read(appLockProvider.future);

      await c.read(appLockProvider.notifier).unlock('ok');

      final state = c.read(appLockProvider).value!;
      expect(state.locked, isTrue);
      expect(state.failed, isTrue);
    });

    test('bekapcsolás előtt azonosít, és csak sikernél kapcsol be', () async {
      final repository = FakeAppLockRepository(enabled: false);
      final c = container(repository: repository);
      await c.read(appLockProvider.future);

      await c.read(appLockProvider.notifier).setEnabled(true, 'ok');

      expect(repository.authenticateCalls, 1);
      expect(repository.enabled, isTrue);
      expect(c.read(appLockProvider).value!.enabled, isTrue);
    });

    test('sikertelen azonosításnál nem kapcsol be', () async {
      final repository = FakeAppLockRepository(enabled: false, authenticates: false);
      final c = container(repository: repository);
      await c.read(appLockProvider.future);

      await c.read(appLockProvider.notifier).setEnabled(true, 'ok');

      expect(repository.enabled, isFalse);
      expect(c.read(appLockProvider).value!.enabled, isFalse);
      expect(c.read(appLockProvider).value!.failed, isTrue);
    });

    test('kikapcsolás azonosítás nélkül, azonnal megy', () async {
      final repository = FakeAppLockRepository(enabled: true);
      final c = container(repository: repository);
      await c.read(appLockProvider.future);

      await c.read(appLockProvider.notifier).setEnabled(false, 'ok');

      expect(repository.authenticateCalls, 0);
      expect(repository.enabled, isFalse);
    });

    test('nem támogatott eszközön nem lehet bekapcsolni', () async {
      final repository = FakeAppLockRepository(enabled: false, supported: false);
      final c = container(repository: repository);
      await c.read(appLockProvider.future);

      await c.read(appLockProvider.notifier).setEnabled(true, 'ok');

      expect(repository.enabled, isFalse);
      expect(repository.authenticateCalls, 0);
    });
  });
}
