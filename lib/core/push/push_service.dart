import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../config.dart';
import '../providers.dart';

/// Push értesítések (FCM). Firebase-konfiguráció nélkül (nincs google-services.json / GoogleService-Info.plist)
/// az egész szolgáltatás csendben kikapcsolt marad – az app így Firebase nélkül is fut és épül.
///
/// Az engedélyt NEM indításkor kérjük, hanem az első foglalás után ([enableAfterBooking]); belépett ügyfélnél
/// a már megadott engedéllyel a token belépéskor regisztrálódik ([registerIfAllowed]).
class PushService {
  PushService(this._ref);

  final Ref _ref;
  bool _initialized = false;
  bool _available = false;
  int? _deviceId;
  StreamSubscription<String>? _refreshSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  /// A Firebase indítása; false, ha nincs konfigurálva.
  Future<bool> _ensureInitialized() async {
    if (_initialized) return _available;
    _initialized = true;
    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (e) {
      debugPrint('Push kikapcsolva (Firebase nincs konfigurálva): $e');
    }
    return _available;
  }

  /// Az első foglalás után: engedélykérés, majd a token regisztrálása.
  Future<void> enableAfterBooking() async {
    if (!await _ensureInitialized()) return;
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;
    await _register();
  }

  /// Belépéskor / indításkor: ha az engedély már megvan, a token (újra)regisztrálása.
  Future<void> registerIfAllowed() async {
    if (!await _ensureInitialized()) return;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _register();
    }
  }

  /// Az értesítésre koppintás: ha van foglalás-kezelő token, a foglalás megnyílik.
  Future<void> listenForTaps(GoRouter router) async {
    if (!await _ensureInitialized()) return;
    _openedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen((message) => _open(router, message));

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _open(router, initial);
  }

  void _open(GoRouter router, RemoteMessage message) {
    final token = message.data['manage_token'];
    if (token is String && token.isNotEmpty) router.push('/manage/$token');
  }

  Future<void> _register() async {
    // Az eszköz-regisztráció ügyfél-tokent kér: belépés előtt csak az engedélyt kértük, a token belépéskor megy fel.
    if (!(_ref.read(authControllerProvider).value ?? false)) return;

    // ignore: deprecated_member_use
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    await _send(token);

    // ignore: deprecated_member_use
    _refreshSubscription ??= FirebaseMessaging.instance.onTokenRefresh.listen(_send);
  }

  Future<void> _send(String token) async {
    try {
      final api = _ref.read(apiClientProvider);
      final response = await api.call((d) => d.post('/customer/devices', data: {
            'push_token': token,
            'platform': Platform.isIOS ? 'ios' : 'android',
            'app_version': AppConfig.appVersion,
          }));
      _deviceId = (response.data['id'] as num?)?.toInt();
    } catch (e) {
      debugPrint('Az eszköz regisztrálása sikertelen: $e');
    }
  }

  /// Kijelentkezés előtt: a szerver törli az eszközt a logouttal, itt csak a helyi állapotot nullázzuk.
  void reset() {
    _deviceId = null;
    _refreshSubscription?.cancel();
    _refreshSubscription = null;
  }

  int? get deviceId => _deviceId;
}

final pushServiceProvider = Provider<PushService>(PushService.new);
