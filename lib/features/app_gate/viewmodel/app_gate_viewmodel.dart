import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_config_repository.dart';
import '../model/app_config.dart';

/// A szerver indításkori beállításai (egyszer töltődnek be): verzió-kapu, store-linkek, elérhető belépési módok.
/// Hálózati hiba esetén az alapértelmezés érvényes (nincs kényszer, nincs közösségi belépés).
class RemoteConfigViewModel extends AsyncNotifier<RemoteAppConfig> {
  @override
  Future<RemoteAppConfig> build() async {
    try {
      return await ref.read(appConfigRepositoryProvider).remoteConfig();
    } catch (_) {
      return const RemoteAppConfig();
    }
  }
}

final remoteConfigProvider = AsyncNotifierProvider<RemoteConfigViewModel, RemoteAppConfig>(RemoteConfigViewModel.new);

/// A verzió-kapu: az érték `null`, ha az app használható; [UpdateRequired], ha frissíteni kell.
class AppGateViewModel extends AsyncNotifier<UpdateRequired?> {
  @override
  Future<UpdateRequired?> build() async {
    final config = await ref.watch(remoteConfigProvider.future);
    final minimum = config.minVersion;
    if (minimum == null) return null;

    try {
      final installed = await ref.read(appConfigRepositoryProvider).installedVersion();
      if (!isOutdated(installed, minimum)) return null;
      return UpdateRequired(minVersion: minimum, storeUrl: Platform.isIOS ? config.iosStoreUrl : config.androidStoreUrl);
    } catch (_) {
      return null;
    }
  }
}

final appGateProvider = AsyncNotifierProvider<AppGateViewModel, UpdateRequired?>(AppGateViewModel.new);
