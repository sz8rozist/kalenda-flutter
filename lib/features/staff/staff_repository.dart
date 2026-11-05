import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../booking/booking_repository.dart' show dateParam;
import 'staff_models.dart';

final portalDashboardProvider = FutureProvider.autoDispose<PortalDashboard>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.call((d) => d.get('/staff-portal/dashboard'));
  return PortalDashboard.fromJson(response.data as Map<String, dynamic>);
});

/// A saját naptár egy tartományra (legfeljebb 62 nap).
typedef DateRange = ({DateTime from, DateTime to});

final portalCalendarProvider = FutureProvider.autoDispose.family<PortalCalendar, DateRange>((ref, range) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.call((d) => d.get('/staff-portal/calendar',
      queryParameters: {'from': dateParam(range.from), 'to': dateParam(range.to)}));
  return PortalCalendar.fromJson(response.data as Map<String, dynamic>);
});

final leaveRequestsProvider = FutureProvider.autoDispose<List<LeaveRequest>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.call((d) => d.get('/staff-portal/leave-requests'));
  return (response.data as List).map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>)).toList();
});

/// Szabad időpontok a foglalás áthelyezéséhez ("HH:mm").
final portalRescheduleSlotsProvider =
    FutureProvider.autoDispose.family<List<String>, ({int appointmentId, DateTime date})>((ref, q) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.call((d) => d.get('/staff-portal/appointments/${q.appointmentId}/reschedule-slots',
      queryParameters: {'date': dateParam(q.date)}));
  return (response.data as List).map((e) => '$e').toList();
});

class StaffRepository {
  StaffRepository(this._ref);

  final Ref _ref;

  void _refreshAppointments() {
    _ref.invalidate(portalDashboardProvider);
    _ref.invalidate(portalCalendarProvider);
  }

  Future<void> setStatus(int appointmentId, String status) async {
    final api = _ref.read(apiClientProvider);
    await api.call((d) => d.patch('/staff-portal/appointments/$appointmentId/status', data: {'status': status}));
    _refreshAppointments();
  }

  Future<void> reschedule(int appointmentId, DateTime date, String time) async {
    final api = _ref.read(apiClientProvider);
    await api.call((d) => d.patch('/staff-portal/appointments/$appointmentId/reschedule',
        data: {'date': dateParam(date), 'time': time}));
    _refreshAppointments();
  }

  Future<void> clockIn() async {
    final api = _ref.read(apiClientProvider);
    await api.call((d) => d.post('/staff-portal/timesheet/clock-in'));
    _ref.invalidate(portalDashboardProvider);
  }

  Future<void> clockOut({int? breakMinutes}) async {
    final api = _ref.read(apiClientProvider);
    await api.call((d) => d.post('/staff-portal/timesheet/clock-out',
        data: breakMinutes == null ? <String, dynamic>{} : {'break_minutes': breakMinutes}));
    _ref.invalidate(portalDashboardProvider);
  }

  Future<void> requestLeave(DateTime from, DateTime to, String? reason) async {
    final api = _ref.read(apiClientProvider);
    await api.call((d) => d.post('/staff-portal/leave-requests', data: {
          'date_from': dateParam(from),
          'date_to': dateParam(to),
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        }));
    _ref.invalidate(leaveRequestsProvider);
  }

  Future<void> cancelLeave(int id) async {
    final api = _ref.read(apiClientProvider);
    await api.call((d) => d.post('/staff-portal/leave-requests/$id/cancel'));
    _ref.invalidate(leaveRequestsProvider);
  }
}

final staffRepositoryProvider = Provider<StaffRepository>(StaffRepository.new);
