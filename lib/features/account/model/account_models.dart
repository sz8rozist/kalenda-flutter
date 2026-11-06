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
    this.businessSlug,
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

  /// A vállalkozás azonosítója (az újrafoglaláshoz).
  final String? businessSlug;
  final String service;
  final String? staff;
  final DateTime startsAt;
  final String status;
  final int? priceHuf;

  factory AccountAppointment.fromJson(Map<String, dynamic> json) => AccountAppointment(
        id: (json['id'] as num).toInt(),
        business: json['business'] as String? ?? '',
        businessSlug: json['business_slug'] as String?,
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
  AccountOverview({
    required this.profile,
    required this.upcoming,
    required this.past,
    this.loyalty = const [],
    this.passes = const [],
    this.consents = const [],
    this.invoices = const [],
  });

  final List<LoyaltyItem> loyalty;
  final List<PassItem> passes;
  final List<ConsentItem> consents;
  final List<AccountInvoice> invoices;

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
      loyalty: _mapList(json['loyalty'], LoyaltyItem.fromJson),
      passes: _mapList(json['passes'], PassItem.fromJson),
      consents: _mapList(json['consents'], ConsentItem.fromJson),
      invoices: _mapList(json['invoices'], AccountInvoice.fromJson),
    );
  }
}

class LoyaltyItem {
  LoyaltyItem({required this.business, required this.businessSlug, required this.balance, this.rewardPoints, this.rewardValueHuf});

  final String business;
  final String businessSlug;
  final int balance;
  final int? rewardPoints;
  final int? rewardValueHuf;

  factory LoyaltyItem.fromJson(Map<String, dynamic> j) => LoyaltyItem(
        business: j['business'] as String? ?? '',
        businessSlug: j['business_slug'] as String? ?? '',
        balance: (j['balance'] as num?)?.toInt() ?? 0,
        rewardPoints: (j['reward_points'] as num?)?.toInt(),
        rewardValueHuf: (j['reward_value_huf'] as num?)?.toInt(),
      );
}

class PassItem {
  PassItem({
    required this.id,
    required this.business,
    required this.name,
    required this.kind,
    required this.expired,
    this.code,
    this.sessionsRemaining,
    this.balanceHuf,
    this.expiresAt,
  });

  final int id;
  final String business;
  final String name;
  final String kind;
  final String? code;
  final int? sessionsRemaining;
  final int? balanceHuf;
  final String? expiresAt;
  final bool expired;

  factory PassItem.fromJson(Map<String, dynamic> j) => PassItem(
        id: (j['id'] as num).toInt(),
        business: j['business'] as String? ?? '',
        name: j['name'] as String? ?? '',
        kind: j['kind'] as String? ?? '',
        code: j['code'] as String?,
        sessionsRemaining: (j['sessions_remaining'] as num?)?.toInt(),
        balanceHuf: (j['balance_huf'] as num?)?.toInt(),
        expiresAt: j['expires_at'] as String?,
        expired: j['expired'] as bool? ?? false,
      );
}

class ConsentItem {
  ConsentItem({required this.businessId, required this.business, required this.marketingConsent});

  final int businessId;
  final String business;
  final bool marketingConsent;

  factory ConsentItem.fromJson(Map<String, dynamic> j) => ConsentItem(
        businessId: (j['business_id'] as num).toInt(),
        business: j['business'] as String? ?? '',
        marketingConsent: j['marketing_consent'] as bool? ?? false,
      );
}

List<T> _mapList<T>(Object? raw, T Function(Map<String, dynamic>) from) =>
    ((raw as List?) ?? const []).map((e) => from(e as Map<String, dynamic>)).toList();

/// Az ügyfél egy számlája / nyugtája (`GET /customer/account` → `invoices`).
class AccountInvoice {
  AccountInvoice({required this.business, required this.number, required this.amountHuf, required this.paymentState, this.kind, this.date, this.dueDate, this.downloadUrl});

  final String business;
  final String number;

  /// `invoice` | `receipt`.
  final String? kind;
  final DateTime? date;
  final int amountHuf;

  /// `paid` | `unpaid` | `overdue`.
  final String paymentState;
  final DateTime? dueDate;

  /// A letöltés (hitelesített) útvonala.
  final String? downloadUrl;

  factory AccountInvoice.fromJson(Map<String, dynamic> j) => AccountInvoice(
        business: j['business'] as String? ?? '',
        number: j['number'] as String? ?? '',
        kind: j['kind'] as String?,
        date: DateTime.tryParse(j['date'] as String? ?? ''),
        amountHuf: (j['amount_huf'] as num?)?.toInt() ?? 0,
        paymentState: j['payment_state'] as String? ?? '',
        dueDate: DateTime.tryParse(j['due_date'] as String? ?? ''),
        downloadUrl: j['download_url'] as String?,
      );
}
