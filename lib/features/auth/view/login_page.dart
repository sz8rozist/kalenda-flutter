import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/social_sign_in_gateway.dart';
import '../../../l10n/app_localizations.dart';
import '../../app_gate/model/app_config.dart';
import '../../app_gate/viewmodel/app_gate_viewmodel.dart';
import '../../../shared/format.dart';
import '../viewmodel/login_viewmodel.dart';

/// Belépés e-mailes linkkel (View): a logika a [LoginViewModel]-ben van, itt csak a beviteli mezők élnek.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(loginViewModelProvider);
    final viewModel = ref.read(loginViewModelProvider.notifier);
    // A szerver jelzi, melyik közösségi belépés van beállítva; az Apple csak Apple-eszközön érhető el.
    final config = ref.watch(remoteConfigProvider).value ?? const RemoteAppConfig();
    final gateway = ref.read(socialSignInGatewayProvider);

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
              onPressed: state.busy ? null : () => viewModel.requestLink(_email.text),
              child: Text(l10n.sendLink),
            ),
            if (state.linkSent) ...[
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
                onPressed: state.busy ? null : () => viewModel.signIn(_code.text),
                child: Text(l10n.signIn),
              ),
            ],
            if (config.googleLogin || (config.appleLogin && gateway.appleSupported)) ...[
              const SizedBox(height: 24),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(l10n.orSignInWith)),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 12),
              if (config.appleLogin && gateway.appleSupported)
                OutlinedButton.icon(
                  icon: const Icon(Icons.apple),
                  label: Text(l10n.continueWithApple),
                  onPressed: state.busy ? null : viewModel.signInWithApple,
                ),
              if (config.googleLogin) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: Text(l10n.continueWithGoogle),
                  onPressed: state.busy ? null : viewModel.signInWithGoogle,
                ),
              ],
            ],
            if (state.error != null) ...[
              const SizedBox(height: 16),
              Text(errorText(context, state.error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 32),
            TextButton(onPressed: () => context.push('/staff'), child: Text(l10n.staffLoginLink)),
          ],
        ),
      ),
    );
  }
}
