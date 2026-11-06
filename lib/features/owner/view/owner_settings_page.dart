import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/app_image.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/business_info.dart';
import '../model/settings_models.dart';
import '../viewmodel/owner_tools_viewmodels.dart';
import '../viewmodel/settings_viewmodels.dart';

int? _int(TextEditingController c) => int.tryParse(c.text.trim());

/// A vállalkozás beállításai (View): szakaszonként nyíló kártyák, mindegyiknek saját mentés-gombja.
class OwnerSettingsPage extends ConsumerWidget {
  const OwnerSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;
    listenFlash(ref, context, settingsActionsProvider.select((s) => s.flash));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerSettings)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<BusinessInfo>(
              value: ref.watch(businessInfoProvider(businessId)),
              onRetry: () => ref.invalidate(businessInfoProvider(businessId)),
              builder: (context, info) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Section(
                    title: l10n.settingsBusiness,
                    icon: Icons.storefront_outlined,
                    child: _BusinessForm(info: info),
                  ),
                  _Section(
                    title: l10n.settingsBookingPage,
                    icon: Icons.web_outlined,
                    child: _BookingPageForm(businessId: businessId),
                  ),
                  _Section(
                    title: l10n.settingsPolicy,
                    icon: Icons.rule_rounded,
                    child: _PolicyForm(info: info),
                  ),
                  _Section(
                    title: l10n.settingsPayments,
                    icon: Icons.payments_outlined,
                    child: _PaymentsForm(businessId: businessId),
                  ),
                  if (info.hasFeature('own_invoicing'))
                    _Section(
                      title: l10n.settingsInvoicing,
                      icon: Icons.receipt_long_outlined,
                      child: _InvoicingForm(businessId: businessId),
                    ),
                  if (info.hasFeature('calendar_sync'))
                    _Section(
                      title: l10n.settingsCalendarSync,
                      icon: Icons.sync_rounded,
                      child: _CalendarForm(businessId: businessId),
                    ),
                ],
              ),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title, style: Theme.of(context).textTheme.titleSmall),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [child],
        ),
      ),
    );
  }
}

class _SaveButton extends ConsumerWidget {
  const _SaveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(settingsActionsProvider.select((s) => s.busy));
    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
        onPressed: busy ? null : onPressed,
        child: Text(AppLocalizations.of(context).save),
      ),
    );
  }
}

// ─── Vállalkozás ───────────────────────────────────────────────

class _BusinessForm extends ConsumerStatefulWidget {
  const _BusinessForm({required this.info});

  final BusinessInfo info;

  @override
  ConsumerState<_BusinessForm> createState() => _BusinessFormState();
}

class _BusinessFormState extends ConsumerState<_BusinessForm> {
  late final _name = TextEditingController(text: widget.info.name);
  late final _email = TextEditingController(text: widget.info.email ?? '');
  late final _phone = TextEditingController(text: widget.info.phone ?? '');
  late final _address = TextEditingController(text: widget.info.address ?? '');
  late final _city = TextEditingController(text: widget.info.city ?? '');
  late final _description = TextEditingController(text: widget.info.description ?? '');
  late bool _solo = widget.info.isSolo;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _address, _city, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(settingsActionsProvider.notifier);

    return Column(
      children: [
        TextField(
          controller: _name,
          decoration: InputDecoration(labelText: l10n.name),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: l10n.email),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: l10n.phone),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _address,
                decoration: InputDecoration(labelText: l10n.fieldAddress),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _city,
                decoration: InputDecoration(labelText: l10n.businessCity),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.businessDescription),
        ),
        const SizedBox(height: 8),
        _SaveButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) return;
            actions.updateBusiness(
              widget.info.id,
              name: _name.text,
              email: _email.text,
              phone: _phone.text,
              address: _address.text,
              city: _city.text,
              description: _description.text,
            );
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.settingsMode),
          value: _solo,
          onChanged: (v) {
            setState(() => _solo = v);
            actions.setSolo(widget.info.id, v);
          },
        ),
      ],
    );
  }
}

// ─── Foglalási oldal ───────────────────────────────────────────

class _BookingPageForm extends ConsumerStatefulWidget {
  const _BookingPageForm({required this.businessId});

  final int businessId;

  @override
  ConsumerState<_BookingPageForm> createState() => _BookingPageFormState();
}

