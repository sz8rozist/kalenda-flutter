int _int(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _date(Object? v) => DateTime.tryParse(v as String? ?? '')?.toLocal();

/// Egy bizonylat (számla / nyugta) a foglaláshoz.
class AppointmentDocument {
  const AppointmentDocument({
    required this.id,
    required this.kind,
    required this.role,
    required this.amountHuf,
    this.number,
    this.paymentMethod,
    this.cancelledAt,
    this.cancelNumber,
    this.createdAt,
  });

  final int id;

  /// `invoice` | `receipt`.
  final String kind;

  /// `deposit` (előleg) | `final` (végszámla) | egyéb.
  final String role;
  final String? number;
  final int amountHuf;
  final String? paymentMethod;
  final DateTime? cancelledAt;
  final String? cancelNumber;
  final DateTime? createdAt;

  bool get isCancelled => cancelledAt != null;

  factory AppointmentDocument.fromJson(Map<String, dynamic> j) => AppointmentDocument(
    id: _int(j['id']),
    kind: j['kind'] as String? ?? 'invoice',
    role: j['role'] as String? ?? '',
    amountHuf: _int(j['amount_huf']),
    number: j['number'] as String?,
    paymentMethod: j['payment_method'] as String?,
    cancelledAt: _date(j['cancelled_at']),
    cancelNumber: j['cancel_number'] as String?,
    createdAt: _date(j['created_at']),
  );
}

class PaymentLine {
  const PaymentLine({required this.method, required this.amountHuf, this.source, this.paidAt});

  final String method;
  final int amountHuf;
  final String? source;
  final DateTime? paidAt;

  factory PaymentLine.fromJson(Map<String, dynamic> j) => PaymentLine(
    method: j['method'] as String? ?? '',
    amountHuf: _int(j['amount_huf']),
    source: j['source'] as String?,
    paidAt: _date(j['paid_at']),
  );
}

class AppointmentAddon {
  const AppointmentAddon({required this.name, required this.priceHuf});

  final String name;
  final int priceHuf;
}

/// A vállalkozó által látott foglalás-részletek (`GET /businesses/{id}/appointments/{id}`).
class AppointmentDetail {
  const AppointmentDetail({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.serviceName,
    required this.totalHuf,
    required this.paidHuf,
    required this.dueHuf,
    required this.coveredByPass,
    required this.invoices,
    required this.payments,
    required this.addons,
    required this.invoicingReady,
    required this.invoiceRemainingHuf,
    this.notes,
    this.paymentStatus,
    this.staffName,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.manageToken,
    this.documentType,
  });

  final int id;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final String? notes;
  final String? paymentStatus;
  final String serviceName;
  final String? staffName;
  final int? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final int totalHuf;
  final int paidHuf;
  final int dueHuf;
  final bool coveredByPass;
  final List<AppointmentDocument> invoices;
  final List<PaymentLine> payments;
  final List<AppointmentAddon> addons;

  /// Kiállítható-e most bizonylat, és mekkora összegre.
  final bool invoicingReady;
  final int invoiceRemainingHuf;
  final String? manageToken;

  /// `receipt` (nyugta) vagy `invoice` (számla): mit állít ki a rendszer.
  final String? documentType;

  bool get isLive => status == 'pending' || status == 'confirmed';

  /// Volt-e már előlegszámla (akkor a következő a végszámla).
  bool get hasDepositInvoice => invoices.any((i) => i.kind == 'invoice' && i.role == 'deposit' && !i.isCancelled);

  factory AppointmentDetail.fromJson(Map<String, dynamic> j) {
    final a = (j['appointment'] as Map<String, dynamic>?) ?? const {};
    final payment = (j['payment'] as Map<String, dynamic>?) ?? const {};
    final invoicing = (j['invoicing'] as Map<String, dynamic>?) ?? const {};
    final service = (a['service'] as Map<String, dynamic>?) ?? const {};
    final staff = a['staff'] as Map<String, dynamic>?;
    final customer = a['customer'] as Map<String, dynamic>?;

    return AppointmentDetail(
      id: _int(a['id']),
      startsAt: _date(a['starts_at']) ?? DateTime.now(),
      endsAt: _date(a['ends_at']) ?? DateTime.now(),
      status: a['status'] as String? ?? 'pending',
      notes: a['notes'] as String?,
      paymentStatus: a['payment_status'] as String?,
      serviceName: service['name'] as String? ?? '',
      staffName: staff?['name'] as String?,
      customerId: (customer?['id'] as num?)?.toInt(),
      customerName: customer?['name'] as String?,
      customerEmail: customer?['email'] as String?,
      customerPhone: customer?['phone'] as String?,
      totalHuf: _int(payment['total_huf'] ?? a['total_price_huf']),
      paidHuf: _int(payment['paid_huf']),
      dueHuf: _int(payment['due_huf']),
      coveredByPass: payment['covered_by_pass'] as bool? ?? false,
      invoices: [for (final e in (a['invoices'] as List?) ?? const []) AppointmentDocument.fromJson(e as Map<String, dynamic>)],
      payments: [for (final e in (payment['payments'] as List?) ?? const []) PaymentLine.fromJson(e as Map<String, dynamic>)],
      addons: [
        for (final e in (a['addons'] as List?) ?? const [])
          AppointmentAddon(name: (e as Map<String, dynamic>)['name'] as String? ?? '', priceHuf: _int(e['price_huf'])),
      ],
      invoicingReady: invoicing['ready'] as bool? ?? false,
      invoiceRemainingHuf: _int(invoicing['remaining_huf']),
      documentType: invoicing['document_type'] as String?,
      manageToken: j['manage_token'] as String?,
    );
  }
}
