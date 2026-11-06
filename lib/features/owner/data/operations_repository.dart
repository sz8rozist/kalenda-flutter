import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/date_param.dart';
import '../../../core/providers.dart';
import '../model/operations_models.dart';

/// Csoportos alkalmak, szünetek és munkaidő (`/businesses/{id}/group-sessions|breaks|timesheet`).
class OperationsRepository {
  OperationsRepository(this._api);

  final ApiClient _api;

  // ─── Csoportos alkalmak ───────────────────────────────────────

  Future<List<GroupSessionItem>> groupSessions(int businessId) async {
    final from = dateParam(DateTime.now());
    final response = await _api.call((d) => d.get('/businesses/$businessId/group-sessions', queryParameters: {'from': from, 'size': 50}));
    return GroupSessionItem.fromPaged(response.data);
  }

  Future<void> createGroupSession(
    int businessId, {
    required int serviceId,
    required int staffId,
    required DateTime date,
    required String time,
    required int capacity,
    int? priceHuf,
    String? notes,
    int repeatWeeks = 0,
  }) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/group-sessions',
      data: {
        'service_id': serviceId,
        'staff_id': staffId,
        'date': dateParam(date),
        'time': time,
        'capacity': capacity,
        'price_huf': priceHuf,
        'notes': notes == null || notes.trim().isEmpty ? null : notes.trim(),
        'repeat_weeks': repeatWeeks,
      },
    ),
  );

  Future<void> cancelGroupSession(int businessId, int id) => _api.call((d) => d.post('/businesses/$businessId/group-sessions/$id/cancel'));

  Future<void> addAttendee(int businessId, int id, {required String name, required String email, String? phone}) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/group-sessions/$id/attendees',
      data: {
        'customer_name': name,
        'customer_email': email,
        'customer_phone': phone == null || phone.trim().isEmpty ? null : phone.trim(),
        'notify_customer': true,
      },
    ),
  );

  // ─── Szünetek ─────────────────────────────────────────────────

  Future<List<StaffBreaks>> breaks(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/breaks'));
    return [for (final e in response.data as List) StaffBreaks.fromJson(e as Map<String, dynamic>)];
  }

  Future<void> addBreak(
    int businessId, {
    required int staffId,
    required int dayOfWeek,
    required String start,
    required String end,
    String? label,
  }) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/breaks',
      data: {
        'staff_id': staffId,
        'day_of_week': dayOfWeek,
        'start_at': start,
        'end_at': end,
        'label': label == null || label.trim().isEmpty ? null : label.trim(),
      },
    ),
  );

  Future<void> deleteBreak(int businessId, int id) => _api.call((d) => d.delete('/businesses/$businessId/breaks/$id'));

  // ─── Munkaidő ─────────────────────────────────────────────────

  String monthKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

  Future<TimesheetMonth> timesheet(int businessId, DateTime month) async {
    final response = await _api.call(
      (d) => d.get('/businesses/$businessId/timesheet', queryParameters: {'month': monthKey(month), 'size': 100}),
    );
    return TimesheetMonth.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> addTimeEntry(
    int businessId, {
    required int staffId,
    required DateTime clockIn,
    required DateTime clockOut,
    int breakMinutes = 0,
    String? note,
  }) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/time-entries',
      data: {
        'staff_id': staffId,
        'clock_in_at': clockIn.toUtc().toIso8601String(),
        'clock_out_at': clockOut.toUtc().toIso8601String(),
        'break_minutes': breakMinutes,
        'note': note == null || note.trim().isEmpty ? null : note.trim(),
      },
    ),
  );

  Future<void> deleteTimeEntry(int businessId, int id) => _api.call((d) => d.delete('/businesses/$businessId/time-entries/$id'));

  Future<void> closeMonth(int businessId, DateTime month) =>
      _api.call((d) => d.post('/businesses/$businessId/timesheet/close', data: {'month': monthKey(month)}));

  Future<void> reopenMonth(int businessId, DateTime month) =>
      _api.call((d) => d.post('/businesses/$businessId/timesheet/reopen', data: {'month': monthKey(month)}));

  /// Egy munkatárs ki-/bejelentkeztetése a vállalkozó nevében.
  Future<void> clockStaff(int businessId, int staffId, {required bool clockIn}) =>
      _api.call((d) => d.post('/businesses/$businessId/staff/$staffId/${clockIn ? 'clock-in' : 'clock-out'}'));
}

final operationsRepositoryProvider = Provider<OperationsRepository>((ref) => OperationsRepository(ref.watch(apiClientProvider)));
