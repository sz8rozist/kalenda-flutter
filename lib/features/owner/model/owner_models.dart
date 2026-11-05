// A vállalkozói felület modelljei (`/businesses/{id}/dashboard|calendar|customers`).

import '../../staff/model/staff_models.dart';

class WeekRevenue {
  WeekRevenue({required this.total, required this.toDateTotal, required this.previousToDateTotal});

  final int total;
  final int toDateTotal;
  final int previousToDateTotal;

  /// A mai napig tartó bevétel változása az előző hét azonos időszakához képest (%); null, ha nincs alap.
  double? get changePercent =>
      previousToDateTotal == 0 ? null : (toDateTotal - previousToDateTotal) * 100 / previousToDateTotal;

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
        appointments: ((j['appointments'] as List?) ?? const [])
            .map((e) => calendarAppointment(e as Map<String, dynamic>))
            .toList(),
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
