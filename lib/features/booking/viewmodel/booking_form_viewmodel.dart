import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/push/push_service.dart';
import '../../account/model/account_models.dart';
import '../../account/viewmodel/account_viewmodel.dart';
import '../../auth/viewmodel/customer_session_viewmodel.dart';
import '../data/booking_repository.dart';
import '../model/booking_request.dart';
import 'business_viewmodels.dart';

/// A foglalás sikeres beküldése után: a foglalás-kezelő token. Előlegnél a fizetés a visszaigazoló képernyőn indul.
class BookingOutcome {
  const BookingOutcome({required this.manageToken});

  final String manageToken;
}

/// A foglalási űrlap állapota. A szövegmezők (név, e-mail…) a View-ban élnek, ez a választásokat és a küldést követi.
class BookingFormState {
  const BookingFormState({
    this.staffId,
    this.addonIds = const {},
    this.date,
    this.time,
    this.marketing = false,
    this.busy = false,
    this.incomplete = false,
    this.error,
    this.outcome,
    this.prefill,
  });

  final int? staffId;
  final Set<int> addonIds;
  final DateTime? date;
  final String? time;
  final bool marketing;
  final bool busy;

  /// A munkatárs / nap / időpont még nincs kiválasztva, de küldeni próbálták.
  final bool incomplete;
  final Object? error;
  final BookingOutcome? outcome;

  /// Belépett ügyfél adatai az űrlap előtöltéséhez.
  final AccountProfile? prefill;

  BookingFormState copyWith({
    int? staffId,
    Set<int>? addonIds,
    DateTime? date,
    String? time,
    bool clearTime = false,
    bool? marketing,
    bool? busy,
    bool? incomplete,
    Object? error,
    bool clearError = false,
    BookingOutcome? outcome,
    AccountProfile? prefill,
  }) =>
      BookingFormState(
        staffId: staffId ?? this.staffId,
        addonIds: addonIds ?? this.addonIds,
        date: date ?? this.date,
        time: clearTime ? null : (time ?? this.time),
        marketing: marketing ?? this.marketing,
        busy: busy ?? this.busy,
        incomplete: incomplete ?? this.incomplete,
        error: clearError ? null : (error ?? this.error),
        outcome: outcome ?? this.outcome,
        prefill: prefill ?? this.prefill,
      );
}

typedef BookingArgs = ({String slug, int serviceId});

/// Egy szolgáltatás foglalásának ViewModel-je (View: BookingPage).
class BookingFormViewModel extends Notifier<BookingFormState> {
  BookingFormViewModel(this.args);

  final BookingArgs args;

  @override
  BookingFormState build() {
    final business = ref.read(businessViewModelProvider(args.slug)).value;
    final staff = business?.staffFor(args.serviceId) ?? const [];

    if (ref.read(customerSessionProvider).value ?? false) {
      unawaited(Future.microtask(_loadPrefill));
    }
    return BookingFormState(staffId: staff.length == 1 ? staff.first.id : null);
  }

  Future<void> _loadPrefill() async {
    try {
      final overview = await ref.read(accountViewModelProvider.future);
      if (ref.mounted) state = state.copyWith(prefill: overview.profile);
    } catch (_) {
      // Az előtöltés nem kötelező.
    }
  }

  /// A kiválasztott nap időpont-rácsának lekérdezése; amíg a munkatárs vagy a nap hiányzik, null.
  SlotQuery? get slotQuery {
    final staffId = state.staffId;
    final date = state.date;
    if (staffId == null || date == null) return null;
    return SlotQuery(slug: args.slug, serviceId: args.serviceId, staffId: staffId, date: date, addonIds: state.addonIds.toList());
  }

  void selectStaff(int? id) => state = BookingFormState(
        staffId: id,
        addonIds: state.addonIds,
        date: state.date,
        marketing: state.marketing,
        prefill: state.prefill,
      );

  void toggleAddon(int id, bool selected) {
    final next = {...state.addonIds};
    selected ? next.add(id) : next.remove(id);
    state = state.copyWith(addonIds: next, clearTime: true);
  }

  void pickDate(DateTime date) => state = state.copyWith(date: date, clearTime: true);

  void selectTime(String time) => state = state.copyWith(time: time);

  void setMarketing(bool value) => state = state.copyWith(marketing: value);

  /// A foglalás beküldése. Siker esetén az `outcome` kitöltődik (a View navigál / megnyitja a fizetést).
  Future<void> submit(BookingDetails details) async {
    final staffId = state.staffId;
    final date = state.date;
    final time = state.time;
    if (staffId == null || date == null || time == null) {
      state = state.copyWith(incomplete: true);
      return;
    }

    state = state.copyWith(busy: true, incomplete: false, clearError: true);
    try {
      final business = ref.read(businessViewModelProvider(args.slug)).value;
      final result = await ref.read(bookingRepositoryProvider).book(
            args.slug,
            BookingRequest(
              serviceId: args.serviceId,
              staffId: staffId,
              date: date,
              time: time,
              name: details.name,
              email: details.email,
              phone: details.phone,
              notes: details.notes,
              passCode: details.passCode,
              marketingConsent: (business?.hasCampaigns ?? false) ? state.marketing : null,
              addonIds: state.addonIds.toList(),
            ),
          );
      ref.invalidate(accountViewModelProvider);
      // Az első foglalás után kérünk értesítés-engedélyt (nem indításkor).
      unawaited(ref.read(pushServiceProvider).enableAfterBooking());
      if (!ref.mounted) return;
      state = state.copyWith(
        busy: false,
        outcome: BookingOutcome(manageToken: result.manageToken),
      );
    } catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, error: e);
    }
  }
}

final bookingFormViewModelProvider =
    NotifierProvider.autoDispose.family<BookingFormViewModel, BookingFormState, BookingArgs>(BookingFormViewModel.new);
