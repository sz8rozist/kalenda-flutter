import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/flash.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/app_logo.dart';
import '../../../shared/ui/step_section.dart';
import '../viewmodel/staff_account_viewmodels.dart';
import '../viewmodel/staff_session_viewmodel.dart';

/// Az „elfelejtett jelszó" párbeszéd: e-mail-címet kér, és levelet küld az új jelszó beállításához.
Future<void> showForgotPasswordDialog(BuildContext context, WidgetRef ref, {String initialEmail = ''}) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialEmail);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.forgotPassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.forgotPasswordText),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.email),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.dialogCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.sendLinkShort)),
      ],
    ),
  );
  final email = controller.text.trim();
  controller.dispose();
  if (confirmed == true && email.contains('@')) {
    final ok = await ref.read(staffAccountProvider.notifier).forgotPassword(email);
    if (ok && context.mounted) showToast(context, l10n.forgotPasswordSent);
  }
}

/// Új fiók létrehozása (View): név, e-mail, jelszó; sikernél a felhasználó be van lépve, jöhet a vállalkozás létrehozása.
class StaffRegisterPage extends ConsumerStatefulWidget {
  const StaffRegisterPage({super.key});

  @override
  ConsumerState<StaffRegisterPage> createState() => _StaffRegisterPageState();
}

class _StaffRegisterPageState extends ConsumerState<StaffRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final router = GoRouter.of(context);
    final ok = await ref.read(staffAccountProvider.notifier).register(name: _name.text, email: _email.text, password: _password.text);
    if (ok) router.go('/staff');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, staffAccountProvider.select((s) => s.flash));
    final busy = ref.watch(staffAccountProvider.select((s) => s.busy));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.pagePadding),
            children: [
              const Center(child: AppLogo(size: 56)),
              const SizedBox(height: 16),
              Text(l10n.registerIntro, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(labelText: l10n.name),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: l10n.email),
                validator: (v) => (v == null || !v.contains('@')) ? l10n.invalidEmail : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(labelText: l10n.password),
                validator: (v) => (v == null || v.length < 8) ? l10n.passwordMin : null,
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: busy ? null : _submit, child: Text(l10n.createAccount)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceRow {
  final name = TextEditingController();
  final minutes = TextEditingController(text: '30');
  final price = TextEditingController();

  void dispose() {
    name.dispose();
    minutes.dispose();
    price.dispose();
  }
}

class _StaffRow {
  final name = TextEditingController();
  final email = TextEditingController();

  void dispose() {
    name.dispose();
    email.dispose();
  }
}

/// Az első vállalkozás létrehozása (View): adatok, kezdő szolgáltatások, munkatársak.
class OwnerSetupPage extends ConsumerStatefulWidget {
  const OwnerSetupPage({super.key});

  @override
  ConsumerState<OwnerSetupPage> createState() => _OwnerSetupPageState();
}

class _OwnerSetupPageState extends ConsumerState<OwnerSetupPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _services = [_ServiceRow()];
  final _staff = <_StaffRow>[];
  bool _solo = true;

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _city]) {
      c.dispose();
    }
    for (final s in _services) {
      s.dispose();
    }
    for (final s in _staff) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final services = [
      for (final s in _services)
        if (s.name.text.trim().isNotEmpty && (int.tryParse(s.minutes.text.trim()) ?? 0) >= 5)
          (name: s.name.text.trim(), durationMinutes: int.parse(s.minutes.text.trim()), priceHuf: int.tryParse(s.price.text.trim())),
    ];
    if (_name.text.trim().isEmpty) {
      showToast(context, l10n.required, kind: AlertKind.warning);
      return;
    }
    if (services.isEmpty) {
      showToast(context, l10n.setupNeedsService, kind: AlertKind.warning);
      return;
    }
    final router = GoRouter.of(context);
    final ok = await ref
        .read(staffAccountProvider.notifier)
        .createBusiness(
          name: _name.text,
          isSolo: _solo,
          services: services,
          staff: [
            if (!_solo)
              for (final s in _staff)
                if (s.name.text.trim().isNotEmpty) (name: s.name.text.trim(), email: s.email.text.trim()),
          ],
          phone: _phone.text,
          address: _address.text,
          city: _city.text,
        );
    if (ok) router.go('/staff');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, staffAccountProvider.select((s) => s.flash));
    final busy = ref.watch(staffAccountProvider.select((s) => s.busy));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          children: [
            Text(l10n.setupIntro),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.setupBusinessName),
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.setupSolo),
              value: _solo,
              onChanged: (v) => setState(() => _solo = v),
            ),
            const SizedBox(height: 8),
            StepSection(
              number: 1,
              title: l10n.setupServices,
              child: Column(
                children: [
                  for (final (index, s) in _services.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: s.name,
                              decoration: InputDecoration(labelText: l10n.name),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 64,
                            child: TextField(
                              controller: s.minutes,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'perc'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: s.price,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: l10n.servicePriceHuf),
                            ),
                          ),
                          if (_services.length > 1)
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => setState(() => _services.removeAt(index).dispose()),
                            ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _services.add(_ServiceRow())),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.setupAddService),
                    ),
                  ),
                ],
              ),
            ),
            if (!_solo)
              StepSection(
                number: 2,
                title: l10n.setupStaff,
                child: Column(
                  children: [
                    for (final (index, s) in _staff.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: s.name,
                                decoration: InputDecoration(labelText: l10n.name),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: s.email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(labelText: l10n.email),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => setState(() => _staff.removeAt(index).dispose()),
                            ),
                          ],
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _staff.add(_StaffRow())),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.setupAddStaff),
                      ),
                    ),
                  ],
                ),
              ),
            FilledButton(onPressed: busy ? null : _create, child: Text(l10n.setupCreate)),
          ],
        ),
      ),
    );
  }
}

