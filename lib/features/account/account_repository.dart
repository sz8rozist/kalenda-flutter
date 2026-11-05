import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'account_models.dart';

/// A bejelentkezett ügyfél áttekintése: profil, közelgő és korábbi foglalások.
final accountOverviewProvider = FutureProvider.autoDispose<AccountOverview>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.call((d) => d.get('/customer/account'));
  return AccountOverview.fromJson(response.data as Map<String, dynamic>);
});
