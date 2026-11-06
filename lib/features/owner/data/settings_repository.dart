import '../model/extras_models.dart';
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

  // ─── Kiegészítők ──────────────────────────────────────────────

  Future<List<Addon>> addons(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/service-addons'));
    return [for (final e in response.data as List) Addon.fromJson(e as Map<String, dynamic>)];
  }

  Future<void> saveAddon(int businessId, {int? id, required Addon addon}) => id == null
      ? _api.call((d) => d.post('/businesses/$businessId/service-addons', data: addon.toJson()))
      : _api.call((d) => d.put('/businesses/$businessId/service-addons/$id', data: addon.toJson()));

  Future<void> deleteAddon(int businessId, int id) => _api.call((d) => d.delete('/businesses/$businessId/service-addons/$id'));

  // ─── Munkatárs: munkaidő, bér, fotó ───────────────────────────

  Future<List<StaffHour>> staffHours(int businessId, int staffId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/staff/$staffId/hours'));
    return StaffHour.weekFrom([for (final e in response.data as List) StaffHour.fromJson(e as Map<String, dynamic>)]);
  }

  Future<void> saveStaffHours(int businessId, int staffId, List<StaffHour> hours) =>
      _api.call((d) => d.put('/businesses/$businessId/staff/$staffId/hours', data: {'hours': [for (final h in hours) h.toJson()]}));

  Future<StaffPay> staffPay(int businessId, int staffId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/staff/$staffId/pay'));
    return StaffPay.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> saveStaffPay(int businessId, int staffId, {required String payType, required int payRateHuf, required String hoursSource, double serviceCommission = 0, double productCommission = 0}) =>
      _api.call(
        (d) => d.put(
          '/businesses/$businessId/staff/$staffId/pay',
          data: {
            'pay_type': payType,
            'pay_rate_huf': payRateHuf,
            'hours_source': hoursSource,
            'service_commission_percent': serviceCommission,
            'product_commission_percent': productCommission,
          },
        ),
      );

  // ─── Szolgáltatás: anyagok ────────────────────────────────────

  /// Az anyagfelhasználás beállítása: termék-azonosító → mennyiség egy alkalomra.
  Future<void> saveServiceMaterials(int businessId, int serviceId, Map<int, double> materials) => _api.call(
    (d) => d.put(
      '/businesses/$businessId/services/$serviceId/materials',
      data: {
        'materials': [
          for (final e in materials.entries) {'product_id': e.key, 'quantity': e.value},
        ],
      },
    ),
  );

  // ─── Munkatársi portál: saját munkaidő és profil ──────────────

  Future<PortalTimesheet> portalTimesheet(DateTime month) async {
    final key = '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';
    final response = await _api.call((d) => d.get('/staff-portal/timesheet', queryParameters: {'month': key}));
    return PortalTimesheet.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PortalProfile> portalProfile() async {
    final response = await _api.call((d) => d.get('/staff-portal/profile'));
    return PortalProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PortalProfile> regeneratePortalCalendarToken() async {
    final response = await _api.call((d) => d.post('/staff-portal/profile/calendar-token'));
    return PortalProfile.fromJson(response.data as Map<String, dynamic>);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => SettingsRepository(ref.watch(apiClientProvider)));
