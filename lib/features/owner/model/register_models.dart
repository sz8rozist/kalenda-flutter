int _int(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _date(Object? v) => DateTime.tryParse(v as String? ?? '')?.toLocal();

/// Egy pénztár-tétel (bevétel, befizetés a kasszába, kivét).
class RegisterPayment {
  const RegisterPayment({
    required this.id,
    required this.kind,
    required this.method,
    required this.amountHuf,
    this.description,
    this.paidAt,
  });

  final int id;

  /// `income` (bevétel) | `cash_in` (befizetés) | `cash_out` (kivét).
  final String kind;
  final String method;
  final int amountHuf;
  final String? description;
  final DateTime? paidAt;

  bool get isOut => kind == 'cash_out';

  factory RegisterPayment.fromJson(Map<String, dynamic> j) => RegisterPayment(
    id: _int(j['id']),
    kind: j['kind'] as String? ?? 'income',
    method: j['method'] as String? ?? 'cash',
    amountHuf: _int(j['amount_huf']),
    description: j['description'] as String?,
    paidAt: _date(j['paid_at']),
  );
}

/// Még ki nem fizetett foglalás a napon (a pénztárból egy koppintással rendezhető).
class UnpaidAppointment {
  const UnpaidAppointment({required this.id, required this.dueHuf, this.time, this.customer, this.service, this.staff});

  final int id;
  final String? time;
  final String? customer;
  final String? service;
  final String? staff;
  final int dueHuf;

  factory UnpaidAppointment.fromJson(Map<String, dynamic> j) => UnpaidAppointment(
    id: _int(j['id']),
    dueHuf: _int(j['due_huf']),
    time: j['time'] as String?,
    customer: j['customer'] as String?,
    service: j['service'] as String?,
    staff: j['staff'] as String?,
  );
}

/// Egy lezárt nap adatai.
class RegisterClosure {
  const RegisterClosure({required this.countedHuf, required this.expectedHuf, required this.differenceHuf, this.note});

  final int countedHuf;
  final int expectedHuf;
  final int differenceHuf;
  final String? note;

  factory RegisterClosure.fromJson(Map<String, dynamic> j) => RegisterClosure(
    countedHuf: _int(j['counted_cash_huf']),
    expectedHuf: _int(j['expected_cash_huf']),
    differenceHuf: _int(j['difference_huf']),
    note: j['note'] as String?,
  );
}

/// Egy nap pénztár-képe (`GET /businesses/{id}/register?date=`).
class RegisterDay {
  const RegisterDay({
    required this.date,
    required this.isToday,
    required this.incomeTotal,
    required this.onlineTotal,
    required this.cashIn,
    required this.cashOut,
    required this.openingCash,
    required this.expectedCash,
    required this.byMethod,
    required this.payments,
    required this.unpaid,
    required this.invoicingReady,
    this.closure,
  });

  final DateTime date;
  final bool isToday;
  final int incomeTotal;
  final int onlineTotal;
  final int cashIn;
  final int cashOut;
  final int openingCash;
  final int expectedCash;
  final Map<String, int> byMethod;
  final List<RegisterPayment> payments;
  final List<UnpaidAppointment> unpaid;
  final bool invoicingReady;
  final RegisterClosure? closure;

  bool get isClosed => closure != null;

  factory RegisterDay.fromJson(Map<String, dynamic> j) {
    final summary = (j['summary'] as Map<String, dynamic>?) ?? const {};
    final byMethod = (summary['by_method'] as Map<String, dynamic>?) ?? const {};
    final closure = summary['closure'] as Map<String, dynamic>?;

    return RegisterDay(
      date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
      isToday: j['is_today'] as bool? ?? true,
      incomeTotal: _int(summary['income_total']),
      onlineTotal: _int(summary['online_total']),
      cashIn: _int(summary['cash_in']),
      cashOut: _int(summary['cash_out']),
      openingCash: _int(summary['opening_cash']),
      expectedCash: _int(summary['expected_cash']),
      byMethod: {for (final e in byMethod.entries) e.key: _int(e.value)},
      payments: [for (final e in (summary['payments'] as List?) ?? const []) RegisterPayment.fromJson(e as Map<String, dynamic>)],
      unpaid: [
        for (final e in (summary['unpaid_appointments'] as List?) ?? const []) UnpaidAppointment.fromJson(e as Map<String, dynamic>),
      ],
      invoicingReady: j['invoicing_ready'] as bool? ?? false,
      closure: closure == null ? null : RegisterClosure.fromJson(closure),
    );
  }
}
