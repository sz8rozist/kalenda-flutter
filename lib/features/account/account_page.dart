import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/async_view.dart';
import '../../shared/format.dart';
import 'account_models.dart';
import 'account_repository.dart';

/// „Fiókom": profil szerkesztése, hűségpontok, bérletek, hírlevél-hozzájárulások, kijelentkezés.
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountTitle),
        actions: [
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: AsyncView<AccountOverview>(
        value: ref.watch(accountOverviewProvider),
        onRetry: () => ref.invalidate(accountOverviewProvider),
        builder: (context, data) => RefreshIndicator(
          onRefresh: () => ref.refresh(accountOverviewProvider.future),
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
            ],
          ),
        ),
      ),
    );
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
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(accountRepositoryProvider).updateProfile(name: _name.text.trim(), phone: _phone.text.trim());
      messenger.showSnackBar(SnackBar(content: Text(l10n.saved)));
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(errorText(context, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
              child: FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.save)),
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
      onChanged: (value) async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await ref.read(accountRepositoryProvider).setMarketingConsent(consent.businessId, value);
        } catch (e) {
          if (context.mounted) messenger.showSnackBar(SnackBar(content: Text(errorText(context, e))));
        }
      },
    );
  }
}
