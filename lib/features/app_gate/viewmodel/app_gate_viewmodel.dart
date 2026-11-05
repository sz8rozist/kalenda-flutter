import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_config_repository.dart';
import '../model/app_config.dart';

/// A verzió-kapu: indításkor lekéri a szerver minimum verzióját. Az érték `null`, ha az app használható;
/// [UpdateRequired], ha frissíteni kell. Hálózati hiba esetén nem zárjuk ki a felhasználót (az app úgyis jelzi a hibát).
class AppGateViewModel extends AsyncNotifier<UpdateRequired?> {
  @override
  Future<UpdateRequired?> build() async {
    final repository = ref.read(appConfigRepositoryProvider);

    try {
      final config = await repository.remoteConfig();
      final installed = await repository.installedVersion();
      final minimum = config.minVersion;

      if (minimum == null || !isOutdated(installed, minimum)) return null;
      return UpdateRequired(
        minVersion: minimum,
        storeUrl: Platform.isIOS ? config.iosStoreUrl : config.androidStoreUrl,
      );
    } catch (_) {
      return null;
    }
  }
}

final appGateProvider = AsyncNotifierProvider<AppGateViewModel, UpdateRequired?>(AppGateViewModel.new);
