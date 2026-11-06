import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/owner_repository.dart';
import '../model/owner_models.dart';

/// A vállalkozás munkatársai; a kulcs a vállalkozás azonosítója.
class OwnerStaffViewModel extends AsyncNotifier<List<OwnerStaff>> {
  OwnerStaffViewModel(this.businessId);

  final int businessId;

  @override
  Future<List<OwnerStaff>> build() => ref.watch(ownerRepositoryProvider).staffList(businessId);
}

final ownerStaffProvider =
    AsyncNotifierProvider.autoDispose.family<OwnerStaffViewModel, List<OwnerStaff>, int>(OwnerStaffViewModel.new);

/// A munkatársak gyors szerkesztése: aktív / inaktív váltás, név, telefonszám.
class StaffManageViewModel extends ActionNotifier {
  Future<bool> setActive(int businessId, int staffId, bool active) => _patch(businessId, staffId, isActive: active);

  Future<bool> update(int businessId, int staffId, {required String name, String? phone}) =>
      _patch(businessId, staffId, name: name, phone: phone, success: FlashKind.saved);

  Future<bool> _patch(int businessId, int staffId, {String? name, String? phone, bool? isActive, FlashKind? success}) async {
    final ok = await perform(
      () => ref.read(ownerRepositoryProvider).patchStaff(businessId, staffId, name: name, phone: phone, isActive: isActive),
      success: success,
    );
    if (ok) ref.invalidate(ownerStaffProvider(businessId));
    return ok;
  }
}

final staffManageProvider = NotifierProvider.autoDispose<StaffManageViewModel, ActionState>(StaffManageViewModel.new);
