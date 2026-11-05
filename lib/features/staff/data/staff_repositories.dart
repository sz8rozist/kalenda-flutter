import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/date_param.dart';
import '../../../core/providers.dart';
import '../model/staff_models.dart';

/// A munkatársi / vállalkozói fiók hitelesítése (`/auth/*`, `/me`).
class StaffAuthRepository {
  StaffAuthRepository(this._api);

  final ApiClient _api;

  Future<StaffUser> me() async {
    final response = await _api.call((d) => d.get('/me'));
    return StaffUser.fromJson(response.data as Map<String, dynamic>);
  }

  /// Mobilon a `device_name` kötelező; a válasz a token és a felhasználó.
  Future<({String token, StaffUser user})> login(String email, String password) async {
    final response = await _api.call((d) => d.post('/auth/login', data: {
          'email': email.trim(),
          'password': password,
          'device_name': 'Kalenda app (${Platform.operatingSystem})',
        }));
    final data = response.data as Map<String, dynamic>;
    return (token: data['token'] as String, user: StaffUser.fromJson(data['user'] as Map<String, dynamic>));
  }

  Future<void> logout() => _api.call((d) => d.post('/auth/logout'));
}

final staffAuthRepositoryProvider = Provider<StaffAuthRepository>((ref) => StaffAuthRepository(ref.watch(apiClientProvider)));

/// A munkatársi portál (`/staff-portal/*`).
class StaffRepository {
  StaffRepository(this._api);

  final ApiClient _api;

  Future<PortalDashboard> dashboard() async {
    final response = await _api.call((d) => d.get('/staff-portal/dashboard'));
    return PortalDashboard.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PortalCalendar> calendar(DateRange range) async {
    final response = await _api.call((d) => d.get('/staff-portal/calendar',
        queryParameters: {'from': dateParam(range.from), 'to': dateParam(range.to)}));
    return PortalCalendar.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<LeaveRequest>> leaveRequests() async {
    final response = await _api.call((d) => d.get('/staff-portal/leave-requests'));
    return (response.data as List).map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<String>> rescheduleSlots(int appointmentId, DateTime date) async {
    final response = await _api.call((d) => d.get('/staff-portal/appointments/$appointmentId/reschedule-slots',
        queryParameters: {'date': dateParam(date)}));
    return (response.data as List).map((e) => '$e').toList();
  }

  Future<void> setStatus(int appointmentId, String status) =>
      _api.call((d) => d.patch('/staff-portal/appointments/$appointmentId/status', data: {'status': status}));

  Future<void> reschedule(int appointmentId, DateTime date, String time) => _api.call(
      (d) => d.patch('/staff-portal/appointments/$appointmentId/reschedule', data: {'date': dateParam(date), 'time': time}));

  Future<void> clockIn() => _api.call((d) => d.post('/staff-portal/timesheet/clock-in'));

  Future<void> clockOut({int? breakMinutes}) => _api.call((d) => d.post('/staff-portal/timesheet/clock-out',
      data: breakMinutes == null ? <String, dynamic>{} : {'break_minutes': breakMinutes}));

  Future<void> requestLeave(DateTime from, DateTime to, String? reason) => _api.call((d) => d.post('/staff-portal/leave-requests', data: {
        'date_from': dateParam(from),
        'date_to': dateParam(to),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      }));

  Future<void> cancelLeave(int id) => _api.call((d) => d.post('/staff-portal/leave-requests/$id/cancel'));
}

final staffRepositoryProvider = Provider<StaffRepository>((ref) => StaffRepository(ref.watch(apiClientProvider)));
