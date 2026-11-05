import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/owner_repository.dart';
import '../model/owner_models.dart';

/// A vállalkozás szolgáltatásai; a kulcs a vállalkozás azonosítója.
class OwnerServicesViewModel extends AsyncNotifier<List<OwnerService>> {
  OwnerServicesViewModel(this.businessId);

  final int businessId;

  @override
  Future<List<OwnerService>> build() => ref.watch(ownerRepositoryProvider).services(businessId);
}

final ownerServicesProvider =
    AsyncNotifierProvider.autoDispose.family<OwnerServicesViewModel, List<OwnerService>, int>(OwnerServicesViewModel.new);

/// A szolgáltatások gyors szerkesztése: aktív / inaktív váltás, név, időtartam, ár.
class ServiceActionsViewModel extends ActionNotifier {
  Future<bool> setActive(int businessId, int serviceId, bool active) => _patch(businessId, serviceId, isActive: active);

  Future<bool> update(int businessId, int serviceId, {required String name, required int durationMinutes, int? priceHuf}) =>
      _patch(businessId, serviceId, name: name, durationMinutes: durationMinutes, priceHuf: priceHuf, success: FlashKind.saved);

  Future<bool> _patch(
    int businessId,
    int serviceId, {
    String? name,
    int? durationMinutes,
    int? priceHuf,
    bool? isActive,
    FlashKind? success,
  }) async {
    final ok = await perform(
      () => ref.read(ownerRepositoryProvider).patchService(
            businessId,
            serviceId,
            name: name,
            durationMinutes: durationMinutes,
            priceHuf: priceHuf,
            isActive: isActive,
          ),
      success: success,
    );
    if (ok) ref.invalidate(ownerServicesProvider(businessId));
    return ok;
  }
}

final serviceActionsProvider = NotifierProvider.autoDispose<ServiceActionsViewModel, ActionState>(ServiceActionsViewModel.new);
