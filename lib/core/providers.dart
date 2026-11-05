import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/viewmodel/customer_session_viewmodel.dart';
import '../features/staff/viewmodel/staff_session_viewmodel.dart';
import 'api/api_client.dart';
import 'auth/token_store.dart';
import 'push/device_repository.dart';

/// Közös (Model-réteg) providerek: a token-tár és az API-kliens. A repository-k ezekre épülnek.
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  final store = ref.watch(tokenStoreProvider);
  return ApiClient(
    readCustomerToken: () => store.read(TokenKind.customer),
    readStaffToken: () => store.read(TokenKind.staff),
    // Lejárt vagy visszavont token: a megfelelő fióktípus kilép, a felület a belépéshez irányít.
    onUnauthorized: (path) {
      if (path.startsWith('/customer/')) {
        ref.read(customerSessionProvider.notifier).sessionExpired();
      } else {
        ref.read(staffSessionProvider.notifier).sessionExpired();
      }
    },
  );
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) => DeviceRepository(ref.watch(apiClientProvider)));
