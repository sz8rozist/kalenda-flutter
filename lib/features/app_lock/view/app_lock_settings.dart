import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../settings/view/language_tile.dart';
import '../../settings/view/theme_mode_tile.dart';
import '../viewmodel/app_lock_viewmodel.dart';

/// Kapcsoló az alkalmazászár (biometrikus azonosítás) be- és kikapcsolására (View-komponens).
class AppLockTile extends ConsumerWidget {
  const AppLockTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(appLockProvider).value;
    if (state == null) return const SizedBox.shrink();

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: const Icon(Icons.fingerprint),
      title: Text(l10n.appLockTitle),
      subtitle: Text(
        !state.supported ? l10n.appLockUnavailable : (state.failed ? l10n.unlockFailed : l10n.appLockSubtitle),
      ),
      value: state.enabled,
      onChanged: state.supported ? (value) => ref.read(appLockProvider.notifier).setEnabled(value, l10n.unlockReason) : null,
    );
  }
}

/// A beállítások lapja (munkatársi / vállalkozói felület): jelenleg az alkalmazászár kapcsolója.
Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).settingsTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const LanguageTile(),
            const ThemeModeTile(),
            const AppLockTile(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.manage_accounts_outlined),
              title: Text(AppLocalizations.of(context).accountSecurityTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/account/security');
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// A beállítások lapját nyitó gomb az AppBar-ban.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: AppLocalizations.of(context).settingsTitle,
        icon: const Icon(Icons.settings_outlined),
        onPressed: () => showSettingsSheet(context),
      );
}
