import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/date_param.dart';
import '../../../core/providers.dart';
import '../../booking/model/booking_models.dart' show TimeSlot;
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
    final response = await _api.call((d) => d.get('/businesses/$businessId/calendar',
        queryParameters: {'from': dateParam(range.from), 'to': dateParam(range.to)}));
    return OwnerCalendar.fromJson(response.data as Map<String, dynamic>);
  }

  /// Az ügyfelek első oldala (legfeljebb 50), név / e-mail / telefon szerint kereshető.
  Future<List<CustomerItem>> customers(int businessId, String search) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/customers', queryParameters: {
          if (search.isNotEmpty) 'search': search,
          'size': 50,
        }));
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
    final response = await _api.call((d) => d.get('/businesses/$businessId/available-slots',
        queryParameters: {'service_id': serviceId, 'staff_id': staffId, 'date': dateParam(date)}));
    return (response.data as List).map((e) => TimeSlot.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createAppointment(int businessId, OwnerBookingRequest r) => _api.call((d) => d.post('/businesses/$businessId/appointments', data: {
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
      }));

  Future<List<OwnerService>> services(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/services'));
    return (response.data as List).map((e) => OwnerService.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Részleges módosítás (PATCH): csak a megadott mezők változnak.
  Future<void> patchService(
    int businessId,
    int serviceId, {
    String? name,
    int? durationMinutes,
    int? priceHuf,
    bool? isActive,
  }) =>
      _api.call((d) => d.patch('/businesses/$businessId/services/$serviceId', data: {
            'name': ?name,
            'duration_minutes': ?durationMinutes,
            'price_huf': ?priceHuf,
            'is_active': ?isActive,
          }));

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
    final response = await _api.call((d) => d.get('/businesses/$businessId/invoices', queryParameters: {
          'payment': ?payment,
          'size': 50,
        }));
    final content = ((response.data as Map<String, dynamic>)['invoices'] as Map<String, dynamic>)['content'] as List;
    return content.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Kifizetettnek jelölés; a `method`: cash | card | transfer | other, a dátum a mai nap.
  Future<void> markInvoicePaid(int businessId, int invoiceId, {required String method, required DateTime date}) =>
      _api.call((d) => d.post('/businesses/$businessId/invoices/$invoiceId/paid', data: {
            'payment_method': method,
            'paid_date': dateParam(date),
          }));

  Future<void> markInvoiceUnpaid(int businessId, int invoiceId) =>
      _api.call((d) => d.post('/businesses/$businessId/invoices/$invoiceId/unpaid'));

  /// Fizetési emlékeztető küldése az ügyfélnek.
  Future<void> remindInvoice(int businessId, int invoiceId) =>
      _api.call((d) => d.post('/businesses/$businessId/invoices/$invoiceId/remind'));

  Future<void> setStatus(int businessId, int appointmentId, String status) =>
      _api.call((d) => d.patch('/businesses/$businessId/appointments/$appointmentId/status', data: {'status': status}));
}

final ownerRepositoryProvider = Provider<OwnerRepository>((ref) => OwnerRepository(ref.watch(apiClientProvider)));
