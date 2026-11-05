import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'account_models.dart';

/// A bejelentkezett ügyfél áttekintése: profil, foglalások, hűségpontok, bérletek, hozzájárulások.
final accountOverviewProvider = FutureProvider.autoDispose<AccountOverview>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.call((d) => d.get('/customer/account'));
  return AccountOverview.fromJson(response.data as Map<String, dynamic>);
});

class AccountRepository {
  AccountRepository(this._ref);

  final Ref _ref;

  Future<void> updateProfile({required String name, String? phone}) async {
    final api = _ref.read(apiClientProvider);
    await api.call((d) => d.patch('/customer/account', data: {'name': name, 'phone': phone ?? ''}));
    _ref.invalidate(accountOverviewProvider);
  }

  Future<void> setMarketingConsent(int businessId, bool value) async {
    final api = _ref.read(apiClientProvider);
    await api.call((d) => d.put('/customer/consents/$businessId', data: {'marketing_consent': value}));
    _ref.invalidate(accountOverviewProvider);
  }
}

final accountRepositoryProvider = Provider<AccountRepository>(AccountRepository.new);
