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
import '../viewmodel/settings_viewmodels.dart';
import 'owner_extras_pages.dart';
import '../viewmodel/owner_service_viewmodels.dart';
import '../viewmodel/owner_staff_viewmodels.dart';

/// Munkatárs létrehozása vagy szerkesztése (View). `staffId == null` az új munkatárs.
class OwnerStaffFormPage extends ConsumerWidget {
  const OwnerStaffFormPage({super.key, this.staffId});

  final int? staffId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(staffId == null ? l10n.newStaff : l10n.editStaff)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<List<OwnerService>>(
              value: ref.watch(ownerServicesProvider(businessId)),
              onRetry: () => ref.invalidate(ownerServicesProvider(businessId)),
              builder: (context, services) {
                if (staffId == null) return _StaffForm(businessId: businessId, services: services);
                return AsyncView<List<OwnerStaff>>(
                  value: ref.watch(ownerStaffProvider(businessId)),
                  onRetry: () => ref.invalidate(ownerStaffProvider(businessId)),
                  builder: (context, staff) {
                    final existing = staff.where((s) => s.id == staffId).firstOrNull;
                    return existing == null
                        ? Center(child: Text(l10n.genericError))
                        : _StaffForm(businessId: businessId, services: services, staff: existing);
                  },
                );
              },
            ),
    );
  }
}

class _StaffForm extends ConsumerStatefulWidget {
  const _StaffForm({required this.businessId, required this.services, this.staff});

  final int businessId;
  final List<OwnerService> services;
  final OwnerStaff? staff;

  @override
  ConsumerState<_StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends ConsumerState<_StaffForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.staff?.name ?? '');
  late final _email = TextEditingController(text: widget.staff?.email ?? '');
  late final _phone = TextEditingController(text: widget.staff?.phone ?? '');
  late final _bio = TextEditingController(text: widget.staff?.bio ?? '');
  late String _color = widget.staff?.color ?? ColorChoice.palette.first;
  late String _kind = widget.staff?.kind ?? 'person';
  late bool _active = widget.staff?.isActive ?? true;
  late final Set<int> _serviceIds = {...?widget.staff?.serviceIds};

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _bio]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final router = GoRouter.of(context);
    final draft = OwnerStaff(
      id: widget.staff?.id ?? 0,
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      bio: _bio.text.trim(),
      color: _color,
      kind: _kind,
      isActive: _active,
      hasAccount: widget.staff?.hasAccount ?? false,
      upcomingCount: 0,
    );
    final ok = await ref.read(staffEditProvider.notifier).save(widget.businessId, draft, _serviceIds.toList());
    if (ok && router.canPop()) router.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final confirmed = await showConfirmAlert(
      context,
      title: l10n.deleteStaffTitle,
      message: l10n.deleteStaffText,
      confirmLabel: l10n.actionDelete,
      destructive: true,
      icon: Icons.person_remove_outlined,
    );
    if (!confirmed) return;
    final ok = await ref.read(staffEditProvider.notifier).delete(widget.businessId, widget.staff!.id);
    if (ok && router.canPop()) router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, staffEditProvider.select((s) => s.flash));
    final busy = ref.watch(staffEditProvider.select((s) => s.busy));
    final actions = ref.read(staffEditProvider.notifier);
    final existing = widget.staff;
    final isNew = existing == null;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.name),
            validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.email),
            validator: (v) => (v != null && v.trim().isNotEmpty && !v.contains('@')) ? l10n.invalidEmail : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.phone),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bio,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.staffBio),
          ),
          const SizedBox(height: 24),
          if (isNew) ...[
            Text(l10n.staffKindLabel, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'person', label: Text(l10n.staffKindPerson)),
                ButtonSegment(value: 'resource', label: Text(l10n.staffKindResource)),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 24),
          ],
          StepSection(
            number: 1,
            title: l10n.fieldColor,
            child: ColorChoice(value: _color, onChanged: (c) => setState(() => _color = c)),
          ),
          StepSection(
            number: 2,
            title: l10n.staffServicesTitle,
            child: widget.services.isEmpty
                ? Text(l10n.nothingYet)
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in widget.services)
                        FilterChip(
                          label: Text(s.name),
                          selected: _serviceIds.contains(s.id),
                          onSelected: (on) => setState(() => on ? _serviceIds.add(s.id) : _serviceIds.remove(s.id)),
                        ),
                    ],
                  ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.fieldActive),
            value: _active,
            onChanged: (v) => setState(() => _active = v),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy ? null : _save,
            child: busy
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text(l10n.save),
          ),
          if (existing != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.schedule_rounded),
              label: Text(l10n.staffHoursButton),
              onPressed: () => showStaffHoursSheet(context, (businessId: widget.businessId, staffId: existing.id)),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.payments_outlined),
              label: Text(l10n.staffPayButton),
              onPressed: () => showStaffPaySheet(context, (businessId: widget.businessId, staffId: existing.id)),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.staffPhotoButton),
              onPressed: () => ref.read(extrasActionsProvider.notifier).uploadImage(widget.businessId, 'staff/${existing.id}/photo'),
            ),
            const SizedBox(height: 8),
            if (existing.hasAccount)
              OutlinedButton.icon(
                icon: const Icon(Icons.lock_reset_outlined),
                label: Text(l10n.revokeAccess),
                onPressed: busy ? null : () => actions.revokeAccess(widget.businessId, existing.id),
              )
            else if (existing.email != null && existing.email!.isNotEmpty)
              OutlinedButton.icon(
                icon: const Icon(Icons.mark_email_unread_outlined),
                label: Text(l10n.inviteStaff),
                onPressed: busy ? null : () => actions.invite(widget.businessId, existing.id),
              ),
            TextButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.actionDelete),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: busy ? null : _delete,
            ),
          ],
        ],
      ),
    );
  }
}
