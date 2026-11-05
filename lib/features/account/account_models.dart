/// Az ügyfélfiók áttekintése (`GET /customer/account`) – csak a megjelenített mezők.
class AccountProfile {
  AccountProfile({required this.name, required this.email, this.phone});

  final String name;
  final String email;
  final String? phone;

  factory AccountProfile.fromJson(Map<String, dynamic> json) => AccountProfile(
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
      );
}

class AccountAppointment {
  AccountAppointment({
    required this.id,
    required this.business,
    required this.service,
    required this.startsAt,
    required this.status,
    this.staff,
    this.priceHuf,
    this.manageUrl,
  });

  final String? manageUrl;

  /// A foglalás-kezelő token a `manage_url` utolsó szakasza (`…/booking/manage/{token}`); null, ha nem kezelhető.
  String? get manageToken {
    final url = manageUrl;
    if (url == null || url.isEmpty) return null;
    final segments = Uri.parse(url).pathSegments.where((s) => s.isNotEmpty);
    return segments.isEmpty ? null : segments.last;
  }

  final int id;
  final String business;
  final String service;
  final String? staff;
  final DateTime startsAt;
  final String status;
  final int? priceHuf;

  factory AccountAppointment.fromJson(Map<String, dynamic> json) => AccountAppointment(
        id: (json['id'] as num).toInt(),
        business: json['business'] as String? ?? '',
        service: json['service'] as String? ?? '',
        staff: json['staff'] as String?,
        // Helyi (Europe/Budapest) falióra-idő, "Z" nélkül – nem UTC-ként értelmezzük.
        startsAt: DateTime.parse(json['starts_at'] as String),
        status: json['status'] as String? ?? '',
        priceHuf: (json['price_huf'] as num?)?.toInt(),
        manageUrl: json['manage_url'] as String?,
      );
}

class AccountOverview {
  AccountOverview({required this.profile, required this.upcoming, required this.past});

  final AccountProfile profile;
  final List<AccountAppointment> upcoming;
  final List<AccountAppointment> past;

  factory AccountOverview.fromJson(Map<String, dynamic> json) {
    List<AccountAppointment> items(String key) => ((json[key] as List?) ?? const [])
        .map((e) => AccountAppointment.fromJson(e as Map<String, dynamic>))
        .toList();

    return AccountOverview(
      profile: AccountProfile.fromJson(json['profile'] as Map<String, dynamic>),
      upcoming: items('upcoming'),
      past: items('past'),
    );
  }
}
