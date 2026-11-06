import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../model/staff_models.dart';

/// A vállalkozói / munkatársi fiók kezelése: regisztráció, jelszó, visszajelzés, első vállalkozás létrehozása.
class StaffAccountRepository {
  StaffAccountRepository(this._api);

  final ApiClient _api;

  /// Új fiók; a válasz a token és a felhasználó (rögtön be is lép).
  Future<({String token, StaffUser user})> register({required String name, required String email, required String password}) async {
    final response = await _api.call(
      (d) => d.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'password_confirmation': password,
          'device_name': 'Kalenda app (${Platform.operatingSystem})',
        },
      ),
    );
    final data = response.data as Map<String, dynamic>;
    return (token: data['token'] as String, user: StaffUser.fromJson(data['user'] as Map<String, dynamic>));
  }

  Future<void> forgotPassword(String email) => _api.call((d) => d.post('/auth/forgot-password', data: {'email': email.trim()}));

  Future<void> changePassword({required String current, required String password}) =>
      _api.call((d) => d.put('/me/password', data: {'current_password': current, 'password': password, 'password_confirmation': password}));

  Future<void> sendFeedback({required String type, required String subject, required String message}) =>
      _api.call((d) => d.post('/me/feedback', data: {'type': type, 'subject': subject.trim(), 'message': message.trim()}));

  /// Az első vállalkozás létrehozása a kezdő szolgáltatásokkal és munkatársakkal.
  Future<void> createBusiness({
    required String name,
    required bool isSolo,
    required List<({String name, int durationMinutes, int? priceHuf})> services,
    required List<({String name, String? email})> staff,
    String? phone,
    String? address,
    String? city,
  }) => _api.call(
    (d) => d.post(
      '/businesses',
      data: {
        'name': name.trim(),
        'phone': phone == null || phone.trim().isEmpty ? null : phone.trim(),
        'address': address == null || address.trim().isEmpty ? null : address.trim(),
        'city': city == null || city.trim().isEmpty ? null : city.trim(),
        'timezone': 'Europe/Budapest',
        'is_solo': isSolo,
        'services': [
          for (final s in services) {'name': s.name, 'duration_minutes': s.durationMinutes, 'price_huf': s.priceHuf},
        ],
        'staff': [
          for (final s in staff) {'name': s.name, 'email': s.email == null || s.email!.isEmpty ? null : s.email},
        ],
      },
    ),
  );
}

final staffAccountRepositoryProvider = Provider<StaffAccountRepository>((ref) => StaffAccountRepository(ref.watch(apiClientProvider)));
