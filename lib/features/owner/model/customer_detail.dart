/// Egy ügyfél részletes adatai a vállalkozónak (`GET /businesses/{id}/customers/{id}`).
class CustomerDetail {
  const CustomerDetail({
    required this.id,
    required this.name,
    required this.total,
    required this.completed,
    required this.noShow,
    required this.cancelled,
    required this.totalSpentHuf,
    required this.depositExempt,
    required this.marketingConsent,
    required this.hasCampaigns,
    required this.noShowFlagged,
    required this.loyaltyBalance,
    required this.loyaltyTransactions,
    this.email,
    this.phone,
    this.internalNote,
    this.billingPostCode,
    this.billingCity,
    this.billingAddress,
    this.billingTaxNumber,
    this.billingEmail,
    this.loyaltyRewardPoints,
    this.loyaltyRewardValueHuf,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final int total;
  final int completed;
  final int noShow;
  final int cancelled;
  final int totalSpentHuf;
  final String? internalNote;
  final bool depositExempt;
  final bool marketingConsent;
  final bool hasCampaigns;
  final String? billingPostCode;
  final String? billingCity;
  final String? billingAddress;
  final String? billingTaxNumber;
  final String? billingEmail;
  final bool noShowFlagged;
  final int loyaltyBalance;
  final int? loyaltyRewardPoints;
  final int? loyaltyRewardValueHuf;
  final List<LoyaltyEntry> loyaltyTransactions;

  /// Van-e hűségprogram (jutalom megadva).
  bool get hasLoyaltyReward => loyaltyRewardPoints != null && loyaltyRewardPoints! > 0;

  bool get canRedeem => hasLoyaltyReward && loyaltyBalance >= loyaltyRewardPoints!;

  factory CustomerDetail.fromJson(Map<String, dynamic> j) {
    final customer = (j['customer'] as Map<String, dynamic>?) ?? const {};
    final stats = (j['stats'] as Map<String, dynamic>?) ?? const {};
    final profile = (j['profile'] as Map<String, dynamic>?) ?? const {};
    final protection = (j['no_show_protection'] as Map<String, dynamic>?) ?? const {};
    final loyalty = (j['loyalty'] as Map<String, dynamic>?) ?? const {};
    int n(Object? v) => (v as num?)?.toInt() ?? 0;

    return CustomerDetail(
      id: n(customer['id']),
      name: customer['name'] as String? ?? '',
      email: customer['email'] as String?,
      phone: customer['phone'] as String?,
      total: n(stats['total']),
      completed: n(stats['completed']),
      noShow: n(stats['no_show']),
      cancelled: n(stats['cancelled']),
      totalSpentHuf: n(stats['total_spent_huf']),
      internalNote: profile['internal_note'] as String?,
      depositExempt: profile['deposit_exempt'] as bool? ?? false,
      marketingConsent: profile['marketing_consent'] as bool? ?? false,
      hasCampaigns: j['has_campaigns'] as bool? ?? false,
      billingPostCode: profile['billing_post_code'] as String?,
      billingCity: profile['billing_city'] as String?,
      billingAddress: profile['billing_address'] as String?,
      billingTaxNumber: profile['billing_tax_number'] as String?,
      billingEmail: profile['billing_email'] as String?,
      noShowFlagged: protection['flagged'] as bool? ?? false,
      loyaltyBalance: n(loyalty['balance']),
      loyaltyRewardPoints: (loyalty['reward_points'] as num?)?.toInt(),
      loyaltyRewardValueHuf: (loyalty['reward_value_huf'] as num?)?.toInt(),
      loyaltyTransactions: [
        for (final t in (loyalty['transactions'] as List?) ?? const []) LoyaltyEntry.fromJson(t as Map<String, dynamic>),
      ],
    );
  }
}

/// Egy hűségpont-mozgás (jóváírás, beváltás, korrekció).
class LoyaltyEntry {
  const LoyaltyEntry({required this.points, required this.createdAt, this.reason, this.note});

  final int points;
  final DateTime? createdAt;
  final String? reason;
  final String? note;

  factory LoyaltyEntry.fromJson(Map<String, dynamic> j) => LoyaltyEntry(
    points: (j['points'] as num?)?.toInt() ?? 0,
    createdAt: DateTime.tryParse(j['created_at'] as String? ?? '')?.toLocal(),
    reason: j['reason'] as String?,
    note: j['note'] as String?,
  );
}
