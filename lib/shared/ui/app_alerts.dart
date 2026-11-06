import 'package:flutter/material.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'haptics.dart';

enum AlertKind { success, info, warning, error }

extension on AlertKind {
  Color get color => switch (this) {
    AlertKind.success => AppColors.success,
    AlertKind.info => AppColors.brand,
    AlertKind.warning => AppColors.warning,
    AlertKind.error => AppColors.danger,
  };

  IconData get icon => switch (this) {
    AlertKind.success => Icons.check_circle_rounded,
    AlertKind.info => Icons.info_rounded,
    AlertKind.warning => Icons.warning_amber_rounded,
    AlertKind.error => Icons.error_rounded,
  };
}

/// A hiba felhasználónak szánt leírása: cím, szöveg és ikon. A szerver üzenetét (pl. 422) megtartja, a többit emberi
/// nyelvre fordítja (nincs kapcsolat, szerverhiba, jogosultság…).
class ErrorInfo {
  const ErrorInfo({required this.title, required this.message, required this.icon, this.retryable = false});

  final String title;
  final String message;
  final IconData icon;

  /// Érdemes-e újrapróbálni (hálózati / szerverhiba).
  final bool retryable;
}

ErrorInfo describeError(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);

  if (error is ApiException) {
    if (error.isNetwork) {
      return ErrorInfo(title: l10n.errorTitleNetwork, message: l10n.errorNetworkText, icon: Icons.wifi_off_rounded, retryable: true);
    }

    final serverMessage = error.firstMessage;
    final status = error.statusCode ?? 0;

    if (status == 401) {
      return ErrorInfo(title: l10n.errorTitleSession, message: serverMessage ?? l10n.errorSessionText, icon: Icons.lock_clock_outlined);
    }
    if (status == 403) {
      return ErrorInfo(title: l10n.errorTitleDenied, message: serverMessage ?? l10n.genericError, icon: Icons.block_rounded);
    }
    if (status == 404) {
      return ErrorInfo(title: l10n.errorTitleNotFound, message: serverMessage ?? l10n.genericError, icon: Icons.search_off_rounded);
    }
    if (status == 422 || status == 400) {
      return ErrorInfo(title: l10n.errorTitleValidation, message: serverMessage ?? l10n.genericError, icon: Icons.edit_note_rounded);
    }
    if (status == 429) {
      return ErrorInfo(title: l10n.errorTitleTooMany, message: serverMessage ?? l10n.errorTooManyText, icon: Icons.hourglass_top_rounded);
    }
    if (status >= 500) {
      return ErrorInfo(title: l10n.errorTitleServer, message: l10n.errorServerText, icon: Icons.cloud_off_rounded, retryable: true);
    }
    return ErrorInfo(title: l10n.errorTitleGeneric, message: serverMessage ?? l10n.genericError, icon: Icons.error_outline_rounded);
  }

  return ErrorInfo(title: l10n.errorTitleGeneric, message: l10n.genericError, icon: Icons.error_outline_rounded);
}

/// Hiba-alert (párbeszéd): ikon, cím, érthető szöveg, „Rendben" – és ha érdemes, „Újra" gomb.
Future<void> showErrorAlert(BuildContext context, Object error, {VoidCallback? onRetry}) {
  final info = describeError(context, error);
  final l10n = AppLocalizations.of(context);

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: scheme.error.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(info.icon, color: scheme.error, size: 28),
        ),
        title: Text(info.title, textAlign: TextAlign.center),
        content: Text(info.message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowDirection: VerticalDirection.down,
        actions: [
          if (onRetry != null && info.retryable)
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onRetry();
              },
              child: Text(l10n.retry),
            ),
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.ok)),
        ],
      );
    },
  );
}

/// Rövid, lebegő visszajelzés (toast): színes ikon + szöveg. Siker / információ / figyelmeztetés.
void showToast(BuildContext context, String message, {AlertKind kind = AlertKind.success}) {
  if (kind == AlertKind.error) {
    Haptics.error();
  } else if (kind == AlertKind.success) {
    Haptics.light();
  }
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
        content: Row(
          children: [
            Icon(kind.icon, color: kind.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
}

/// Megerősítő alert (pl. törlés, lemondás). Igazat ad, ha a felhasználó megerősítette.
Future<bool> showConfirmAlert(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      final color = destructive ? scheme.error : scheme.primary;
      return AlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(cancelLabel ?? l10n.no)),
          FilledButton(
            style: destructive ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError) : null,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
