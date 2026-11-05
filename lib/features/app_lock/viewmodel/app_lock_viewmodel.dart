import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/token_store.dart';
import '../../../core/providers.dart';
import '../../auth/viewmodel/customer_session_viewmodel.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../data/app_lock_repository.dart';

/// Az alkalmazászár állapota.
class AppLockState {
  const AppLockState({this.enabled = false, this.supported = false, this.locked = false, this.busy = false, this.failed = false});

  /// A felhasználó bekapcsolta a zárat.
  final bool enabled;

  /// Az eszköz támogat biometrikus azonosítót / képernyőzárat.
  final bool supported;

  /// Jelenleg zárolva van (a zárképernyő látszik).
  final bool locked;
  final bool busy;

  /// Az utolsó azonosítás nem sikerült.
  final bool failed;

  AppLockState copyWith({bool? enabled, bool? supported, bool? locked, bool? busy, bool? failed}) => AppLockState(
        enabled: enabled ?? this.enabled,
        supported: supported ?? this.supported,
        locked: locked ?? this.locked,
        busy: busy ?? this.busy,
        failed: failed ?? this.failed,
      );
}

/// Alkalmazászár biometrikus azonosítással: bekapcsolva, belépett fiók mellett az app indításkor és a háttérből való
/// visszatéréskor (rövid türelmi idő után) zárolva van, feloldásig nem látszik semmi.
class AppLockViewModel extends AsyncNotifier<AppLockState> {
  /// Ennyi ideig lehet a háttérben zárolás nélkül (pl. egy másik app megnyitása erejéig).
  static const gracePeriod = Duration(seconds: 30);

  DateTime? _backgroundedAt;

  @override
  Future<AppLockState> build() async {
    final repository = ref.read(appLockRepositoryProvider);
    final enabled = await repository.isEnabled();
    final supported = await repository.isSupported();

    // Indításkor zárolt, ha be van kapcsolva, támogatott, és van belépett fiók.
    final locked = enabled && supported && await _hasSession();
    return AppLockState(enabled: enabled, supported: supported, locked: locked);
  }

  Future<bool> _hasSession() async {
    final store = ref.read(tokenStoreProvider);
    return await store.read(TokenKind.customer) != null || await store.read(TokenKind.staff) != null;
  }

  /// Az app a háttérbe került.
  void onBackgrounded() => _backgroundedAt = DateTime.now();

  /// Az app visszatért a háttérből: a türelmi idő letelte után zárol.
  Future<void> onResumed() async {
    final current = state.value;
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (current == null || since == null || !current.enabled || !current.supported || current.locked) return;

    if (DateTime.now().difference(since) >= gracePeriod && await _hasSession()) {
      state = AsyncData(current.copyWith(locked: true, failed: false));
    }
  }

  /// Feloldás a rendszer azonosításával.
  Future<void> unlock(String reason) async {
    final current = state.value;
    if (current == null || !current.locked || current.busy) return;

    state = AsyncData(current.copyWith(busy: true, failed: false));
    final ok = await ref.read(appLockRepositoryProvider).authenticate(reason);
    state = AsyncData(state.value!.copyWith(busy: false, locked: !ok, failed: !ok));
  }

  /// Kiút, ha az azonosítás nem működik (pl. megváltozott az eszköz zárja): kijelentkezés minden fiókból, a zár feloldódik.
  Future<void> signOutAndUnlock() async {
    await ref.read(customerSessionProvider.notifier).signOut();
    await ref.read(staffSessionProvider.notifier).signOut();
    final current = state.value;
    if (current != null) state = AsyncData(current.copyWith(locked: false, failed: false));
  }

  /// Bekapcsolás előtt azonosítunk (hogy bizonyosan működjön); kikapcsolás azonnali.
  Future<void> setEnabled(bool value, String reason) async {
    final current = state.value;
    if (current == null) return;
    final repository = ref.read(appLockRepositoryProvider);

    if (value) {
      if (!current.supported || !await repository.authenticate(reason)) {
        state = AsyncData(current.copyWith(failed: true));
        return;
      }
    }
    await repository.setEnabled(value);
    state = AsyncData(current.copyWith(enabled: value, locked: false, failed: false));
  }
}

final appLockProvider = AsyncNotifierProvider<AppLockViewModel, AppLockState>(AppLockViewModel.new);
