/// Egy időpont-rács lekérdezése: melyik vállalkozás, szolgáltatás, munkatárs, nap és kiegészítők.
/// Értékegyenlőség van rajta (provider-kulcs): a kiegészítők sorrendje nem számít.
class SlotQuery {
  SlotQuery({required this.slug, required this.serviceId, required this.staffId, required DateTime date, required List<int> addonIds, this.durationMinutes})
      : date = DateTime(date.year, date.month, date.day),
        addonIds = List.unmodifiable([...addonIds]..sort());

  final String slug;
  final int serviceId;
  final int staffId;
  final DateTime date;
  final List<int> addonIds;

  /// Bérlésnél a kért időtartam (perc).
  final int? durationMinutes;

  @override
  bool operator ==(Object other) =>
      other is SlotQuery &&
      other.slug == slug &&
      other.serviceId == serviceId &&
      other.staffId == staffId &&
      other.date == date &&
      other.durationMinutes == durationMinutes &&
      other.addonIds.length == addonIds.length &&
      Iterable<int>.generate(addonIds.length).every((i) => addonIds[i] == other.addonIds[i]);

  @override
  int get hashCode => Object.hash(slug, serviceId, staffId, date, durationMinutes, Object.hashAll(addonIds));
}

/// A foglalás beküldött adatai (`POST /public/businesses/{slug}/bookings`).
class BookingRequest {
  BookingRequest({
    required this.serviceId,
    required this.staffId,
    required this.date,
    required this.time,
    required this.name,
    required this.email,
    this.phone,
    this.notes,
    this.passCode,
    this.marketingConsent,
    this.addonIds = const [],
    this.durationMinutes,
  });

  final int serviceId;
  final int staffId;
  final DateTime date;
  final String time;
  final String name;
  final String email;
  final String? phone;
  final String? notes;
  final String? passCode;
  final bool? marketingConsent;
  final List<int> addonIds;

  /// Bérlésnél a kért időtartam (perc).
  final int? durationMinutes;
}

/// Feliratkozás a várólistára (`POST /public/businesses/{slug}/waitlist`).
class WaitlistRequest {
  WaitlistRequest({required this.serviceId, required this.name, required this.email, this.staffId, this.phone, this.preferredDate});

  final int serviceId;
  final int? staffId;
  final String name;
  final String email;
  final String? phone;
  final DateTime? preferredDate;
}

/// A form mezői, ahogy a View beírta őket (a ViewModel ebből és a saját állapotából állítja össze a kérést).
class BookingDetails {
  const BookingDetails({required this.name, required this.email, this.phone, this.notes, this.passCode});

  final String name;
  final String email;
  final String? phone;
  final String? notes;
  final String? passCode;
}

/// Jelentkezés egy csoportos alkalomra (`POST /public/businesses/{slug}/group-sessions/{id}/bookings`).
class GroupBookRequest {
  GroupBookRequest({required this.name, required this.email, this.phone, this.notes, this.passCode, this.marketingConsent});

  final String name;
  final String email;
  final String? phone;
  final String? notes;
  final String? passCode;
  final bool? marketingConsent;
}

/// Bérlet / utalvány vásárlása (`POST /public/businesses/{slug}/passes/checkout`); ajándéknál a címzett adataival.
class PassPurchaseRequest {
  PassPurchaseRequest({required this.passTypeId, required this.email, this.recipientName, this.recipientEmail, this.senderName, this.giftMessage});

  final int passTypeId;
  final String email;
  final String? recipientName;
  final String? recipientEmail;
  final String? senderName;
  final String? giftMessage;
}
