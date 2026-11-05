import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'features/app_gate/view/update_required_page.dart';
import 'features/app_gate/viewmodel/app_gate_viewmodel.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: KalendaApp()));
}

class KalendaApp extends ConsumerWidget {
  const KalendaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(appGateProvider).value;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: ref.watch(routerProvider),
      theme: ThemeData(colorSchemeSeed: const Color(0xFF4F46E5), useMaterial3: true),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Elavult verziónál minden képernyő helyett a kötelező frissítés oldal jelenik meg.
      builder: (context, child) => update != null ? UpdateRequiredPage(requirement: update) : (child ?? const SizedBox.shrink()),
    );
  }
}
