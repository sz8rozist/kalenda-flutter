import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/date_param.dart';
import '../../../core/providers.dart';
import '../model/owner_models.dart';

/// A vállalkozói végpontok (`/businesses/{id}/…`).
class OwnerRepository {
  OwnerRepository(this._api);

  final ApiClient _api;

  Future<OwnerDashboard> dashboard(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/dashboard'));
    return OwnerDashboard.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OwnerCalendar> calendar(int businessId, DateRange range) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/calendar',
        queryParameters: {'from': dateParam(range.from), 'to': dateParam(range.to)}));
    return OwnerCalendar.fromJson(response.data as Map<String, dynamic>);
  }

  /// Az ügyfelek első oldala (legfeljebb 50), név / e-mail / telefon szerint kereshető.
  Future<List<CustomerItem>> customers(int businessId, String search) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/customers', queryParameters: {
          if (search.isNotEmpty) 'search': search,
          'size': 50,
        }));
    // A lapozott lista Spring PagedModel: {content: [...], page: {...}}.
    final content = ((response.data as Map<String, dynamic>)['customers'] as Map<String, dynamic>)['content'] as List;
    return content.map((e) => CustomerItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> setStatus(int businessId, int appointmentId, String status) =>
      _api.call((d) => d.patch('/businesses/$businessId/appointments/$appointmentId/status', data: {'status': status}));
}

final ownerRepositoryProvider = Provider<OwnerRepository>((ref) => OwnerRepository(ref.watch(apiClientProvider)));
