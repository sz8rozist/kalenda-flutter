import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/push/push_service.dart';
import '../../account/viewmodel/account_viewmodel.dart';
import '../data/booking_repository.dart';
import '../model/booking_models.dart';
import '../model/booking_request.dart';
import 'business_viewmodels.dart';

/// A vállalkozás csoportos alkalmai; a kulcs a slug.
class GroupSessionsViewModel extends AsyncNotifier<List<GroupSession>> {
  GroupSessionsViewModel(this.slug);

  final String slug;

  @override
  Future<List<GroupSession>> build() => ref.watch(bookingRepositoryProvider).groupSessions(slug);
}

final groupSessionsViewModelProvider =
    AsyncNotifierProvider.autoDispose.family<GroupSessionsViewModel, List<GroupSession>, String>(GroupSessionsViewModel.new);

/// A csoportos alkalomra jelentkezés állapota.
class GroupBookingState {
  const GroupBookingState({this.marketing = false, this.busy = false, this.error, this.manageToken});

  final bool marketing;
  final bool busy;
  final Object? error;

  /// Siker esetén a foglalás-kezelő token (a View a visszaigazolásra navigál).
  final String? manageToken;

  GroupBookingState copyWith({bool? marketing, bool? busy, Object? error, bool clearError = false, String? manageToken}) => GroupBookingState(
        marketing: marketing ?? this.marketing,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
        manageToken: manageToken ?? this.manageToken,
      );
}

typedef GroupBookingArgs = ({String slug, int sessionId});

class GroupBookingViewModel extends Notifier<GroupBookingState> {
  GroupBookingViewModel(this.args);

  final GroupBookingArgs args;

  @override
  GroupBookingState build() => const GroupBookingState();

  void setMarketing(bool value) => state = state.copyWith(marketing: value);

  Future<void> submit(BookingDetails details) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final business = ref.read(businessViewModelProvider(args.slug)).value;
      final result = await ref.read(bookingRepositoryProvider).bookGroupSession(
            args.slug,
            args.sessionId,
            GroupBookRequest(
              name: details.name,
              email: details.email,
              phone: details.phone,
              notes: details.notes,
              passCode: details.passCode,
              marketingConsent: (business?.hasCampaigns ?? false) ? state.marketing : null,
            ),
          );
      ref.invalidate(accountViewModelProvider);
      ref.invalidate(groupSessionsViewModelProvider(args.slug));
      unawaited(ref.read(pushServiceProvider).enableAfterBooking());
      if (ref.mounted) state = state.copyWith(busy: false, manageToken: result.manageToken);
    } catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, error: e);
    }
  }
}

final groupBookingViewModelProvider =
    NotifierProvider.autoDispose.family<GroupBookingViewModel, GroupBookingState, GroupBookingArgs>(GroupBookingViewModel.new);