/// Jelszócsere és visszajelzés küldése (View) – a munkatársi és a vállalkozói felületről is elérhető.
class AccountSecurityPage extends ConsumerStatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  ConsumerState<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends ConsumerState<AccountSecurityPage> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  String _type = 'bug';

  @override
  void dispose() {
    for (final c in [_current, _password, _subject, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context);
    if (_password.text.length < 8) {
      showToast(context, l10n.passwordMin, kind: AlertKind.warning);
      return;
    }
    if (await ref.read(staffAccountProvider.notifier).changePassword(current: _current.text, password: _password.text)) {
      _current.clear();
      _password.clear();
    }
  }

  Future<void> _sendFeedback() async {
    if (_subject.text.trim().isEmpty || _message.text.trim().isEmpty) return;
    if (await ref.read(staffAccountProvider.notifier).sendFeedback(type: _type, subject: _subject.text, message: _message.text)) {
      _subject.clear();
      _message.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(staffSessionProvider).value;
    listenFlash(ref, context, staffAccountProvider.select((s) => s.flash));
    final busy = ref.watch(staffAccountProvider.select((s) => s.busy));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountSecurityTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        children: [
          if (user != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline_rounded),
              title: Text(user.name),
              subtitle: Text(user.email),
            ),
          const SizedBox(height: 8),
          StepSection(
            number: 1,
            title: l10n.changePassword,
            child: Column(
              children: [
                TextField(
                  controller: _current,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.currentPassword),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.newPassword),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size(140, 44)),
                    onPressed: busy ? null : _changePassword,
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
          StepSection(
            number: 2,
            title: l10n.feedbackTitle,
            child: Column(
              children: [
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: 'bug', label: Text(l10n.feedbackTypeBug)),
                    ButtonSegment(value: 'feature', label: Text(l10n.feedbackTypeFeature)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (v) => setState(() => _type = v.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _subject,
                  decoration: InputDecoration(labelText: l10n.feedbackSubject),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _message,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: l10n.feedbackMessage),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size(140, 44)),
                    onPressed: busy ? null : _sendFeedback,
                    child: Text(l10n.feedbackSend),
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
