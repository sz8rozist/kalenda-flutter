// A vállalkozói felület modelljei (`/businesses/{id}/dashboard|calendar|customers`).

import '../../staff/model/staff_models.dart';

class WeekRevenue {
  WeekRevenue({required this.total, required this.toDateTotal, required this.previousToDateTotal});

  final int total;
  final int toDateTotal;
  final int previousToDateTotal;

  /// A mai napig tartó bevétel változása az előző hét azonos időszakához képest (%); null, ha nincs alap.
  double? get changePercent => previousToDateTotal == 0 ? null : (toDateTotal - previousToDateTotal) * 100 / previousToDateTotal;

  factory WeekRevenue.fromJson(Map<String, dynamic>? j) => WeekRevenue(
    total: (j?['total'] as num?)?.toInt() ?? 0,
    toDateTotal: (j?['to_date_total'] as num?)?.toInt() ?? 0,
    previousToDateTotal: (j?['previous_to_date_total'] as num?)?.toInt() ?? 0,
  );
}

class Receivables {
  Receivables({required this.outstandingHuf, required this.outstandingCount, required this.overdueHuf, required this.overdueCount});

  final int outstandingHuf;
  final int outstandingCount;
  final int overdueHuf;
  final int overdueCount;

  factory Receivables.fromJson(Map<String, dynamic>? j) => Receivables(
    outstandingHuf: (j?['outstanding_huf'] as num?)?.toInt() ?? 0,
    outstandingCount: (j?['outstanding_count'] as num?)?.toInt() ?? 0,
    overdueHuf: (j?['overdue_huf'] as num?)?.toInt() ?? 0,
    overdueCount: (j?['overdue_count'] as num?)?.toInt() ?? 0,
  );
}

class OwnerDashboard {
  OwnerDashboard({
    required this.appointmentsToday,
    required this.confirmed,
    required this.today,
    required this.weekRevenue,
    required this.receivables,
    required this.lowStockCount,
  });

  final int appointmentsToday;
  final int confirmed;
  final List<PortalAppointment> today;
  final WeekRevenue weekRevenue;
  final Receivables receivables;
  final int lowStockCount;

