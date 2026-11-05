/// Build-idejű beállítások: `flutter run --dart-define=API_BASE_URL=https://kalenda.example`.
class AppConfig {
  /// Az Android emulátorból a gép localhostja a 10.0.2.2.
  static const apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080');

  /// A Google "web" típusú OAuth-kliens azonosítója (`--dart-define=GOOGLE_SERVER_CLIENT_ID=…`): az id-token célközönsége,
  /// a backend `GOOGLE_CLIENT_IDS` listájában is szerepelnie kell.
  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  /// Az API-nak küldött kliensverzió (minimum-verzió ellenőrzéshez).
  static const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
}
