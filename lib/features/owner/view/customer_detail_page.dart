import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/step_section.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/customer_detail.dart';
import '../viewmodel/owner_manage_viewmodels.dart';

/// Egy ügyfél adatlapja a vállalkozónak (View): statisztika, belső megjegyzés, számlázási adatok, hűségpontok.
class CustomerDetailPage extends ConsumerWidget {
  const CustomerDetailPage({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customerDetailsTitle)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<CustomerDetail>(
              value: ref.watch(customerDetailProvider((businessId: businessId, customerId: customerId))),
              onRetry: () => ref.invalidate(customerDetailProvider((businessId: businessId, customerId: customerId))),
              builder: (context, detail) => _Content(keyOf: (businessId: businessId, customerId: customerId), detail: detail),
            ),
    );
  }
}

class _Content extends ConsumerStatefulWidget {
  const _Content({required this.keyOf, required this.detail});

  final CustomerKey keyOf;
  final CustomerDetail detail;

  @override
  ConsumerState<_Content> createState() => _ContentState();
}

class _ContentState extends ConsumerState<_Content> {
  late final _note = TextEditingController(text: widget.detail.internalNote ?? '');
  late final _postCode = TextEditingController(text: widget.detail.billingPostCode ?? '');
  late final _city = TextEditingController(text: widget.detail.billingCity ?? '');
  late final _address = TextEditingController(text: widget.detail.billingAddress ?? '');
  late final _tax = TextEditingController(text: widget.detail.billingTaxNumber ?? '');
  late final _billingEmail = TextEditingController(text: widget.detail.billingEmail ?? '');
  late bool _depositExempt = widget.detail.depositExempt;
  late bool _marketing = widget.detail.marketingConsent;

  @override
  void dispose() {
    for (final c in [_note, _postCode, _city, _address, _tax, _billingEmail]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveProfile() => ref
      .read(customerActionsProvider.notifier)
      .saveProfile(
        widget.keyOf,
        depositExempt: _depositExempt,
        internalNote: _note.text,
        marketingConsent: widget.detail.hasCampaigns ? _marketing : null,
        billingPostCode: _postCode.text,
        billingCity: _city.text,
        billingAddress: _address.text,
        billingTaxNumber: _tax.text,
        billingEmail: _billingEmail.text,
      );

  Future<void> _adjust() async {
    final l10n = AppLocalizations.of(context);
    final points = TextEditingController();
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.loyaltyAdjust),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: points,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              decoration: InputDecoration(labelText: l10n.loyaltyAdjustPoints),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: note,
              decoration: InputDecoration(labelText: l10n.notes),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.dialogCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.save)),
        ],
      ),
    );
    final value = int.tryParse(points.text.trim());
    final text = note.text.trim();
    points.dispose();
    note.dispose();
    if (confirmed != true || value == null || value == 0 || text.isEmpty) return;
    await ref.read(customerActionsProvider.notifier).adjustLoyalty(widget.keyOf, points: value, note: text);
  }

  Future<void> _redeem() async {
    final l10n = AppLocalizations.of(context);
    final viewModel = ref.read(customerActionsProvider.notifier);
    if (await viewModel.redeem(widget.keyOf) && mounted) {
      showToast(context, l10n.loyaltyRedeemed(formatHuf(context, viewModel.lastRedeemedDiscountHuf ?? 0)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final d = widget.detail;
    listenFlash(ref, context, customerActionsProvider.select((s) => s.flash));
    final busy = ref.watch(customerActionsProvider.select((s) => s.busy));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(customerDetailProvider(widget.keyOf).future),
      child: ListView(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Text(
                  d.name.isEmpty ? '?' : d.name.characters.first.toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name, style: theme.textTheme.titleLarge),
                    if (d.email != null) Text(d.email!, style: theme.textTheme.bodySmall),
                    if (d.phone != null) Text(d.phone!, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (d.phone != null && d.phone!.isNotEmpty)
                IconButton.filledTonal(
                  tooltip: l10n.call,
                  icon: const Icon(Icons.phone_outlined),
                  onPressed: () => launchUrl(Uri(scheme: 'tel', path: d.phone)),
                ),
            ],
          ),
          if (d.noShowFlagged) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l10n.customerNoShowFlag)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Stat(label: l10n.customerBookings, value: '${d.total}'),
              _Stat(label: l10n.customerCompleted, value: '${d.completed}'),
              _Stat(label: l10n.customerCancelled, value: '${d.cancelled}'),
              _Stat(label: l10n.customerNoShows, value: '${d.noShow}'),
              _Stat(label: l10n.customerSpent, value: formatHuf(context, d.totalSpentHuf)),
            ],
          ),
          const SizedBox(height: 24),
          StepSection(
            number: 1,
            title: l10n.customerNote,
            child: Column(
              children: [
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.customerNote),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.customerDepositExempt),
                  value: _depositExempt,
                  onChanged: (v) => setState(() => _depositExempt = v),
                ),
                if (d.hasCampaigns)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.marketingConsent),
                    value: _marketing,
                    onChanged: (v) => setState(() => _marketing = v),
                  ),
              ],
            ),
          ),
          StepSection(
            number: 2,
            title: l10n.billingTitle,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _postCode,
                        decoration: InputDecoration(labelText: l10n.billingPostCode),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _city,
                        decoration: InputDecoration(labelText: l10n.billingCity),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _address,
                  decoration: InputDecoration(labelText: l10n.fieldAddress),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tax,
                  decoration: InputDecoration(labelText: l10n.billingTaxNumber),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _billingEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: l10n.billingEmail),
                ),
              ],
            ),
          ),
          FilledButton(onPressed: busy ? null : _saveProfile, child: Text(l10n.save)),
          const SizedBox(height: 28),
          StepSection(
            number: 3,
            title: l10n.loyaltyTitleOwner,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.loyaltyBalance(d.loyaltyBalance), style: theme.textTheme.titleMedium),
                if (d.hasLoyaltyReward)
                  Text(
                    l10n.loyaltyReward(d.loyaltyRewardPoints!, formatHuf(context, d.loyaltyRewardValueHuf ?? 0)),
                    style: theme.textTheme.bodySmall,
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(onPressed: busy ? null : _adjust, child: Text(l10n.loyaltyAdjust)),
                    ),
                    if (d.hasLoyaltyReward) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(onPressed: busy || !d.canRedeem ? null : _redeem, child: Text(l10n.loyaltyRedeem)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(l10n.loyaltyHistory, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                if (d.loyaltyTransactions.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.stars_rounded),
                for (final t in d.loyaltyTransactions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text([if (t.reason != null) t.reason!, if (t.note != null && t.note!.isNotEmpty) t.note!].join(' · ')),
                    subtitle: t.createdAt == null ? null : Text(formatDateTime(context, t.createdAt!)),
                    trailing: Text(
                      t.points > 0 ? '+${t.points}' : '${t.points}',
                      style: theme.textTheme.titleSmall?.copyWith(color: t.points >= 0 ? AppColors.success : AppColors.danger),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
