int _int(Object? v) => (v as num?)?.toInt() ?? 0;

/// Egy kiegészítő szolgáltatás (pl. hajmosás), amit a foglaláskor lehet választani.
class Addon {
  const Addon({
    required this.id,
    required this.name,
    required this.priceHuf,
    required this.durationMinutes,
    required this.isActive,
    required this.serviceIds,
    this.description,
  });

  final int id;
  final String name;
  final String? description;
  final int priceHuf;
  final int durationMinutes;
  final bool isActive;
  final List<int> serviceIds;

  factory Addon.fromJson(Map<String, dynamic> j) => Addon(
    id: _int(j['id']),
    name: j['name'] as String? ?? '',
    description: j['description'] as String?,
    priceHuf: _int(j['price_huf']),
    durationMinutes: _int(j['duration_minutes']),
    isActive: j['is_active'] as bool? ?? true,
    serviceIds: [for (final e in (j['service_ids'] as List?) ?? const []) (e as num).toInt()],
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'description': description ?? '',
    'price_huf': priceHuf,
    'duration_minutes': durationMinutes,
    'is_active': isActive,
    'service_ids': serviceIds,
  };
}

/// Egy munkatárs napi munkaideje (0 = vasárnap … 6 = szombat).
class StaffHour {
  const StaffHour({required this.dayOfWeek, required this.startAt, required this.endAt, required this.isDayOff});

  final int dayOfWeek;
  final String startAt;
  final String endAt;
  final bool isDayOff;

  StaffHour copyWith({String? startAt, String? endAt, bool? isDayOff}) =>
      StaffHour(dayOfWeek: dayOfWeek, startAt: startAt ?? this.startAt, endAt: endAt ?? this.endAt, isDayOff: isDayOff ?? this.isDayOff);

  factory StaffHour.fromJson(Map<String, dynamic> j) => StaffHour(
    dayOfWeek: _int(j['day_of_week']),
    startAt: j['start_at'] as String? ?? '09:00',
    endAt: j['end_at'] as String? ?? '17:00',
    isDayOff: j['is_day_off'] as bool? ?? false,
  );

  Map<String, Object?> toJson() => {
    'day_of_week': dayOfWeek,
    'is_day_off': isDayOff,
    if (!isDayOff) 'start_at': startAt,
    if (!isDayOff) 'end_at': endAt,
  };

  /// A hét hét napja: ha a szerver nem adott vissza egy napot, hétköznap 9–17, hétvégén szabadnap.
  static List<StaffHour> weekFrom(List<StaffHour> loaded) => [
    for (final day in const [1, 2, 3, 4, 5, 6, 0])
      loaded.where((h) => h.dayOfWeek == day).firstOrNull ??
          StaffHour(dayOfWeek: day, startAt: '09:00', endAt: '17:00', isDayOff: day == 0 || day == 6),
  ];
}

/// Egy munkatárs bér-beállítása.
class StaffPay {
  const StaffPay({
    required this.payType,
    required this.payRateHuf,
    required this.hoursSource,
    required this.serviceCommission,
    required this.productCommission,
  });

  /// `none` | `hourly` | `monthly` …
  final String payType;
  final int payRateHuf;

  /// `schedule` (beosztás) | `clock` (időmérés) | `appointments` (foglalások).
  final String hoursSource;
  final double serviceCommission;
  final double productCommission;

  factory StaffPay.fromJson(Map<String, dynamic> j) => StaffPay(
    payType: j['pay_type'] as String? ?? 'none',
    payRateHuf: _int(j['pay_rate_huf']),
    hoursSource: j['hours_source'] as String? ?? 'schedule',
    serviceCommission: (j['service_commission_percent'] as num?)?.toDouble() ?? 0,
    productCommission: (j['product_commission_percent'] as num?)?.toDouble() ?? 0,
  );
}

/// A munkatársi portál saját munkaidő-nyilvántartása (egy hónap).
class PortalTimesheet {
  const PortalTimesheet({
    required this.month,
    required this.entries,
    required this.plannedMinutes,
    required this.clockedMinutes,
    this.openSince,
    this.isStale = false,
  });

  final String month;
  final List<({int id, DateTime? clockIn, DateTime? clockOut, int workedMinutes, int breakMinutes})> entries;
  final int plannedMinutes;
  final int clockedMinutes;
  final DateTime? openSince;
  final bool isStale;

  factory PortalTimesheet.fromJson(Map<String, dynamic> j) {
    final clock = (j['time_clock'] as Map<String, dynamic>?) ?? const {};
    return PortalTimesheet(
      month: j['month'] as String? ?? '',
      entries: [
        for (final e in (j['entries'] as List?) ?? const [])
          (
            id: _int((e as Map<String, dynamic>)['id']),
            clockIn: DateTime.tryParse(e['clock_in_at'] as String? ?? '')?.toLocal(),
            clockOut: DateTime.tryParse(e['clock_out_at'] as String? ?? '')?.toLocal(),
            workedMinutes: _int(e['worked_minutes']),
            breakMinutes: _int(e['break_minutes']),
          ),
      ],
      plannedMinutes: _int(j['planned_minutes']),
      clockedMinutes: _int(j['clocked_minutes']),
      openSince: DateTime.tryParse(clock['open_since'] as String? ?? '')?.toLocal(),
      isStale: clock['is_stale'] as bool? ?? false,
    );
  }
}

/// A munkatárs saját profilja a portálon.
class PortalProfile {
  const PortalProfile({required this.name, required this.email, this.phone, this.bio, this.calendarFeedUrl});

  final String name;
  final String email;
  final String? phone;
  final String? bio;
  final String? calendarFeedUrl;

  factory PortalProfile.fromJson(Map<String, dynamic> j) => PortalProfile(
    name: j['name'] as String? ?? '',
    email: j['email'] as String? ?? '',
    phone: j['phone'] as String?,
    bio: j['bio'] as String?,
    calendarFeedUrl: j['calendar_feed_url'] as String?,
  );
}
