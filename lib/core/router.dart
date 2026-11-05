import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/account/appointments_page.dart';
import '../features/account/login_page.dart';
import 'auth/auth_controller.dart';

/// Router: belépés nélkül a belépő oldal, belépve a foglalások. Az auth-állapot változására újraértékel.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (auth.isLoading) return null;
      final signedIn = auth.value ?? false;
      final atLogin = state.matchedLocation == '/login';
      if (!signedIn && !atLogin) return '/login';
      if (signedIn && atLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const AppointmentsPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
    ],
    errorBuilder: (_, _) => const Scaffold(body: Center(child: Icon(Icons.error_outline))),
  );
});
