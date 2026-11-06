import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/owner_repository.dart';
import '../model/customer_detail.dart';
import '../model/owner_models.dart';
import 'owner_service_viewmodels.dart';
import 'owner_staff_viewmodels.dart';

/// Szolgáltatás létrehozása / mentése / törlése (a teljes szerkesztő űrlap műveletei).
class ServiceEditViewModel extends ActionNotifier {
  /// Új szolgáltatás (ha `service.id == 0`), különben a meglévő mentése.
  Future<bool> save(int businessId, OwnerService service) async {
    final repository = ref.read(ownerRepositoryProvider);
    final ok = await perform(
      () => service.id == 0 ? repository.createService(businessId, service) : repository.saveService(businessId, service),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(ownerServicesProvider(businessId));
    return ok;
  }

  Future<bool> delete(int businessId, int serviceId) async {
    final ok = await perform(() => ref.read(ownerRepositoryProvider).deleteService(businessId, serviceId));
    if (ok) ref.invalidate(ownerServicesProvider(businessId));
    return ok;
  }
}

final serviceEditProvider = NotifierProvider.autoDispose<ServiceEditViewModel, ActionState>(ServiceEditViewModel.new);

/// Munkatárs létrehozása / mentése / törlése, szolgáltatások hozzárendelése, meghívó, hozzáférés megvonása.
class StaffEditViewModel extends ActionNotifier {
  /// Új munkatárs (ha `staff.id == 0`) vagy a meglévő mentése; a szolgáltatásokat is beállítja.
  Future<bool> save(int businessId, OwnerStaff staff, List<int> serviceIds) async {
    final repository = ref.read(ownerRepositoryProvider);
    final ok = await perform(() async {
      var id = staff.id;
      if (id == 0) {
        id = (await repository.createStaff(businessId, staff)).id;
      } else {
        await repository.saveStaff(businessId, staff);
      }
      await repository.setStaffServices(businessId, id, serviceIds);
    }, success: FlashKind.saved);
    if (ok) ref.invalidate(ownerStaffProvider(businessId));
    return ok;
  }

  Future<bool> delete(int businessId, int staffId) async {
    final ok = await perform(() => ref.read(ownerRepositoryProvider).deleteStaff(businessId, staffId));
    if (ok) ref.invalidate(ownerStaffProvider(businessId));
    return ok;
  }

  Future<bool> invite(int businessId, int staffId) async {
    final ok = await perform(() => ref.read(ownerRepositoryProvider).inviteStaff(businessId, staffId), success: FlashKind.saved);
    if (ok) ref.invalidate(ownerStaffProvider(businessId));
    return ok;
  }

  Future<bool> revokeAccess(int businessId, int staffId) async {
    final ok = await perform(() => ref.read(ownerRepositoryProvider).revokeStaffAccess(businessId, staffId), success: FlashKind.saved);
    if (ok) ref.invalidate(ownerStaffProvider(businessId));
    return ok;
  }
}

final staffEditProvider = NotifierProvider.autoDispose<StaffEditViewModel, ActionState>(StaffEditViewModel.new);

typedef CustomerKey = ({int businessId, int customerId});

/// Egy ügyfél részletei (statisztika, profil, hűségpontok).
class CustomerDetailViewModel extends AsyncNotifier<CustomerDetail> {
  CustomerDetailViewModel(this.key);

  final CustomerKey key;

  @override
  Future<CustomerDetail> build() => ref.watch(ownerRepositoryProvider).customerDetail(key.businessId, key.customerId);
}

final customerDetailProvider = AsyncNotifierProvider.autoDispose.family<CustomerDetailViewModel, CustomerDetail, CustomerKey>(
  CustomerDetailViewModel.new,
);

/// Az ügyfél-oldal műveletei: profil mentése, hűségpont módosítása, jutalom beváltása.
class CustomerActionsViewModel extends ActionNotifier {
  /// A legutóbb beváltott jutalom kedvezménye (Ft); a View ebből mutat visszajelzést.
  int? lastRedeemedDiscountHuf;

  Future<bool> saveProfile(
    CustomerKey key, {
    required bool depositExempt,
    required String internalNote,
    bool? marketingConsent,
    String? billingPostCode,
    String? billingCity,
    String? billingAddress,
    String? billingTaxNumber,
    String? billingEmail,
  }) async {
    final ok = await perform(
      () => ref
          .read(ownerRepositoryProvider)
          .updateCustomerProfile(
            key.businessId,
            key.customerId,
            depositExempt: depositExempt,
            internalNote: internalNote,
            marketingConsent: marketingConsent,
            billingPostCode: billingPostCode,
            billingCity: billingCity,
            billingAddress: billingAddress,
            billingTaxNumber: billingTaxNumber,
            billingEmail: billingEmail,
          ),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(customerDetailProvider(key));
    return ok;
  }

  Future<bool> adjustLoyalty(CustomerKey key, {required int points, required String note}) async {
    final ok = await perform(
      () => ref.read(ownerRepositoryProvider).adjustLoyalty(key.businessId, key.customerId, points: points, note: note),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(customerDetailProvider(key));
    return ok;
  }

  Future<bool> redeem(CustomerKey key) async {
    final ok = await perform(() async {
      lastRedeemedDiscountHuf = await ref.read(ownerRepositoryProvider).redeemLoyalty(key.businessId, key.customerId);
    }, success: FlashKind.saved);
    if (ok) ref.invalidate(customerDetailProvider(key));
    return ok;
  }
}

final customerActionsProvider = NotifierProvider.autoDispose<CustomerActionsViewModel, ActionState>(CustomerActionsViewModel.new);
