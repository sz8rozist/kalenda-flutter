import 'owner_tools_models.dart' show pagedContent;

int _int(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _date(Object? v) => DateTime.tryParse(v as String? ?? '')?.toLocal();

class GroupAttendee {
  const GroupAttendee({required this.name, required this.status, this.email, this.phone});

  final String name;
  final String status;
  final String? email;
  final String? phone;

  factory GroupAttendee.fromJson(Map<String, dynamic> j) => GroupAttendee(
    name: j['customer_name'] as String? ?? '',
    status: j['status'] as String? ?? '',
    email: j['customer_email'] as String?,
    phone: j['customer_phone'] as String?,
  );
}

/// Egy csoportos alkalom a vállalkozói kezelőben.
class GroupSessionItem {
  const GroupSessionItem({
    required this.id,
    required this.startsAt,
    required this.capacity,
    required this.booked,
    required this.placesLeft,
    required this.status,
    required this.attendees,
    this.priceHuf,
    this.serviceName,
    this.staffName,
    this.notes,
  });

  final int id;
  final DateTime startsAt;
  final int capacity;
  final int booked;
  final int placesLeft;
  final int? priceHuf;

  /// `scheduled` | `cancelled` | …
  final String status;
  final String? serviceName;
  final String? staffName;
  final String? notes;
  final List<GroupAttendee> attendees;

  bool get isCancelled => status == 'cancelled';

  factory GroupSessionItem.fromJson(Map<String, dynamic> j) => GroupSessionItem(
    id: _int(j['id']),
    startsAt: _date(j['starts_at']) ?? DateTime.now(),
    capacity: _int(j['capacity']),
    booked: _int(j['booked']),
    placesLeft: _int(j['places_left']),
    priceHuf: (j['price_huf'] as num?)?.toInt(),
    status: j['status'] as String? ?? '',
    serviceName: (j['service'] as Map<String, dynamic>?)?['name'] as String?,
    staffName: (j['staff'] as Map<String, dynamic>?)?['name'] as String?,
    notes: j['notes'] as String?,
    attendees: [for (final e in (j['attendees'] as List?) ?? const []) GroupAttendee.fromJson(e as Map<String, dynamic>)],
  );

  static List<GroupSessionItem> fromPaged(Object? paged) => [for (final e in pagedContent(paged)) GroupSessionItem.fromJson(e)];
}

/// Egy ismétlődő szünet (pl. ebédidő) egy munkatárs heti beosztásában.
class StaffBreak {
  const StaffBreak({required this.id, required this.dayOfWeek, required this.startAt, required this.endAt, this.label});

  final int id;

  /// 0 = vasárnap … 6 = szombat.
  final int dayOfWeek;
  final String startAt;
  final String endAt;
  final String? label;

  factory StaffBreak.fromJson(Map<String, dynamic> j) => StaffBreak(
    id: _int(j['id']),
    dayOfWeek: _int(j['day_of_week']),
    startAt: j['start_at'] as String? ?? '',
    endAt: j['end_at'] as String? ?? '',
    label: j['label'] as String?,
  );
}

class StaffBreaks {
  const StaffBreaks({required this.staffId, required this.staffName, required this.breaks});

  final int staffId;
  final String staffName;
  final List<StaffBreak> breaks;

  factory StaffBreaks.fromJson(Map<String, dynamic> j) {
    final staff = (j['staff'] as Map<String, dynamic>?) ?? const {};
    return StaffBreaks(
      staffId: _int(staff['id']),
      staffName: staff['name'] as String? ?? '',
      breaks: [for (final e in (j['breaks'] as List?) ?? const []) StaffBreak.fromJson(e as Map<String, dynamic>)],
    );
  }
}

/// Egy munkatárs havi munkaidő-összesítője.
class TimesheetRow {
  const TimesheetRow({
    required this.staffId,
    required this.name,
    required this.workedMinutes,
    required this.plannedMinutes,
    required this.overtimeMinutes,
    required this.estimatedPayHuf,
    required this.shiftCount,
    this.openSince,
    this.openIsStale = false,
  });

  final int staffId;
  final String name;
  final int workedMinutes;
  final int plannedMinutes;
  final int overtimeMinutes;
  final int estimatedPayHuf;
  final int shiftCount;
  final DateTime? openSince;
  final bool openIsStale;

  factory TimesheetRow.fromJson(Map<String, dynamic> j) => TimesheetRow(
    staffId: _int(j['staff_id']),
    name: j['name'] as String? ?? '',
    workedMinutes: _int(j['worked_minutes']),
    plannedMinutes: _int(j['planned_minutes']),
    overtimeMinutes: _int(j['overtime_minutes']),
    estimatedPayHuf: _int(j['estimated_pay_huf']),
    shiftCount: _int(j['shift_count']),
    openSince: _date(j['open_since']),
    openIsStale: j['open_is_stale'] as bool? ?? false,
  );
}

class TimeEntryItem {
  const TimeEntryItem({
    required this.id,
    required this.staffName,
    required this.workedMinutes,
    required this.breakMinutes,
    this.clockInAt,
    this.clockOutAt,
    this.note,
  });

  final int id;
  final String staffName;
  final DateTime? clockInAt;
  final DateTime? clockOutAt;
  final int workedMinutes;
  final int breakMinutes;
  final String? note;

  factory TimeEntryItem.fromJson(Map<String, dynamic> j) => TimeEntryItem(
    id: _int(j['id']),
    staffName: (j['staff'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    clockInAt: _date(j['clock_in_at']),
    clockOutAt: _date(j['clock_out_at']),
    workedMinutes: _int(j['worked_minutes']),
    breakMinutes: _int(j['break_minutes']),
    note: j['note'] as String?,
  );
}

/// A munkaidő-nyilvántartás egy hónapja.
class TimesheetMonth {
  const TimesheetMonth({
    required this.month,
    required this.rows,
    required this.entries,
    required this.workedMinutes,
    required this.estimatedPayHuf,
    required this.staleOpenCount,
    required this.staffOptions,
    this.closedAt,
  });

  final String month;
  final List<TimesheetRow> rows;
  final List<TimeEntryItem> entries;
  final int workedMinutes;
  final int estimatedPayHuf;
  final int staleOpenCount;
  final DateTime? closedAt;
  final List<({int id, String name})> staffOptions;

  bool get isClosed => closedAt != null;

  factory TimesheetMonth.fromJson(Map<String, dynamic> j) {
    final summary = (j['summary'] as Map<String, dynamic>?) ?? const {};
    final totals = (summary['totals'] as Map<String, dynamic>?) ?? const {};
    return TimesheetMonth(
      month: j['month'] as String? ?? '',
      rows: [for (final e in (summary['rows'] as List?) ?? const []) TimesheetRow.fromJson(e as Map<String, dynamic>)],
      entries: [for (final e in pagedContent(j['entries'])) TimeEntryItem.fromJson(e)],
      workedMinutes: _int(totals['worked_minutes']),
      estimatedPayHuf: _int(totals['estimated_pay_huf']),
      staleOpenCount: _int(totals['stale_open_count']),
      closedAt: _date(summary['closed_at']),
      staffOptions: [
        for (final e in (j['staff_options'] as List?) ?? const [])
          (id: _int((e as Map<String, dynamic>)['id']), name: e['name'] as String? ?? ''),
      ],
    );
  }
}
