import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Az alkalmazászár adatai: a beállítás tárolása és az eszköz biometrikus / képernyőzár azonosítása.
class AppLockRepository {
  AppLockRepository({FlutterSecureStorage? storage, LocalAuthentication? auth})
      : _storage = storage ?? const FlutterSecureStorage(),
        _auth = auth ?? LocalAuthentication();

  static const _key = 'app_lock_enabled';

  final FlutterSecureStorage _storage;
  final LocalAuthentication _auth;

  Future<bool> isEnabled() async => (await _storage.read(key: _key)) == 'true';

  Future<void> setEnabled(bool value) => value ? _storage.write(key: _key, value: 'true') : _storage.delete(key: _key);

  /// Van-e az eszközön biometrikus azonosító vagy beállított képernyőzár (PIN / minta / jelszó).
  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Azonosítás a rendszer párbeszédével (ujjlenyomat / arc; ha nincs, az eszköz képernyőzára). Igaz, ha sikerült.
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } catch (_) {
      return false;
    }
  }
}

final appLockRepositoryProvider = Provider<AppLockRepository>((ref) => AppLockRepository());
