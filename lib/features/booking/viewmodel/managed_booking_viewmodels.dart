import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calendar/device_calendar_gateway.dart';
import '../../../core/payment/stripe_payment_gateway.dart';
import '../../../core/viewmodel/action_state.dart';
import '../../account/viewmodel/account_viewmodel.dart';
import '../data/booking_repository.dart';
import '../model/booking_models.dart';
import '../model/payment_sheet.dart';

/// Egy foglalás a foglalás-kezelő token alapján; a kulcs a token.
class ManagedBookingViewModel extends AsyncNotifier<ManagedBooking> {
  ManagedBookingViewModel(this.token);

  final String token;

  @override
  Future<ManagedBooking> build() => ref.watch(bookingRepositoryProvider).managed(token);
}

final managedBookingViewModelProvider =
    AsyncNotifierProvider.autoDispose.family<ManagedBookingViewModel, ManagedBooking, String>(ManagedBookingViewModel.new);

/// A foglalás műveletei: lemondás, áthelyezés.
class ManagedBookingActionsViewModel extends ActionNotifier {
  ManagedBookingActionsViewModel(this.token);

  final String token;

  Future<void> cancel() => _changed(() => ref.read(bookingRepositoryProvider).cancel(token), FlashKind.cancelled);

  /// A foglalás mentése az eszköz naptárába (a rendszer naptár-párbeszédével).
  Future<void> addToCalendar(ManagedBooking booking) => perform(() async {
        await ref.read(deviceCalendarGatewayProvider).addEvent(
              title: '${booking.serviceName} – ${booking.businessName}',
              start: booking.startsAt,
              end: booking.endsAt,
              location: booking.address,
              description: booking.staffName,
            );
      });

  Future<void> reschedule(DateTime date, String time) =>
      _changed(() => ref.read(bookingRepositoryProvider).reschedule(token, date, time), FlashKind.saved);

  Future<void> _changed(Future<void> Function() action, FlashKind success) async {
    final ok = await perform(action, success: success);
    if (ok) {
      ref.invalidate(managedBookingViewModelProvider(token));
      ref.invalidate(accountViewModelProvider);
    }
  }
}

final managedBookingActionsProvider =
    NotifierProvider.autoDispose.family<ManagedBookingActionsViewModel, ActionState, String>(ManagedBookingActionsViewModel.new);

/// A foglalási előleg fizetése a mobil PaymentSheet-tel (kártya, Apple Pay, Google Pay).
/// A szerver a PaymentIntentet készíti, az SDK fizet, a szerver a Stripe-nál ellenőrzi a végeredményt.
class PaymentViewModel extends ActionNotifier {
  PaymentViewModel(this.token);

  final String token;

  Future<void> pay() async {
    await perform(() async {
      final repository = ref.read(bookingRepositoryProvider);
      final data = await repository.paymentSheet(token);
      final merchant = ref.read(managedBookingViewModelProvider(token)).value?.businessName ?? 'Kalenda';

      final outcome = await ref.read(stripePaymentGatewayProvider).pay(data, merchantName: merchant);
      if (outcome == PaymentOutcome.paid) await repository.confirmPaymentIntent(token, data.paymentIntentId);
    });

    // Akár sikerült, akár megszakították: a foglalás állapota frissüljön (a webhook közben is rögzíthette).
    if (ref.mounted) {
      ref.invalidate(managedBookingViewModelProvider(token));
      ref.invalidate(accountViewModelProvider);
    }
  }
}

final paymentViewModelProvider =
    NotifierProvider.autoDispose.family<PaymentViewModel, ActionState, String>(PaymentViewModel.new);

/// Szabad időpontok áthelyezéshez ("HH:mm") egy napra.
typedef RescheduleQuery = ({String token, DateTime date});

class RescheduleSlotsViewModel extends AsyncNotifier<List<String>> {
  RescheduleSlotsViewModel(this.query);

  final RescheduleQuery query;

  @override
  Future<List<String>> build() => ref.watch(bookingRepositoryProvider).rescheduleSlots(query.token, query.date);
}

final rescheduleSlotsViewModelProvider =
    AsyncNotifierProvider.autoDispose.family<RescheduleSlotsViewModel, List<String>, RescheduleQuery>(RescheduleSlotsViewModel.new);
