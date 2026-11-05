import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../../auth/viewmodel/customer_session_viewmodel.dart';
import '../data/account_repository.dart';
import '../model/account_models.dart';

/// A bejelentkezett ügyfél adatai (profil, foglalások, hűségpontok, bérletek, hozzájárulások).
/// A „Foglalásaim" és a „Fiókom" képernyő közös adatforrása.
class AccountViewModel extends AsyncNotifier<AccountOverview> {
  @override
  Future<AccountOverview> build() => ref.watch(accountRepositoryProvider).overview();

  Future<void> reload() async {
    state = await AsyncValue.guard(ref.read(accountRepositoryProvider).overview);
  }
}

final accountViewModelProvider = AsyncNotifierProvider.autoDispose<AccountViewModel, AccountOverview>(AccountViewModel.new);

/// A „Fiókom" képernyő műveletei: profil mentése, hozzájárulás váltása, fiók törlése.
class AccountActionsViewModel extends ActionNotifier {
  Future<void> updateProfile({required String name, String? phone}) async {
    final ok = await perform(
      () => ref.read(accountRepositoryProvider).updateProfile(name: name, phone: phone),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(accountViewModelProvider);
  }

  Future<void> setMarketingConsent(int businessId, bool value) async {
    final ok = await perform(() => ref.read(accountRepositoryProvider).setMarketingConsent(businessId, value));
    if (ok) ref.invalidate(accountViewModelProvider);
  }

  /// Fiók törlése; közelgő foglalásnál a szerver hibaüzenete jön vissza (a View snackbarban mutatja).
  Future<void> deleteAccount() => perform(() => ref.read(customerSessionProvider.notifier).deleteAccount());
}

final accountActionsProvider = NotifierProvider.autoDispose<AccountActionsViewModel, ActionState>(AccountActionsViewModel.new);
