import '../api/api_client.dart';
import '../config.dart';

/// Az eszköz push-tokenjének regisztrálása az ügyfélfiókhoz (`POST /customer/devices`).
class DeviceRepository {
  DeviceRepository(this._api);

  final ApiClient _api;

  /// A regisztrált eszköz azonosítója.
  Future<int?> register({required String pushToken, required String platform}) async {
    final response = await _api.call((d) => d.post('/customer/devices', data: {
          'push_token': pushToken,
          'platform': platform,
          'app_version': AppConfig.appVersion,
        }));
    return (response.data['id'] as num?)?.toInt();
  }
}
