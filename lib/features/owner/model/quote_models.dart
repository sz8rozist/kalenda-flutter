/// Egy ajánlati tétel (név, mennyiség, egységár).
class QuoteItem {
  const QuoteItem({required this.name, required this.qty, required this.unitPriceHuf});

  final String name;
  final double qty;
  final int unitPriceHuf;

  factory QuoteItem.fromJson(Map<String, dynamic> j) => QuoteItem(
    name: j['name'] as String? ?? '',
    qty: (j['qty'] as num?)?.toDouble() ?? 1,
    unitPriceHuf: (j['unit_price_huf'] as num?)?.toInt() ?? 0,
  );
}

/// Egy árajánlat: piszkozat → elküldve → elfogadva → számlázva.
class Quote {
  const Quote({
    required this.id,
    required this.status,
    required this.totalHuf,
    required this.items,
    this.customerName = '',
    this.customerEmail,
    this.validUntil,
  });

  final int id;

  /// `draft` | `sent` | `accepted` | `converted`.
  final String status;
  final int totalHuf;
  final List<QuoteItem> items;
  final String customerName;
  final String? customerEmail;
  final DateTime? validUntil;

  bool get isConverted => status == 'converted';
  bool get isDraft => status == 'draft';

  factory Quote.fromJson(Map<String, dynamic> j) {
    final customer = j['customer'] as Map<String, dynamic>?;
    return Quote(
      id: (j['id'] as num).toInt(),
      status: j['status'] as String? ?? 'draft',
      totalHuf: (j['total_huf'] as num?)?.toInt() ?? 0,
      items: [for (final i in (j['items'] as List? ?? const [])) QuoteItem.fromJson(i as Map<String, dynamic>)],
      customerName: customer?['name'] as String? ?? '',
      customerEmail: customer?['email'] as String?,
      validUntil: j['valid_until'] == null ? null : DateTime.tryParse(j['valid_until'] as String),
    );
  }
}