class _BookingPageFormState extends ConsumerState<_BookingPageForm> {
  TextEditingController? _description;
  TextEditingController? _extra;
  bool _group = false;
  bool _rentals = false;
  bool _loaded = false;

  @override
  void dispose() {
    _description?.dispose();
    _extra?.dispose();
    super.dispose();
  }

  void _load(BookingPageSettings s) {
    if (_loaded) return;
    _loaded = true;
    _description = TextEditingController(text: s.description ?? '');
    _extra = TextEditingController(text: s.extraInfo ?? '');
    _group = s.groupSessionsEnabled;
    _rentals = s.rentalsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(settingsActionsProvider.notifier);
    final page = ref.watch(bookingPageProvider(widget.businessId));

    return page.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
      error: (_, _) => TextButton(onPressed: () => ref.invalidate(bookingPageProvider(widget.businessId)), child: Text(l10n.retry)),
      data: (s) {
        _load(s);
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _ImageBox(label: l10n.bookingLogo, url: s.logoUrl, businessId: widget.businessId, kind: 'logo'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImageBox(label: l10n.bookingCover, url: s.coverUrl, businessId: widget.businessId, kind: 'cover'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.businessDescription),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _extra,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.bookingExtraInfo),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.bookingGroupEnabled),
              value: _group,
              onChanged: (v) => setState(() => _group = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.bookingRentalsEnabled),
              value: _rentals,
              onChanged: (v) => setState(() => _rentals = v),
            ),
            _SaveButton(
              onPressed: () => actions.saveBookingPage(
                widget.businessId,
                description: _description!.text,
                extraInfo: _extra!.text,
                groupSessions: _group,
                rentals: _rentals,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ImageBox extends ConsumerWidget {
  const _ImageBox({required this.label, required this.url, required this.businessId, required this.kind});

  final String label;
  final String? url;
  final int businessId;
  final String kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(settingsActionsProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 1.6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            child: AppImage(
              url: url,
              fallback: ColoredBox(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                child: Icon(Icons.image_outlined, color: theme.colorScheme.primary),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: l10n.imageUpload,
              icon: const Icon(Icons.upload_rounded),
              onPressed: () => actions.uploadImage(businessId, kind),
            ),
            if (url != null)
              IconButton(
                tooltip: l10n.imageRemove,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => actions.deleteImage(businessId, kind),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Szabályzat ────────────────────────────────────────────────

class _PolicyForm extends ConsumerStatefulWidget {
  const _PolicyForm({required this.info});

  final BusinessInfo info;

  @override
  ConsumerState<_PolicyForm> createState() => _PolicyFormState();
}

class _PolicyFormState extends ConsumerState<_PolicyForm> {
  late final _hours = TextEditingController(text: '${widget.info.cancellationDeadlineHours ?? 24}');
  late final _threshold = TextEditingController(text: widget.info.noShowThreshold?.toString() ?? '');
  late final _deposit = TextEditingController(text: widget.info.noShowDepositPercentage?.toString() ?? '');
  late bool _reschedule = widget.info.allowCustomerReschedule;

  @override
  void dispose() {
    for (final c in [_hours, _threshold, _deposit]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        TextField(
          controller: _hours,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.policyCancelHours),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.policyReschedule),
          value: _reschedule,
          onChanged: (v) => setState(() => _reschedule = v),
        ),
        if (widget.info.hasFeature('no_show_protection')) ...[
          TextField(
            controller: _threshold,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.policyNoShowThreshold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _deposit,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.policyNoShowDeposit),
          ),
        ],
        const SizedBox(height: 8),
        _SaveButton(
          onPressed: () => ref
              .read(settingsActionsProvider.notifier)
              .savePolicy(
                widget.info.id,
                cancellationDeadlineHours: _int(_hours) ?? 24,
                allowCustomerReschedule: _reschedule,
                noShowThreshold: _int(_threshold),
                noShowDepositPercentage: _int(_deposit),
              ),
        ),
      ],
    );
  }
}

// ─── Fizetés ───────────────────────────────────────────────────

class _PaymentsForm extends ConsumerStatefulWidget {
  const _PaymentsForm({required this.businessId});

  final int businessId;

  @override
  ConsumerState<_PaymentsForm> createState() => _PaymentsFormState();
}

class _PaymentsFormState extends ConsumerState<_PaymentsForm> {
  TextEditingController? _percent;
  TextEditingController? _refund;
  String _type = 'none';
  bool _loaded = false;

  @override
  void dispose() {
    _percent?.dispose();
    _refund?.dispose();
    super.dispose();
  }

  void _load(PaymentSettings s) {
    if (_loaded) return;
    _loaded = true;
    _percent = TextEditingController(text: '${s.depositPercentage}');
    _refund = TextEditingController(text: '${s.refundCutoffHours}');
    _type = s.depositType;
  }

  Future<void> _openStripe({required bool dashboard}) async {
    final actions = ref.read(settingsActionsProvider.notifier);
    if (await actions.requestStripeUrl(widget.businessId, dashboard: dashboard) &&
        actions.stripeUrl != null &&
        actions.stripeUrl!.isNotEmpty) {
      await launchUrl(Uri.parse(actions.stripeUrl!), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(settingsActionsProvider.notifier);
    final settings = ref.watch(paymentSettingsProvider(widget.businessId));

    return settings.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
      error: (_, _) => TextButton(onPressed: () => ref.invalidate(paymentSettingsProvider(widget.businessId)), child: Text(l10n.retry)),
      data: (s) {
        _load(s);
        final stripe = s.stripe;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'none', label: Text(l10n.depositNone)),
                ButtonSegment(value: 'percentage', label: Text(l10n.depositPercentage)),
                ButtonSegment(value: 'full', label: Text(l10n.depositFull)),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            if (_type == 'percentage') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _percent,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.depositPercentLabel),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _refund,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.paymentRefundCutoff),
            ),
            const SizedBox(height: 8),
            _SaveButton(
              onPressed: () => actions.savePayments(
                widget.businessId,
                depositType: _type,
                depositPercentage: _int(_percent!) ?? 0,
                refundCutoffHours: _int(_refund!) ?? 0,
              ),
            ),
            const Divider(height: 24),
            if (!stripe.connected) ...[
              Text(l10n.paymentStripeNotConnected),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.link_rounded),
                label: Text(l10n.paymentStripeConnect),
                onPressed: () => _openStripe(dashboard: false),
              ),
            ] else ...[
              Row(
                children: [
                  Icon(
                    stripe.chargesEnabled ? Icons.check_circle_rounded : Icons.pending_outlined,
                    color: stripe.chargesEnabled ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(stripe.chargesEnabled ? l10n.paymentStripeReady : l10n.paymentStripePending)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (!stripe.detailsSubmitted || !stripe.chargesEnabled)
                    OutlinedButton(onPressed: () => _openStripe(dashboard: false), child: Text(l10n.paymentStripeContinue)),
                  OutlinedButton(onPressed: () => _openStripe(dashboard: true), child: Text(l10n.paymentStripeDashboard)),
                  TextButton(onPressed: () => actions.syncStripe(widget.businessId), child: Text(l10n.paymentStripeSync)),
                ],
              ),
              if (s.onlinePaymentsAvailable)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.paymentOnline),
                  subtitle: Text(l10n.paymentFee(s.platformFeePercent.toStringAsFixed(1))),
                  value: s.onlinePaymentsEnabled,
                  onChanged: (v) => actions.setOnlinePayments(widget.businessId, v),
                ),
            ],
          ],
        );
      },
    );
  }
}

