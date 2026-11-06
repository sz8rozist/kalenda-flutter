import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/storage/local_prefs.dart';
import '../../../core/providers.dart';
import '../model/account_models.dart';

/// Az ügyfélfiók adatai (`/customer/account`, `/customer/consents`).
class AccountRepository {
  AccountRepository(this._api, [this._prefs]);

  final ApiClient _api;
  final Future<SharedPreferences?> Function()? _prefs;

  static const _cacheKey = 'account_overview_cache';

  /// A fiók áttekintése. Sikeres lekérdezés után elmentjük az eszközre; ha nincs hálózat, az utolsó mentett
  /// állapotot adjuk vissza, hogy a foglalások offline is láthatók legyenek.
  Future<AccountOverview> overview() async {
    try {
      final response = await _api.call((d) => d.get('/customer/account'));
      final data = response.data as Map<String, dynamic>;
      await _save(data);
      return AccountOverview.fromJson(data);
    } on ApiException catch (e) {
      if (!e.isNetwork) rethrow;
      final cached = await _load();
      if (cached == null) rethrow;
      return cached;
    }
  }

  Future<void> _save(Map<String, dynamic> data) async {
    try {
      final prefs = await _prefs?.call();
      await prefs?.setString(_cacheKey, jsonEncode(data));
    } catch (_) {
      // A gyorsítótár csak segítség, a mentés hibája nem állhat a lekérdezés útjába.
    }
  }

  Future<AccountOverview?> _load() async {
    try {
      final raw = (await _prefs?.call())?.getString(_cacheKey);
      return raw == null ? null : AccountOverview.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile({required String name, String? phone}) =>
      _api.call((d) => d.patch('/customer/account', data: {'name': name, 'phone': phone ?? ''}));

  Future<void> setMarketingConsent(int businessId, bool value) =>
      _api.call((d) => d.put('/customer/consents/$businessId', data: {'marketing_consent': value}));
}

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(apiClientProvider), () => ref.read(localPrefsProvider.future)),
);
