import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/owner_repository.dart';
import '../model/owner_models.dart';
import 'owner_viewmodels.dart';

/// A számla-lista szűrője: null = mind, különben unpaid | overdue | paid.
class InvoiceFilterViewModel extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? payment) => state = payment;
}

final invoiceFilterProvider = NotifierProvider.autoDispose<InvoiceFilterViewModel, String?>(InvoiceFilterViewModel.new);

/// A vállalkozás számlái a kiválasztott szűrő szerint; a kulcs a vállalkozás azonosítója.
class InvoicesViewModel extends AsyncNotifier<List<InvoiceItem>> {
  InvoicesViewModel(this.businessId);

  final int businessId;

  @override
  Future<List<InvoiceItem>> build() {
    final filter = ref.watch(invoiceFilterProvider);
    return ref.watch(ownerRepositoryProvider).invoices(businessId, payment: filter);
  }
}

final invoicesProvider =
    AsyncNotifierProvider.autoDispose.family<InvoicesViewModel, List<InvoiceItem>, int>(InvoicesViewModel.new);

/// A számlák műveletei: kifizetettnek jelölés, visszavonás, fizetési emlékeztető.
class InvoiceActionsViewModel extends ActionNotifier {
  Future<void> markPaid(int businessId, int invoiceId, String method) => _changed(
        businessId,
        () => ref.read(ownerRepositoryProvider).markInvoicePaid(businessId, invoiceId, method: method, date: DateTime.now()),
      );

  Future<void> markUnpaid(int businessId, int invoiceId) =>
      _changed(businessId, () => ref.read(ownerRepositoryProvider).markInvoiceUnpaid(businessId, invoiceId));

  Future<void> remind(int businessId, int invoiceId) =>
      _changed(businessId, () => ref.read(ownerRepositoryProvider).remindInvoice(businessId, invoiceId));

  Future<void> _changed(int businessId, Future<void> Function() action) async {
    final ok = await perform(action, success: FlashKind.saved);
    if (ok) {
      ref.invalidate(invoicesProvider(businessId));
      ref.invalidate(ownerDashboardProvider(businessId)); // a kintlévőségek összege változik
    }
  }
}

final invoiceActionsProvider = NotifierProvider.autoDispose<InvoiceActionsViewModel, ActionState>(InvoiceActionsViewModel.new);
