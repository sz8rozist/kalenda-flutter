import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
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
              if (data.loyalty.isEmpty) Text(l10n.nothingYet),
              for (final item in data.loyalty) _LoyaltyTile(item: item),
              const SizedBox(height: 24),
              _Heading(l10n.passesTitle),
              if (data.passes.isEmpty) Text(l10n.nothingYet),
              for (final pass in data.passes) _PassTile(pass: pass),
              const SizedBox(height: 24),
              if (data.consents.isNotEmpty) ...[
                _Heading(l10n.consentsTitle),
                for (final consent in data.consents) _ConsentTile(consent: consent),
              ],
              const SizedBox(height: 24),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.no)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.deleteAccount)),
        ],
      ),
    );
    if (confirmed == true) await ref.read(accountActionsProvider.notifier).deleteAccount();
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
            _Heading(l10n.profile),
            Text(widget.profile.email),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.name, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.phone, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () => ref
                        .read(accountActionsProvider.notifier)
                        .updateProfile(name: _name.text.trim(), phone: _phone.text.trim()),
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
        title: Text('${pass.business} – ${pass.name}'),
        subtitle: Text(details.join(' · ')),
        trailing: pass.expired ? Text(l10n.expired) : null,
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
