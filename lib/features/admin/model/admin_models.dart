import '../../owner/model/owner_tools_models.dart' show pagedContent;

int _int(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _date(Object? v) => DateTime.tryParse(v as String? ?? '')?.toLocal();

/// A platform összesítő számai (`GET /admin/dashboard`).
class AdminDashboard {
  const AdminDashboard({
    required this.users,
    required this.businesses,
    required this.appointments,
    required this.activeSubscriptions,
    required this.freePlan,
    required this.basicPlan,
    required this.professionalPlan,
    required this.appointmentsToday,
    required this.appointmentsThisMonth,
  });

  final int users;
  final int businesses;
  final int appointments;
  final int activeSubscriptions;
  final int freePlan;
  final int basicPlan;
  final int professionalPlan;
  final int appointmentsToday;
  final int appointmentsThisMonth;

  factory AdminDashboard.fromJson(Map<String, dynamic> j) => AdminDashboard(
    users: _int(j['total_users']),
    businesses: _int(j['total_businesses']),
    appointments: _int(j['total_appointments']),
    activeSubscriptions: _int(j['active_subscriptions']),
    freePlan: _int(j['free_plan']),
    basicPlan: _int(j['basic_plan']),
    professionalPlan: _int(j['professional_plan']),
    appointmentsToday: _int(j['appointments_today']),
    appointmentsThisMonth: _int(j['appointments_this_month']),
  );
}

class AdminBusiness {
  const AdminBusiness({
    required this.id,
    required this.name,
    required this.isActive,
    required this.plan,
    required this.appointments,
    required this.staff,
    this.city,
    this.ownerName,
    this.ownerEmail,
  });

  final int id;
  final String name;
  final String? city;
  final bool isActive;
  final String plan;
  final String? ownerName;
  final String? ownerEmail;
  final int appointments;
  final int staff;

  factory AdminBusiness.fromJson(Map<String, dynamic> j) {
    final owner = j['owner'] as Map<String, dynamic>?;
    return AdminBusiness(
      id: _int(j['id']),
      name: j['name'] as String? ?? '',
      city: j['city'] as String?,
      isActive: j['is_active'] as bool? ?? true,
      plan: j['plan'] as String? ?? '',
      ownerName: owner?['name'] as String?,
      ownerEmail: owner?['email'] as String?,
      appointments: _int(j['appointments_count']),
      staff: _int(j['staff_count']),
    );
  }

  static List<AdminBusiness> fromPaged(Object? paged) => [for (final e in pagedContent(paged)) AdminBusiness.fromJson(e)];
}

class AdminAppointment {
  const AdminAppointment({
    required this.id,
    required this.status,
    required this.priceHuf,
    this.startsAt,
    this.business,
    this.customer,
    this.service,
    this.staff,
  });

  final int id;
  final DateTime? startsAt;
  final String status;
  final String? business;
  final String? customer;
  final String? service;
  final String? staff;
  final int priceHuf;

  factory AdminAppointment.fromJson(Map<String, dynamic> j) => AdminAppointment(
    id: _int(j['id']),
    startsAt: _date(j['starts_at']),
    status: j['status'] as String? ?? '',
    business: (j['business'] as Map<String, dynamic>?)?['name'] as String?,
    customer: j['customer'] as String?,
    service: j['service'] as String?,
    staff: j['staff'] as String?,
    priceHuf: _int(j['total_price_huf']),
  );

  static List<AdminAppointment> fromPaged(Object? paged) => [for (final e in pagedContent(paged)) AdminAppointment.fromJson(e)];
}

class AdminFeedback {
  const AdminFeedback({
    required this.id,
    required this.type,
    required this.subject,
    required this.message,
    required this.status,
    this.adminResponse,
    this.userName,
    this.businessName,
    this.createdAt,
  });

  final int id;

  /// `bug` | `feature`.
  final String type;
  final String subject;
  final String message;

  /// `new` | `in_progress` | `resolved` | `rejected`.
  final String status;
  final String? adminResponse;
  final String? userName;
  final String? businessName;
  final DateTime? createdAt;

  factory AdminFeedback.fromJson(Map<String, dynamic> j) => AdminFeedback(
    id: _int(j['id']),
    type: j['type'] as String? ?? 'bug',
    subject: j['subject'] as String? ?? '',
    message: j['message'] as String? ?? '',
    status: j['status'] as String? ?? 'new',
    adminResponse: j['admin_response'] as String?,
    userName: (j['user'] as Map<String, dynamic>?)?['name'] as String?,
    businessName: (j['business'] as Map<String, dynamic>?)?['name'] as String?,
    createdAt: _date(j['created_at']),
  );

  static List<AdminFeedback> fromPaged(Object? paged) => [for (final e in pagedContent(paged)) AdminFeedback.fromJson(e)];
}
