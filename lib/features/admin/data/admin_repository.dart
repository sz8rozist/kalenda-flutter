import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../model/admin_models.dart';

/// A platform-adminisztrátor végpontjai (`/admin/*`).
class AdminRepository {
  AdminRepository(this._api);

  final ApiClient _api;

  Future<AdminDashboard> dashboard() async {
    final response = await _api.call((d) => d.get('/admin/dashboard'));
    return AdminDashboard.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AdminBusiness>> businesses({String? search}) async {
    final response = await _api.call(
      (d) => d.get(
        '/admin/businesses',
        queryParameters: {'size': 50, if (search != null && search.trim().isNotEmpty) 'search': search.trim()},
      ),
    );
    return AdminBusiness.fromPaged(response.data);
  }

  /// A vállalkozás be- / kikapcsolása; visszaadja az új állapotot.
  Future<bool> toggleBusiness(int id) async {
    final response = await _api.call((d) => d.post('/admin/businesses/$id/toggle'));
    return (response.data as Map<String, dynamic>)['is_active'] as bool? ?? true;
  }

  Future<List<AdminAppointment>> appointments({String? status}) async {
    final response = await _api.call(
      (d) => d.get('/admin/appointments', queryParameters: {'size': 50, if (status != null && status.isNotEmpty) 'status': status}),
    );
    return AdminAppointment.fromPaged(response.data);
  }

  Future<List<AdminFeedback>> feedback({String? status}) async {
    final response = await _api.call(
      (d) => d.get('/admin/feedback', queryParameters: {'size': 50, if (status != null && status.isNotEmpty) 'status': status}),
    );
    return AdminFeedback.fromPaged(response.data);
  }

  Future<void> answerFeedback(int id, {required String status, String? response}) => _api.call(
    (d) => d.patch(
      '/admin/feedback/$id',
      data: {'status': status, 'admin_response': response == null || response.trim().isEmpty ? null : response.trim()},
    ),
  );
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) => AdminRepository(ref.watch(apiClientProvider)));
