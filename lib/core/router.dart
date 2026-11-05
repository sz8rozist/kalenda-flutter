import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/view/login_link_page.dart';
import '../features/booking/view/booking_page.dart';
import '../features/booking/view/business_page.dart';
import '../features/booking/view/manage_booking_page.dart';
import '../features/home/view/home_page.dart';
import '../features/staff/view/staff_home_page.dart';
import 'push/push_service.dart';

/// Útvonalak. A foglalás nyilvános (belépés nélkül is megy), csak a „Foglalásaim" fül kér belépést –
/// azt a [HomePage] kezeli.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
      GoRoute(path: '/staff', builder: (_, _) => const StaffHomePage()),
      // A levélben kapott belépő link (univerzális link / app link ide érkezik).
      GoRoute(path: '/fiokom/belepes/:code', builder: (_, state) => LoginLinkPage(code: state.pathParameters['code']!)),
      GoRoute(path: '/b/:slug', builder: (_, state) => BusinessPage(slug: state.pathParameters['slug']!)),
      GoRoute(
        path: '/b/:slug/book/:serviceId',
        builder: (_, state) => BookingPage(
          slug: state.pathParameters['slug']!,
          serviceId: int.parse(state.pathParameters['serviceId']!),
        ),
      ),
      // A levelekben és a weben használt útvonalak is megnyílnak az appban (univerzális link).
      GoRoute(path: '/booking/manage/:token', builder: (_, state) => ManageBookingPage(token: state.pathParameters['token']!)),
      GoRoute(path: '/booking/:slug', builder: (_, state) => BusinessPage(slug: state.pathParameters['slug']!)),
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
