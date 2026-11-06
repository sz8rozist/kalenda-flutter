import 'package:kalenda_mobile/core/auth/token_store.dart';
import 'package:kalenda_mobile/features/app_lock/data/app_lock_repository.dart';

/// Memóriában tartott token-tár (a valódi Keychain / Keystore helyett).
class FakeTokenStore extends TokenStore {
  FakeTokenStore({String? customer, String? staff}) : _tokens = {TokenKind.customer: customer, TokenKind.staff: staff};

  final Map<TokenKind, String?> _tokens;

  @override
  Future<String?> read([TokenKind kind = TokenKind.customer]) async => _tokens[kind];

  @override
  Future<void> write(String token, [TokenKind kind = TokenKind.customer]) async => _tokens[kind] = token;

  @override
  Future<void> clear([TokenKind kind = TokenKind.customer]) async => _tokens[kind] = null;
}

/// Az alkalmazászár adatai az eszköz nélkül: beállítható támogatás és azonosítás-eredmény.
class FakeAppLockRepository extends AppLockRepository {
  FakeAppLockRepository({this.enabled = false, this.supported = true, this.authenticates = true});

  bool enabled;
  bool supported;
  bool authenticates;
  int authenticateCalls = 0;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled(bool value) async => enabled = value;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> authenticate(String reason) async {
    authenticateCalls++;
    return authenticates;
  }
}
