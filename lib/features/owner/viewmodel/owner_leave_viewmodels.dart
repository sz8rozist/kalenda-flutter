import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/owner_repository.dart';
import '../model/owner_models.dart';
import 'owner_viewmodels.dart';

/// A döntésre váró szabadság-igénylések; a kulcs a vállalkozás azonosítója.
class OwnerLeaveRequestsViewModel extends AsyncNotifier<List<OwnerLeaveRequest>> {
  OwnerLeaveRequestsViewModel(this.businessId);

  final int businessId;

  @override
  Future<List<OwnerLeaveRequest>> build() => ref.watch(ownerRepositoryProvider).pendingLeaveRequests(businessId);
}

final ownerLeaveRequestsProvider = AsyncNotifierProvider.autoDispose
    .family<OwnerLeaveRequestsViewModel, List<OwnerLeaveRequest>, int>(OwnerLeaveRequestsViewModel.new);

/// Az igénylések elbírálása: jóváhagyás (a naptárban szabadnap lesz) vagy elutasítás megjegyzéssel.
class LeaveDecisionViewModel extends ActionNotifier {
  Future<void> approve(int businessId, int requestId) =>
      _decided(businessId, () => ref.read(ownerRepositoryProvider).approveLeave(businessId, requestId));

  Future<void> reject(int businessId, int requestId, {String? note}) =>
      _decided(businessId, () => ref.read(ownerRepositoryProvider).rejectLeave(businessId, requestId, note: note));

  Future<void> _decided(int businessId, Future<void> Function() action) async {
    final ok = await perform(action, success: FlashKind.saved);
    if (ok) {
      ref.invalidate(ownerLeaveRequestsProvider(businessId));
      ref.invalidate(ownerCalendarProvider); // a jóváhagyott szabadság megjelenik a naptárban
    }
  }
}

final leaveDecisionProvider = NotifierProvider.autoDispose<LeaveDecisionViewModel, ActionState>(LeaveDecisionViewModel.new);
