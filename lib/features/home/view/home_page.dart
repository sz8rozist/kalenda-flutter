import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui/floating_nav_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/haptics.dart';
import '../../account/view/account_page.dart';
import '../../account/view/appointments_page.dart';
import '../../auth/view/login_page.dart';
import '../../auth/viewmodel/customer_session_viewmodel.dart';
import '../../booking/view/find_business_page.dart';
import '../viewmodel/home_viewmodel.dart';

/// Kezdőképernyő (View): új foglalás (nyilvános); belépés után a saját foglalások és a fiók, előtte a belépés.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(customerSessionProvider);
    final signedIn = session.value ?? false;

    final pages = <Widget>[
      const FindBusinessPage(),
      if (session.isLoading)
        const Center(child: CircularProgressIndicator())
      else if (signedIn) ...const [AppointmentsPage(), AccountPage()] else
        const LoginPage(),
    ];
    final destinations = <NavigationDestination>[
      NavigationDestination(icon: const Icon(Icons.add_circle_outline), selectedIcon: const Icon(Icons.add_circle), label: l10n.newBooking),
      if (signedIn) ...[
        NavigationDestination(
          icon: const Icon(Icons.event_note_outlined),
          selectedIcon: const Icon(Icons.event_note),
          label: l10n.myAppointments,
        ),
        NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: l10n.accountTitle),
      ] else
        NavigationDestination(icon: const Icon(Icons.login), selectedIcon: const Icon(Icons.login), label: l10n.signIn),
    ];
    final index = ref.watch(homeTabProvider).clamp(0, pages.length - 1);

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: FloatingNavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          Haptics.select();
          ref.read(homeTabProvider.notifier).select(i);
        },
        destinations: destinations,
      ),
    );
  }
}
