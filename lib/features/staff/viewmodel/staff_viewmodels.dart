import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/date_param.dart';
import '../../../core/viewmodel/action_state.dart';
import '../../../core/viewmodel/simple_viewmodels.dart';
import '../../owner/data/owner_repository.dart';
import '../../owner/viewmodel/owner_viewmodels.dart';
import '../data/staff_repositories.dart';
import '../model/staff_models.dart';

/// A „Ma" fül adatai: mai foglalások száma, következő foglalások, be-/kicsekkolás állapota.
class PortalDashboardViewModel extends AsyncNotifier<PortalDashboard> {
  @override
  Future<PortalDashboard> build() => ref.watch(staffRepositoryProvider).dashboard();
}

final portalDashboardProvider = AsyncNotifierProvider.autoDispose<PortalDashboardViewModel, PortalDashboard>(PortalDashboardViewModel.new);

/// A saját naptár egy tartományra (legfeljebb 62 nap).
class PortalCalendarViewModel extends AsyncNotifier<PortalCalendar> {
  PortalCalendarViewModel(this.range);

  final DateRange range;

  @override
  Future<PortalCalendar> build() => ref.watch(staffRepositoryProvider).calendar(range);
}

final portalCalendarProvider =
    AsyncNotifierProvider.autoDispose.family<PortalCalendarViewModel, PortalCalendar, DateRange>(PortalCalendarViewModel.new);

/// A saját szabadság-igénylések.
class LeaveRequestsViewModel extends AsyncNotifier<List<LeaveRequest>> {
  @override
  Future<List<LeaveRequest>> build() => ref.watch(staffRepositoryProvider).leaveRequests();
}

final leaveRequestsProvider = AsyncNotifierProvider.autoDispose<LeaveRequestsViewModel, List<LeaveRequest>>(LeaveRequestsViewModel.new);

/// Szabad időpontok a foglalás áthelyezéséhez ("HH:mm").
typedef PortalSlotsQuery = ({int appointmentId, DateTime date});

class PortalRescheduleSlotsViewModel extends AsyncNotifier<List<String>> {
  PortalRescheduleSlotsViewModel(this.query);

  final PortalSlotsQuery query;

  @override
  Future<List<String>> build() => ref.watch(staffRepositoryProvider).rescheduleSlots(query.appointmentId, query.date);
}

final portalRescheduleSlotsProvider = AsyncNotifierProvider.autoDispose
    .family<PortalRescheduleSlotsViewModel, List<String>, PortalSlotsQuery>(PortalRescheduleSlotsViewModel.new);

/// A munkatársi képernyők műveletei: be-/kicsekkolás, szabadság kérése és visszavonása.
class StaffActionsViewModel extends ActionNotifier {
  Future<void> clockIn() async {
    final ok = await perform(() => ref.read(staffRepositoryProvider).clockIn());
    if (ok) ref.invalidate(portalDashboardProvider);
  }

  Future<void> clockOut({int? breakMinutes}) async {
    final ok = await perform(() => ref.read(staffRepositoryProvider).clockOut(breakMinutes: breakMinutes));
    if (ok) ref.invalidate(portalDashboardProvider);
  }

  Future<void> requestLeave(DateTime from, DateTime to, String? reason) async {
    final ok = await perform(() => ref.read(staffRepositoryProvider).requestLeave(from, to, reason), success: FlashKind.saved);
    if (ok) ref.invalidate(leaveRequestsProvider);
  }

  Future<void> cancelLeave(int id) async {
    final ok = await perform(() => ref.read(staffRepositoryProvider).cancelLeave(id));
    if (ok) ref.invalidate(leaveRequestsProvider);
  }
}

final staffActionsProvider = NotifierProvider.autoDispose<StaffActionsViewModel, ActionState>(StaffActionsViewModel.new);

/// Egy foglalás kezelő lapjának állapota (a munkatársi és a vállalkozói mód közös lapja).
class SheetState {
  const SheetState({this.rescheduling = false, this.date, this.busy = false, this.flash, this.done = false});

  final bool rescheduling;
  final DateTime? date;
  final bool busy;
  final Flash? flash;

  /// A művelet sikerült: a lap bezárható.
  final bool done;

  SheetState copyWith({bool? rescheduling, DateTime? date, bool? busy, Flash? flash, bool? done}) => SheetState(
        rescheduling: rescheduling ?? this.rescheduling,
        date: date ?? this.date,
        busy: busy ?? this.busy,
        flash: flash,
        done: done ?? this.done,
      );
}

/// A foglalás-lap kulcsa: a foglalás, és vállalkozói módban a vállalkozás azonosítója (munkatársi módban null).
typedef SheetKey = ({int appointmentId, int? businessId});

class AppointmentSheetViewModel extends Notifier<SheetState> {
  AppointmentSheetViewModel(this.key);

  final SheetKey key;

  @override
  SheetState build() => const SheetState();

  void toggleReschedule() => state = SheetState(rescheduling: !state.rescheduling, date: state.date);

  void pickDate(DateTime date) => state = SheetState(rescheduling: state.rescheduling, date: date);

  /// Státuszváltás: munkatársi módban a portál végpontján, vállalkozói módban a vállalkozóin.
  Future<void> setStatus(String status) {
    final businessId = key.businessId;
    return _run(() => businessId == null
        ? ref.read(staffRepositoryProvider).setStatus(key.appointmentId, status)
        : ref.read(ownerRepositoryProvider).setStatus(businessId, key.appointmentId, status));
  }

  /// Áthelyezés a kiválasztott napra és időpontra (csak munkatársi módban).
  Future<void> reschedule(String time) {
    final date = state.date;
    if (date == null) return Future.value();
    return _run(() => ref.read(staffRepositoryProvider).reschedule(key.appointmentId, date, time));
  }

  Future<void> _run(Future<void> Function() action) async {
    state = state.copyWith(busy: true);
    try {
      await action();
      ref.invalidate(portalDashboardProvider);
      ref.invalidate(portalCalendarProvider);
      ref.invalidate(ownerDashboardProvider);
      ref.invalidate(ownerCalendarProvider);
      if (ref.mounted) state = state.copyWith(busy: false, done: true, flash: const Flash.saved());
    } catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, flash: Flash(FlashKind.error, e));
    }
  }
}

final appointmentSheetProvider =
    NotifierProvider.autoDispose.family<AppointmentSheetViewModel, SheetState, SheetKey>(AppointmentSheetViewModel.new);

final staffWeekProvider = NotifierProvider.autoDispose<WeekViewModel, DateTime>(WeekViewModel.new);
final staffTabProvider = NotifierProvider.autoDispose<TabIndexViewModel, int>(TabIndexViewModel.new);
