import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/operations_repository.dart';
import '../model/operations_models.dart';

final groupSessionsProvider = FutureProvider.autoDispose.family<List<GroupSessionItem>, int>(
  (ref, businessId) => ref.watch(operationsRepositoryProvider).groupSessions(businessId),
);

final breaksProvider = FutureProvider.autoDispose.family<List<StaffBreaks>, int>(
  (ref, businessId) => ref.watch(operationsRepositoryProvider).breaks(businessId),
);

/// A munkaidő-nyilvántartásban megnézett hónap.
class TimesheetMonthViewModel extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void shift(int months) => state = DateTime(state.year, state.month + months);
}

final timesheetMonthProvider = NotifierProvider.autoDispose<TimesheetMonthViewModel, DateTime>(TimesheetMonthViewModel.new);

final timesheetProvider = FutureProvider.autoDispose.family<TimesheetMonth, int>(
  (ref, businessId) => ref.watch(operationsRepositoryProvider).timesheet(businessId, ref.watch(timesheetMonthProvider)),
);

/// A csoportos alkalmak, szünetek és munkaidő műveletei.
class OperationsActionsViewModel extends ActionNotifier {
  OperationsRepository get _repo => ref.read(operationsRepositoryProvider);

  Future<bool> _run(int businessId, Future<void> Function() action, {FlashKind? success = FlashKind.saved}) async {
    final ok = await perform(action, success: success);
    if (ok) {
      ref.invalidate(groupSessionsProvider(businessId));
      ref.invalidate(breaksProvider(businessId));
      ref.invalidate(timesheetProvider(businessId));
    }
    return ok;
  }

  Future<bool> createGroupSession(
    int businessId, {
    required int serviceId,
    required int staffId,
    required DateTime date,
    required String time,
    required int capacity,
    int? priceHuf,
    String? notes,
    int repeatWeeks = 0,
  }) => _run(
    businessId,
    () => _repo.createGroupSession(
      businessId,
      serviceId: serviceId,
      staffId: staffId,
      date: date,
      time: time,
      capacity: capacity,
      priceHuf: priceHuf,
      notes: notes,
      repeatWeeks: repeatWeeks,
    ),
  );

  Future<bool> cancelGroupSession(int businessId, int id) => _run(businessId, () => _repo.cancelGroupSession(businessId, id));

  Future<bool> addAttendee(int businessId, int id, {required String name, required String email, String? phone}) =>
      _run(businessId, () => _repo.addAttendee(businessId, id, name: name, email: email, phone: phone));

  Future<bool> addBreak(
    int businessId, {
    required int staffId,
    required int dayOfWeek,
    required String start,
    required String end,
    String? label,
  }) => _run(businessId, () => _repo.addBreak(businessId, staffId: staffId, dayOfWeek: dayOfWeek, start: start, end: end, label: label));

  Future<bool> deleteBreak(int businessId, int id) => _run(businessId, () => _repo.deleteBreak(businessId, id), success: null);

  Future<bool> addTimeEntry(
    int businessId, {
    required int staffId,
    required DateTime clockIn,
    required DateTime clockOut,
    int breakMinutes = 0,
    String? note,
  }) => _run(
    businessId,
    () => _repo.addTimeEntry(businessId, staffId: staffId, clockIn: clockIn, clockOut: clockOut, breakMinutes: breakMinutes, note: note),
  );

  Future<bool> deleteTimeEntry(int businessId, int id) => _run(businessId, () => _repo.deleteTimeEntry(businessId, id), success: null);

  Future<bool> closeMonth(int businessId, DateTime month) => _run(businessId, () => _repo.closeMonth(businessId, month));

  Future<bool> reopenMonth(int businessId, DateTime month) => _run(businessId, () => _repo.reopenMonth(businessId, month));
}

final operationsActionsProvider = NotifierProvider.autoDispose<OperationsActionsViewModel, ActionState>(OperationsActionsViewModel.new);
