/// A vállalkozás alapadatai, csomagja és a csomaggal elérhető funkciók (`GET /businesses/{id}`).
/// Az előfizetést a mobilon csak kiolvassuk; a vásárlás és a módosítás a webes felületen történik.
class BusinessInfo {
  const BusinessInfo({
    required this.id,
    required this.name,
    required this.plan,
    required this.planFeatures,
    required this.subscriptionStatus,
    required this.locked,
    required this.isSolo,
    required this.groupSessionsEnabled,
    required this.rentalsEnabled,
    this.slug,
    this.trialDaysLeft,
    this.trialEndsAt,
    this.documentType,
    this.canAcceptOnlinePayments = false,
    this.stripeConnected = false,
    this.onlinePaymentsEnabled = false,
    this.description,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.cancellationDeadlineHours,
    this.allowCustomerReschedule = true,
    this.noShowThreshold,
    this.noShowDepositPercentage,
  });

  final int id;
  final String name;
  final String? slug;

  /// `trial` | `basic` | `professional`.
  final String plan;

  /// Funkció-kulcs → elérhető-e a csomagban (pl. `passes`, `campaigns`, `register`).
  final Map<String, bool> planFeatures;
  final String subscriptionStatus;
  final DateTime? trialEndsAt;
  final int? trialDaysLeft;

  /// Lejárt próbaidő / felfüggesztett előfizetés: a vállalkozás zárolva van.
  final bool locked;
  final bool isSolo;
  final bool groupSessionsEnabled;
  final bool rentalsEnabled;
  final String? documentType;
  final bool canAcceptOnlinePayments;
  final bool stripeConnected;
  final bool onlinePaymentsEnabled;
  final String? description;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final int? cancellationDeadlineHours;
  final bool allowCustomerReschedule;
  final int? noShowThreshold;
  final int? noShowDepositPercentage;

  /// Elérhető-e a funkció a csomagban. Ismeretlen kulcsnál (nincs a listában) engedélyezettnek vesszük –
  /// a szerver úgyis 403-mal utasítja el, ha mégsem.
  bool hasFeature(String? key) => key == null || (planFeatures[key] ?? true);

  factory BusinessInfo.fromJson(Map<String, dynamic> j) {
    final subscription = (j['subscription'] as Map<String, dynamic>?) ?? const {};
    final policy = (j['policy'] as Map<String, dynamic>?) ?? const {};
    final payments = (j['payments'] as Map<String, dynamic>?) ?? const {};
    final features = (j['plan_features'] as Map<String, dynamic>?) ?? const {};

    return BusinessInfo(
      id: (j['id'] as num).toInt(),
      name: j['name'] as String? ?? '',
      slug: j['slug'] as String?,
      plan: j['plan'] as String? ?? (subscription['plan'] as String? ?? 'trial'),
      planFeatures: {
        for (final e in features.entries)
          if (e.value is bool) e.key: e.value as bool,
      },
      subscriptionStatus: subscription['status'] as String? ?? '',
      trialEndsAt: DateTime.tryParse(subscription['trial_ends_at'] as String? ?? ''),
      trialDaysLeft: (subscription['trial_days_left'] as num?)?.toInt(),
      locked: subscription['locked'] as bool? ?? false,
      isSolo: j['is_solo'] as bool? ?? false,
      groupSessionsEnabled: j['group_sessions_enabled'] as bool? ?? false,
      rentalsEnabled: j['rentals_enabled'] as bool? ?? false,
      documentType: j['document_type'] as String?,
      canAcceptOnlinePayments: payments['can_accept_online_payments'] as bool? ?? false,
      stripeConnected: payments['stripe_connected'] as bool? ?? false,
      onlinePaymentsEnabled: payments['online_payments_enabled'] as bool? ?? false,
      description: j['description'] as String?,
      email: j['email'] as String?,
      phone: j['phone'] as String?,
      address: j['address'] as String?,
      city: j['city'] as String?,
      cancellationDeadlineHours: (policy['cancellation_deadline_hours'] as num?)?.toInt(),
      allowCustomerReschedule: policy['allow_customer_reschedule'] as bool? ?? true,
      noShowThreshold: (policy['no_show_threshold'] as num?)?.toInt(),
      noShowDepositPercentage: (policy['no_show_deposit_percentage'] as num?)?.toInt(),
    );
  }
}

/// Az előfizetés részletei (`GET /businesses/{id}/subscription`) – csak olvasásra.
class SubscriptionState {
  const SubscriptionState({
    required this.currentPlan,
    required this.status,
    required this.cancelAtPeriodEnd,
    this.trialEndsAt,
    this.currentPeriodEnd,
  });

  final String currentPlan;
  final String status;
  final bool cancelAtPeriodEnd;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;

  factory SubscriptionState.fromJson(Map<String, dynamic> j) {
    final s = (j['subscription'] as Map<String, dynamic>?) ?? const {};
    return SubscriptionState(
      currentPlan: j['current_plan'] as String? ?? s['plan'] as String? ?? 'trial',
      status: s['status'] as String? ?? '',
      cancelAtPeriodEnd: s['cancel_at_period_end'] as bool? ?? false,
      trialEndsAt: DateTime.tryParse(s['trial_ends_at'] as String? ?? '')?.toLocal(),
      currentPeriodEnd: DateTime.tryParse(s['current_period_end'] as String? ?? '')?.toLocal(),
    );
  }
}
