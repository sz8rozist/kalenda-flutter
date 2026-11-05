// A nyilvános foglalás adatmodelljei (`/public/businesses/{slug}`, `/slots`, `/bookings`).

int? _int(Object? v) => (v as num?)?.toInt();

List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) from) =>
    ((raw as List?) ?? const []).map((e) => from(e as Map<String, dynamic>)).toList();

class PublicService {
  PublicService({
    required this.id,
    required this.name,
    required this.durationMinutes,
    this.description,
    this.priceHuf,
    this.requiresPayment = false,
    this.depositLabel,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String? description;
  final int durationMinutes;
  final int? priceHuf;
  final bool requiresPayment;
  final String? depositLabel;
  final String? imageUrl;

  factory PublicService.fromJson(Map<String, dynamic> j) => PublicService(
        id: _int(j['id'])!,
        name: j['name'] as String? ?? '',
        description: j['description'] as String?,
        durationMinutes: _int(j['duration_minutes']) ?? 0,
        priceHuf: _int(j['price_huf']),
        requiresPayment: j['requires_payment'] as bool? ?? false,
        depositLabel: j['deposit_label'] as String?,
        imageUrl: j['image_url'] as String?,
      );
}

class PublicStaff {
  PublicStaff({required this.id, required this.name, required this.serviceIds, this.bio, this.photoUrl});

  final int id;
  final String name;
  final String? bio;
  final List<int> serviceIds;
  final String? photoUrl;

  factory PublicStaff.fromJson(Map<String, dynamic> j) => PublicStaff(
        id: _int(j['id'])!,
        name: j['name'] as String? ?? '',
        bio: j['bio'] as String?,
        serviceIds: ((j['service_ids'] as List?) ?? const []).map((e) => (e as num).toInt()).toList(),
        photoUrl: j['photo_url'] as String?,
      );
}

class PublicAddon {
  PublicAddon({required this.id, required this.name, required this.priceHuf, required this.durationMinutes});

  final int id;
  final String name;
  final int priceHuf;
  final int durationMinutes;

  factory PublicAddon.fromJson(Map<String, dynamic> j) => PublicAddon(
        id: _int(j['id'])!,
        name: j['name'] as String? ?? '',
        priceHuf: _int(j['price_huf']) ?? 0,
        durationMinutes: _int(j['duration_minutes']) ?? 0,
      );
}

class PublicBusiness {
  PublicBusiness({
    required this.name,
    required this.slug,
    required this.services,
    required this.staff,
    required this.addonsByService,
    this.description,
    this.address,
    this.city,
    this.phone,
    this.email,
    this.logoUrl,
    this.coverUrl,
    this.extraInfo,
    this.hasCampaigns = false,
    this.hasPasses = false,
    this.hasWaitlist = false,
  });

  final String name;
  final String slug;
  final String? description;
  final String? address;
  final String? city;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final String? coverUrl;
  final String? extraInfo;
  final bool hasCampaigns;
  final bool hasPasses;
  final bool hasWaitlist;
  final List<PublicService> services;
  final List<PublicStaff> staff;
  final Map<int, List<PublicAddon>> addonsByService;

  String get fullAddress => [address, city].whereType<String>().where((s) => s.isNotEmpty).join(', ');

  PublicService? service(int id) => services.where((s) => s.id == id).firstOrNull;

  /// A szolgáltatást végző munkatársak.
  List<PublicStaff> staffFor(int serviceId) => staff.where((s) => s.serviceIds.contains(serviceId)).toList();

  factory PublicBusiness.fromJson(Map<String, dynamic> j) {
    final addons = <int, List<PublicAddon>>{};
    (j['addons_by_service'] as Map<String, dynamic>? ?? const {}).forEach((key, value) {
      addons[int.parse(key)] = _list(value, PublicAddon.fromJson);
    });

    return PublicBusiness(
      name: j['name'] as String? ?? '',
      slug: j['slug'] as String? ?? '',
      description: j['description'] as String?,
      address: j['address'] as String?,
      city: j['city'] as String?,
      phone: j['phone'] as String?,
      email: j['email'] as String?,
      logoUrl: j['logo_url'] as String?,
      coverUrl: j['cover_url'] as String?,
      extraInfo: j['extra_info'] as String?,
      hasCampaigns: j['has_campaigns'] as bool? ?? false,
      hasPasses: j['has_passes'] as bool? ?? false,
      hasWaitlist: j['has_waitlist'] as bool? ?? false,
      services: _list(j['services'], PublicService.fromJson),
      staff: _list(j['staff'], PublicStaff.fromJson),
      addonsByService: addons,
    );
  }
}

class TimeSlot {
  TimeSlot({required this.time, required this.available});

  final String time;
  final bool available;

  factory TimeSlot.fromJson(Map<String, dynamic> j) =>
      TimeSlot(time: j['time'] as String, available: j['available'] as bool? ?? false);
}

/// A saját foglalás (foglalás-kezelő token alapján) – `GET /public/bookings/{token}`.
class ManagedBooking {
  ManagedBooking({
    required this.startsAt,
    required this.status,
    required this.serviceName,
    required this.businessName,
    required this.canModify,
    required this.canCancel,
    this.staffName,
    this.totalPriceHuf,
    this.address,
    this.phone,
    this.paymentRequired = false,
    this.paymentStatus,
  });

  final DateTime startsAt;
  final String status;
  final String serviceName;
  final String? staffName;
  final String businessName;
  final String? address;
  final String? phone;
  final int? totalPriceHuf;
  final bool canModify;
  final bool canCancel;
  final bool paymentRequired;
  final String? paymentStatus;

  factory ManagedBooking.fromJson(Map<String, dynamic> j) {
    final business = (j['business'] as Map<String, dynamic>?) ?? const {};
    final payment = j['payment'] as Map<String, dynamic>?;
    final address = [business['address'], business['city']].whereType<String>().where((s) => s.isNotEmpty).join(', ');

    return ManagedBooking(
      // Helyi falióra-idő, "Z" nélkül.
      startsAt: DateTime.parse(j['starts_at'] as String),
      status: j['status'] as String? ?? '',
      serviceName: (j['service'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      staffName: (j['staff'] as Map<String, dynamic>?)?['name'] as String?,
      businessName: business['name'] as String? ?? '',
      address: address.isEmpty ? null : address,
      phone: business['phone'] as String?,
      totalPriceHuf: _int(j['total_price_huf']),
      canModify: j['can_modify'] as bool? ?? false,
      canCancel: j['can_cancel'] as bool? ?? false,
      paymentRequired: payment?['required'] as bool? ?? false,
      paymentStatus: payment?['status'] as String?,
    );
  }
}

/// `POST /public/businesses/{slug}/bookings` eredménye.
class BookedResult {
  BookedResult({required this.booking, required this.manageToken, required this.requiresPayment, this.checkoutUrl, this.paymentNotice});

  final ManagedBooking booking;
  final String manageToken;
  final bool requiresPayment;
  final String? checkoutUrl;
  final String? paymentNotice;

  factory BookedResult.fromJson(Map<String, dynamic> j) => BookedResult(
        booking: ManagedBooking.fromJson(j['appointment'] as Map<String, dynamic>),
        manageToken: j['manage_token'] as String? ?? '',
        requiresPayment: j['requires_payment'] as bool? ?? false,
        checkoutUrl: j['checkout_url'] as String?,
        paymentNotice: j['payment_notice'] as String?,
      );
}
