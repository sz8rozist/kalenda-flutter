import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Melyik fiókhoz tartozik a token: az ügyfélfiókhoz vagy a munkatárshoz / vállalkozóhoz.
enum TokenKind { customer, staff }

/// A tokenek tárolása Keychain-ben / Keystore-ban. A két fióktípus külön tokent kap, mert egy készüléken
/// ugyanaz a személy lehet ügyfél és munkatárs is.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _key(TokenKind kind) => kind == TokenKind.customer ? 'customer_token' : 'staff_token';

  Future<String?> read([TokenKind kind = TokenKind.customer]) => _storage.read(key: _key(kind));
  Future<void> write(String token, [TokenKind kind = TokenKind.customer]) => _storage.write(key: _key(kind), value: token);
  Future<void> clear([TokenKind kind = TokenKind.customer]) => _storage.delete(key: _key(kind));
}
