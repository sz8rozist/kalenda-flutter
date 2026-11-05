/// Build-idejű beállítások: `flutter run --dart-define=API_BASE_URL=https://kalenda.example`.
class AppConfig {
  /// Az Android emulátorból a gép localhostja a 10.0.2.2.
  static const apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080');

  /// Az API-nak küldött kliensverzió (minimum-verzió ellenőrzéshez).
  static const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
}
