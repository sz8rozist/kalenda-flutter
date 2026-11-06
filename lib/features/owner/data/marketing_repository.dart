import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../model/marketing_models.dart';

/// Bérlet-típusok, hűségprogram és kampányok (`/businesses/{id}/pass-types|loyalty|campaigns`).
class MarketingRepository {
  MarketingRepository(this._api);

  final ApiClient _api;

  // ─── Bérlet- és utalvány-típusok ──────────────────────────────

  Future<List<PassType>> passTypes(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/pass-types'));
    return [for (final e in (response.data as Map<String, dynamic>)['pass_types'] as List) PassType.fromJson(e as Map<String, dynamic>)];
  }

  Future<void> createPassType(
    int businessId, {
    required String kind,
    required String name,
    required int priceHuf,
    required int validityDays,
    int? sessionsCount,
    int? valueHuf,
    int? serviceId,
  }) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/pass-types',
      data: {
        'kind': kind,
        'name': name,
        'price_huf': priceHuf,
        'validity_days': validityDays,
        if (kind == 'pass') 'sessions_count': sessionsCount,
        if (kind == 'pass') 'service_id': serviceId,
        if (kind == 'voucher') 'value_huf': valueHuf,
      },
    ),
  );

  Future<void> togglePassType(int businessId, int passTypeId) =>
      _api.call((d) => d.patch('/businesses/$businessId/pass-types/$passTypeId/toggle'));

  Future<void> deletePassType(int businessId, int passTypeId) =>
      _api.call((d) => d.delete('/businesses/$businessId/pass-types/$passTypeId'));

  /// Helyszíni eladás a vevő e-mail-címére (vagy ajándékba).
  Future<void> sellPassType(
    int businessId,
    int passTypeId, {
    required String paymentMethod,
    String? purchaserEmail,
    String? recipientName,
  }) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/pass-types/$passTypeId/sell',
      data: {
        'payment_method': paymentMethod,
        'purchaser_email': purchaserEmail == null || purchaserEmail.trim().isEmpty ? null : purchaserEmail.trim(),
        'recipient_name': recipientName == null || recipientName.trim().isEmpty ? null : recipientName.trim(),
      },
    ),
  );

  // ─── Hűségprogram ─────────────────────────────────────────────

  Future<LoyaltyOverview> loyalty(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/loyalty'));
    return LoyaltyOverview.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> saveLoyaltySettings(int businessId, LoyaltySettings s) => _api.call(
    (d) => d.put(
      '/businesses/$businessId/loyalty/settings',
      data: {
        'loyalty_enabled': s.enabled,
        'loyalty_points_per1000_huf': s.pointsPer1000Huf,
        'loyalty_reward_points': s.rewardPoints,
        'loyalty_reward_value_huf': s.rewardValueHuf,
      },
    ),
  );

  // ─── Kampányok ────────────────────────────────────────────────

  Future<CampaignListing> campaigns(int businessId) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/campaigns', queryParameters: {'size': 50}));
    return CampaignListing.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> saveCampaign(
    int businessId, {
    int? id,
    required String name,
    required String subject,
    required String body,
    required CampaignSegment segment,
  }) {
    final data = {'name': name, 'subject': subject, 'body': body, 'segment': segment.toJson()};
    return id == null
        ? _api.call((d) => d.post('/businesses/$businessId/campaigns', data: data))
        : _api.call((d) => d.patch('/businesses/$businessId/campaigns/$id', data: data));
  }

  Future<void> deleteCampaign(int businessId, int id) => _api.call((d) => d.delete('/businesses/$businessId/campaigns/$id'));

  /// Hányan kapnák meg a levelet a célcsoport szerint.
  Future<int> audienceCount(int businessId, CampaignSegment segment) async {
    final response = await _api.call((d) => d.post('/businesses/$businessId/campaigns/preview', data: {'segment': segment.toJson()}));
    return ((response.data as Map<String, dynamic>)['count'] as num?)?.toInt() ?? 0;
  }

  /// Próbalevél a saját címre; visszaadja, hová ment.
  Future<String> sendTest(int businessId, int id) async {
    final response = await _api.call((d) => d.post('/businesses/$businessId/campaigns/$id/test'));
    return (response.data as Map<String, dynamic>)['sent_to'] as String? ?? '';
  }

  /// Kiküldés; visszaadja a címzettek számát.
  Future<int> sendCampaign(int businessId, int id) async {
    final response = await _api.call((d) => d.post('/businesses/$businessId/campaigns/$id/send'));
    return ((response.data as Map<String, dynamic>)['recipients'] as num?)?.toInt() ?? 0;
  }
}

final marketingRepositoryProvider = Provider<MarketingRepository>((ref) => MarketingRepository(ref.watch(apiClientProvider)));
