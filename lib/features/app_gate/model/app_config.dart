/// A szerver indításkori beállításai az apphoz (`GET /app-config`).
class RemoteAppConfig {
  const RemoteAppConfig({this.minVersion, this.androidStoreUrl, this.iosStoreUrl, this.googleLogin = false, this.appleLogin = false});

  /// A közösségi belépés elérhető-e (a szerveren be van állítva a kliensazonosító).
  final bool googleLogin;
  final bool appleLogin;

  /// Az ennél régebbi app frissítésre kényszerül; null = nincs kényszer.
  final String? minVersion;
  final String? androidStoreUrl;
  final String? iosStoreUrl;

  factory RemoteAppConfig.fromJson(Map<String, dynamic> j) => RemoteAppConfig(
        minVersion: j['min_version'] as String?,
        androidStoreUrl: j['android_store_url'] as String?,
        iosStoreUrl: j['ios_store_url'] as String?,
        googleLogin: j['google_login'] as bool? ?? false,
        appleLogin: j['apple_login'] as bool? ?? false,
      );
}

/// Kell-e frissíteni: a telepített verzió kisebb-e a minimumnál. Verzió: `1.2.3` (a `+build` és a `-előtag` elmarad).
bool isOutdated(String installed, String? minimum) {
  if (minimum == null || minimum.trim().isEmpty) return false;
  final a = _parts(installed);
  final b = _parts(minimum);

  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] < b[i];
  }
  return false;
}

List<int> _parts(String version) {
  final core = version.split('+').first.split('-').first.trim();
  final numbers = core.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  return [for (var i = 0; i < 3; i++) i < numbers.length ? numbers[i] : 0];
}

/// A frissítés-kényszer: a képernyő gombja ide visz (null = nincs ismert store-link).
class UpdateRequired {
  const UpdateRequired({required this.minVersion, this.storeUrl});

  final String minVersion;
  final String? storeUrl;
}
