int _int(Object? v) => (v as num?)?.toInt() ?? 0;

/// A Stripe Connect fiók állapota (online fizetések fogadásához).
class StripeStatus {
  const StripeStatus({required this.connected, required this.chargesEnabled, required this.payoutsEnabled, required this.detailsSubmitted});

  final bool connected;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final bool detailsSubmitted;

  factory StripeStatus.fromJson(Map<String, dynamic>? j) => StripeStatus(
    connected: j?['connected'] as bool? ?? false,
    chargesEnabled: j?['charges_enabled'] as bool? ?? false,
    payoutsEnabled: j?['payouts_enabled'] as bool? ?? false,
    detailsSubmitted: j?['details_submitted'] as bool? ?? false,
  );
}

/// Fizetési beállítások (`GET /businesses/{id}/payment-settings`).
class PaymentSettings {
  const PaymentSettings({
    required this.depositType,
    required this.depositPercentage,
    required this.refundCutoffHours,
    required this.onlinePaymentsAvailable,
    required this.onlinePaymentsEnabled,
    required this.platformFeePercent,
    required this.stripe,
  });

  /// `none` | `percentage` | `full`.
  final String depositType;
  final int depositPercentage;
  final int refundCutoffHours;
  final bool onlinePaymentsAvailable;
  final bool onlinePaymentsEnabled;
  final double platformFeePercent;
  final StripeStatus stripe;

  factory PaymentSettings.fromJson(Map<String, dynamic> j) => PaymentSettings(
    depositType: j['deposit_type'] as String? ?? 'none',
    depositPercentage: _int(j['deposit_percentage']),
    refundCutoffHours: _int(j['refund_cutoff_hours']),
    onlinePaymentsAvailable: j['online_payments_available'] as bool? ?? false,
    onlinePaymentsEnabled: j['online_payments_enabled'] as bool? ?? false,
    platformFeePercent: (j['platform_fee_percent'] as num?)?.toDouble() ?? 0,
    stripe: StripeStatus.fromJson(j['stripe_connect'] as Map<String, dynamic>?),
  );
}

/// Számlázó-integráció beállításai. A kulcsokat a szerver nem adja vissza, csak azt, hogy meg vannak-e adva.
class InvoicingSettings {
  const InvoicingSettings({
    required this.enabled,
    required this.provider,
    required this.documentType,
    required this.invoiceMode,
    required this.hasApiKey,
    required this.hasAgentKey,
    required this.vat,
    required this.autoSend,
    required this.vatCodes,
    this.blockId,
    this.receiptBlockId,
    this.voucherVatMode,
  });

  final bool enabled;

  /// `billingo` | `szamlazz` | …
  final String provider;

  /// `invoice` | `receipt`.
  final String documentType;
  final String invoiceMode;
  final bool hasApiKey;
  final bool hasAgentKey;
  final int? blockId;
  final int? receiptBlockId;
  final String vat;
  final bool autoSend;
  final String? voucherVatMode;
  final List<String> vatCodes;

  factory InvoicingSettings.fromJson(Map<String, dynamic> j) => InvoicingSettings(
    enabled: j['enabled'] as bool? ?? false,
    provider: j['provider'] as String? ?? 'billingo',
    documentType: j['document_type'] as String? ?? 'invoice',
    invoiceMode: j['invoice_mode'] as String? ?? '',
    hasApiKey: j['has_api_key'] as bool? ?? false,
    hasAgentKey: j['has_agent_key'] as bool? ?? false,
    blockId: (j['block_id'] as num?)?.toInt(),
    receiptBlockId: (j['receipt_block_id'] as num?)?.toInt(),
    vat: j['vat'] as String? ?? 'AAM',
    autoSend: j['auto_send'] as bool? ?? false,
    voucherVatMode: j['voucher_vat_mode'] as String?,
    vatCodes: [for (final c in (j['vat_codes'] as List?) ?? const []) c as String],
  );
}

/// Naptár-szinkron (iCal) hivatkozások.
class CalendarFeeds {
  const CalendarFeeds({required this.businessUrl, required this.staff});

  final String? businessUrl;
  final List<({int id, String name, String url})> staff;

  factory CalendarFeeds.fromJson(Map<String, dynamic> j) => CalendarFeeds(
    businessUrl: j['business_feed_url'] as String?,
    staff: [
      for (final e in (j['staff_feeds'] as List?) ?? const [])
        (id: _int((e as Map<String, dynamic>)['id']), name: e['name'] as String? ?? '', url: e['url'] as String? ?? ''),
    ],
  );
}

/// A nyilvános foglalási oldal beállításai.
class BookingPageSettings {
  const BookingPageSettings({
    required this.groupSessionsEnabled,
    required this.rentalsEnabled,
    this.logoUrl,
    this.coverUrl,
    this.description,
    this.extraInfo,
    this.bookingUrl,
  });

  final String? logoUrl;
  final String? coverUrl;
  final String? description;
  final String? extraInfo;
  final bool groupSessionsEnabled;
  final bool rentalsEnabled;
  final String? bookingUrl;

  factory BookingPageSettings.fromJson(Map<String, dynamic> j) => BookingPageSettings(
    logoUrl: j['logo_url'] as String?,
    coverUrl: j['cover_url'] as String?,
    description: j['description'] as String?,
    extraInfo: j['extra_info'] as String?,
    groupSessionsEnabled: j['group_sessions_enabled'] as bool? ?? false,
    rentalsEnabled: j['rentals_enabled'] as bool? ?? false,
    bookingUrl: j['booking_url'] as String?,
  );
}
