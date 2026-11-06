import 'owner_tools_models.dart' show pagedContent;

int _int(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _date(Object? v) => DateTime.tryParse(v as String? ?? '')?.toLocal();

/// Egy termék (`GET /businesses/{id}/products`).
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.priceHuf,
    required this.stockQuantity,
    required this.isActive,
    required this.isLowStock,
    this.description,
    this.sku,
    this.vat,
    this.costPriceHuf,
    this.supplierId,
    this.packageSize,
    this.packageUnit,
    this.lowStockThreshold,
    this.salesCount = 0,
  });

  final int id;
  final String name;
  final String? description;
  final String? sku;
  final int priceHuf;
  final String? vat;
  final int? costPriceHuf;
  final int? supplierId;
  final int stockQuantity;
  final double? packageSize;
  final String? packageUnit;
  final int? lowStockThreshold;
  final bool isLowStock;
  final bool isActive;
  final int salesCount;

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: _int(j['id']),
    name: j['name'] as String? ?? '',
    description: j['description'] as String?,
    sku: j['sku'] as String?,
    priceHuf: _int(j['price_huf']),
    vat: j['vat'] as String?,
    costPriceHuf: (j['cost_price_huf'] as num?)?.toInt(),
    supplierId: (j['supplier_id'] as num?)?.toInt(),
    stockQuantity: _int(j['stock_quantity']),
    packageSize: (j['package_size'] as num?)?.toDouble(),
    packageUnit: j['package_unit'] as String?,
    lowStockThreshold: (j['low_stock_threshold'] as num?)?.toInt(),
    isLowStock: j['is_low_stock'] as bool? ?? false,
    isActive: j['is_active'] as bool? ?? true,
    salesCount: _int(j['sales_count']),
  );
}

/// Egy beszállító.
class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.isActive,
    this.contactName,
    this.email,
    this.phone,
    this.taxNumber,
    this.note,
  });

  final int id;
  final String name;
  final String? contactName;
  final String? email;
  final String? phone;
  final String? taxNumber;
  final String? note;
  final bool isActive;

  factory Supplier.fromJson(Map<String, dynamic> j) => Supplier(
    id: _int(j['id']),
    name: j['name'] as String? ?? '',
    isActive: j['is_active'] as bool? ?? true,
    contactName: j['contact_name'] as String?,
    email: j['email'] as String?,
    phone: j['phone'] as String?,
    taxNumber: j['tax_number'] as String?,
    note: j['note'] as String?,
  );
}

class OrderLine {
  const OrderLine({
    required this.id,
    required this.description,
    required this.quantity,
    required this.receivedQuantity,
    required this.unitCostHuf,
    this.productId,
  });

  final int id;
  final int? productId;
  final String description;
  final int quantity;
  final int receivedQuantity;
  final int unitCostHuf;

  factory OrderLine.fromJson(Map<String, dynamic> j) => OrderLine(
    id: _int(j['id']),
    productId: (j['product_id'] as num?)?.toInt(),
    description: j['description'] as String? ?? '',
    quantity: _int(j['quantity']),
    receivedQuantity: _int(j['received_quantity']),
    unitCostHuf: _int(j['unit_cost_huf']),
  );
}

/// Egy beszerzési rendelés.
class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.status,
    required this.totalHuf,
    required this.items,
    this.number,
    this.supplierName,
    this.expectedDate,
    this.receivedAt,
    this.note,
  });

  final int id;
  final String? number;

  /// `draft` | `ordered` | `received` | `cancelled`.
  final String status;
  final String? supplierName;
  final DateTime? expectedDate;
  final DateTime? receivedAt;
  final int totalHuf;
  final String? note;
  final List<OrderLine> items;

  bool get isOpen => status == 'draft' || status == 'ordered';

  factory PurchaseOrder.fromJson(Map<String, dynamic> j) => PurchaseOrder(
    id: _int(j['id']),
    number: j['number'] as String?,
    status: j['status'] as String? ?? 'draft',
    supplierName: (j['supplier'] as Map<String, dynamic>?)?['name'] as String?,
    expectedDate: _date(j['expected_date']),
    receivedAt: _date(j['received_at']),
    totalHuf: _int(j['total_huf']),
    note: j['note'] as String?,
    items: [for (final e in (j['items'] as List?) ?? const []) OrderLine.fromJson(e as Map<String, dynamic>)],
  );

  static List<PurchaseOrder> fromPaged(Object? paged) => [for (final e in pagedContent(paged)) PurchaseOrder.fromJson(e)];
}
