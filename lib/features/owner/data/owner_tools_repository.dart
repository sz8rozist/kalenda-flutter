import '../model/finance_models.dart';
import '../model/register_models.dart';
import '../model/appointment_detail.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/date_param.dart';
import '../../../core/providers.dart';
import '../model/business_info.dart';
import '../model/owner_tools_models.dart';

/// A vállalkozói „egyéb" végpontok: költségek, értékelések, bérletek, várólista, tevékenység-napló.
class OwnerToolsRepository {
  OwnerToolsRepository(this._api);

  final ApiClient _api;

  // ─── Költségek ────────────────────────────────────────────────

  Future<ExpenseListing> expenses(int businessId) async {
    final response = await _api.call(
      (d) => d.get('/businesses/$businessId/expenses', queryParameters: {'size': 100, 'sort': 'expenseDate,desc'}),
    );
    return ExpenseListing.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createExpense(
    int businessId, {
    required String category,
    required int amountHuf,
    required DateTime date,
    String? vendor,
    bool recurring = false,
  }) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/expenses',
      data: {
        'category': category,
        'amount_huf': amountHuf,
        'expense_date': dateParam(date),
        'vendor': vendor == null || vendor.trim().isEmpty ? null : vendor.trim(),
        'is_recurring': recurring,
      },
    ),
  );

  Future<void> deleteExpense(int businessId, int expenseId) => _api.call((d) => d.delete('/businesses/$businessId/expenses/$expenseId'));

  // ─── Értékelések ──────────────────────────────────────────────

  Future<ReviewListing> reviews(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/reviews', queryParameters: {'size': 50}));
    return ReviewListing.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> saveReviewSettings(int businessId, {required bool enabled, String? googleUrl}) => _api.call(
    (d) => d.put(
      '/businesses/$businessId/reviews/settings',
      data: {'reviews_enabled': enabled, 'google_review_url': googleUrl == null || googleUrl.trim().isEmpty ? null : googleUrl.trim()},
    ),
  );

  // ─── Bérletek és utalványok ───────────────────────────────────

  Future<List<SoldPass>> soldPasses(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/passes', queryParameters: {'size': 50}));
    return [for (final e in pagedContent((response.data as Map<String, dynamic>)['passes'])) SoldPass.fromJson(e)];
  }

  // ─── Várólista ────────────────────────────────────────────────

  Future<List<WaitlistEntry>> waitlist(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/waitlist', queryParameters: {'size': 50}));
    return [for (final e in pagedContent((response.data as Map<String, dynamic>)['entries'])) WaitlistEntry.fromJson(e)];
  }

  Future<void> notifyWaitlist(int businessId, int entryId) => _api.call((d) => d.post('/businesses/$businessId/waitlist/$entryId/notify'));

  Future<void> removeWaitlist(int businessId, int entryId) => _api.call((d) => d.delete('/businesses/$businessId/waitlist/$entryId'));

  // ─── Tevékenység-napló ────────────────────────────────────────

  Future<List<ActivityEntry>> activityLog(int businessId, {String? search}) async {
    final response = await _api.call(
      (d) => d.get(
        '/businesses/$businessId/activity-log',
        queryParameters: {'size': 50, if (search != null && search.trim().isNotEmpty) 'search': search.trim()},
      ),
    );
    return [for (final e in pagedContent((response.data as Map<String, dynamic>)['entries'])) ActivityEntry.fromJson(e)];
  }

  // ─── Vállalkozás és csomag (csak olvasás) ─────────────────────

  Future<BusinessInfo> businessInfo(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId'));
    return BusinessInfo.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SubscriptionState> subscription(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/subscription'));
    return SubscriptionState.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── Foglalás-részletek és bizonylatok ────────────────────────

  Future<AppointmentDetail> appointmentDetail(int businessId, int appointmentId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/appointments/$appointmentId'));
    return AppointmentDetail.fromJson(response.data as Map<String, dynamic>);
  }

  /// Állapotváltás; lemondásnál a `refund` igaz esetén a befizetett összeg visszatérítésre kerül.
  Future<void> changeAppointmentStatus(int businessId, int appointmentId, String status, {bool refund = false}) =>
      _api.call((d) => d.patch('/businesses/$businessId/appointments/$appointmentId/status', data: {'status': status, 'refund': refund}));

  /// Számla / nyugta kiállítása a foglaláshoz (a fizetés módjával).
  Future<void> issueAppointmentInvoice(int businessId, int appointmentId, {required String paymentMethod}) =>
      _api.call((d) => d.post('/businesses/$businessId/appointments/$appointmentId/invoice', data: {'payment_method': paymentMethod}));

  Future<void> cancelDocument(int businessId, String type, int documentId, {String? reason}) =>
      _api.call((d) => d.post('/businesses/$businessId/documents/$type/$documentId/cancel', data: {'reason': reason ?? ''}));

  /// A bizonylat PDF-je (hitelesítve töltjük le, ezért nem nyitható közvetlen linkkel).
  Future<Uint8List> documentPdf(int businessId, String type, int documentId) async {
    final response = await _api.call(
      (d) => d.get<List<int>>('/businesses/$businessId/documents/$type/$documentId/pdf', options: Options(responseType: ResponseType.bytes)),
    );
    return Uint8List.fromList(response.data ?? const []);
  }

  // ─── Önálló számla ────────────────────────────────────────────

  /// Új önálló számla (a tételek bruttó egységárral; az ÁFA-kulcs a vállalkozás alapértelmezése).
  Future<void> createStandaloneInvoice(
    int businessId, {
    required List<({String name, double qty, int unitPriceHuf})> items,
    String? customerName,
    String? customerEmail,
    int dueDays = 8,
    bool alreadyPaid = false,
    String? paymentMethod,
  }) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/invoices',
      data: {
        'customer_name': customerName == null || customerName.trim().isEmpty ? null : customerName.trim(),
        'customer_email': customerEmail == null || customerEmail.trim().isEmpty ? null : customerEmail.trim(),
        'items': [
          for (final i in items) {'name': i.name, 'qty': i.qty, 'unit_price_huf': i.unitPriceHuf},
        ],
        'due_days': dueDays,
        'already_paid': alreadyPaid,
        if (alreadyPaid) 'payment_method': paymentMethod ?? 'cash',
      },
    ),
  );

  // ─── Pénztár ──────────────────────────────────────────────────

  Future<RegisterDay> registerDay(int businessId, DateTime date) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/register', queryParameters: {'date': dateParam(date)}));
    return RegisterDay.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> recordRegisterPayment(
    int businessId, {
    required String kind,
    required String method,
    required int amountHuf,
    required DateTime date,
    String? description,
  }) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/register/payments',
      data: {
        'kind': kind,
        'method': kind == 'income' ? method : 'cash',
        'amount_huf': amountHuf,
        'date': dateParam(date),
        'description': description == null || description.trim().isEmpty ? null : description.trim(),
      },
    ),
  );

  Future<void> deleteRegisterPayment(int businessId, int paymentId) => _api.call((d) => d.delete('/businesses/$businessId/register/payments/$paymentId'));

  Future<void> payAppointmentAtRegister(int businessId, int appointmentId, {required String method, int? amountHuf}) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/register/appointments/$appointmentId/pay',
      data: {'method': method, 'amount_huf': ?amountHuf},
    ),
  );

  Future<void> closeRegister(int businessId, DateTime date, {required int countedCashHuf, String? note}) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/register/close',
      data: {'date': dateParam(date), 'counted_cash_huf': countedCashHuf, 'note': note == null || note.trim().isEmpty ? null : note.trim()},
    ),
  );

  Future<void> reopenRegister(int businessId, DateTime date) =>
      _api.call((d) => d.post('/businesses/$businessId/register/reopen', data: {'date': dateParam(date)}));

  // ─── Kifizetések és hiányzó bizonylatok ───────────────────────

  Future<PayoutsOverview> payouts(int businessId, {String? payoutId}) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/reports/payouts', queryParameters: {'payout': ?payoutId}));
    return PayoutsOverview.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<MissingDocument>> missingDocuments(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/invoices/missing-documents'));
    return [for (final e in response.data as List) MissingDocument.fromJson(e as Map<String, dynamic>)];
  }

  Future<void> retryMissingDocument(int businessId, String key) => _api.call((d) => d.post('/businesses/$businessId/documents/missing/retry', data: {'key': key}));
}

final ownerToolsRepositoryProvider = Provider<OwnerToolsRepository>((ref) => OwnerToolsRepository(ref.watch(apiClientProvider)));
