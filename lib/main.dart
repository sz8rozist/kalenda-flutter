import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'features/app_gate/view/update_required_page.dart';
import 'features/app_gate/viewmodel/app_gate_viewmodel.dart';
import 'features/app_lock/view/app_lock_gate.dart';
import 'features/splash/view/splash_gate.dart';
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
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Kívülről befelé: splash → zár (biometrikus azonosítás) → a tartalom (vagy a kötelező frissítés oldal).
      builder: (context, child) => SplashGate(
        child: AppLockGate(
          child: update != null ? UpdateRequiredPage(requirement: update) : (child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
