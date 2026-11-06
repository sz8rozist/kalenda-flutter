import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_gate/viewmodel/app_gate_viewmodel.dart';
import '../../app_lock/viewmodel/app_lock_viewmodel.dart';
import '../../auth/viewmodel/customer_session_viewmodel.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';

/// Az indítás: megvárja a munkamenetet, a szerver-beállításokat és az alkalmazászárat, de legalább egy rövid ideig
/// megmutatja a splash-t (hogy ne villanjon fel), legfeljebb pár másodpercig vár (lassú hálózatnál sem akad el).
class StartupViewModel extends AsyncNotifier<void> {
  static const minimum = Duration(milliseconds: 1200);
  static const maximum = Duration(seconds: 4);

  @override
  Future<void> build() async {
    final loading = Future.wait<Object?>([
      ref.watch(customerSessionProvider.future),
      ref.watch(staffSessionProvider.future),
      ref.watch(remoteConfigProvider.future),
      ref.watch(appLockProvider.future),
    ]).then((_) => null).timeout(maximum, onTimeout: () => null);

    await Future.wait<void>([loading, Future<void>.delayed(minimum)]);
  }
}

final startupProvider = AsyncNotifierProvider<StartupViewModel, void>(StartupViewModel.new);
