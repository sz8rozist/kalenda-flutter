import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/flash.dart';
import '../viewmodel/staff_session_viewmodel.dart';
import 'staff_account_pages.dart';

/// Belépés munkatársként / vállalkozóként (View): a bejelentkezést a [StaffLoginViewModel] végzi.
class StaffLoginPage extends ConsumerStatefulWidget {
  const StaffLoginPage({super.key});

  @override
  ConsumerState<StaffLoginPage> createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends ConsumerState<StaffLoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() => ref.read(staffLoginProvider.notifier).signIn(_email.text, _password.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    listenFlash(ref, context, staffLoginProvider.select((s) => s.flash));
    final busy = ref.watch(staffLoginProvider.select((s) => s.busy));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.staffLoginTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.staffLoginIntro),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              decoration: InputDecoration(labelText: l10n.email),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(labelText: l10n.password),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: busy ? null : _submit, child: Text(l10n.signIn)),
            const SizedBox(height: 8),
            TextButton(onPressed: () => showForgotPasswordDialog(context, ref, initialEmail: _email.text), child: Text(l10n.forgotPassword)),
            TextButton(onPressed: () => context.push('/staff/register'), child: Text(l10n.registerBusinessLink)),
          ],
        ),
      ),
    );
  }
}
