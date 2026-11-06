import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/status_chip.dart';
import '../../app_lock/view/app_lock_settings.dart';
import '../../auth/viewmodel/customer_session_viewmodel.dart';
import '../model/account_models.dart';
import '../viewmodel/account_viewmodel.dart';

/// „Fiókom" (View): profil, hűségpontok, bérletek, hozzájárulások, kijelentkezés, fióktörlés.
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, accountActionsProvider.select((s) => s.flash));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountTitle),
        actions: [
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(customerSessionProvider.notifier).signOut(),
          ),
        ],
      ),
      body: AsyncView<AccountOverview>(
        value: ref.watch(accountViewModelProvider),
        onRetry: () => ref.invalidate(accountViewModelProvider),
        builder: (context, data) => RefreshIndicator(
          onRefresh: () => ref.refresh(accountViewModelProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileCard(profile: data.profile),
              const SizedBox(height: 24),
              _Heading(l10n.loyaltyTitle),
              if (data.loyalty.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.stars_rounded),
              for (final item in data.loyalty) _LoyaltyTile(item: item),
              const SizedBox(height: 24),
              _Heading(l10n.passesTitle),
              if (data.passes.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.confirmation_number_outlined),
              for (final pass in data.passes) _PassTile(pass: pass),
              const SizedBox(height: 24),
              if (data.consents.isNotEmpty) ...[
                _Heading(l10n.consentsTitle),
                for (final consent in data.consents) _ConsentTile(consent: consent),
              ],
              const SizedBox(height: 24),
              const AppLockTile(),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.deleteAccount),
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A megerősítő párbeszéd a View dolga; a törlést a ViewModel végzi.
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmAlert(
      context,
      title: l10n.deleteAccountTitle,
      message: l10n.deleteAccountText,
      confirmLabel: l10n.deleteAccount,
      destructive: true,
      icon: Icons.delete_forever_outlined,
    );
    if (confirmed) await ref.read(accountActionsProvider.notifier).deleteAccount();
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _ProfileCard extends ConsumerStatefulWidget {
  const _ProfileCard({required this.profile});

  final AccountProfile profile;

  @override
  ConsumerState<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<_ProfileCard> {
  late final _name = TextEditingController(text: widget.profile.name);
  late final _phone = TextEditingController(text: widget.profile.phone ?? '');

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(accountActionsProvider.select((s) => s.busy));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    widget.profile.name.isEmpty ? '?' : widget.profile.name.characters.first.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.profile.name, style: Theme.of(context).textTheme.titleMedium),
                      Text(widget.profile.email, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.name),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.phone),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () => ref.read(accountActionsProvider.notifier).updateProfile(name: _name.text.trim(), phone: _phone.text.trim()),
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoyaltyTile extends StatelessWidget {
  const _LoyaltyTile({required this.item});

  final LoyaltyItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reward = (item.rewardPoints != null && item.rewardValueHuf != null)
        ? l10n.loyaltyReward(item.rewardPoints!, formatHuf(context, item.rewardValueHuf!))
        : null;

    return Card(
      child: ListTile(
        leading: const _TileIcon(Icons.stars_rounded),
        title: Text(item.business),
        subtitle: reward == null ? null : Text(reward),
        trailing: Text(l10n.loyaltyBalance(item.balance)),
        onTap: item.businessSlug.isEmpty ? null : () => context.push('/b/${item.businessSlug}'),
      ),
    );
  }
}

class _PassTile extends StatelessWidget {
  const _PassTile({required this.pass});

  final PassItem pass;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final details = [
      if (pass.sessionsRemaining != null) l10n.sessionsLeft(pass.sessionsRemaining!),
      if (pass.balanceHuf != null) l10n.balanceLeft(formatHuf(context, pass.balanceHuf!)),
      if (pass.expiresAt != null) l10n.expiresOn(pass.expiresAt!),
      if (pass.code != null) pass.code!,
    ];

    return Card(
      child: ListTile(
        leading: const _TileIcon(Icons.confirmation_number_outlined),
        title: Text('${pass.business} – ${pass.name}'),
        subtitle: Text(details.join(' · ')),
        trailing: pass.expired ? StatusChip('cancelled', label: l10n.expired) : null,
      ),
    );
  }
}

class _ConsentTile extends ConsumerWidget {
  const _ConsentTile({required this.consent});

  final ConsentItem consent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(consent.business),
      value: consent.marketingConsent,
      onChanged: (value) => ref.read(accountActionsProvider.notifier).setMarketingConsent(consent.businessId, value),
    );
  }
}

/// Lekerekített, halvány hátterű ikon a listaelemek elején.
class _TileIcon extends StatelessWidget {
  const _TileIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color),
    );
  }
}
