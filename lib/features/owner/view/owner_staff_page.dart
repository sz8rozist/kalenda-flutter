import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/owner_models.dart';
import '../viewmodel/owner_staff_viewmodels.dart';

/// A vállalkozás munkatársai (View): aktív / inaktív váltó, koppintásra név és telefonszám szerkesztése.
class OwnerStaffPage extends ConsumerWidget {
  const OwnerStaffPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, staffManageProvider.select((s) => s.flash));
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerStaff)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<List<OwnerStaff>>(
              value: ref.watch(ownerStaffProvider(businessId)),
              onRetry: () => ref.invalidate(ownerStaffProvider(businessId)),
              builder: (context, staff) => RefreshIndicator(
                onRefresh: () => ref.refresh(ownerStaffProvider(businessId).future),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (staff.isEmpty) Text(l10n.nothingYet),
                    for (final s in staff) _StaffTile(staff: s, businessId: businessId),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StaffTile extends ConsumerWidget {
  const _StaffTile({required this.staff, required this.businessId});

  final OwnerStaff staff;
  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        title: Text(staff.name),
        subtitle: Text([
          l10n.upcomingBookings(staff.upcomingCount),
          if (staff.hasAccount) l10n.staffHasAccount,
          if (staff.phone != null && staff.phone!.isNotEmpty) staff.phone!,
        ].join(' · ')),
        trailing: Switch(value: staff.isActive, onChanged: (v) => ref.read(staffManageProvider.notifier).setActive(businessId, staff.id, v)),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _EditSheet(staff: staff, businessId: businessId),
        ),
      ),
    );
  }
}

class _EditSheet extends ConsumerStatefulWidget {
  const _EditSheet({required this.staff, required this.businessId});

  final OwnerStaff staff;
  final int businessId;

  @override
  ConsumerState<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends ConsumerState<_EditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.staff.name);
  late final _phone = TextEditingController(text: widget.staff.phone ?? '');

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final ok = await ref.read(staffManageProvider.notifier).update(
          widget.businessId,
          widget.staff.id,
          name: _name.text.trim(),
          phone: _phone.text.trim(),
        );
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(staffManageProvider.select((s) => s.busy));

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
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.phone, border: const OutlineInputBorder()),
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
