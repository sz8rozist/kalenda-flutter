import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/format.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/business_info.dart';
import '../viewmodel/owner_tools_viewmodels.dart';

/// Egy menüpont a vállalkozói „Továbbiak" oldalon. A `feature` a csomag-funkció kulcsa (null: mindig elérhető).
class OwnerMenuItem {
  const OwnerMenuItem(this.route, this.icon, this.label, {this.feature});

  final String route;
  final IconData icon;
  final String Function(AppLocalizations l10n) label;
  final String? feature;
}

class OwnerMenuGroup {
  const OwnerMenuGroup(this.title, this.items);

  final String Function(AppLocalizations l10n) title;
  final List<OwnerMenuItem> items;
}

/// A menü felépítése: új oldal felvételekor itt kell egy sort hozzáadni.
final ownerMenu = <OwnerMenuGroup>[
  OwnerMenuGroup((l) => l.menuGroupBooking, [
    OwnerMenuItem('/owner/services', Icons.content_cut_rounded, (l) => l.ownerServices),
    OwnerMenuItem('/owner/staff', Icons.badge_outlined, (l) => l.ownerStaff),
    OwnerMenuItem('/owner/waitlist', Icons.hourglass_empty_rounded, (l) => l.ownerWaitlist, feature: 'waitlist'),
    OwnerMenuItem('/owner/reviews', Icons.star_outline_rounded, (l) => l.ownerReviews, feature: 'reviews'),
  ]),
  OwnerMenuGroup((l) => l.menuGroupSales, [
    OwnerMenuItem('/owner/passes', Icons.confirmation_number_outlined, (l) => l.ownerPasses, feature: 'passes'),
  ]),
  OwnerMenuGroup((l) => l.menuGroupFinance, [
    OwnerMenuItem('/owner/expenses', Icons.receipt_long_outlined, (l) => l.ownerExpenses, feature: 'expenses'),
  ]),
  OwnerMenuGroup((l) => l.menuGroupOperations, [
    OwnerMenuItem('/owner/activity', Icons.history_rounded, (l) => l.ownerActivityLog, feature: 'activity_log'),
  ]),
  OwnerMenuGroup((l) => l.menuGroupSettings, [
    OwnerMenuItem('/owner/hours', Icons.schedule_rounded, (l) => l.ownerHours),
    OwnerMenuItem('/owner/leaves', Icons.beach_access_outlined, (l) => l.ownerLeaves),
  ]),
];

/// A vállalkozói „Továbbiak" oldal (View): csoportosított menü, a csomagban nem szereplő funkciók lezárva;
/// felül a csomag állapota (az előfizetés kezelése a webes felületen történik).
class OwnerMorePage extends ConsumerWidget {
  const OwnerMorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerMore)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<BusinessInfo>(
              value: ref.watch(businessInfoProvider(businessId)),
              onRetry: () => ref.invalidate(businessInfoProvider(businessId)),
              builder: (context, info) => RefreshIndicator(
                onRefresh: () => ref.refresh(businessInfoProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.all(AppDimens.pagePadding),
                  children: [
                    _PlanCard(info: info),
                    for (final group in ownerMenu) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        child: Text(group.title(l10n), style: Theme.of(context).textTheme.titleSmall),
                      ),
                      for (final item in group.items) _MenuTile(item: item, enabled: info.hasFeature(item.feature)),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

String planLabel(AppLocalizations l10n, String plan) => switch (plan) {
  'basic' => l10n.planBasic,
  'professional' => l10n.planProfessional,
  _ => l10n.planTrial,
};

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.info});

  final BusinessInfo info;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => context.push('/owner/subscription'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (info.locked ? AppColors.danger : theme.colorScheme.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  info.locked ? Icons.lock_outline : Icons.workspace_premium_outlined,
                  color: info.locked ? AppColors.danger : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.planName(planLabel(l10n, info.plan)), style: theme.textTheme.titleSmall),
                    if (info.locked)
                      Text(l10n.subscriptionLocked, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.danger))
                    else if (info.plan == 'trial' && info.trialDaysLeft != null)
                      Text(l10n.trialDaysLeft(info.trialDaysLeft!), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item, required this.enabled});

  final OwnerMenuItem item;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        enabled: enabled,
        leading: Icon(item.icon, color: enabled ? theme.colorScheme.primary : theme.disabledColor),
        title: Text(item.label(l10n)),
        subtitle: enabled ? null : Text(l10n.menuNotInPlan),
        trailing: Icon(enabled ? Icons.chevron_right_rounded : Icons.lock_outline, size: 20),
        onTap: enabled ? () => context.push(item.route) : null,
      ),
    );
  }
}

/// Az előfizetés állapota (View) – csak olvasható; a vásárlás és a módosítás a webes felületen történik.
class OwnerSubscriptionPage extends ConsumerWidget {
  const OwnerSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.subscriptionTitle)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<BusinessInfo>(
              value: ref.watch(businessInfoProvider(businessId)),
              onRetry: () => ref.invalidate(businessInfoProvider(businessId)),
              builder: (context, info) {
                final state = ref.watch(subscriptionStateProvider(businessId)).value;
                final features = info.planFeatures.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

                return ListView(
                  padding: const EdgeInsets.all(AppDimens.pagePadding),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.planName(planLabel(l10n, info.plan)), style: theme.textTheme.titleLarge),
                            const SizedBox(height: 8),
                            if (info.locked)
                              Text(l10n.subscriptionLocked, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.danger)),
                            if (info.plan == 'trial' && info.trialDaysLeft != null) Text(l10n.trialDaysLeft(info.trialDaysLeft!)),
                            if (state?.currentPeriodEnd != null)
                              Text(l10n.subscriptionRenewsOn(formatDate(context, state!.currentPeriodEnd!))),
                            if (state?.cancelAtPeriodEnd ?? false) Text(l10n.subscriptionCancelsAtEnd),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(child: Text(l10n.subscriptionManageOnWeb, style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(l10n.openWebApp),
                      onPressed: () => launchUrl(Uri.parse(AppConfig.webBaseUrl), mode: LaunchMode.externalApplication),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.subscriptionFeatures, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    for (final f in features)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          f.value ? Icons.check_circle_rounded : Icons.remove_circle_outline,
                          color: f.value ? AppColors.success : theme.disabledColor,
                        ),
                        title: Text(f.key),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