// ─── Számlázás ─────────────────────────────────────────────────

class _InvoicingForm extends ConsumerStatefulWidget {
  const _InvoicingForm({required this.businessId});

  final int businessId;

  @override
  ConsumerState<_InvoicingForm> createState() => _InvoicingFormState();
}

class _InvoicingFormState extends ConsumerState<_InvoicingForm> {
  final _apiKey = TextEditingController();
  final _agentKey = TextEditingController();
  TextEditingController? _block;
  TextEditingController? _receiptBlock;
  bool _enabled = false;
  bool _autoSend = false;
  String _provider = 'billingo';
  String _docType = 'invoice';
  String _vat = 'AAM';
  bool _loaded = false;

  @override
  void dispose() {
    _apiKey.dispose();
    _agentKey.dispose();
    _block?.dispose();
    _receiptBlock?.dispose();
    super.dispose();
  }

  void _load(InvoicingSettings s) {
    if (_loaded) return;
    _loaded = true;
    _block = TextEditingController(text: s.blockId?.toString() ?? '');
    _receiptBlock = TextEditingController(text: s.receiptBlockId?.toString() ?? '');
    _enabled = s.enabled;
    _autoSend = s.autoSend;
    _provider = s.provider;
    _docType = s.documentType;
    _vat = s.vat;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(invoicingSettingsProvider(widget.businessId));

    return settings.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
      error: (_, _) => TextButton(onPressed: () => ref.invalidate(invoicingSettingsProvider(widget.businessId)), child: Text(l10n.retry)),
      data: (s) {
        _load(s);
        final vatCodes = s.vatCodes.contains(_vat) ? s.vatCodes : [_vat, ...s.vatCodes];
        return Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.invoicingEnabled),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            if (_enabled) ...[
              DropdownButtonFormField<String>(
                initialValue: _provider,
                decoration: InputDecoration(labelText: l10n.invoicingProvider),
                items: const [
                  DropdownMenuItem(value: 'billingo', child: Text('Billingo')),
                  DropdownMenuItem(value: 'szamlazz', child: Text('Számlázz.hu')),
                ],
                onChanged: (v) => setState(() => _provider = v ?? 'billingo'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _docType,
                decoration: InputDecoration(labelText: l10n.invoicingDocType),
                items: [
                  DropdownMenuItem(value: 'invoice', child: Text(l10n.docInvoice)),
                  DropdownMenuItem(value: 'receipt', child: Text(l10n.docReceipt)),
                ],
                onChanged: (v) => setState(() => _docType = v ?? 'invoice'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _vat,
                decoration: InputDecoration(labelText: l10n.invoicingVat),
                items: [for (final c in vatCodes) DropdownMenuItem(value: c, child: Text(c))],
                onChanged: (v) => setState(() => _vat = v ?? _vat),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _apiKey,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.invoicingApiKey, helperText: s.hasApiKey ? l10n.invoicingKeySet : null),
              ),
              if (_provider == 'szamlazz') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _agentKey,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.invoicingAgentKey, helperText: s.hasAgentKey ? l10n.invoicingKeySet : null),
                ),
              ],
              if (_provider == 'billingo') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _block,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.invoicingBlock),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _receiptBlock,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.invoicingReceiptBlock),
                      ),
                    ),
                  ],
                ),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.invoicingAutoSend),
                value: _autoSend,
                onChanged: (v) => setState(() => _autoSend = v),
              ),
            ],
            _SaveButton(
              onPressed: () => ref
                  .read(settingsActionsProvider.notifier)
                  .saveInvoicing(
                    widget.businessId,
                    enabled: _enabled,
                    provider: _provider,
                    documentType: _docType,
                    vat: _vat,
                    autoSend: _autoSend,
                    apiKey: _apiKey.text,
                    agentKey: _agentKey.text,
                    blockId: _int(_block!),
                    receiptBlockId: _int(_receiptBlock!),
                  ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Naptár-szinkron ───────────────────────────────────────────

class _CalendarForm extends ConsumerWidget {
  const _CalendarForm({required this.businessId});

  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(settingsActionsProvider.notifier);
    final feeds = ref.watch(calendarFeedsProvider(businessId));

    Widget row(String name, String? url, int? staffId) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Text(url ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.calendarCopy,
            icon: const Icon(Icons.copy_rounded),
            onPressed: url == null
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (context.mounted) showToast(context, l10n.calendarCopied);
                  },
          ),
          IconButton(
            tooltip: l10n.calendarRegenerate,
            icon: const Icon(Icons.autorenew_rounded),
            onPressed: () async {
              final confirmed = await showConfirmAlert(
                context,
                title: l10n.calendarRegenerateTitle,
                message: l10n.calendarRegenerateText,
                confirmLabel: l10n.calendarRegenerate,
                icon: Icons.autorenew_rounded,
              );
              if (confirmed) await actions.regenerateFeed(businessId, staffId: staffId);
            },
          ),
        ],
      ),
    );

    return feeds.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
      error: (_, _) => TextButton(onPressed: () => ref.invalidate(calendarFeedsProvider(businessId)), child: Text(l10n.retry)),
      data: (f) =>
          Column(children: [row(l10n.calendarBusinessFeed, f.businessUrl, null), for (final s in f.staff) row(s.name, s.url, s.id)]),
    );
  }
}
