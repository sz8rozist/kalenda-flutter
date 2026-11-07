import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'features/app_gate/view/update_required_page.dart';
import 'features/app_gate/viewmodel/app_gate_viewmodel.dart';
import 'features/app_lock/view/app_lock_gate.dart';
import 'features/connectivity/view/offline_banner.dart';
import 'features/onboarding/view/onboarding_page.dart';
import 'features/settings/viewmodel/locale_viewmodel.dart';
import 'features/settings/viewmodel/theme_mode_viewmodel.dart';
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
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: ref.watch(routerProvider),
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Kívülről befelé: splash → zár (biometrikus azonosítás) → bevezető és offline sáv → a tartalom
      // (vagy a kötelező frissítés oldal). A betűméret-skálázást követjük, de ésszerű határok közt.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.9,
        maxScaleFactor: 1.4,
        child: SplashGate(
          child: AppLockGate(
            child: update != null
                ? UpdateRequiredPage(requirement: update)
                : OnboardingGate(child: OfflineBanner(child: child ?? const SizedBox.shrink())),
          ),
        ),
      ),
    );
  }
}
