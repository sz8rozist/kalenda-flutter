import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/format.dart';
import '../viewmodel/login_link_viewmodel.dart';

/// A levélből megnyitott belépő link fogadása (View): belép, majd a kezdőképernyőre visz.
class LoginLinkPage extends ConsumerWidget {
  const LoginLinkPage({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final result = ref.watch(loginLinkProvider(code));

    // Sikeres belépés: a kezdőképernyő (a „Foglalásaim" fül) a munkamenet alapján magától a belépett nézetet mutatja.
    ref.listen(loginLinkProvider(code), (_, next) {
      if (next is AsyncData) context.go('/');
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: result.when(
            loading: () => const CircularProgressIndicator(),
            data: (_) => const CircularProgressIndicator(),
            error: (error, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(errorText(context, error), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => context.go('/'), child: Text(l10n.backToStart)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
