import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/inventory_repository.dart';
import '../model/inventory_models.dart';

/// A termék-lista szűrői: keresőszöveg és „csak az alacsony készletű".
typedef ProductFilter = ({String search, bool lowStockOnly});

class ProductFilterViewModel extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => (search: '', lowStockOnly: false);

  void search(String text) => state = (search: text, lowStockOnly: state.lowStockOnly);

  void toggleLowStock() => state = (search: state.search, lowStockOnly: !state.lowStockOnly);
}

final productFilterProvider = NotifierProvider.autoDispose<ProductFilterViewModel, ProductFilter>(ProductFilterViewModel.new);

final productsProvider = FutureProvider.autoDispose.family<List<Product>, int>((ref, businessId) {
  final filter = ref.watch(productFilterProvider);
  return ref.watch(inventoryRepositoryProvider).products(businessId, search: filter.search, lowStockOnly: filter.lowStockOnly);
});

final suppliersProvider = FutureProvider.autoDispose.family<List<Supplier>, int>(
  (ref, businessId) => ref.watch(inventoryRepositoryProvider).suppliers(businessId),
);

final purchaseOrdersProvider = FutureProvider.autoDispose.family<List<PurchaseOrder>, int>(
  (ref, businessId) => ref.watch(inventoryRepositoryProvider).orders(businessId),
);

/// A készlet műveletei: termék / beszállító mentése és törlése, értékesítés, rendelések kezelése.
class InventoryActionsViewModel extends ActionNotifier {
  InventoryRepository get _repo => ref.read(inventoryRepositoryProvider);

  Future<bool> _run(int businessId, Future<void> Function() action, {FlashKind? success = FlashKind.saved}) async {
    final ok = await perform(action, success: success);
    if (ok) {
      ref.invalidate(productsProvider(businessId));
      ref.invalidate(suppliersProvider(businessId));
      ref.invalidate(purchaseOrdersProvider(businessId));
    }
    return ok;
  }

  Future<bool> saveProduct(int businessId, Product product) => _run(businessId, () => _repo.saveProduct(businessId, product));

  Future<bool> deleteProduct(int businessId, int productId) =>
      _run(businessId, () => _repo.deleteProduct(businessId, productId), success: null);

  Future<bool> sell(int businessId, {required int productId, required int quantity, String? customerName, String? paymentMethod}) => _run(
    businessId,
    () => _repo.sellProduct(businessId, productId: productId, quantity: quantity, customerName: customerName, paymentMethod: paymentMethod),
  );

  Future<bool> saveSupplier(int businessId, Supplier supplier) => _run(businessId, () => _repo.saveSupplier(businessId, supplier));

  Future<bool> deleteSupplier(int businessId, int supplierId) =>
      _run(businessId, () => _repo.deleteSupplier(businessId, supplierId), success: null);

  Future<bool> createOrder(
    int businessId, {
    required int supplierId,
    required List<({int? productId, String description, int quantity, int unitCostHuf})> lines,
    DateTime? expectedDate,
    String? note,
  }) => _run(businessId, () => _repo.createOrder(businessId, supplierId: supplierId, lines: lines, expectedDate: expectedDate, note: note));

  Future<bool> markOrdered(int businessId, int orderId) => _run(businessId, () => _repo.markOrdered(businessId, orderId));

  Future<bool> cancelOrder(int businessId, int orderId) => _run(businessId, () => _repo.cancelOrder(businessId, orderId));

  Future<bool> receiveOrder(int businessId, int orderId, Map<int, int> received) =>
      _run(businessId, () => _repo.receiveOrder(businessId, orderId, received));
}

final inventoryActionsProvider = NotifierProvider.autoDispose<InventoryActionsViewModel, ActionState>(InventoryActionsViewModel.new);
