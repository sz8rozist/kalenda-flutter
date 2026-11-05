import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'booking_models.dart';

String dateParam(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// A vállalkozás nyilvános adatlapja (szolgáltatások, munkatársak, kiegészítők).
final businessProvider = FutureProvider.autoDispose.family<PublicBusiness, String>((ref, slug) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.call((d) => d.get('/public/businesses/$slug'));
  return PublicBusiness.fromJson(response.data as Map<String, dynamic>);
});

/// Egy nap időpont-rácsa a szolgáltatáshoz és a munkatárshoz.
typedef SlotQuery = ({String slug, int serviceId, int staffId, DateTime date, List<int> addonIds});

final slotsProvider = FutureProvider.autoDispose.family<List<TimeSlot>, SlotQuery>((ref, q) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.call((d) => d.get('/public/businesses/${q.slug}/slots', queryParameters: {
        'service_id': q.serviceId,
        'staff_id': q.staffId,
        'date': dateParam(q.date),
        if (q.addonIds.isNotEmpty) 'addon_ids[]': q.addonIds,
      }));
  return (response.data as List).map((e) => TimeSlot.fromJson(e as Map<String, dynamic>)).toList();
});

/// A saját foglalás a foglalás-kezelő token alapján.
final managedBookingProvider = FutureProvider.autoDispose.family<ManagedBooking, String>((ref, token) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.call((d) => d.get('/public/bookings/$token'));
  return ManagedBooking.fromJson(response.data as Map<String, dynamic>);
});

/// Szabad időpontok áthelyezéshez ("HH:mm" szövegek).
final rescheduleSlotsProvider =
    FutureProvider.autoDispose.family<List<String>, ({String token, DateTime date})>((ref, q) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.call(
      (d) => d.get('/public/bookings/${q.token}/slots', queryParameters: {'date': dateParam(q.date)}));
  return (response.data as List).map((e) => '$e').toList();
});

class BookingRepository {
  BookingRepository(this._ref);

  final Ref _ref;

  Future<BookedResult> book(
    String slug, {
    required int serviceId,
    required int staffId,
    required DateTime date,
    required String time,
    required String name,
    required String email,
    String? phone,
    String? notes,
    String? passCode,
    bool? marketingConsent,
    List<int> addonIds = const [],
  }) async {
    final api = _ref.read(apiClientProvider);
    final response = await api.call((d) => d.post('/public/businesses/$slug/bookings', data: {
          'service_id': serviceId,
          'staff_id': staffId,
          'date': dateParam(date),
          'time': time,
          'customer_name': name,
          'customer_email': email,
          if (phone != null && phone.isNotEmpty) 'customer_phone': phone,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (passCode != null && passCode.isNotEmpty) 'pass_code': passCode,
          'marketing_consent': ?marketingConsent,
          if (addonIds.isNotEmpty) 'addon_ids': addonIds,
        }));
    return BookedResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cancel(String token) async {
    final api = _ref.read(apiClientProvider);
    await api.call((d) => d.post('/public/bookings/$token/cancel'));
    _ref.invalidate(managedBookingProvider(token));
  }

  Future<void> reschedule(String token, DateTime date, String time) async {
    final api = _ref.read(apiClientProvider);
    await api.call((d) => d.patch('/public/bookings/$token', data: {'date': dateParam(date), 'time': time}));
    _ref.invalidate(managedBookingProvider(token));
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>(BookingRepository.new);
