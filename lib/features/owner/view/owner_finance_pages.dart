import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/empty_state.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/finance_models.dart';
import '../viewmodel/owner_tools_viewmodels.dart';
import 'owner_appointment_page.dart' show paymentMethodLabel;

/// A Stripe-kifizetések (View): a kifizetések listája, a kiválasztott kifizetés tételei és összesítője.
class OwnerPayoutsPage extends ConsumerWidget {
  const OwnerPayoutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    final selected = ref.watch(selectedPayoutProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerPayouts)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<PayoutsOverview>(
              value: ref.watch(payoutsProvider(businessId)),
              onRetry: () => ref.invalidate(payoutsProvider(businessId)),
              builder: (context, data) {
                if (!data.connected) return EmptyState(icon: Icons.account_balance_outlined, title: l10n.paymentStripeNotConnected);
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(payoutsProvider(businessId).future),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (data.payouts.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.account_balance_outlined),
                      for (final p in data.payouts)
                        Card(
                          color: (selected ?? data.selected) == p.id ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
                          child: ListTile(
                            leading: const Icon(Icons.account_balance_outlined),
                            title: Text(formatHuf(context, p.amountHuf)),
                            subtitle: Text([p.status, if (p.arrivalDate != null) formatDate(context, p.arrivalDate!)].join(' · ')),
                            onTap: () => ref.read(selectedPayoutProvider.notifier).select(p.id),
                          ),
                        ),
                      if (data.lines.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(l10n.payoutLines, style: theme.textTheme.titleMedium),
                        Text(
                          '${l10n.payoutGross(formatHuf(context, data.grossHuf))} · ${l10n.payoutFee(formatHuf(context, data.feeHuf))} · ${l10n.payoutNet(formatHuf(context, data.netHuf))}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        for (final l in data.lines)
                          Card(
                            child: ListTile(
                              dense: true,
                              title: Text(l.description ?? l.type),
                              subtitle: Text(
                                [
                                  if (l.created != null) formatDate(context, l.created!),
                                  l10n.payoutFee(formatHuf(context, l.feeHuf)),
                                ].join(' · '),
                              ),
                              trailing: Text(formatHuf(context, l.netHuf), style: theme.textTheme.titleSmall),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

/// Kimaradt számlák / nyugták (View): újrapróbálás egy koppintással.
class OwnerMissingDocumentsPage extends ConsumerWidget {
  const OwnerMissingDocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, missingDocumentsActionsProvider.select((s) => s.flash));
    final busy = ref.watch(missingDocumentsActionsProvider.select((s) => s.busy));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerMissingDocuments)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<List<MissingDocument>>(
              value: ref.watch(missingDocumentsProvider(businessId)),
              onRetry: () => ref.invalidate(missingDocumentsProvider(businessId)),
              builder: (context, docs) => RefreshIndicator(
                onRefresh: () => ref.refresh(missingDocumentsProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (docs.isEmpty) EmptyNote(l10n.missingDocumentsNone, icon: Icons.check_circle_outline),
                    for (final d in docs)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                          title: Text([?d.customer, ?d.description].join(' · ')),
                          subtitle: Text(
                            [
                              if (d.date != null) formatDate(context, d.date!),
                              formatHuf(context, d.amountHuf),
                              if (d.paymentMethod != null) paymentMethodLabel(l10n, d.paymentMethod),
                            ].join(' · '),
                          ),
                          trailing: FilledButton.tonal(
                            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                            onPressed: busy ? null : () => ref.read(missingDocumentsActionsProvider.notifier).retry(businessId, d.key),
                            child: Text(l10n.retry),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
