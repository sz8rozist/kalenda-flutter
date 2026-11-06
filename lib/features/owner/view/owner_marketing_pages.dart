import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/status_chip.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/marketing_models.dart';
import '../model/owner_models.dart';
import '../viewmodel/marketing_viewmodels.dart';
import '../viewmodel/owner_service_viewmodels.dart';
import 'owner_appointment_page.dart' show paymentMethodLabel;

class _Frame extends ConsumerWidget {
  const _Frame({required this.title, required this.builder, this.fab});

  final String title;
  final Widget Function(BuildContext context, int businessId) builder;
  final Widget Function(BuildContext context, int businessId)? fab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, marketingActionsProvider.select((s) => s.flash));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: businessId == null ? null : fab?.call(context, businessId),
      body: businessId == null ? Center(child: Text(AppLocalizations.of(context).ownerNoBusiness)) : builder(context, businessId),
    );
  }
}

Future<void> _sheet(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: builder);

int? _int(TextEditingController c) => int.tryParse(c.text.trim());

// ─── Bérlet- és utalvány-típusok ───────────────────────────────

class OwnerPassTypesPage extends ConsumerWidget {
  const OwnerPassTypesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(marketingActionsProvider.notifier);

    return _Frame(
      title: l10n.ownerPassTypes,
      fab: (context, businessId) => FloatingActionButton.extended(
        onPressed: () => _sheet(context, (_) => _PassTypeSheet(businessId: businessId)),
        icon: const Icon(Icons.add),
        label: Text(l10n.newPassType),
      ),
      builder: (context, businessId) => AsyncView<List<PassType>>(
        value: ref.watch(passTypesProvider(businessId)),
        onRetry: () => ref.invalidate(passTypesProvider(businessId)),
        builder: (context, types) => RefreshIndicator(
          onRefresh: () => ref.refresh(passTypesProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (types.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.confirmation_number_outlined),
              for (final t in types)
                Card(
                  child: ListTile(
                    leading: Icon(t.isVoucher ? Icons.card_giftcard_rounded : Icons.confirmation_number_outlined),
                    title: Text(t.name),
                    subtitle: Text(
                      [
                        formatHuf(context, t.priceHuf),
                        if (t.isVoucher && t.valueHuf != null)
                          formatHuf(context, t.valueHuf!)
                        else if (t.sessionsCount != null)
                          l10n.sessionsLeft(t.sessionsCount!),
                        if (t.serviceName != null) t.serviceName!,
                        l10n.passTypeSoldCount(t.soldCount),
                        if (!t.isActive) l10n.passTypeInactive,
                      ].join(' · '),
                    ),
                    trailing: Switch(value: t.isActive, onChanged: (_) => actions.togglePassType(businessId, t.id)),
                    onTap: () => _sheet(context, (_) => _PassActionsSheet(businessId: businessId, type: t)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PassActionsSheet extends ConsumerStatefulWidget {
  const _PassActionsSheet({required this.businessId, required this.type});

  final int businessId;
  final PassType type;

  @override
  ConsumerState<_PassActionsSheet> createState() => _PassActionsSheetState();
}

class _PassActionsSheetState extends ConsumerState<_PassActionsSheet> {
  final _email = TextEditingController();
  final _recipient = TextEditingController();
  String _method = 'cash';

  @override
  void dispose() {
    _email.dispose();
    _recipient.dispose();
    super.dispose();
  }

  Future<void> _sell() async {
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(marketingActionsProvider.notifier)
        .sellPassType(
          widget.businessId,
          widget.type.id,
          paymentMethod: _method,
          purchaserEmail: _email.text,
          recipientName: _recipient.text,
        );
    if (ok) navigator.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showConfirmAlert(
      context,
      title: l10n.passTypeDeleteTitle,
      message: widget.type.name,
      confirmLabel: l10n.actionDelete,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed) return;
    final ok = await ref.read(marketingActionsProvider.notifier).deletePassType(widget.businessId, widget.type.id);
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(marketingActionsProvider.select((s) => s.busy));

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.type.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.passTypePurchaserEmail),
            ),
            if (widget.type.isVoucher) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _recipient,
                decoration: InputDecoration(labelText: l10n.passTypeRecipient),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _method,
              decoration: InputDecoration(labelText: l10n.payMethod),
              items: [
                for (final m in const ['cash', 'card', 'transfer', 'other'])
                  DropdownMenuItem(value: m, child: Text(paymentMethodLabel(l10n, m))),
              ],
              onChanged: (v) => setState(() => _method = v ?? 'cash'),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: busy || !widget.type.isActive ? null : _sell, child: Text(l10n.passTypeSell)),
            TextButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.actionDelete),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: busy ? null : _delete,
            ),
          ],
        ),
      ),
    );
  }
}

