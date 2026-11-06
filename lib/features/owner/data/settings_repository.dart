import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../model/settings_models.dart';

/// A vállalkozás beállításai (`/businesses/{id}/…`): adatok, szabályzat, fizetés, számlázás, naptár-szinkron, foglalási oldal.
class SettingsRepository {
  SettingsRepository(this._api);

  final ApiClient _api;

  String? _blank(String? v) => v == null || v.trim().isEmpty ? null : v.trim();

  // ─── Vállalkozás, mód, szabályzat ─────────────────────────────

  Future<void> updateBusiness(
    int businessId, {
    required String name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? description,
  }) => _api.call(
    (d) => d.patch(
      '/businesses/$businessId',
      data: {
        'name': name.trim(),
        'email': _blank(email),
        'phone': _blank(phone),
        'address': _blank(address),
        'city': _blank(city),
        'description': description?.trim() ?? '',
      },
    ),
  );

  Future<void> setSolo(int businessId, bool isSolo) => _api.call((d) => d.put('/businesses/$businessId/mode', data: {'is_solo': isSolo}));

  Future<void> savePolicy(
    int businessId, {
    required int cancellationDeadlineHours,
    required bool allowCustomerReschedule,
    int? noShowThreshold,
    int? noShowDepositPercentage,
  }) => _api.call(
    (d) => d.put(
      '/businesses/$businessId/policy',
      data: {
        'cancellation_deadline_hours': cancellationDeadlineHours,
        'allow_customer_reschedule': allowCustomerReschedule,
        'no_show_threshold': noShowThreshold,
        'no_show_deposit_percentage': noShowDepositPercentage,
      },
    ),
  );

  // ─── Fizetés ──────────────────────────────────────────────────

  Future<PaymentSettings> paymentSettings(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/payment-settings'));
    return PaymentSettings.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> savePaymentSettings(
    int businessId, {
    required String depositType,
    required int depositPercentage,
    required int refundCutoffHours,
  }) => _api.call(
    (d) => d.put(
      '/businesses/$businessId/payment-settings',
      data: {
        'deposit_type': depositType,
        'deposit_percentage': depositType == 'percentage' ? depositPercentage : null,
        'refund_cutoff_hours': refundCutoffHours,
      },
    ),
  );

  /// Az online fizetés be- és kikapcsolása.
  Future<void> setOnlinePayments(int businessId, bool enabled) =>
      _api.call((d) => d.put('/businesses/$businessId/payment-settings/online-payments', data: {'enabled': enabled}));

  Future<String> stripeOnboardingUrl(int businessId) async {
    final response = await _api.call((d) => d.post('/businesses/$businessId/stripe-connect/onboarding-link'));
    return (response.data as Map<String, dynamic>)['url'] as String? ?? '';
  }

  Future<String> stripeDashboardUrl(int businessId) async {
    final response = await _api.call((d) => d.post('/businesses/$businessId/stripe-connect/dashboard-link'));
    return (response.data as Map<String, dynamic>)['url'] as String? ?? '';
  }

  Future<StripeStatus> syncStripe(int businessId) async {
    final response = await _api.call((d) => d.post('/businesses/$businessId/stripe-connect/sync'));
    return StripeStatus.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── Számlázás ────────────────────────────────────────────────

  Future<InvoicingSettings> invoicingSettings(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/invoicing-settings'));
    return InvoicingSettings.fromJson(response.data as Map<String, dynamic>);
  }

  /// A kulcsokat csak akkor küldjük, ha újat írtak be (üresen hagyva a régi marad).
  Future<void> saveInvoicingSettings(
    int businessId, {
    required bool enabled,
    required String provider,
    required String documentType,
    required String vat,
    required bool autoSend,
    String? apiKey,
    String? agentKey,
    int? blockId,
    int? receiptBlockId,
  }) => _api.call(
    (d) => d.put(
      '/businesses/$businessId/invoicing-settings',
      data: {
        'enabled': enabled,
        'provider': provider,
        'document_type': documentType,
        'vat': vat,
        'auto_send': autoSend,
        if (_blank(apiKey) != null) 'api_key': apiKey!.trim(),
        if (_blank(agentKey) != null) 'agent_key': agentKey!.trim(),
        'block_id': blockId,
        'receipt_block_id': receiptBlockId,
      },
    ),
  );

  // ─── Naptár-szinkron ──────────────────────────────────────────

  Future<CalendarFeeds> calendarFeeds(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/calendar-sync'));
    return CalendarFeeds.fromJson(response.data as Map<String, dynamic>);
  }

  /// Új hivatkozás generálása (a régi érvényét veszti). `staffId` nélkül a vállalkozás hivatkozása.
  Future<CalendarFeeds> regenerateFeed(int businessId, {int? staffId}) async {
    final response = await _api.call(
      (d) => d.post(
        '/businesses/$businessId/calendar-sync/regenerate',
        data: {'scope': staffId == null ? 'business' : 'staff', 'staff_id': ?staffId},
      ),
    );
    return CalendarFeeds.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── Foglalási oldal ──────────────────────────────────────────

  Future<BookingPageSettings> bookingPage(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/booking-page'));
    return BookingPageSettings.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> saveBookingPage(
    int businessId, {
    String? description,
    String? extraInfo,
    required bool groupSessions,
    required bool rentals,
  }) => _api.call(
    (d) => d.put(
      '/businesses/$businessId/booking-page',
      data: {
        'description': description?.trim() ?? '',
        'extra_info': extraInfo?.trim() ?? '',
        'group_sessions_enabled': groupSessions,
        'rentals_enabled': rentals,
      },
    ),
  );

  /// Kép feltöltése. A `kind`: `logo` | `cover` | `staff/{id}/photo` | `services/{id}/image`.
  Future<void> uploadImage(int businessId, String kind, String filePath) async {
    final form = FormData.fromMap({'file': await MultipartFile.fromFile(filePath)});
    await _api.call((d) => d.post('/businesses/$businessId/booking-page/$kind', data: form));
  }

  Future<void> deleteImage(int businessId, String kind) => _api.call((d) => d.delete('/businesses/$businessId/booking-page/$kind'));
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => SettingsRepository(ref.watch(apiClientProvider)));
