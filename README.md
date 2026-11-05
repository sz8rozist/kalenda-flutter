# Kalenda – mobilalkalmazás

Flutter-alkalmazás a Kalenda időpontfoglalóhoz (iOS + Android). Backend:
[kalenda-java-backend](https://github.com/sz8rozist/kalenda-java-backend) REST API (`/api/v1`).
Terv, funkciók, backend-teendők: [docs/PLAN.md](docs/PLAN.md).

## Állapot
Alap: Riverpod + go_router + Dio, hu/en lokalizáció, ügyfél-belépés e-mailes linkkel
(`/customer/login-link` → `/customer/login`), tárolt token (Keychain/Keystore),
„Foglalásaim" (`/customer/account`).

## Fejlesztés
```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080   # Android emulátor -> a gép localhostja
flutter analyze && flutter test
```

Flutter nélkül, Dockerből:

```bash
docker run --rm -v "$PWD:/w" -w /w ghcr.io/cirruslabs/flutter:stable sh -c "flutter pub get && flutter analyze && flutter test"
```

Az iOS-build Windowson nem megy (Xcode): felhős CI (Codemagic / GitHub Actions macOS) kell hozzá.

## Push értesítések (Firebase)
Az app Firebase-konfiguráció nélkül is épül és fut (a push ilyenkor ki van kapcsolva). Bekapcsolás:
1. Firebase-projekt létrehozása, Android- és iOS-alkalmazás felvétele (`hu.kalenda.kalenda_mobile`).
2. `dart pub global activate flutterfire_cli`, majd `flutterfire configure` – ez felveszi a `google-services.json` / `GoogleService-Info.plist` fájlokat és a Gradle/Xcode beállítást.
3. iOS-hez: APNs-hitelesítési kulcs feltöltése a Firebase-projektben.
4. A backenden `FCM_CREDENTIALS_FILE` a Firebase service account JSON útvonalával (ld. a backend `env.docker.example`).
Az értesítés-engedélyt az app az első foglalás után kéri; belépés után az eszköz-token a `/customer/devices` végponton regisztrálódik.

## Architektúra: Riverpod + MVVM
Állapotkezelés: **Riverpod**. Tervezési minta: **MVVM**, funkciónként (`lib/features/<funkció>/`):

| Réteg | Mappa | Mi van benne |
| --- | --- | --- |
| **Model** | `model/`, `data/` | adatmodellek (JSON ↔ osztály) és repository-k (a HTTP-hívás csak itt van, `ApiClient`-en át) |
| **ViewModel** | `viewmodel/` | Riverpod `Notifier` / `AsyncNotifier`: az adat betöltése (`AsyncNotifier`), a műveletek és a képernyő állapota (`ActionNotifier` → `ActionState`: busy + visszajelzés), a form választásai és a küldés |
| **View** | `view/` | widgetek: csak megjelenítés és eseménykiváltás; a szövegmezők controllerei, párbeszédek és a navigáció itt vannak, üzleti állapot és repository-hívás nincs |

Szabályok: a View nem hív repository-t / Dio-t, és üzleti állapotot nem tart `setState`-tel; a ViewModel nem ismeri a `BuildContext`-et (a visszajelzést `Flash`-ként adja, a szöveget a View állítja össze – `shared/flash.dart`);
közös segédek: `core/viewmodel/` (`ActionNotifier`, fül-/hét-/dátumválasztó ViewModel-ek), `shared/` (`AsyncView`, `WeekHeader`, formázók).
Új képernyő = `view` + `viewmodel` (+ `model`/`data`, ha új adat kell).
