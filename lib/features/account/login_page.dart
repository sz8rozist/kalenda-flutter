import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';

/// Belépés e-mailes linkkel: 1) e-mail → link, 2) a levélben kapott kód beírása.
/// (Az univerzális link bekötése után a kód beírása elmarad.)
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _linkSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on ApiException catch (e) {
      _error = e.isNetwork ? l10n.networkError : (e.firstMessage ?? l10n.genericError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.loginIntro, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(labelText: l10n.email, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                        await auth.requestLink(_email.text.trim());
                        if (mounted) setState(() => _linkSent = true);
                      }),
              child: Text(l10n.sendLink),
            ),
            if (_linkSent) ...[
              const SizedBox(height: 24),
              Text(l10n.linkSent),
              const SizedBox(height: 12),
              TextField(
                controller: _code,
                decoration: InputDecoration(
                  labelText: l10n.tokenLabel,
                  helperText: l10n.tokenHelp,
                  helperMaxLines: 3,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _busy ? null : () => _run(() => auth.signIn(_code.text)),
                child: Text(l10n.signIn),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 32),
            TextButton(onPressed: () => context.push('/staff'), child: Text(l10n.staffLoginLink)),
          ],
        ),
      ),
    );
  }
}
