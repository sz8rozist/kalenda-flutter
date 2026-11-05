import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../../account/viewmodel/account_viewmodel.dart';
import '../data/booking_repository.dart';
import '../model/booking_models.dart';

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
