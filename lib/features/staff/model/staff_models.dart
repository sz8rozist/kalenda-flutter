// A munkatársi portál modelljei (`/me`, `/staff-portal/*`). Az időpontok helyi falióra-idők, "Z" nélkül.

List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) from) =>
    ((raw as List?) ?? const []).map((e) => from(e as Map<String, dynamic>)).toList();

/// A bejelentkezett felhasználó (`GET /me`): szerepkörök és a vállalkozás.
class StaffUser {
  StaffUser({
    required this.name,
    required this.email,
    required this.isStaff,
    required this.isOwner,
    this.isAdmin = false,
    this.businessName,
    this.businessId,
    this.businessSlug,
  });

  /// A platform adminisztrátora (az admin felület elérhető).
  final bool isAdmin;

  final String? businessSlug;

  final int? businessId;

  final String name;
  final String email;
  final bool isStaff;
  final bool isOwner;
  final String? businessName;

  factory StaffUser.fromJson(Map<String, dynamic> j) {
    final roles = (j['roles'] as Map<String, dynamic>?) ?? const {};
    final business = j['business'] as Map<String, dynamic>?;
    final staffBusiness = (j['staff'] as Map<String, dynamic>?)?['business'] as Map<String, dynamic>?;

    return StaffUser(
      name: j['name'] as String? ?? '',
      email: j['email'] as String? ?? '',
      isStaff: roles['staff'] as bool? ?? false,
      isOwner: roles['business_owner'] as bool? ?? false,
      isAdmin: roles['admin'] as bool? ?? false,
      businessName: (business?['name'] ?? staffBusiness?['name']) as String?,
      businessId: ((business?['id'] ?? staffBusiness?['id']) as num?)?.toInt(),
      businessSlug: (business?['slug'] ?? staffBusiness?['slug']) as String?,
    );
  }
}

class PortalAppointment {
  PortalAppointment({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.serviceName,
    required this.canManage,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.notes,
    this.totalPriceHuf,
  });

  final int id;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final String serviceName;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? notes;
  final int? totalPriceHuf;
  final bool canManage;

  factory PortalAppointment.fromJson(Map<String, dynamic> j) {
    final customer = j['customer'] as Map<String, dynamic>?;
    return PortalAppointment(
      id: (j['id'] as num).toInt(),
      startsAt: DateTime.parse(j['starts_at'] as String),
      endsAt: DateTime.parse(j['ends_at'] as String),
      status: j['status'] as String? ?? '',
      serviceName: (j['service'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      customerName: customer?['name'] as String?,
      customerPhone: customer?['phone'] as String?,
      customerEmail: customer?['email'] as String?,
      notes: j['notes'] as String?,
      totalPriceHuf: (j['total_price_huf'] as num?)?.toInt(),
      // A vezérlőpult listája nem küld can_manage-et: ott a saját foglalások jönnek, a szerver úgyis ellenőriz.
      canManage: j['can_manage'] as bool? ?? true,
    );
  }
}

/// A be-/kicsekkolás állapota: `openSince` kitöltve = jelenleg bent van.
class ClockState {
  ClockState({this.openSince, this.isStale = false});

  final DateTime? openSince;
  final bool isStale;

  bool get isClockedIn => openSince != null;

  factory ClockState.fromJson(Map<String, dynamic>? j) => ClockState(
        openSince: j?['open_since'] == null ? null : DateTime.parse(j!['open_since'] as String),
        isStale: j?['is_stale'] as bool? ?? false,
      );
}

class PortalDashboard {
  PortalDashboard({required this.staffName, required this.businessName, required this.todayCount, required this.upcoming, required this.clock});

  final String staffName;
  final String businessName;
  final int todayCount;
  final List<PortalAppointment> upcoming;
  final ClockState clock;

  factory PortalDashboard.fromJson(Map<String, dynamic> j) => PortalDashboard(
        staffName: (j['staff'] as Map<String, dynamic>?)?['name'] as String? ?? '',
        businessName: (j['business'] as Map<String, dynamic>?)?['name'] as String? ?? '',
        todayCount: (j['today_count'] as num?)?.toInt() ?? 0,
        upcoming: _list(j['upcoming'], PortalAppointment.fromJson),
        clock: ClockState.fromJson(j['time_clock'] as Map<String, dynamic>?),
      );
}

class PortalLeave {
  PortalLeave({required this.dateFrom, required this.dateTo, this.reason});

  final DateTime dateFrom;
  final DateTime dateTo;
  final String? reason;

  factory PortalLeave.fromJson(Map<String, dynamic> j) => PortalLeave(
        dateFrom: DateTime.parse(j['date_from'] as String),
        dateTo: DateTime.parse(j['date_to'] as String),
        reason: j['reason'] as String?,
      );
}

class PortalCalendar {
  PortalCalendar({required this.appointments, required this.leaves});

  final List<PortalAppointment> appointments;
  final List<PortalLeave> leaves;

  factory PortalCalendar.fromJson(Map<String, dynamic> j) => PortalCalendar(
        appointments: _list(j['appointments'], PortalAppointment.fromJson),
        leaves: _list(j['leaves'], PortalLeave.fromJson),
      );
}

/// A saját szabadság-igénylés (`/staff-portal/leave-requests`); a status: pending | approved | rejected | cancelled.
class LeaveRequest {
  LeaveRequest({required this.id, required this.dateFrom, required this.dateTo, required this.status, this.reason});

  final int id;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String status;
  final String? reason;

  bool get cancellable => status == 'pending';

  factory LeaveRequest.fromJson(Map<String, dynamic> j) => LeaveRequest(
        id: (j['id'] as num).toInt(),
        dateFrom: DateTime.parse(j['date_from'] as String),
        dateTo: DateTime.parse(j['date_to'] as String),
        status: j['status'] as String? ?? '',
        reason: j['reason'] as String?,
      );
}
