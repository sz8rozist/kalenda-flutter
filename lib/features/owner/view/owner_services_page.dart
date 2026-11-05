import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../../shared/format.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/owner_models.dart';
import '../viewmodel/owner_service_viewmodels.dart';

/// A vállalkozás szolgáltatásainak gyors szerkesztése (View): aktív / inaktív váltó, koppintásra név, időtartam, ár.
class OwnerServicesPage extends ConsumerWidget {
  const OwnerServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, serviceActionsProvider.select((s) => s.flash));
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerServices)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<List<OwnerService>>(
              value: ref.watch(ownerServicesProvider(businessId)),
              onRetry: () => ref.invalidate(ownerServicesProvider(businessId)),
              builder: (context, services) => RefreshIndicator(
                onRefresh: () => ref.refresh(ownerServicesProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (services.isEmpty) Text(l10n.nothingYet),
                    for (final s in services) _ServiceTile(service: s, businessId: businessId),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ServiceTile extends ConsumerWidget {
  const _ServiceTile({required this.service, required this.businessId});

  final OwnerService service;
  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(serviceActionsProvider.notifier);

    return Card(
      child: ListTile(
        title: Text(service.name),
        subtitle: Text([
          l10n.minutes(service.durationMinutes),
          if (service.priceHuf != null) formatHuf(context, service.priceHuf!),
          if (service.isGroup) l10n.groupSessions,
          if (service.isRental) l10n.serviceRental,
        ].join(' · ')),
        trailing: Switch(value: service.isActive, onChanged: (v) => actions.setActive(businessId, service.id, v)),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _EditSheet(service: service, businessId: businessId),
        ),
      ),
    );
  }
}

class _EditSheet extends ConsumerStatefulWidget {
  const _EditSheet({required this.service, required this.businessId});

  final OwnerService service;
  final int businessId;

  @override
  ConsumerState<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends ConsumerState<_EditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.service.name);
  late final _duration = TextEditingController(text: '${widget.service.durationMinutes}');
  late final _price = TextEditingController(text: widget.service.priceHuf?.toString() ?? '');

  @override
  void dispose() {
    _name.dispose();
    _duration.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final ok = await ref.read(serviceActionsProvider.notifier).update(
          widget.businessId,
          widget.service.id,
          name: _name.text.trim(),
          durationMinutes: int.parse(_duration.text.trim()),
          priceHuf: int.tryParse(_price.text.trim()),
        );
    // Hibánál a lap nyitva marad (a snackbar jelzi a hibát); sikernél bezárjuk.
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(serviceActionsProvider.select((s) => s.busy));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.name, border: const OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _duration,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.serviceDurationMinutes, border: const OutlineInputBorder()),
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  return (n == null || n < 5 || n > 480) ? l10n.required : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.servicePriceHuf, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: busy ? null : _save, child: Text(l10n.save))),
            ],
          ),
        ),
      ),
    );
  }
}
