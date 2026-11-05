import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../viewmodel/app_lock_viewmodel.dart';

/// Az egész app fölé kerülő zár (View): a háttérbe kerülést / visszatérést továbbítja a [AppLockViewModel]-nek, és
/// zárolt állapotban teljes képernyős zárképernyővel takarja az appot. A tartalom végig él (a navigáció nem vész el).
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final viewModel = ref.read(appLockProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused:
        viewModel.onBackgrounded();
      case AppLifecycleState.resumed:
        viewModel.onResumed();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(appLockProvider);

    return Stack(
      children: [
        widget.child,
        // Amíg a beállítás nem töltődött be, nem villantjuk fel a tartalmat.
        if (lock.isLoading) const Positioned.fill(child: ColoredBox(color: Colors.white)),
        if (lock.value?.locked ?? false) const Positioned.fill(child: _LockScreen()),
      ],
    );
  }
}

class _LockScreen extends ConsumerStatefulWidget {
  const _LockScreen();

  @override
  ConsumerState<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<_LockScreen> {
  @override
  void initState() {
    super.initState();
    // A zárképernyő megjelenésekor azonnal elindul az azonosítás.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(appLockProvider.notifier).unlock(AppLocalizations.of(context).unlockReason);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(appLockProvider).value;
    final viewModel = ref.read(appLockProvider.notifier);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64),
                const SizedBox(height: 16),
                Text(l10n.unlockTitle, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                if (state?.failed ?? false) ...[
                  const SizedBox(height: 8),
                  Text(l10n.unlockFailed, style: TextStyle(color: theme.colorScheme.error)),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.unlockButton),
                  onPressed: (state?.busy ?? false) ? null : () => viewModel.unlock(l10n.unlockReason),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: viewModel.signOutAndUnlock, child: Text(l10n.signOut)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
