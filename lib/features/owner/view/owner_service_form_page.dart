import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/color_choice.dart';
import '../../../shared/ui/step_section.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/owner_models.dart';
import '../viewmodel/owner_manage_viewmodels.dart';
import '../viewmodel/owner_service_viewmodels.dart';
import '../viewmodel/settings_viewmodels.dart';
import 'owner_extras_pages.dart';

/// Szolgáltatás létrehozása vagy szerkesztése (View). `serviceId == null` az új szolgáltatás.
class OwnerServiceFormPage extends ConsumerWidget {
  const OwnerServiceFormPage({super.key, this.serviceId});

  final int? serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(serviceId == null ? l10n.newService : l10n.editService)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : serviceId == null
          ? _ServiceForm(businessId: businessId)
          : AsyncView<List<OwnerService>>(
              value: ref.watch(ownerServicesProvider(businessId)),
              onRetry: () => ref.invalidate(ownerServicesProvider(businessId)),
              builder: (context, services) {
                final existing = services.where((s) => s.id == serviceId).firstOrNull;
                return existing == null ? Center(child: Text(l10n.genericError)) : _ServiceForm(businessId: businessId, service: existing);
              },
            ),
    );
  }
}

class _ServiceForm extends ConsumerStatefulWidget {
  const _ServiceForm({required this.businessId, this.service});

  final int businessId;
  final OwnerService? service;

  @override
  ConsumerState<_ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends ConsumerState<_ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.service?.name ?? '');
  late final _description = TextEditingController(text: widget.service?.description ?? '');
  late final _duration = TextEditingController(text: '${widget.service?.durationMinutes ?? 30}');
  late final _price = TextEditingController(text: widget.service?.priceHuf?.toString() ?? '');
  late final _depositPercent = TextEditingController(text: widget.service?.depositPercentage?.toString() ?? '');
  late final _bufferBefore = TextEditingController(text: '${widget.service?.bufferBefore ?? 0}');
  late final _bufferAfter = TextEditingController(text: '${widget.service?.bufferAfter ?? 0}');
  late final _maxDuration = TextEditingController(text: widget.service?.maxDurationMinutes?.toString() ?? '');
  late final _step = TextEditingController(text: widget.service?.durationStepMinutes?.toString() ?? '');
  late String _depositType = widget.service?.depositType ?? 'none';
  late String _color = widget.service?.color ?? ColorChoice.palette.first;
  late bool _active = widget.service?.isActive ?? true;
  late bool _group = widget.service?.isGroup ?? false;
  late bool _rental = widget.service?.isRental ?? false;

  @override
  void dispose() {
    for (final c in [_name, _description, _duration, _price, _depositPercent, _bufferBefore, _bufferAfter, _maxDuration, _step]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final router = GoRouter.of(context);
    final draft = OwnerService(
      id: widget.service?.id ?? 0,
      name: _name.text.trim(),
      description: _description.text.trim(),
      durationMinutes: _int(_duration)!,
      priceHuf: _int(_price),
      isActive: _active,
      isGroup: _group,
      isRental: _rental,
      depositType: _depositType,
      depositPercentage: _int(_depositPercent),
      color: _color,
      bufferBefore: _int(_bufferBefore) ?? 0,
      bufferAfter: _int(_bufferAfter) ?? 0,
      maxDurationMinutes: _int(_maxDuration),
      durationStepMinutes: _int(_step),
    );
    final ok = await ref.read(serviceEditProvider.notifier).save(widget.businessId, draft);
    if (ok && router.canPop()) router.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final confirmed = await showConfirmAlert(
      context,
      title: l10n.deleteServiceTitle,
      message: l10n.deleteServiceText,
      confirmLabel: l10n.actionDelete,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed) return;
    final ok = await ref.read(serviceEditProvider.notifier).delete(widget.businessId, widget.service!.id);
    if (ok && router.canPop()) router.pop();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context).required : null;

  String? _minutes(String? v, {int min = 1, int max = 1440}) {
    final n = int.tryParse(v?.trim() ?? '');
    return (n == null || n < min || n > max) ? AppLocalizations.of(context).required : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, serviceEditProvider.select((s) => s.flash));
    final busy = ref.watch(serviceEditProvider.select((s) => s.busy));

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.name),
            validator: _required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _description,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.fieldDescription),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _duration,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.serviceDurationMinutes),
                  validator: (v) => _minutes(v, min: 5, max: 480),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.servicePriceHuf),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          StepSection(
            number: 1,
            title: l10n.depositTypeLabel,
            child: Column(
              children: [
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: 'none', label: Text(l10n.depositNone)),
                    ButtonSegment(value: 'percentage', label: Text(l10n.depositPercentage)),
                    ButtonSegment(value: 'full', label: Text(l10n.depositFull)),
                  ],
                  selected: {_depositType},
                  onSelectionChanged: (s) => setState(() => _depositType = s.first),
                ),
                if (_depositType == 'percentage') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _depositPercent,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.depositPercentLabel),
                    validator: (v) => _minutes(v, min: 1, max: 100),
                  ),
                ],
              ],
            ),
          ),
          StepSection(
            number: 2,
            title: l10n.fieldColor,
            child: ColorChoice(value: _color, onChanged: (c) => setState(() => _color = c)),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _bufferBefore,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.bufferBefore),
                  validator: (v) => _minutes(v, min: 0, max: 240),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _bufferAfter,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.bufferAfter),
                  validator: (v) => _minutes(v, min: 0, max: 240),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.fieldActive),
            value: _active,
            onChanged: (v) => setState(() => _active = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.groupServiceLabel),
            value: _group,
            onChanged: (v) => setState(() => _group = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.rentalServiceLabel),
            value: _rental,
            onChanged: (v) => setState(() => _rental = v),
          ),
          if (_rental) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxDuration,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.maxDurationLabel),
                    validator: (v) => _minutes(v, min: 5, max: 1440),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _step,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.durationStepLabel),
                    validator: (v) => _minutes(v, min: 5, max: 240),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: busy ? null : _save,
            child: busy
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text(l10n.save),
          ),
          if (widget.service != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.science_outlined),
              label: Text(l10n.serviceMaterials),
              onPressed: () => showMaterialsSheet(context, businessId: widget.businessId, serviceId: widget.service!.id),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.image_outlined),
              label: Text(l10n.serviceImage),
              onPressed: () => ref.read(extrasActionsProvider.notifier).uploadImage(widget.businessId, 'services/${widget.service!.id}/image'),
            ),
          ],
          if (widget.service != null)
            TextButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.actionDelete),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: busy ? null : _delete,
            ),
        ],
      ),
    );
  }
}
