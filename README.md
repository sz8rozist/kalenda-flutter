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
