import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/owner_tools_repository.dart';
import '../model/owner_tools_models.dart';

final expensesProvider = FutureProvider.autoDispose.family<ExpenseListing, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).expenses(businessId),
);

final reviewsProvider = FutureProvider.autoDispose.family<ReviewListing, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).reviews(businessId),
);

final soldPassesProvider = FutureProvider.autoDispose.family<List<SoldPass>, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).soldPasses(businessId),
);

final waitlistProvider = FutureProvider.autoDispose.family<List<WaitlistEntry>, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).waitlist(businessId),
);

/// A tevékenység-napló keresőszövege (a lista ebből szűr).
class ActivitySearchViewModel extends Notifier<String> {
  @override
  String build() => '';

  void search(String text) => state = text;
}

final activitySearchProvider = NotifierProvider.autoDispose<ActivitySearchViewModel, String>(ActivitySearchViewModel.new);

final activityLogProvider = FutureProvider.autoDispose.family<List<ActivityEntry>, int>(
  (ref, businessId) => ref.watch(ownerToolsRepositoryProvider).activityLog(businessId, search: ref.watch(activitySearchProvider)),
);

/// A költségek, értékelés-beállítás és várólista műveletei.
class OwnerToolsActionsViewModel extends ActionNotifier {
  Future<bool> addExpense(
    int businessId, {
    required String category,
    required int amountHuf,
    required DateTime date,
    String? vendor,
    bool recurring = false,
  }) async {
    final ok = await perform(
      () => ref
          .read(ownerToolsRepositoryProvider)
          .createExpense(businessId, category: category, amountHuf: amountHuf, date: date, vendor: vendor, recurring: recurring),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(expensesProvider(businessId));
    return ok;
  }

  Future<bool> deleteExpense(int businessId, int expenseId) async {
    final ok = await perform(() => ref.read(ownerToolsRepositoryProvider).deleteExpense(businessId, expenseId));
    if (ok) ref.invalidate(expensesProvider(businessId));
    return ok;
  }

  Future<bool> saveReviewSettings(int businessId, {required bool enabled, String? googleUrl}) async {
    final ok = await perform(
      () => ref.read(ownerToolsRepositoryProvider).saveReviewSettings(businessId, enabled: enabled, googleUrl: googleUrl),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(reviewsProvider(businessId));
    return ok;
  }

  Future<bool> notifyWaitlist(int businessId, int entryId) async {
    final ok = await perform(() => ref.read(ownerToolsRepositoryProvider).notifyWaitlist(businessId, entryId), success: FlashKind.saved);
    if (ok) ref.invalidate(waitlistProvider(businessId));
    return ok;
  }

  Future<bool> removeWaitlist(int businessId, int entryId) async {
    final ok = await perform(() => ref.read(ownerToolsRepositoryProvider).removeWaitlist(businessId, entryId));
    if (ok) ref.invalidate(waitlistProvider(businessId));
    return ok;
  }
}

final ownerToolsActionsProvider = NotifierProvider.autoDispose<OwnerToolsActionsViewModel, ActionState>(OwnerToolsActionsViewModel.new);