class _PassTypeSheet extends ConsumerStatefulWidget {
  const _PassTypeSheet({required this.businessId});

  final int businessId;

  @override
  ConsumerState<_PassTypeSheet> createState() => _PassTypeSheetState();
}

class _PassTypeSheetState extends ConsumerState<_PassTypeSheet> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _validity = TextEditingController(text: '365');
  final _sessions = TextEditingController(text: '10');
  final _value = TextEditingController();
  String _kind = 'pass';
  int? _serviceId;

  @override
  void dispose() {
    for (final c in [_name, _price, _validity, _sessions, _value]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final price = _int(_price);
    final validity = _int(_validity);
    if (_name.text.trim().isEmpty || price == null || validity == null) return;
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(marketingActionsProvider.notifier)
        .createPassType(
          widget.businessId,
          kind: _kind,
          name: _name.text.trim(),
          priceHuf: price,
          validityDays: validity,
          sessionsCount: _int(_sessions),
          valueHuf: _int(_value),
          serviceId: _serviceId,
        );
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(marketingActionsProvider.select((s) => s.busy));
    final services = ref.watch(ownerServicesProvider(widget.businessId)).value ?? const <OwnerService>[];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'pass', label: Text(l10n.passKindPass)),
                ButtonSegment(value: 'voucher', label: Text(l10n.passKindVoucher)),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.name),
            ),
            const SizedBox(height: 12),
            if (_kind == 'pass') ...[
              TextField(
                controller: _sessions,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.passTypeSessions),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _serviceId,
                decoration: InputDecoration(labelText: l10n.passTypeService),
                items: [
                  DropdownMenuItem<int?>(value: null, child: Text(l10n.passTypeAnyService)),
                  for (final s in services) DropdownMenuItem<int?>(value: s.id, child: Text(s.name)),
                ],
                onChanged: (v) => setState(() => _serviceId = v),
              ),
            ] else
              TextField(
                controller: _value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.passTypeValue),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.passTypePrice),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _validity,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.passTypeValidity),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}

// ─── Hűségprogram ──────────────────────────────────────────────

