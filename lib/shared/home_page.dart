import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_controller.dart';
import '../features/account/appointments_page.dart';
import '../features/account/login_page.dart';
import '../features/booking/find_business_page.dart';
import '../l10n/app_localizations.dart';

/// Kezdőképernyő két füllel: új foglalás (nyilvános) és a saját foglalások (belépés után).
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

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const FindBusinessPage(),
          if (auth.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            signedIn ? const AppointmentsPage() : const LoginPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.add_circle_outline), label: l10n.newBooking),
          NavigationDestination(icon: const Icon(Icons.event_note_outlined), label: l10n.myAppointments),
        ],
      ),
    );
  }
}
