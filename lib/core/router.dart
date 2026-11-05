import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/booking/booking_page.dart';
import '../features/staff/staff_home_page.dart';
import 'push/push_service.dart';
import '../features/booking/business_page.dart';
import '../features/booking/manage_booking_page.dart';
import '../shared/home_page.dart';

/// Útvonalak. A foglalás nyilvános (belépés nélkül is megy), csak a „Foglalásaim" fül kér belépést –
/// azt a [HomePage] kezeli.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
      GoRoute(path: '/staff', builder: (_, _) => const StaffHomePage()),
      GoRoute(path: '/b/:slug', builder: (_, state) => BusinessPage(slug: state.pathParameters['slug']!)),
      GoRoute(
        path: '/b/:slug/book/:serviceId',
        builder: (_, state) => BookingPage(
          slug: state.pathParameters['slug']!,
          serviceId: int.parse(state.pathParameters['serviceId']!),
        ),
      ),
      GoRoute(path: '/manage/:token', builder: (_, state) => ManageBookingPage(token: state.pathParameters['token']!)),
      GoRoute(
        path: '/booked/:token',
        builder: (_, state) => ManageBookingPage(token: state.pathParameters['token']!, justBooked: true),
      ),
    ],
    errorBuilder: (_, _) => const Scaffold(body: Center(child: Icon(Icons.error_outline))),
  );

  // Értesítésre koppintás: a foglalás megnyitása (Firebase nélkül nem csinál semmit).
  ref.read(pushServiceProvider).listenForTaps(router);
  return router;
});
