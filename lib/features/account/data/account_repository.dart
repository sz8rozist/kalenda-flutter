import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../model/account_models.dart';

/// Az ügyfélfiók adatai (`/customer/account`, `/customer/consents`).
class AccountRepository {
  AccountRepository(this._api);

  final ApiClient _api;

  Future<AccountOverview> overview() async {
    final response = await _api.call((d) => d.get('/customer/account'));
    return AccountOverview.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateProfile({required String name, String? phone}) =>
      _api.call((d) => d.patch('/customer/account', data: {'name': name, 'phone': phone ?? ''}));

  Future<void> setMarketingConsent(int businessId, bool value) =>
      _api.call((d) => d.put('/customer/consents/$businessId', data: {'marketing_consent': value}));
}

final accountRepositoryProvider = Provider<AccountRepository>((ref) => AccountRepository(ref.watch(apiClientProvider)));
