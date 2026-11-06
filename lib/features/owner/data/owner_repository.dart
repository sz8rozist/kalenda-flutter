import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/date_param.dart';
import '../../../core/providers.dart';
import '../../booking/model/booking_models.dart' show TimeSlot;
import '../model/customer_detail.dart';
import '../model/owner_models.dart';

/// A vállalkozói végpontok (`/businesses/{id}/…`).
class OwnerRepository {
  OwnerRepository(this._api);

  final ApiClient _api;

  Future<OwnerDashboard> dashboard(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/dashboard'));
    return OwnerDashboard.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OwnerCalendar> calendar(int businessId, DateRange range) async {
    final response = await _api.call(
      (d) => d.get('/businesses/$businessId/calendar', queryParameters: {'from': dateParam(range.from), 'to': dateParam(range.to)}),
    );
    return OwnerCalendar.fromJson(response.data as Map<String, dynamic>);
  }

  /// Az ügyfelek első oldala (legfeljebb 50), név / e-mail / telefon szerint kereshető.
  Future<List<CustomerItem>> customers(int businessId, String search) async {
    final response = await _api.call(
      (d) => d.get('/businesses/$businessId/customers', queryParameters: {if (search.isNotEmpty) 'search': search, 'size': 50}),
    );
    // A lapozott lista Spring PagedModel: {content: [...], page: {...}}.
    final content = ((response.data as Map<String, dynamic>)['customers'] as Map<String, dynamic>)['content'] as List;
    return content.map((e) => CustomerItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Meglévő ügyfelek a foglalás felviteléhez.
  Future<List<CustomerOption>> customerOptions(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/appointment-customers'));
    return (response.data as List).map((e) => CustomerOption.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// A teljes napi rács a foglalt sávokkal (available: false).
  Future<List<TimeSlot>> availableSlots(int businessId, {required int serviceId, required int staffId, required DateTime date}) async {
    final response = await _api.call(
      (d) => d.get(
        '/businesses/$businessId/available-slots',
        queryParameters: {'service_id': serviceId, 'staff_id': staffId, 'date': dateParam(date)},
      ),
    );
    return (response.data as List).map((e) => TimeSlot.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createAppointment(int businessId, OwnerBookingRequest r) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/appointments',
      data: {
        'service_id': r.serviceId,
        'staff_id': r.staffId,
        'date': dateParam(r.date),
        'time': r.time,
        if (r.customerId != null) 'customer_id': r.customerId,
        if (r.customerId == null && r.customerName != null && r.customerName!.isNotEmpty) 'customer_name': r.customerName,
        if (r.customerId == null && r.customerEmail != null && r.customerEmail!.isNotEmpty) 'customer_email': r.customerEmail,
        if (r.customerId == null && r.customerPhone != null && r.customerPhone!.isNotEmpty) 'customer_phone': r.customerPhone,
        if (r.notes != null && r.notes!.isNotEmpty) 'notes': r.notes,
        'send_email': r.sendEmail,
      },
    ),
  );

  Future<List<OwnerStaff>> staffList(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/staff'));
    return (response.data as List).map((e) => OwnerStaff.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Részleges módosítás (PATCH): csak a megadott mezők változnak.
  Future<void> patchStaff(int businessId, int staffId, {String? name, String? phone, bool? isActive}) =>
      _api.call((d) => d.patch('/businesses/$businessId/staff/$staffId', data: {'name': ?name, 'phone': ?phone, 'is_active': ?isActive}));

  /// A döntésre váró szabadság-igénylések.
  Future<List<OwnerLeaveRequest>> pendingLeaveRequests(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/leave-requests', queryParameters: {'status': 'pending'}));
    return (response.data as List).map((e) => OwnerLeaveRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> approveLeave(int businessId, int requestId) =>
      _api.call((d) => d.post('/businesses/$businessId/leave-requests/$requestId/approve'));

  Future<void> rejectLeave(int businessId, int requestId, {String? note}) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/leave-requests/$requestId/reject',
      data: {'response_note': ?(note == null || note.isEmpty ? null : note)},
    ),
  );

  Future<List<HourRow>> hours(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/hours'));
    return (response.data as List).map((e) => HourRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// A teljes heti nyitvatartás mentése; a válasz a mentett állapot.
  Future<List<HourRow>> saveHours(int businessId, List<HourRow> rows) async {
    final response = await _api.call((d) => d.put('/businesses/$businessId/hours', data: {'hours': rows.map((r) => r.toJson()).toList()}));
    return (response.data as List).map((e) => HourRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<OwnerService>> services(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/services'));
    return (response.data as List).map((e) => OwnerService.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Részleges módosítás (PATCH): csak a megadott mezők változnak.
  Future<void> patchService(int businessId, int serviceId, {String? name, int? durationMinutes, int? priceHuf, bool? isActive}) =>
      _api.call(
        (d) => d.patch(
          '/businesses/$businessId/services/$serviceId',
          data: {'name': ?name, 'duration_minutes': ?durationMinutes, 'price_huf': ?priceHuf, 'is_active': ?isActive},
        ),
      );

  /// Havi könyvelői összesítő (a hónap bármelyik napjával).
  Future<AccountingReport> accountingReport(int businessId, DateTime month) async {
    final key = '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';
    final response = await _api.call((d) => d.get('/businesses/$businessId/reports/accounting', queryParameters: {'month': key}));
    return AccountingReport.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<CashflowPeriod>> cashflow(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/reports/cashflow'));
    final periods = (response.data as Map<String, dynamic>)['periods'] as List? ?? const [];
    return periods.map((e) => CashflowPeriod.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// A számlák első oldala (legfeljebb 50); `payment`: unpaid | overdue | paid, null = mind.
  Future<List<InvoiceItem>> invoices(int businessId, {String? payment}) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/invoices', queryParameters: {'payment': ?payment, 'size': 50}));
    final content = ((response.data as Map<String, dynamic>)['invoices'] as Map<String, dynamic>)['content'] as List;
    return content.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Kifizetettnek jelölés; a `method`: cash | card | transfer | other, a dátum a mai nap.
  Future<void> markInvoicePaid(int businessId, int invoiceId, {required String method, required DateTime date}) => _api.call(
    (d) => d.post('/businesses/$businessId/invoices/$invoiceId/paid', data: {'payment_method': method, 'paid_date': dateParam(date)}),
  );

  Future<void> markInvoiceUnpaid(int businessId, int invoiceId) =>
      _api.call((d) => d.post('/businesses/$businessId/invoices/$invoiceId/unpaid'));

  /// Fizetési emlékeztető küldése az ügyfélnek.
  Future<void> remindInvoice(int businessId, int invoiceId) =>
      _api.call((d) => d.post('/businesses/$businessId/invoices/$invoiceId/remind'));

  Future<void> setStatus(int businessId, int appointmentId, String status) =>
      _api.call((d) => d.patch('/businesses/$businessId/appointments/$appointmentId/status', data: {'status': status}));

  // ─── Szolgáltatások: teljes kezelés ───────────────────────────

  Future<void> createService(int businessId, OwnerService service) =>
      _api.call((d) => d.post('/businesses/$businessId/services', data: service.toSaveJson()));

  Future<void> saveService(int businessId, OwnerService service) =>
      _api.call((d) => d.put('/businesses/$businessId/services/${service.id}', data: service.toSaveJson()));

  Future<void> deleteService(int businessId, int serviceId) => _api.call((d) => d.delete('/businesses/$businessId/services/$serviceId'));

  // ─── Munkatársak: teljes kezelés ──────────────────────────────

  Map<String, Object?> _staffJson(OwnerStaff s, {bool withKind = false}) => {
    'name': s.name,
    'email': s.email == null || s.email!.isEmpty ? null : s.email,
    'phone': s.phone ?? '',
    'bio': s.bio ?? '',
    'color': s.color,
    'is_active': s.isActive,
    if (withKind) 'kind': s.kind,
  };

  /// Új munkatárs; visszaadja a létrehozottat (a szolgáltatásokat külön kell hozzárendelni).
  Future<OwnerStaff> createStaff(int businessId, OwnerStaff staff) async {
    final response = await _api.call((d) => d.post('/businesses/$businessId/staff', data: _staffJson(staff, withKind: true)));
    return OwnerStaff.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> saveStaff(int businessId, OwnerStaff staff) =>
      _api.call((d) => d.put('/businesses/$businessId/staff/${staff.id}', data: _staffJson(staff)));

  Future<void> setStaffServices(int businessId, int staffId, List<int> serviceIds) =>
      _api.call((d) => d.put('/businesses/$businessId/staff/$staffId/services', data: {'service_ids': serviceIds}));

  Future<void> deleteStaff(int businessId, int staffId) => _api.call((d) => d.delete('/businesses/$businessId/staff/$staffId'));

  /// Meghívó e-mail a munkatársnak (belépés a munkatársi portálra).
  Future<void> inviteStaff(int businessId, int staffId) => _api.call((d) => d.post('/businesses/$businessId/staff/$staffId/invite'));

  Future<void> revokeStaffAccess(int businessId, int staffId) =>
      _api.call((d) => d.delete('/businesses/$businessId/staff/$staffId/access'));

  // ─── Ügyfél részletei ─────────────────────────────────────────

  Future<CustomerDetail> customerDetail(int businessId, int customerId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/customers/$customerId'));
    return CustomerDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CustomerDetail> updateCustomerProfile(
    int businessId,
    int customerId, {
    required bool depositExempt,
    String? internalNote,
    bool? marketingConsent,
    String? billingPostCode,
    String? billingCity,
    String? billingAddress,
    String? billingTaxNumber,
    String? billingEmail,
  }) async {
    String? blank(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final response = await _api.call(
      (d) => d.patch(
        '/businesses/$businessId/customers/$customerId/profile',
        data: {
          'deposit_exempt': depositExempt,
          'internal_note': internalNote?.trim() ?? '',
          'marketing_consent': ?marketingConsent,
          'billing_post_code': blank(billingPostCode),
          'billing_city': blank(billingCity),
          'billing_address': blank(billingAddress),
          'billing_tax_number': blank(billingTaxNumber),
          'billing_email': blank(billingEmail),
        },
      ),
    );
    return CustomerDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> adjustLoyalty(int businessId, int customerId, {required int points, required String note}) =>
      _api.call((d) => d.post('/businesses/$businessId/customers/$customerId/loyalty/adjust', data: {'points': points, 'note': note}));

  /// Jutalom beváltása; visszaadja a kapott kedvezményt (Ft).
  Future<int> redeemLoyalty(int businessId, int customerId) async {
    final response = await _api.call((d) => d.post('/businesses/$businessId/customers/$customerId/loyalty/redeem'));
    return ((response.data as Map<String, dynamic>)['discount_huf'] as num?)?.toInt() ?? 0;
  }
}

final ownerRepositoryProvider = Provider<OwnerRepository>((ref) => OwnerRepository(ref.watch(apiClientProvider)));
