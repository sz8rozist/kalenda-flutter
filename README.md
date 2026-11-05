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