class OwnerLoyaltyPage extends ConsumerWidget {
  const OwnerLoyaltyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return _Frame(
      title: l10n.ownerLoyalty,
      builder: (context, businessId) => AsyncView<LoyaltyOverview>(
        value: ref.watch(loyaltyProvider(businessId)),
        onRetry: () => ref.invalidate(loyaltyProvider(businessId)),
        builder: (context, data) => RefreshIndicator(
          onRefresh: () => ref.refresh(loyaltyProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _LoyaltyForm(businessId: businessId, settings: data.settings),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(l10n.loyaltyMembers(data.members))),
                  Chip(label: Text(l10n.loyaltyOutstanding(data.outstandingPoints))),
                ],
              ),
              const SizedBox(height: 12),
              Text(l10n.loyaltyLeaderboard, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (data.leaderboard.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.stars_rounded),
              for (final (index, m) in data.leaderboard.indexed)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(m.name),
                    trailing: Text(l10n.loyaltyBalance(m.balance)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoyaltyForm extends ConsumerStatefulWidget {
  const _LoyaltyForm({required this.businessId, required this.settings});

  final int businessId;
  final LoyaltySettings settings;

  @override
  ConsumerState<_LoyaltyForm> createState() => _LoyaltyFormState();
}

class _LoyaltyFormState extends ConsumerState<_LoyaltyForm> {
  late bool _enabled = widget.settings.enabled;
  late final _per1000 = TextEditingController(text: '${widget.settings.pointsPer1000Huf}');
  late final _rewardPoints = TextEditingController(text: '${widget.settings.rewardPoints}');
  late final _rewardValue = TextEditingController(text: '${widget.settings.rewardValueHuf}');

  @override
  void dispose() {
    for (final c in [_per1000, _rewardPoints, _rewardValue]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(marketingActionsProvider.select((s) => s.busy));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.loyaltyEnabled),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            if (_enabled) ...[
              TextField(
                controller: _per1000,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.loyaltyPointsPer1000),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rewardPoints,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.loyaltyRewardPointsLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rewardValue,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.loyaltyRewardValueLabel),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
                onPressed: busy
                    ? null
                    : () => ref
                          .read(marketingActionsProvider.notifier)
                          .saveLoyalty(
                            widget.businessId,
                            LoyaltySettings(
                              enabled: _enabled,
                              pointsPer1000Huf: _int(_per1000) ?? 0,
                              rewardPoints: _int(_rewardPoints) ?? 0,
                              rewardValueHuf: _int(_rewardValue) ?? 0,
                            ),
                          ),
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Kampányok ─────────────────────────────────────────────────

class OwnerCampaignsPage extends ConsumerWidget {
  const OwnerCampaignsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return _Frame(
      title: l10n.ownerCampaigns,
      fab: (context, businessId) => FloatingActionButton.extended(
        onPressed: () => _sheet(context, (_) => _CampaignSheet(businessId: businessId)),
        icon: const Icon(Icons.add),
        label: Text(l10n.newCampaign),
      ),
      builder: (context, businessId) => AsyncView<CampaignListing>(
        value: ref.watch(campaignsProvider(businessId)),
        onRetry: () => ref.invalidate(campaignsProvider(businessId)),
        builder: (context, data) => RefreshIndicator(
          onRefresh: () => ref.refresh(campaignsProvider(businessId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text(l10n.campaignConsents(data.consentCount, data.dailyLimit), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              if (data.campaigns.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.campaign_outlined),
              for (final c in data.campaigns)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.campaign_outlined),
                    title: Text(c.name),
                    subtitle: Text(
                      [c.subject, if (c.sentAt != null) formatDateTime(context, c.sentAt!), if (!c.isDraft) '${c.recipients}'].join(' · '),
                    ),
                    trailing: StatusChip(
                      c.isDraft ? 'pending' : 'confirmed',
                      label: c.isDraft ? l10n.campaignStatusDraft : l10n.campaignStatusSent,
                    ),
                    onTap: () => _sheet(context, (_) => _CampaignSheet(businessId: businessId, campaign: c)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampaignSheet extends ConsumerStatefulWidget {
  const _CampaignSheet({required this.businessId, this.campaign});

  final int businessId;
  final Campaign? campaign;

  @override
  ConsumerState<_CampaignSheet> createState() => _CampaignSheetState();
}

class _CampaignSheetState extends ConsumerState<_CampaignSheet> {
  late final _name = TextEditingController(text: widget.campaign?.name ?? '');
  late final _subject = TextEditingController(text: widget.campaign?.subject ?? '');
  late final _body = TextEditingController(text: widget.campaign?.body ?? '');
  late final _days = TextEditingController(text: '${widget.campaign?.segment.days ?? 90}');
  late String _type = widget.campaign?.segment.type ?? 'all';
  late int? _serviceId = widget.campaign?.segment.serviceId;
  int? _audience;

  bool get _locked => widget.campaign != null && !widget.campaign!.isDraft;

  @override
  void initState() {
    super.initState();
    _refreshAudience();
  }

  @override
  void dispose() {
    for (final c in [_name, _subject, _body, _days]) {
      c.dispose();
    }
    super.dispose();
  }

  CampaignSegment get _segment => CampaignSegment(
    type: _type,
    days: (_type == 'inactive' || _type == 'new') ? (_int(_days) ?? 90) : null,
    serviceId: _type == 'service' ? _serviceId : null,
  );

  Future<void> _refreshAudience() async {
    if (_locked) return;
    final count = await ref.read(marketingActionsProvider.notifier).audienceCount(widget.businessId, _segment);
    if (mounted) setState(() => _audience = count);
  }

  Future<bool> _save() async {
    if (_name.text.trim().isEmpty || _subject.text.trim().isEmpty || _body.text.trim().isEmpty) return false;
    return ref
        .read(marketingActionsProvider.notifier)
        .saveCampaign(
          widget.businessId,
          id: widget.campaign?.id,
          name: _name.text.trim(),
          subject: _subject.text.trim(),
          body: _body.text.trim(),
          segment: _segment,
        );
  }

  Future<void> _saveAndClose() async {
    final navigator = Navigator.of(context);
    if (await _save()) navigator.pop();
  }

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context);
    final viewModel = ref.read(marketingActionsProvider.notifier);
    if (!await _save() || widget.campaign == null || !mounted) return;
    if (await viewModel.sendTest(widget.businessId, widget.campaign!.id) && mounted) {
      showToast(context, l10n.campaignTestSent(viewModel.lastTestSentTo ?? ''));
    }
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final viewModel = ref.read(marketingActionsProvider.notifier);
    final confirmed = await showConfirmAlert(
      context,
      title: l10n.campaignSend,
      message: l10n.campaignSendConfirm,
      confirmLabel: l10n.campaignSend,
      icon: Icons.send_outlined,
    );
    if (!confirmed || widget.campaign == null) return;
    if (await viewModel.send(widget.businessId, widget.campaign!.id)) {
      if (mounted) showToast(context, l10n.campaignSent(viewModel.lastRecipients ?? 0));
      navigator.pop();
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showConfirmAlert(
      context,
      title: l10n.campaignDeleteTitle,
      message: widget.campaign!.name,
      confirmLabel: l10n.actionDelete,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed) return;
    final ok = await ref.read(marketingActionsProvider.notifier).deleteCampaign(widget.businessId, widget.campaign!.id);
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(marketingActionsProvider.select((s) => s.busy));
    final services = ref.watch(ownerServicesProvider(widget.businessId)).value ?? const <OwnerService>[];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              enabled: !_locked,
              decoration: InputDecoration(labelText: l10n.campaignName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subject,
              enabled: !_locked,
              decoration: InputDecoration(labelText: l10n.campaignSubject),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _body,
              enabled: !_locked,
              maxLines: 6,
              decoration: InputDecoration(labelText: l10n.campaignBody),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.campaignSegmentLabel),
              items: [
                DropdownMenuItem(value: 'all', child: Text(l10n.segAll)),
                DropdownMenuItem(value: 'inactive', child: Text(l10n.segInactive)),
                DropdownMenuItem(value: 'new', child: Text(l10n.segNew)),
                DropdownMenuItem(value: 'service', child: Text(l10n.segService)),
                DropdownMenuItem(value: 'loyalty_reward', child: Text(l10n.segLoyalty)),
              ],
              onChanged: _locked
                  ? null
                  : (v) {
                      setState(() => _type = v ?? 'all');
                      _refreshAudience();
                    },
            ),
            if (_type == 'inactive' || _type == 'new') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _days,
                enabled: !_locked,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _refreshAudience(),
                decoration: InputDecoration(labelText: l10n.segDays),
              ),
            ],
            if (_type == 'service') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _serviceId,
                decoration: InputDecoration(labelText: l10n.ownerServices),
                items: [for (final s in services) DropdownMenuItem(value: s.id, child: Text(s.name))],
                onChanged: _locked
                    ? null
                    : (v) {
                        setState(() => _serviceId = v);
                        _refreshAudience();
                      },
              ),
            ],
            if (_audience != null && !_locked)
              Padding(padding: const EdgeInsets.only(top: 8), child: Text(l10n.campaignAudience(_audience!))),
            const SizedBox(height: 16),
            if (!_locked) FilledButton(onPressed: busy ? null : _saveAndClose, child: Text(l10n.save)),
            if (widget.campaign != null && !_locked) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.mark_email_read_outlined),
                label: Text(l10n.campaignSendTest),
                onPressed: busy ? null : _test,
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(icon: const Icon(Icons.send_outlined), label: Text(l10n.campaignSend), onPressed: busy ? null : _send),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.actionDelete),
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                onPressed: busy ? null : _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
