import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../booking/model/booking_models.dart' show TimeSlot;
import '../data/owner_repository.dart';
import '../model/owner_models.dart';
import 'owner_viewmodels.dart';

/// A felvihető ügyfelek (meglévők) listája; a kulcs a vállalkozás azonosítója.
class CustomerOptionsViewModel extends AsyncNotifier<List<CustomerOption>> {
  CustomerOptionsViewModel(this.businessId);

  final int businessId;

  @override
  Future<List<CustomerOption>> build() => ref.watch(ownerRepositoryProvider).customerOptions(businessId);
}

final customerOptionsProvider =
    AsyncNotifierProvider.autoDispose.family<CustomerOptionsViewModel, List<CustomerOption>, int>(CustomerOptionsViewModel.new);

/// Egy nap időpont-rácsa a vállalkozói felvitelhez.
typedef OwnerSlotQuery = ({int businessId, int serviceId, int staffId, DateTime date});

class OwnerSlotsViewModel extends AsyncNotifier<List<TimeSlot>> {
  OwnerSlotsViewModel(this.query);

  final OwnerSlotQuery query;

  @override
  Future<List<TimeSlot>> build() => ref
      .watch(ownerRepositoryProvider)
      .availableSlots(query.businessId, serviceId: query.serviceId, staffId: query.staffId, date: query.date);
}

final ownerSlotsProvider =
    AsyncNotifierProvider.autoDispose.family<OwnerSlotsViewModel, List<TimeSlot>, OwnerSlotQuery>(OwnerSlotsViewModel.new);

/// A foglalás-felvitel űrlapjának állapota.
class OwnerBookingState {
  const OwnerBookingState({
    this.serviceId,
    this.staffId,
    this.date,
    this.time,
    this.customerId,
    this.sendEmail = false,
    this.busy = false,
    this.incomplete = false,
    this.error,
    this.created = false,
  });

  final int? serviceId;
  final int? staffId;
  final DateTime? date;
  final String? time;

  /// A kiválasztott meglévő ügyfél; null = új ügyfél (a mezőket a View küldi be).
  final int? customerId;
  final bool sendEmail;
  final bool busy;
  final bool incomplete;
  final Object? error;
  final bool created;

  OwnerBookingState copyWith({
    int? serviceId,
    int? staffId,
    bool clearStaff = false,
    DateTime? date,
    String? time,
    bool clearTime = false,
    int? customerId,
    bool clearCustomer = false,
    bool? sendEmail,
    bool? busy,
    bool? incomplete,
    Object? error,
    bool clearError = false,
    bool? created,
  }) =>
      OwnerBookingState(
        serviceId: serviceId ?? this.serviceId,
        staffId: clearStaff ? null : (staffId ?? this.staffId),
        date: date ?? this.date,
        time: clearTime ? null : (time ?? this.time),
        customerId: clearCustomer ? null : (customerId ?? this.customerId),
        sendEmail: sendEmail ?? this.sendEmail,
        busy: busy ?? this.busy,
        incomplete: incomplete ?? this.incomplete,
        error: clearError ? null : (error ?? this.error),
        created: created ?? this.created,
      );
}

/// A vállalkozó által felvitt foglalás ViewModel-je (View: OwnerBookingPage); a kulcs a vállalkozás azonosítója.
class OwnerBookingViewModel extends Notifier<OwnerBookingState> {
  OwnerBookingViewModel(this.businessId);

  final int businessId;

  @override
  OwnerBookingState build() => const OwnerBookingState();

  /// A rács lekérdezése; amíg a szolgáltatás, a munkatárs vagy a nap hiányzik, null.
  OwnerSlotQuery? get slotQuery {
    final s = state;
    if (s.serviceId == null || s.staffId == null || s.date == null) return null;
    return (businessId: businessId, serviceId: s.serviceId!, staffId: s.staffId!, date: DateTime(s.date!.year, s.date!.month, s.date!.day));
  }

  /// Szolgáltatásváltáskor a munkatárs és az időpont újraválasztandó (más munkatársak végzik).
  void selectService(int? id) => state = state.copyWith(serviceId: id, clearStaff: true, clearTime: true);

  void selectStaff(int? id) => state = state.copyWith(staffId: id, clearStaff: id == null, clearTime: true);

  void pickDate(DateTime date) => state = state.copyWith(date: date, clearTime: true);

  void selectTime(String time) => state = state.copyWith(time: time);

  void selectCustomer(int? id) => state = state.copyWith(customerId: id, clearCustomer: id == null);

  void setSendEmail(bool value) => state = state.copyWith(sendEmail: value);

  Future<void> submit(OwnerBookingDetails details) async {
    final s = state;
    if (s.serviceId == null || s.staffId == null || s.date == null || s.time == null) {
      state = s.copyWith(incomplete: true);
      return;
    }

    state = s.copyWith(busy: true, incomplete: false, clearError: true);
    try {
      await ref.read(ownerRepositoryProvider).createAppointment(
            businessId,
            OwnerBookingRequest(
              serviceId: s.serviceId!,
              staffId: s.staffId!,
              date: s.date!,
              time: s.time!,
              customerId: s.customerId,
              customerName: details.name,
              customerEmail: details.email,
              customerPhone: details.phone,
              notes: details.notes,
              sendEmail: s.sendEmail,
            ),
          );
      ref.invalidate(ownerDashboardProvider);
      ref.invalidate(ownerCalendarProvider);
      if (ref.mounted) state = state.copyWith(busy: false, created: true);
    } catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, error: e);
    }
  }
}

final ownerBookingProvider =
    NotifierProvider.autoDispose.family<OwnerBookingViewModel, OwnerBookingState, int>(OwnerBookingViewModel.new);
