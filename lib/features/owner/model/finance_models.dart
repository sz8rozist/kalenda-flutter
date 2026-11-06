int _int(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _date(Object? v) => DateTime.tryParse(v as String? ?? '')?.toLocal();

/// Egy Stripe-kifizetés a vállalkozás bankszámlájára.
class Payout {
  const Payout({required this.id, required this.amountHuf, required this.status, this.arrivalDate});

  final String id;
  final int amountHuf;
  final String status;
  final DateTime? arrivalDate;

  factory Payout.fromJson(Map<String, dynamic> j) => Payout(
    id: j['id'] as String? ?? '',
    amountHuf: _int(j['amount_huf']),
    status: j['status'] as String? ?? '',
    arrivalDate: _date(j['arrival_date']),
  );
}

class PayoutLine {
  const PayoutLine({
    required this.type,
    required this.amountHuf,
    required this.feeHuf,
    required this.netHuf,
    this.description,
    this.created,
  });

  final String type;
  final int amountHuf;
  final int feeHuf;
  final int netHuf;
  final String? description;
  final DateTime? created;

  factory PayoutLine.fromJson(Map<String, dynamic> j) => PayoutLine(
    type: j['type'] as String? ?? '',
    amountHuf: _int(j['amount_huf']),
    feeHuf: _int(j['fee_huf']),
    netHuf: _int(j['net_huf']),
    description: j['description'] as String?,
    created: _date(j['created']),
  );
}

/// A kifizetések áttekintése és a kiválasztott kifizetés tételei.
class PayoutsOverview {
  const PayoutsOverview({
    required this.connected,
    required this.payouts,
    required this.lines,
    required this.grossHuf,
    required this.feeHuf,
    required this.netHuf,
    this.selected,
  });

  final bool connected;
  final List<Payout> payouts;
  final String? selected;
  final List<PayoutLine> lines;
  final int grossHuf;
  final int feeHuf;
  final int netHuf;

  factory PayoutsOverview.fromJson(Map<String, dynamic> j) {
    final detail = (j['detail'] as Map<String, dynamic>?) ?? const {};
    final totals = (detail['totals'] as Map<String, dynamic>?) ?? const {};
    return PayoutsOverview(
      connected: j['connected'] as bool? ?? false,
      selected: j['selected'] as String?,
      payouts: [for (final e in (j['payouts'] as List?) ?? const []) Payout.fromJson(e as Map<String, dynamic>)],
      lines: [for (final e in (detail['lines'] as List?) ?? const []) PayoutLine.fromJson(e as Map<String, dynamic>)],
      grossHuf: _int(totals['gross_huf']),
      feeHuf: _int(totals['fee_huf']),
      netHuf: _int(totals['net_huf']),
    );
  }
}

/// Egy kimaradt (nem kiállított) számla / nyugta, amit újra lehet próbálni.
class MissingDocument {
  const MissingDocument({
    required this.key,
    required this.amountHuf,
    this.type,
    this.date,
    this.customer,
    this.description,
    this.paymentMethod,
  });

  final String key;
  final String? type;
  final DateTime? date;
  final String? customer;
  final String? description;
  final int amountHuf;
  final String? paymentMethod;

  factory MissingDocument.fromJson(Map<String, dynamic> j) => MissingDocument(
    key: j['key'] as String? ?? '',
    type: j['type'] as String?,
    date: _date(j['date']),
    customer: j['customer'] as String?,
    description: j['description'] as String?,
    amountHuf: _int(j['amount_huf']),
    paymentMethod: j['payment_method'] as String?,
  );
}
