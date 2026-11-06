import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/token_store.dart';
import '../../../core/providers.dart';
import '../../../core/viewmodel/action_state.dart';
import '../data/staff_repositories.dart';
import '../model/staff_models.dart';

/// A munkatársi / vállalkozói fiók munkamenete. Az érték a bejelentkezett felhasználó, `null` = nincs belépve.
class StaffSessionViewModel extends AsyncNotifier<StaffUser?> {
  @override
  Future<StaffUser?> build() async {
    if (await ref.read(tokenStoreProvider).read(TokenKind.staff) == null) return null;

    try {
      return await ref.read(staffAuthRepositoryProvider).me();
    } catch (_) {
      // Lejárt token vagy hálózati hiba: belépés nélküliként indulunk (hálózati hibánál a token megmarad).
      return null;
    }
  }

  Future<void> signIn(String email, String password) async {
    final result = await ref.read(staffAuthRepositoryProvider).login(email, password);
    await ref.read(tokenStoreProvider).write(result.token, TokenKind.staff);
    state = AsyncData(result.user);
  }

  /// Egy már hitelesített felhasználó átvétele (pl. regisztráció vagy az első vállalkozás létrehozása után).
  void adopt(StaffUser user) => state = AsyncData(user);

  Future<void> signOut() async {
    try {
      await ref.read(staffAuthRepositoryProvider).logout();
    } catch (_) {
      // Hálózati hiba esetén is töröljük a helyi tokent.
    }
    await sessionExpired();
  }

  Future<void> sessionExpired() async {
    await ref.read(tokenStoreProvider).clear(TokenKind.staff);
    state = const AsyncData(null);
  }
}

final staffSessionProvider = AsyncNotifierProvider<StaffSessionViewModel, StaffUser?>(StaffSessionViewModel.new);

/// A munkatársi belépő képernyő ViewModel-je.
class StaffLoginViewModel extends ActionNotifier {
  Future<void> signIn(String email, String password) =>
      perform(() => ref.read(staffSessionProvider.notifier).signIn(email, password));
}

final staffLoginProvider = NotifierProvider.autoDispose<StaffLoginViewModel, ActionState>(StaffLoginViewModel.new);