  factory OwnerDashboard.fromJson(Map<String, dynamic> j) {
    final counts = (j['counts'] as Map<String, dynamic>?) ?? const {};
    return OwnerDashboard(
      appointmentsToday: (counts['appointments_today'] as num?)?.toInt() ?? 0,
      confirmed: (counts['confirmed_appointments'] as num?)?.toInt() ?? 0,
      today: ((j['today'] as List?) ?? const []).map((e) => PortalAppointment.fromJson(e as Map<String, dynamic>)).toList(),
      weekRevenue: WeekRevenue.fromJson(j['week_revenue'] as Map<String, dynamic>?),
      receivables: Receivables.fromJson(j['receivables'] as Map<String, dynamic>?),
      lowStockCount: (j['low_stock_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A naptár egy tétele (`GET /businesses/{id}/calendar`) a munkatársi foglalás-modellre képezve.
PortalAppointment calendarAppointment(Map<String, dynamic> j) => PortalAppointment(
  id: (j['id'] as num).toInt(),
  startsAt: DateTime.parse(j['start'] as String),
  endsAt: DateTime.parse(j['end'] as String),
  status: j['status'] as String? ?? '',
  serviceName: j['title'] as String? ?? '',
  customerName: j['customer_name'] as String?,
  canManage: true,
);

class OwnerCalendar {
  OwnerCalendar({required this.appointments, required this.leaves});

  final List<PortalAppointment> appointments;
  final List<PortalLeave> leaves;

  factory OwnerCalendar.fromJson(Map<String, dynamic> j) => OwnerCalendar(
    appointments: ((j['appointments'] as List?) ?? const []).map((e) => calendarAppointment(e as Map<String, dynamic>)).toList(),
    leaves: ((j['leaves'] as List?) ?? const []).map((e) => PortalLeave.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

class CustomerItem {
  CustomerItem({
    required this.id,
    required this.name,
    required this.totalCount,
    required this.noShowCount,
    required this.upcomingCount,
    required this.totalSpentHuf,
    this.email,
    this.phone,
    this.lastVisitAt,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final int totalCount;
  final int noShowCount;
  final int upcomingCount;
  final int totalSpentHuf;
  final DateTime? lastVisitAt;

  factory CustomerItem.fromJson(Map<String, dynamic> j) => CustomerItem(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String? ?? '',
    email: j['email'] as String?,
    phone: j['phone'] as String?,
    totalCount: (j['total_count'] as num?)?.toInt() ?? 0,
    noShowCount: (j['no_show_count'] as num?)?.toInt() ?? 0,
    upcomingCount: (j['upcoming_count'] as num?)?.toInt() ?? 0,
    totalSpentHuf: (j['total_spent_huf'] as num?)?.toInt() ?? 0,
    lastVisitAt: j['last_visit_at'] == null ? null : DateTime.parse(j['last_visit_at'] as String),
  );
}

/// Meglévő ügyfél a foglalás felviteléhez (`GET /businesses/{id}/appointment-customers`).
class CustomerOption {
  CustomerOption({required this.id, required this.name, this.email, this.phone});

  final int id;
  final String name;
  final String? email;
  final String? phone;

  factory CustomerOption.fromJson(Map<String, dynamic> j) => CustomerOption(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String? ?? '',
    email: j['email'] as String?,
    phone: j['phone'] as String?,
  );
}

/// A vállalkozó által felvitt foglalás (`POST /businesses/{id}/appointments`). Meglévő ügyfélnél a `customerId`,
/// újnál a név (e-mail, telefon elhagyható).
class OwnerBookingRequest {
  OwnerBookingRequest({
    required this.serviceId,
    required this.staffId,
    required this.date,
    required this.time,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.notes,
    this.sendEmail = false,
  });

  final int serviceId;
  final int staffId;
  final DateTime date;
  final String time;
  final int? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? notes;
  final bool sendEmail;
}

/// A felvitt foglalás űrlapjának szövegmezői (új ügyfélnél a név / e-mail / telefon).
class OwnerBookingDetails {
  const OwnerBookingDetails({this.name, this.email, this.phone, this.notes});

  final String? name;
  final String? email;
  final String? phone;
  final String? notes;
}

/// Egy számla a vállalkozói listában (`GET /businesses/{id}/invoices`).
class InvoiceItem {
  InvoiceItem({
    required this.id,
    required this.number,
    required this.totalHuf,
    required this.paymentState,
    required this.reminderCount,
    this.customerName,
    this.issuedAt,
    this.dueDate,
    this.paidAt,
    this.cancelled = false,
  });

  final int id;
  final String number;
  final String? customerName;
  final int totalHuf;
  final DateTime? issuedAt;
  final DateTime? dueDate;
  final DateTime? paidAt;

  /// `unpaid` (nyitott) | `overdue` (lejárt) | `paid` (kifizetve).
  final String paymentState;
  final int reminderCount;
  final bool cancelled;

  bool get isPaid => paymentState == 'paid';

  factory InvoiceItem.fromJson(Map<String, dynamic> j) {
    DateTime? date(String key) => j[key] == null ? null : DateTime.tryParse(j[key] as String);

    return InvoiceItem(
      id: (j['id'] as num).toInt(),
      number: j['number'] as String? ?? '',
      customerName: (j['customer'] as Map<String, dynamic>?)?['name'] as String?,
      totalHuf: (j['total_huf'] as num?)?.toInt() ?? 0,
      issuedAt: date('issued_at'),
      dueDate: date('due_date'),
      paidAt: date('paid_at'),
      paymentState: j['payment_state'] as String? ?? 'unpaid',
      reminderCount: (j['reminder_count'] as num?)?.toInt() ?? 0,
      cancelled: j['cancelled_at'] != null,
    );
  }
}

/// Havi könyvelői összesítő (`GET /businesses/{id}/reports/accounting?month=ÉÉÉÉ-HH`) – a megjelenített mezők.
class AccountingReport {
  AccountingReport({
    required this.grossTotalHuf,
    required this.servicesHuf,
    required this.productsHuf,
    required this.passesSoldHuf,
    required this.vouchersSoldHuf,
    required this.expensesTotalHuf,
    required this.expensesByCategory,
    required this.materialCostHuf,
    required this.receivablesAtMonthEndHuf,
    required this.resultHuf,
    required this.documentsTotalHuf,
    required this.documentsCancelledCount,
    this.payrollEstimateHuf,
  });

  final int grossTotalHuf;
  final int servicesHuf;
  final int productsHuf;
  final int passesSoldHuf;
  final int vouchersSoldHuf;
  final int expensesTotalHuf;
  final Map<String, int> expensesByCategory;
  final int? payrollEstimateHuf;
  final int materialCostHuf;
  final int receivablesAtMonthEndHuf;
  final int resultHuf;
  final int documentsTotalHuf;
  final int documentsCancelledCount;

  factory AccountingReport.fromJson(Map<String, dynamic> j) {
    int n(Object? v) => (v as num?)?.toInt() ?? 0;
    final revenue = (j['revenue'] as Map<String, dynamic>?) ?? const {};

    return AccountingReport(
      grossTotalHuf: n(revenue['gross_total_huf']),
      servicesHuf: n(revenue['services_huf']),
      productsHuf: n(revenue['products_huf']),
      passesSoldHuf: n(revenue['passes_sold_huf']),
      vouchersSoldHuf: n(revenue['vouchers_sold_huf']),
      expensesTotalHuf: n(j['expenses_total_huf']),
      expensesByCategory: {for (final e in ((j['expenses_by_category'] as Map<String, dynamic>?) ?? const {}).entries) e.key: n(e.value)},
      payrollEstimateHuf: (j['payroll_estimate_huf'] as num?)?.toInt(),
      materialCostHuf: n(j['material_cost_huf']),
      receivablesAtMonthEndHuf: n(j['receivables_at_month_end_huf']),
      resultHuf: n(j['result_huf']),
      documentsTotalHuf: n(j['documents_total_huf']),
      documentsCancelledCount: n(j['documents_cancelled_count']),
    );
  }
}

/// A cash flow előrejelzés egy időszaka (`GET /businesses/{id}/reports/cashflow`).
class CashflowPeriod {
  CashflowPeriod({required this.label, required this.partial, required this.inflowHuf, required this.outflowHuf, required this.netHuf});

  final String label;

  /// Még nem teljes időszak (folyamatban van).
  final bool partial;
  final int inflowHuf;
  final int outflowHuf;
  final int netHuf;

  factory CashflowPeriod.fromJson(Map<String, dynamic> j) => CashflowPeriod(
    label: j['label'] as String? ?? '',
    partial: j['partial'] as bool? ?? false,
    inflowHuf: ((j['inflow'] as Map<String, dynamic>?)?['total_huf'] as num?)?.toInt() ?? 0,
    outflowHuf: ((j['outflow'] as Map<String, dynamic>?)?['total_huf'] as num?)?.toInt() ?? 0,
    netHuf: (j['net_huf'] as num?)?.toInt() ?? 0,
  );
}

/// Egy szolgáltatás a vállalkozói kezelőben (`GET /businesses/{id}/services`).
class OwnerService {
  OwnerService({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.isActive,
    this.priceHuf,
    this.isGroup = false,
    this.isRental = false,
    this.description,
    this.depositType = 'none',
    this.depositPercentage,
    this.color = '#3b82f6',
    this.bufferBefore = 0,
    this.bufferAfter = 0,
    this.maxDurationMinutes,
    this.durationStepMinutes,
  });

  final int id;
  final String name;
  final int durationMinutes;
  final int? priceHuf;
  final bool isActive;
  final bool isGroup;
  final bool isRental;
  final String? description;

  /// `none` | `percentage` | `full`.
  final String depositType;
  final int? depositPercentage;
  final String color;
  final int bufferBefore;
  final int bufferAfter;
  final int? maxDurationMinutes;
  final int? durationStepMinutes;

  factory OwnerService.fromJson(Map<String, dynamic> j) => OwnerService(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String? ?? '',
    durationMinutes: (j['duration_minutes'] as num?)?.toInt() ?? 0,
    priceHuf: (j['price_huf'] as num?)?.toInt(),
    isActive: j['is_active'] as bool? ?? true,
    isGroup: j['is_group'] as bool? ?? false,
    isRental: j['is_rental'] as bool? ?? false,
    description: j['description'] as String?,
    depositType: j['deposit_type'] as String? ?? 'none',
    depositPercentage: (j['deposit_percentage'] as num?)?.toInt(),
    color: j['color'] as String? ?? '#3b82f6',
    bufferBefore: (j['buffer_time_before'] as num?)?.toInt() ?? 0,
    bufferAfter: (j['buffer_time_after'] as num?)?.toInt() ?? 0,
    maxDurationMinutes: (j['max_duration_minutes'] as num?)?.toInt(),
    durationStepMinutes: (j['duration_step_minutes'] as num?)?.toInt(),
  );

  /// A teljes mentés (`POST`/`PUT /businesses/{id}/services`) kérés-törzse.
  Map<String, Object?> toSaveJson() => {
    'name': name,
    'description': description ?? '',
    'duration_minutes': durationMinutes,
    'price_huf': priceHuf,
    'deposit_type': depositType,
    'deposit_percentage': depositType == 'percentage' ? depositPercentage : null,
    'color': color,
    'buffer_time_before': bufferBefore,
    'buffer_time_after': bufferAfter,
    'is_active': isActive,
    'is_group': isGroup,
    'is_rental': isRental,
    'max_duration_minutes': isRental ? maxDurationMinutes : null,
    'duration_step_minutes': isRental ? durationStepMinutes : null,
  };
}

/// A vállalkozás nyitvatartása egy napra (`GET/PUT /businesses/{id}/hours`). A nap: 0 = vasárnap … 6 = szombat.
class HourRow {
  const HourRow({required this.dayOfWeek, required this.openAt, required this.closeAt, required this.isClosed});

  final int dayOfWeek;
  final String openAt;
  final String closeAt;
  final bool isClosed;

  HourRow copyWith({String? openAt, String? closeAt, bool? isClosed}) =>
      HourRow(dayOfWeek: dayOfWeek, openAt: openAt ?? this.openAt, closeAt: closeAt ?? this.closeAt, isClosed: isClosed ?? this.isClosed);

  factory HourRow.fromJson(Map<String, dynamic> j) => HourRow(
    dayOfWeek: (j['day_of_week'] as num).toInt(),
    openAt: _hhmm(j['open_at'] as String?, '09:00'),
    closeAt: _hhmm(j['close_at'] as String?, '17:00'),
    isClosed: j['is_closed'] as bool? ?? false,
  );

  /// Zárt napnál a szerver 00:00-t tárol: nyitáskor értelmes alapérték kell.
  static String _hhmm(String? value, String fallback) {
    if (value == null || value.length < 5) return fallback;
    final text = value.substring(0, 5);
    return text == '00:00' ? fallback : text;
  }

  Map<String, dynamic> toJson() => {
    'day_of_week': dayOfWeek,
    'is_closed': isClosed,
    if (!isClosed) 'open_at': openAt,
    if (!isClosed) 'close_at': closeAt,
  };
}

/// Egy munkatárs szabadság-igénylése a vállalkozó döntésére várva (`GET /businesses/{id}/leave-requests`).
class OwnerLeaveRequest {
  OwnerLeaveRequest({
    required this.id,
    required this.staffName,
    required this.dateFrom,
    required this.dateTo,
    required this.status,
    this.reason,
  });

  final int id;
  final String staffName;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String status;
  final String? reason;

  factory OwnerLeaveRequest.fromJson(Map<String, dynamic> j) => OwnerLeaveRequest(
    id: (j['id'] as num).toInt(),
    staffName: (j['staff'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    dateFrom: DateTime.parse(j['date_from'] as String),
    dateTo: DateTime.parse(j['date_to'] as String),
    status: j['status'] as String? ?? '',
    reason: j['reason'] as String?,
  );
}

/// Egy munkatárs a vállalkozói kezelőben (`GET /businesses/{id}/staff`).
class OwnerStaff {
  OwnerStaff({
    required this.id,
    required this.name,
    required this.isActive,
    required this.hasAccount,
    required this.upcomingCount,
    this.email,
    this.phone,
    this.bio,
    this.color = '#3b82f6',
    this.kind = 'person',
    this.serviceIds = const [],
    this.photoUrl,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final bool isActive;

  /// Van-e bejelentkezési fiókja (a munkatársi portált használja).
  final bool hasAccount;
  final int upcomingCount;
  final String? bio;
  final String color;

  /// `person` | `resource` (pálya, terem).
  final String kind;
  final List<int> serviceIds;
  final String? photoUrl;

  factory OwnerStaff.fromJson(Map<String, dynamic> j) => OwnerStaff(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String? ?? '',
    email: j['email'] as String?,
    phone: j['phone'] as String?,
    isActive: j['is_active'] as bool? ?? true,
    hasAccount: j['has_account'] as bool? ?? false,
    upcomingCount: (j['upcoming_appointments_count'] as num?)?.toInt() ?? 0,
    bio: j['bio'] as String?,
    color: j['color'] as String? ?? '#3b82f6',
    kind: j['kind'] as String? ?? 'person',
    serviceIds: [for (final id in (j['service_ids'] as List?) ?? const []) (id as num).toInt()],
    photoUrl: j['photo_url'] as String?,
  );
}
