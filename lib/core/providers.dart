import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'auth/auth_controller.dart';
import 'auth/token_store.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  final store = ref.watch(tokenStoreProvider);
  return ApiClient(
    readToken: store.read,
    // Lejárt vagy visszavont token: kilépés, a router a belépéshez irányít.
    onUnauthorized: () => ref.read(authControllerProvider.notifier).sessionExpired(),
  );
});
