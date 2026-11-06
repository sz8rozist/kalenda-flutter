import 'owner_tools_models.dart' show pagedContent;

int _int(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _date(Object? v) => DateTime.tryParse(v as String? ?? '')?.toLocal();

/// Egy bérlet- vagy utalvány-típus (`GET /businesses/{id}/pass-types`).
class PassType {
  const PassType({
    required this.id,
    required this.kind,
    required this.name,
    required this.priceHuf,
    required this.validityDays,
    required this.isActive,
    required this.soldCount,
    this.sessionsCount,
    this.valueHuf,
    this.serviceId,
    this.serviceName,
  });

  final int id;

  /// `pass` (alkalombérlet) | `voucher` (értékutalvány).
  final String kind;
  final String name;
  final int priceHuf;
  final int validityDays;
  final bool isActive;
  final int soldCount;
  final int? sessionsCount;
  final int? valueHuf;
  final int? serviceId;
  final String? serviceName;

  bool get isVoucher => kind == 'voucher';

  factory PassType.fromJson(Map<String, dynamic> j) {
    final service = j['service'] as Map<String, dynamic>?;
    return PassType(
      id: _int(j['id']),
      kind: j['kind'] as String? ?? 'pass',
      name: j['name'] as String? ?? '',
      priceHuf: _int(j['price_huf']),
      validityDays: _int(j['validity_days']),
      isActive: j['is_active'] as bool? ?? true,
      soldCount: _int(j['sold_count']),
      sessionsCount: (j['sessions_count'] as num?)?.toInt(),
      valueHuf: (j['value_huf'] as num?)?.toInt(),
      serviceId: (service?['id'] as num?)?.toInt(),
      serviceName: service?['name'] as String?,
    );
  }
}

/// A hűségprogram beállításai.
class LoyaltySettings {
  const LoyaltySettings({required this.enabled, required this.pointsPer1000Huf, required this.rewardPoints, required this.rewardValueHuf});

  final bool enabled;
  final int pointsPer1000Huf;
  final int rewardPoints;
  final int rewardValueHuf;

  factory LoyaltySettings.fromJson(Map<String, dynamic> j) => LoyaltySettings(
    enabled: j['loyalty_enabled'] as bool? ?? false,
    pointsPer1000Huf: _int(j['loyalty_points_per1000_huf']),
    rewardPoints: _int(j['loyalty_reward_points']),
    rewardValueHuf: _int(j['loyalty_reward_value_huf']),
  );
}

class LoyaltyMember {
  const LoyaltyMember({required this.customerId, required this.name, required this.balance, required this.earned});

  final int customerId;
  final String name;
  final int balance;
  final int earned;

  factory LoyaltyMember.fromJson(Map<String, dynamic> j) => LoyaltyMember(
    customerId: _int(j['customer_id']),
    name: j['name'] as String? ?? '',
    balance: _int(j['balance']),
    earned: _int(j['earned']),
  );
}

/// A hűségprogram áttekintése: beállítás, ranglista, statisztika.
class LoyaltyOverview {
  const LoyaltyOverview({
    required this.settings,
    required this.leaderboard,
    required this.outstandingPoints,
    required this.members,
    required this.redeemedThisMonth,
  });

  final LoyaltySettings settings;
  final List<LoyaltyMember> leaderboard;
  final int outstandingPoints;
  final int members;
  final int redeemedThisMonth;

  factory LoyaltyOverview.fromJson(Map<String, dynamic> j) {
    final stats = (j['stats'] as Map<String, dynamic>?) ?? const {};
    return LoyaltyOverview(
      settings: LoyaltySettings.fromJson((j['settings'] as Map<String, dynamic>?) ?? const {}),
      leaderboard: [for (final e in (j['leaderboard'] as List?) ?? const []) LoyaltyMember.fromJson(e as Map<String, dynamic>)],
      outstandingPoints: _int(stats['outstanding_points']),
      members: _int(stats['members']),
      redeemedThisMonth: _int(stats['redeemed_this_month']),
    );
  }
}

/// Egy kampány célcsoportja.
class CampaignSegment {
  const CampaignSegment({this.type = 'all', this.days, this.serviceId});

  /// `all` | `inactive` | `new` | `service` | `loyalty_reward`.
  final String type;
  final int? days;
  final int? serviceId;

  Map<String, Object?> toJson() => {'type': type, if (days != null) 'days': days, if (serviceId != null) 'service_id': serviceId};

  factory CampaignSegment.fromJson(Map<String, dynamic>? j) => CampaignSegment(
    type: j?['type'] as String? ?? 'all',
    days: (j?['days'] as num?)?.toInt(),
    serviceId: (j?['service_id'] as num?)?.toInt(),
  );
}

class Campaign {
  const Campaign({
    required this.id,
    required this.name,
    required this.subject,
    required this.body,
    required this.segment,
    required this.status,
    required this.recipients,
    this.sentAt,
  });

  final int id;
  final String name;
  final String subject;
  final String body;
  final CampaignSegment segment;

  /// `draft` | `sent` | …
  final String status;
  final int recipients;
  final DateTime? sentAt;

  bool get isDraft => status == 'draft';

  factory Campaign.fromJson(Map<String, dynamic> j) => Campaign(
    id: _int(j['id']),
    name: j['name'] as String? ?? '',
    subject: j['subject'] as String? ?? '',
    body: j['body'] as String? ?? '',
    segment: CampaignSegment.fromJson(j['segment'] as Map<String, dynamic>?),
    status: j['status'] as String? ?? 'draft',
    recipients: _int(j['recipients_count']),
    sentAt: _date(j['sent_at']),
  );
}

class CampaignListing {
  const CampaignListing({required this.campaigns, required this.consentCount, required this.dailyLimit});

  final List<Campaign> campaigns;
  final int consentCount;
  final int dailyLimit;

  factory CampaignListing.fromJson(Map<String, dynamic> j) => CampaignListing(
    campaigns: [for (final e in pagedContent(j['campaigns'])) Campaign.fromJson(e)],
    consentCount: _int(j['consent_count']),
    dailyLimit: _int(j['daily_limit']),
  );
}
