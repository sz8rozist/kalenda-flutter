import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/marketing_repository.dart';
import '../model/marketing_models.dart';

final passTypesProvider = FutureProvider.autoDispose.family<List<PassType>, int>(
  (ref, businessId) => ref.watch(marketingRepositoryProvider).passTypes(businessId),
);

final loyaltyProvider = FutureProvider.autoDispose.family<LoyaltyOverview, int>(
  (ref, businessId) => ref.watch(marketingRepositoryProvider).loyalty(businessId),
);

final campaignsProvider = FutureProvider.autoDispose.family<CampaignListing, int>(
  (ref, businessId) => ref.watch(marketingRepositoryProvider).campaigns(businessId),
);

/// A marketing-oldalak műveletei: bérlet-típus, hűség-beállítás és kampány kezelése.
class MarketingActionsViewModel extends ActionNotifier {
  MarketingRepository get _repo => ref.read(marketingRepositoryProvider);

  /// A legutóbbi kiküldés címzettjeinek száma / a próbalevél címe (a View ebből mutat visszajelzést).
  int? lastRecipients;
  String? lastTestSentTo;

  Future<bool> _run(int businessId, Future<void> Function() action, {FlashKind? success = FlashKind.saved}) async {
    final ok = await perform(action, success: success);
    if (ok) {
      ref.invalidate(passTypesProvider(businessId));
      ref.invalidate(loyaltyProvider(businessId));
      ref.invalidate(campaignsProvider(businessId));
    }
    return ok;
  }

  Future<bool> createPassType(
    int businessId, {
    required String kind,
    required String name,
    required int priceHuf,
    required int validityDays,
    int? sessionsCount,
    int? valueHuf,
    int? serviceId,
  }) => _run(
    businessId,
    () => _repo.createPassType(
      businessId,
      kind: kind,
      name: name,
      priceHuf: priceHuf,
      validityDays: validityDays,
      sessionsCount: sessionsCount,
      valueHuf: valueHuf,
      serviceId: serviceId,
    ),
  );

  Future<bool> togglePassType(int businessId, int id) => _run(businessId, () => _repo.togglePassType(businessId, id), success: null);

  Future<bool> deletePassType(int businessId, int id) => _run(businessId, () => _repo.deletePassType(businessId, id), success: null);

  Future<bool> sellPassType(int businessId, int id, {required String paymentMethod, String? purchaserEmail, String? recipientName}) => _run(
    businessId,
    () => _repo.sellPassType(businessId, id, paymentMethod: paymentMethod, purchaserEmail: purchaserEmail, recipientName: recipientName),
  );

  Future<bool> saveLoyalty(int businessId, LoyaltySettings settings) =>
      _run(businessId, () => _repo.saveLoyaltySettings(businessId, settings));

  Future<bool> saveCampaign(
    int businessId, {
    int? id,
    required String name,
    required String subject,
    required String body,
    required CampaignSegment segment,
  }) => _run(businessId, () => _repo.saveCampaign(businessId, id: id, name: name, subject: subject, body: body, segment: segment));

  Future<bool> deleteCampaign(int businessId, int id) => _run(businessId, () => _repo.deleteCampaign(businessId, id), success: null);

  Future<bool> sendTest(int businessId, int id) => perform(() async => lastTestSentTo = await _repo.sendTest(businessId, id));

  Future<bool> send(int businessId, int id) =>
      _run(businessId, () async => lastRecipients = await _repo.sendCampaign(businessId, id), success: null);

  Future<int> audienceCount(int businessId, CampaignSegment segment) async {
    try {
      return await _repo.audienceCount(businessId, segment);
    } catch (_) {
      return 0;
    }
  }
}

final marketingActionsProvider = NotifierProvider.autoDispose<MarketingActionsViewModel, ActionState>(MarketingActionsViewModel.new);
