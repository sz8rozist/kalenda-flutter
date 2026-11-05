import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/date_param.dart';
import '../../../core/providers.dart';
import '../model/booking_models.dart';
import '../model/booking_request.dart';

/// A nyilvános foglalás és a foglalás-kezelő token alapú műveletei (`/public/…`).
class BookingRepository {
  BookingRepository(this._api);

  final ApiClient _api;

  Future<PublicBusiness> business(String slug) async {
    final response = await _api.call((d) => d.get('/public/businesses/$slug'));
    return PublicBusiness.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TimeSlot>> slots(SlotQuery q) async {
    final response = await _api.call((d) => d.get('/public/businesses/${q.slug}/slots', queryParameters: {
          'service_id': q.serviceId,
          'staff_id': q.staffId,
          'date': dateParam(q.date),
          if (q.addonIds.isNotEmpty) 'addon_ids[]': q.addonIds,
        }));
    return (response.data as List).map((e) => TimeSlot.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BookedResult> book(String slug, BookingRequest r) async {
    final response = await _api.call((d) => d.post('/public/businesses/$slug/bookings', data: {
          'service_id': r.serviceId,
          'staff_id': r.staffId,
          'date': dateParam(r.date),
          'time': r.time,
          'customer_name': r.name,
          'customer_email': r.email,
          if (r.phone != null && r.phone!.isNotEmpty) 'customer_phone': r.phone,
          if (r.notes != null && r.notes!.isNotEmpty) 'notes': r.notes,
          if (r.passCode != null && r.passCode!.isNotEmpty) 'pass_code': r.passCode,
          'marketing_consent': ?r.marketingConsent,
          if (r.addonIds.isNotEmpty) 'addon_ids': r.addonIds,
        }));
    return BookedResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ManagedBooking> managed(String token) async {
    final response = await _api.call((d) => d.get('/public/bookings/$token'));
    return ManagedBooking.fromJson(response.data as Map<String, dynamic>);
  }

  /// Szabad időpontok áthelyezéshez ("HH:mm").
  Future<List<String>> rescheduleSlots(String token, DateTime date) async {
    final response = await _api.call((d) => d.get('/public/bookings/$token/slots', queryParameters: {'date': dateParam(date)}));
    return (response.data as List).map((e) => '$e').toList();
  }

  Future<void> cancel(String token) => _api.call((d) => d.post('/public/bookings/$token/cancel'));

  Future<void> reschedule(String token, DateTime date, String time) =>
      _api.call((d) => d.patch('/public/bookings/$token', data: {'date': dateParam(date), 'time': time}));
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) => BookingRepository(ref.watch(apiClientProvider)));
