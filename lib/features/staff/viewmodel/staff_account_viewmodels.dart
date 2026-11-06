import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/token_store.dart';
import '../../../core/providers.dart';
import '../../../core/viewmodel/action_state.dart';
import '../data/staff_account_repository.dart';
import '../data/staff_repositories.dart';
import 'staff_session_viewmodel.dart';

/// Regisztráció, elfelejtett jelszó, jelszócsere, visszajelzés és az első vállalkozás létrehozása.
class StaffAccountViewModel extends ActionNotifier {
  StaffAccountRepository get _repo => ref.read(staffAccountRepositoryProvider);

  /// Új fiók létrehozása; sikernél a felhasználó be is van lépve.
  Future<bool> register({required String name, required String email, required String password}) => perform(() async {
    final result = await _repo.register(name: name, email: email, password: password);
    await ref.read(tokenStoreProvider).write(result.token, TokenKind.staff);
    ref.read(staffSessionProvider.notifier).adopt(result.user);
  });

  Future<bool> forgotPassword(String email) => perform(() => _repo.forgotPassword(email), success: FlashKind.saved);

  Future<bool> changePassword({required String current, required String password}) => perform(
    () => _repo.changePassword(current: current, password: password),
    success: FlashKind.saved,
  );

  Future<bool> sendFeedback({required String type, required String subject, required String message}) => perform(
    () => _repo.sendFeedback(type: type, subject: subject, message: message),
    success: FlashKind.saved,
  );

  /// Vállalkozás létrehozása; utána újra betöltjük a felhasználót (megjelenik a vállalkozói felület).
  Future<bool> createBusiness({
    required String name,
    required bool isSolo,
    required List<({String name, int durationMinutes, int? priceHuf})> services,
    required List<({String name, String? email})> staff,
    String? phone,
    String? address,
    String? city,
  }) => perform(() async {
    await _repo.createBusiness(name: name, isSolo: isSolo, services: services, staff: staff, phone: phone, address: address, city: city);
    ref.read(staffSessionProvider.notifier).adopt(await ref.read(staffAuthRepositoryProvider).me());
  }, success: FlashKind.saved);
}

final staffAccountProvider = NotifierProvider.autoDispose<StaffAccountViewModel, ActionState>(StaffAccountViewModel.new);
