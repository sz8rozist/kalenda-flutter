import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../model/app_config.dart';

/// A szerver beállításai és a telepített app verziója.
class AppConfigRepository {
  AppConfigRepository(this._api);

  final ApiClient _api;

  Future<RemoteAppConfig> remoteConfig() async {
    final response = await _api.call((d) => d.get('/app-config'));
    return RemoteAppConfig.fromJson(response.data as Map<String, dynamic>);
  }

  /// A telepített app verziója (a pubspec `version` mezője).
  Future<String> installedVersion() async => (await PackageInfo.fromPlatform()).version;
}

final appConfigRepositoryProvider = Provider<AppConfigRepository>((ref) => AppConfigRepository(ref.watch(apiClientProvider)));
