import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/core/providers.dart';
import 'package:kalenda_mobile/core/push/push_service.dart';
import 'package:kalenda_mobile/features/app_gate/data/app_config_repository.dart';
import 'package:kalenda_mobile/features/app_gate/model/app_config.dart';
import 'package:kalenda_mobile/features/app_gate/viewmodel/app_gate_viewmodel.dart';
import 'package:kalenda_mobile/features/app_lock/data/app_lock_repository.dart';
import 'package:kalenda_mobile/main.dart';

import 'support/fake_repositories.dart';
import 'support/fake_services.dart';
import 'support/fakes.dart';

class _FakeRemoteConfig extends RemoteConfigViewModel {
  _FakeRemoteConfig(this.config);

  final RemoteAppConfig config;

  @override
  Future<RemoteAppConfig> build() async => config;
}

Widget _app({String? customerToken, bool lockEnabled = false, RemoteAppConfig config = const RemoteAppConfig(), String installed = '1.0.0'}) {
  return ProviderScope(
    overrides: [
      tokenStoreProvider.overrideWithValue(FakeTokenStore(customer: customerToken)),
      pushServiceProvider.overrideWith(NoPush.new),
      appLockRepositoryProvider.overrideWithValue(FakeAppLockRepository(enabled: lockEnabled, authenticates: false)),
      remoteConfigProvider.overrideWith(() => _FakeRemoteConfig(config)),
      appConfigRepositoryProvider.overrideWithValue(FakeAppConfigRepository(installed)),
    ],
    child: const KalendaApp(),
  );
}

/// A teszt-környezet alapnyelve angol: magyar felülettel indítjuk az appot.
void _hungarian(WidgetTester tester) {
  tester.platformDispatcher.localesTestValue = const [Locale('hu', 'HU')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
}

void main() {
  testWidgets('az app elindul: a vállalkozás keresése (új foglalás) a kezdőképernyő', (tester) async {
    _hungarian(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Vállalkozás keresése'), findsOneWidget);
    // Belépés nélkül két fül: új foglalás és belépés.
    expect(find.byType(NavigationDestination), findsNWidgets(2));
  });

  testWidgets('belépett ügyfélnek három fül van (új foglalás, foglalásaim, fiókom)', (tester) async {
    _hungarian(tester);
    await tester.pumpWidget(_app(customerToken: 'tok'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(3));
  });

  testWidgets('a belépő fülön látszik a link kérése, közösségi gombok nélkül, ha a szerver nem jelzi', (tester) async {
    _hungarian(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NavigationDestination).last);
    await tester.pumpAndSettle();

    expect(find.text('Belépő link küldése'), findsOneWidget);
    expect(find.text('Folytatás Google-fiókkal'), findsNothing);
  });

  testWidgets('a Google-gomb megjelenik, ha a szerver jelzi', (tester) async {
    _hungarian(tester);
    await tester.pumpWidget(_app(config: const RemoteAppConfig(googleLogin: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NavigationDestination).last);
    await tester.pumpAndSettle();

    expect(find.text('Folytatás Google-fiókkal'), findsOneWidget);
  });

  testWidgets('bekapcsolt zárnál belépett fiókkal a zárképernyő takarja az appot', (tester) async {
    _hungarian(tester);
    await tester.pumpWidget(_app(customerToken: 'tok', lockEnabled: true));
    await tester.pumpAndSettle();

    expect(find.text('Az alkalmazás zárolva van'), findsOneWidget);
    expect(find.text('Az azonosítás nem sikerült.'), findsOneWidget); // az automatikus feloldási kísérlet elbukott
  });

  testWidgets('elavult verziónál a kötelező frissítés oldal jelenik meg', (tester) async {
    _hungarian(tester);
    await tester.pumpWidget(_app(config: const RemoteAppConfig(minVersion: '2.0.0'), installed: '1.0.0'));
    await tester.pumpAndSettle();

    expect(find.text('Frissítés szükséges'), findsOneWidget);
  });

  testWidgets('elég friss verziónál nincs kényszer', (tester) async {
    _hungarian(tester);
    await tester.pumpWidget(_app(config: const RemoteAppConfig(minVersion: '1.0.0'), installed: '1.0.0'));
    await tester.pumpAndSettle();

    expect(find.text('Frissítés szükséges'), findsNothing);
    expect(find.text('Vállalkozás keresése'), findsOneWidget);
  });
}
