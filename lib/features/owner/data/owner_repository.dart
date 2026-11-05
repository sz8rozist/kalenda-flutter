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

  Future<void> setStatus(int businessId, int appointmentId, String status) =>
      _api.call((d) => d.patch('/businesses/$businessId/appointments/$appointmentId/status', data: {'status': status}));
}

final ownerRepositoryProvider = Provider<OwnerRepository>((ref) => OwnerRepository(ref.watch(apiClientProvider)));
