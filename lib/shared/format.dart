import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../core/api/api_exception.dart';
import '../l10n/app_localizations.dart';

/// Ft összeg ezres tagolással a nyelv szerint.
String formatHuf(BuildContext context, int amount) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  return l10n.priceHuf(NumberFormat.decimalPattern(locale).format(amount));
}

String formatDateTime(BuildContext context, DateTime value) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_Hm().format(value);

String formatDate(BuildContext context, DateTime value) =>
    DateFormat.yMMMEd(Localizations.localeOf(context).toString()).format(value);

/// Az `ApiException` felhasználónak szánt szövege.
String errorText(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  if (error is ApiException) {
    if (error.isNetwork) return l10n.networkError;
    return error.firstMessage ?? l10n.genericError;
  }
  return l10n.genericError;
}

/// A foglalás / szabadság állapotának felirata.
String statusLabel(BuildContext context, String status) {
  final l10n = AppLocalizations.of(context);
  return switch (status) {
    'pending' => l10n.statusPending,
    'confirmed' => l10n.statusConfirmed,
    'cancelled' => l10n.statusCancelled,
    'completed' => l10n.statusCompleted,
    'no_show' => l10n.statusNoShow,
    'approved' => l10n.statusApproved,
    'rejected' => l10n.statusRejected,
    _ => status,
  };
}

String formatTime(BuildContext context, DateTime value) =>
    DateFormat.Hm(Localizations.localeOf(context).toString()).format(value);

