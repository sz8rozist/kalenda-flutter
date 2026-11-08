import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/quotes_repository.dart';
import '../model/quote_models.dart';
import 'owner_invoice_viewmodels.dart';
import 'owner_viewmodels.dart';

/// Az ajánlat-lista szűrője: null = mind, különben draft | sent | accepted | converted.
class QuoteFilterViewModel extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? status) => state = status;
}

final quoteFilterProvider = NotifierProvider.autoDispose<QuoteFilterViewModel, String?>(QuoteFilterViewModel.new);

/// A vállalkozás ajánlatai a kiválasztott szűrő szerint; a kulcs a vállalkozás azonosítója.
class QuotesViewModel extends AsyncNotifier<List<Quote>> {
  QuotesViewModel(this.businessId);

  final int businessId;

  @override
  Future<List<Quote>> build() {
    final filter = ref.watch(quoteFilterProvider);
    return ref.watch(quotesRepositoryProvider).quotes(businessId, status: filter);
  }
}

final quotesProvider = AsyncNotifierProvider.autoDispose.family<QuotesViewModel, List<Quote>, int>(QuotesViewModel.new);

/// Az ajánlatok műveletei: mentés, állapotváltás, számlává alakítás, törlés.
class QuoteActionsViewModel extends ActionNotifier {
  QuotesRepository get _repo => ref.read(quotesRepositoryProvider);

  Future<bool> _changed(int businessId, Future<void> Function() action) async {
    final ok = await perform(action, success: FlashKind.saved);
    if (ok) ref.invalidate(quotesProvider(businessId));
    return ok;
  }

  /// Új ajánlat (quoteId == null) vagy meglévő módosítása.
  Future<bool> save(
    int businessId, {
    int? quoteId,
    required String customerName,
    String? customerEmail,
    required List<({String name, double qty, int unitPriceHuf})> items,
    DateTime? validUntil,
  }) => _changed(
    businessId,
    () => quoteId == null
        ? _repo.create(businessId, customerName: customerName, customerEmail: customerEmail, items: items, validUntil: validUntil)
        : _repo.update(businessId, quoteId, customerName: customerName, customerEmail: customerEmail, items: items, validUntil: validUntil),
  );

  Future<bool> setStatus(int businessId, int quoteId, String status) =>
      _changed(businessId, () => _repo.setStatus(businessId, quoteId, status));

  /// Számlává alakítás: a számlák listája és a kintlévőségek is változnak.
  Future<bool> convert(int businessId, int quoteId) async {
    final ok = await _changed(businessId, () => _repo.convert(businessId, quoteId));
    if (ok) {
      ref.invalidate(invoicesProvider(businessId));
      ref.invalidate(ownerDashboardProvider(businessId));
    }
    return ok;
  }

  Future<bool> delete(int businessId, int quoteId) => _changed(businessId, () => _repo.delete(businessId, quoteId));
}

final quoteActionsProvider = NotifierProvider.autoDispose<QuoteActionsViewModel, ActionState>(QuoteActionsViewModel.new);
