import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/viewmodel/action_state.dart';
import '../data/admin_repository.dart';
import '../model/admin_models.dart';

final adminDashboardProvider = FutureProvider.autoDispose<AdminDashboard>((ref) => ref.watch(adminRepositoryProvider).dashboard());

/// A vállalkozás-lista keresőszövege.
class AdminSearchViewModel extends Notifier<String> {
  @override
  String build() => '';

  void search(String text) => state = text;
}

final adminSearchProvider = NotifierProvider.autoDispose<AdminSearchViewModel, String>(AdminSearchViewModel.new);

final adminBusinessesProvider = FutureProvider.autoDispose<List<AdminBusiness>>(
  (ref) => ref.watch(adminRepositoryProvider).businesses(search: ref.watch(adminSearchProvider)),
);

/// A foglalások és visszajelzések állapot-szűrője (üres = mind).
class AdminStatusFilterViewModel extends Notifier<String> {
  @override
  String build() => '';

  void select(String status) => state = status;
}

final adminAppointmentStatusProvider = NotifierProvider.autoDispose<AdminStatusFilterViewModel, String>(AdminStatusFilterViewModel.new);
final adminFeedbackStatusProvider = NotifierProvider.autoDispose<AdminStatusFilterViewModel, String>(AdminStatusFilterViewModel.new);

final adminAppointmentsProvider = FutureProvider.autoDispose<List<AdminAppointment>>(
  (ref) => ref.watch(adminRepositoryProvider).appointments(status: ref.watch(adminAppointmentStatusProvider)),
);

final adminFeedbackProvider = FutureProvider.autoDispose<List<AdminFeedback>>(
  (ref) => ref.watch(adminRepositoryProvider).feedback(status: ref.watch(adminFeedbackStatusProvider)),
);

/// Az admin műveletei: vállalkozás be/kikapcsolása, visszajelzés megválaszolása.
class AdminActionsViewModel extends ActionNotifier {
  Future<bool> toggleBusiness(int id) async {
    final ok = await perform(() => ref.read(adminRepositoryProvider).toggleBusiness(id));
    if (ok) {
      ref.invalidate(adminBusinessesProvider);
      ref.invalidate(adminDashboardProvider);
    }
    return ok;
  }

  Future<bool> answerFeedback(int id, {required String status, String? response}) async {
    final ok = await perform(
      () => ref.read(adminRepositoryProvider).answerFeedback(id, status: status, response: response),
      success: FlashKind.saved,
    );
    if (ok) ref.invalidate(adminFeedbackProvider);
    return ok;
  }
}

final adminActionsProvider = NotifierProvider.autoDispose<AdminActionsViewModel, ActionState>(AdminActionsViewModel.new);
