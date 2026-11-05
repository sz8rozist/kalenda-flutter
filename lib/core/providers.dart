import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/staff/staff_auth.dart';
import 'api/api_client.dart';
import 'auth/auth_controller.dart';
import 'auth/token_store.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  final store = ref.watch(tokenStoreProvider);
  return ApiClient(
    readCustomerToken: () => store.read(TokenKind.customer),
    readStaffToken: () => store.read(TokenKind.staff),
    // Lejárt vagy visszavont token: a megfelelő fióktípus kilép, a felület a belépéshez irányít.
    onUnauthorized: (path) {
      if (path.startsWith('/customer/')) {
        ref.read(authControllerProvider.notifier).sessionExpired();
      } else {
        ref.read(staffAuthProvider.notifier).sessionExpired();
      }
    },
  );
});
