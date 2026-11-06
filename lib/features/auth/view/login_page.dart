import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/social_sign_in_gateway.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/flash.dart';
import '../../../shared/ui/app_logo.dart';
import '../../app_gate/model/app_config.dart';
import '../../app_gate/viewmodel/app_gate_viewmodel.dart';
import '../viewmodel/login_viewmodel.dart';

/// Belépés e-mailes linkkel (View): a logika a [LoginViewModel]-ben van, itt csak a beviteli mezők és a megjelenés.
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
    final theme = Theme.of(context);
    final state = ref.watch(loginViewModelProvider);
    listenError(ref, context, loginViewModelProvider.select((s) => s.error));
    final viewModel = ref.read(loginViewModelProvider.notifier);
    // A szerver jelzi, melyik közösségi belépés van beállítva; az Apple csak Apple-eszközön érhető el.
    final config = ref.watch(remoteConfigProvider).value ?? const RemoteAppConfig();
    final gateway = ref.read(socialSignInGatewayProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          children: [
            const SizedBox(height: 24),
            const Center(child: AppLogo(size: 72)),
            const SizedBox(height: 24),
            Text(l10n.loginTitle, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              l10n.loginIntro,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(labelText: l10n.email, prefixIcon: const Icon(Icons.mail_outline_rounded)),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: state.busy ? null : () => viewModel.requestLink(_email.text),
              child: state.busy && !state.linkSent
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text(l10n.sendLink),
            ),
            if (state.linkSent) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mark_email_read_outlined, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.linkSent)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _code,
                decoration: InputDecoration(
                  labelText: l10n.tokenLabel,
                  helperText: l10n.tokenHelp,
                  helperMaxLines: 3,
                  prefixIcon: const Icon(Icons.key_rounded),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: state.busy ? null : () => viewModel.signIn(_code.text),
                child: Text(l10n.signIn),
              ),
            ],
            if (config.googleLogin || (config.appleLogin && gateway.appleSupported)) ...[
              const SizedBox(height: 28),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(l10n.orSignInWith, style: theme.textTheme.bodySmall),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),
              if (config.appleLogin && gateway.appleSupported)
                OutlinedButton.icon(
                  icon: const Icon(Icons.apple),
                  label: Text(l10n.continueWithApple),
                  onPressed: state.busy ? null : viewModel.signInWithApple,
                ),
              if (config.googleLogin) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: Text(l10n.continueWithGoogle),
                  onPressed: state.busy ? null : viewModel.signInWithGoogle,
                ),
              ],
            ],
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => context.push('/staff'),
              icon: const Icon(Icons.badge_outlined),
              label: Text(l10n.staffLoginLink),
            ),
          ],
        ),
      ),
    );
  }
}
