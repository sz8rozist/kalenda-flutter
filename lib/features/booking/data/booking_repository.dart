import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/date_param.dart';
import '../../../core/providers.dart';
import '../model/booking_models.dart';
import '../model/booking_request.dart';
import '../model/payment_sheet.dart';

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
          'duration_minutes': ?q.durationMinutes,
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
          'duration_minutes': ?r.durationMinutes,
        }));
    return BookedResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// Bérlet / utalvány vásárlása: a Stripe Checkout címe (böngészőben fizet az ügyfél).
  Future<String> passCheckoutUrl(String slug, PassPurchaseRequest r) async {
    final response = await _api.call((d) => d.post('/public/businesses/$slug/passes/checkout', data: {
          'pass_type_id': r.passTypeId,
          'email': r.email,
          if (r.recipientEmail != null && r.recipientEmail!.isNotEmpty) ...{
            'recipient_name': r.recipientName,
            'recipient_email': r.recipientEmail,
            'sender_name': r.senderName,
            'gift_message': r.giftMessage,
          },
        }));
    return (response.data as Map<String, dynamic>)['checkout_url'] as String;
  }

  /// A vállalkozás meghirdetett csoportos alkalmai (üres, ha a vállalkozás nem használ ilyet).
  Future<List<GroupSession>> groupSessions(String slug) async {
    final response = await _api.call((d) => d.get('/public/businesses/$slug/group-sessions'));
    return (response.data as List).map((e) => GroupSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BookedResult> bookGroupSession(String slug, int sessionId, GroupBookRequest r) async {
    final response = await _api.call((d) => d.post('/public/businesses/$slug/group-sessions/$sessionId/bookings', data: {
          'customer_name': r.name,
          'customer_email': r.email,
          if (r.phone != null && r.phone!.isNotEmpty) 'customer_phone': r.phone,
          if (r.notes != null && r.notes!.isNotEmpty) 'notes': r.notes,
          if (r.passCode != null && r.passCode!.isNotEmpty) 'pass_code': r.passCode,
          'marketing_consent': ?r.marketingConsent,
        }));
    return BookedResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// Feliratkozás a várólistára; a válasz a szerver üzenete.
  Future<String> joinWaitlist(String slug, WaitlistRequest r) async {
    final response = await _api.call((d) => d.post('/public/businesses/$slug/waitlist', data: {
          'service_id': r.serviceId,
          'staff_id': ?r.staffId,
          'customer_name': r.name,
          'customer_email': r.email,
          if (r.phone != null && r.phone!.isNotEmpty) 'customer_phone': r.phone,
          'preferred_date': ?(r.preferredDate == null ? null : dateParam(r.preferredDate!)),
        }));
    return (response.data as Map<String, dynamic>)['message'] as String? ?? '';
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

  /// PaymentIntent a még ki nem fizetett előleghez (mobil PaymentSheet).
  Future<PaymentSheetData> paymentSheet(String token) async {
    final response = await _api.call((d) => d.post('/public/bookings/$token/payment/sheet'));
    return PaymentSheetData.fromJson(response.data as Map<String, dynamic>);
  }

  /// A sikeres fizetés visszaigazolása; a szerver a Stripe-nál ellenőrzi. Igaz, ha a foglalás ki van fizetve.
  Future<bool> confirmPaymentIntent(String token, String paymentIntentId) async {
    final response = await _api.call((d) => d.post('/public/bookings/$token/payment/confirm-intent',
        data: {'payment_intent_id': paymentIntentId}));
    return (response.data as Map<String, dynamic>)['paid'] as bool? ?? false;
  }

  Future<void> cancel(String token) => _api.call((d) => d.post('/public/bookings/$token/cancel'));

  Future<void> reschedule(String token, DateTime date, String time) =>
      _api.call((d) => d.patch('/public/bookings/$token', data: {'date': dateParam(date), 'time': time}));

  /// A vállalkozás bérelhető szolgáltatásai erőforrásokkal (üres, ha nincs ilyen).
  Future<List<PublicRental>> rentals(String slug) async {
    final response = await _api.call((d) => d.get('/public/businesses/$slug/rentals'));
    return (response.data as List).map((e) => PublicRental.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Leiratkozás a várólistáról a levélben kapott linkkel.
  Future<void> removeFromWaitlist(String token) => _api.call((d) => d.delete('/public/waitlist/$token'));
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) => BookingRepository(ref.watch(apiClientProvider)));
