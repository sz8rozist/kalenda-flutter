import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_controller.dart';
import '../features/account/account_page.dart';
import '../features/account/appointments_page.dart';
import '../features/account/login_page.dart';
import '../features/booking/find_business_page.dart';
import '../l10n/app_localizations.dart';

/// Kezdőképernyő: új foglalás (nyilvános); belépés után a saját foglalások és a fiók, előtte a belépés.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final signedIn = auth.value ?? false;

    final pages = <Widget>[
      const FindBusinessPage(),
      if (auth.isLoading)
        const Center(child: CircularProgressIndicator())
      else if (signedIn) ...const [AppointmentsPage(), AccountPage()]
      else
        const LoginPage(),
    ];
    final destinations = <NavigationDestination>[
      NavigationDestination(icon: const Icon(Icons.add_circle_outline), label: l10n.newBooking),
      if (signedIn) ...[
        NavigationDestination(icon: const Icon(Icons.event_note_outlined), label: l10n.myAppointments),
        NavigationDestination(icon: const Icon(Icons.person_outline), label: l10n.accountTitle),
      ] else
        NavigationDestination(icon: const Icon(Icons.login), label: l10n.signIn),
    ];
    final index = _index.clamp(0, pages.length - 1);

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: destinations,
      ),
    );
  }
}
