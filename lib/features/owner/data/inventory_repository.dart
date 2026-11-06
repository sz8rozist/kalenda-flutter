import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/date_param.dart';
import '../../../core/providers.dart';
import '../model/inventory_models.dart';
import '../model/owner_tools_models.dart' show pagedContent;

/// Termékek, beszállítók és beszerzési rendelések (`/businesses/{id}/products|suppliers|purchase-orders`).
class InventoryRepository {
  InventoryRepository(this._api);

  final ApiClient _api;

  // ─── Termékek ─────────────────────────────────────────────────

  Future<List<Product>> products(int businessId, {String? search, bool lowStockOnly = false}) async {
    final response = await _api.call(
      (d) => d.get(
        '/businesses/$businessId/products',
        queryParameters: {
          'size': 100,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          if (lowStockOnly) 'low_stock': true,
        },
      ),
    );
    return [for (final e in pagedContent((response.data as Map<String, dynamic>)['products'])) Product.fromJson(e)];
  }

  Map<String, Object?> _productJson(Product p) => {
    'name': p.name,
    'description': p.description ?? '',
    'sku': p.sku == null || p.sku!.isEmpty ? null : p.sku,
    'price_huf': p.priceHuf,
    'cost_price_huf': p.costPriceHuf,
    'supplier_id': p.supplierId,
    'stock_quantity': p.stockQuantity,
    'package_size': p.packageSize,
    'package_unit': p.packageUnit == null || p.packageUnit!.isEmpty ? null : p.packageUnit,
    'low_stock_threshold': p.lowStockThreshold,
    'is_active': p.isActive,
  };

  Future<void> saveProduct(int businessId, Product product) => product.id == 0
      ? _api.call((d) => d.post('/businesses/$businessId/products', data: _productJson(product)))
      : _api.call((d) => d.put('/businesses/$businessId/products/${product.id}', data: _productJson(product)));

  Future<void> deleteProduct(int businessId, int productId) => _api.call((d) => d.delete('/businesses/$businessId/products/$productId'));

  Future<void> sellProduct(int businessId, {required int productId, required int quantity, String? customerName, String? paymentMethod}) =>
      _api.call(
        (d) => d.post(
          '/businesses/$businessId/product-sales',
          data: {
            'product_id': productId,
            'quantity': quantity,
            'customer_name': customerName == null || customerName.trim().isEmpty ? null : customerName.trim(),
            'payment_method': paymentMethod ?? 'cash',
          },
        ),
      );

  // ─── Beszállítók ──────────────────────────────────────────────

  Future<List<Supplier>> suppliers(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/suppliers'));
    return [for (final e in response.data as List) Supplier.fromJson(e as Map<String, dynamic>)];
  }

  Future<void> saveSupplier(int businessId, Supplier s) {
    final data = {
      'name': s.name,
      'contact_name': s.contactName,
      'email': s.email == null || s.email!.isEmpty ? null : s.email,
      'phone': s.phone,
      'tax_number': s.taxNumber,
      'note': s.note,
      'is_active': s.isActive,
    };
    return s.id == 0
        ? _api.call((d) => d.post('/businesses/$businessId/suppliers', data: data))
        : _api.call((d) => d.put('/businesses/$businessId/suppliers/${s.id}', data: data));
  }

  Future<void> deleteSupplier(int businessId, int supplierId) =>
      _api.call((d) => d.delete('/businesses/$businessId/suppliers/$supplierId'));

  // ─── Beszerzési rendelések ────────────────────────────────────

  Future<List<PurchaseOrder>> orders(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/purchase-orders', queryParameters: {'size': 50}));
    return PurchaseOrder.fromPaged(response.data);
  }

  Future<void> createOrder(
    int businessId, {
    required int supplierId,
    required List<({int? productId, String description, int quantity, int unitCostHuf})> lines,
    DateTime? expectedDate,
    String? note,
  }) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/purchase-orders',
      data: {
        'supplier_id': supplierId,
        'expected_date': expectedDate == null ? null : dateParam(expectedDate),
        'note': note == null || note.trim().isEmpty ? null : note.trim(),
        'items': [
          for (final l in lines)
            {'product_id': l.productId, 'description': l.description, 'quantity': l.quantity, 'unit_cost_huf': l.unitCostHuf},
        ],
      },
    ),
  );

  Future<void> markOrdered(int businessId, int orderId) =>
      _api.call((d) => d.post('/businesses/$businessId/purchase-orders/$orderId/ordered'));

  Future<void> cancelOrder(int businessId, int orderId) =>
      _api.call((d) => d.post('/businesses/$businessId/purchase-orders/$orderId/cancel'));

  /// Bevételezés: tétel-azonosító → beérkezett darab.
  Future<void> receiveOrder(int businessId, int orderId, Map<int, int> received) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/purchase-orders/$orderId/receive',
      data: {
        'received': {for (final e in received.entries) '${e.key}': e.value},
      },
    ),
  );
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) => InventoryRepository(ref.watch(apiClientProvider)));
