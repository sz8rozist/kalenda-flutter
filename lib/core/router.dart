import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/view/login_link_page.dart';
import '../features/booking/view/booking_page.dart';
import '../features/booking/view/business_page.dart';
import '../features/booking/view/group_booking_page.dart';
import '../features/booking/view/manage_booking_page.dart';
import '../features/booking/view/pass_purchase_page.dart';
import '../features/booking/view/scan_qr_page.dart';
import '../features/home/view/home_page.dart';
import '../features/owner/view/customer_detail_page.dart';
import '../features/owner/view/owner_booking_page.dart';
import '../features/owner/view/owner_hours_page.dart';
import '../features/owner/view/owner_leaves_page.dart';
import '../features/owner/view/owner_service_form_page.dart';
import '../features/owner/view/owner_services_page.dart';
import '../features/owner/view/owner_staff_form_page.dart';
import '../features/owner/view/owner_staff_page.dart';
import '../features/review/view/review_page.dart';
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
      GoRoute(path: '/scan', builder: (_, _) => const ScanQrPage()),
      GoRoute(path: '/owner/new-booking', builder: (_, _) => const OwnerBookingPage()),
      GoRoute(path: '/owner/services', builder: (_, _) => const OwnerServicesPage()),
      GoRoute(path: '/owner/services/new', builder: (_, _) => const OwnerServiceFormPage()),
      GoRoute(
        path: '/owner/services/:id',
        builder: (_, state) => OwnerServiceFormPage(serviceId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/owner/staff/new', builder: (_, _) => const OwnerStaffFormPage()),
      GoRoute(
        path: '/owner/staff/:id',
        builder: (_, state) => OwnerStaffFormPage(staffId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/owner/customers/:id',
        builder: (_, state) => CustomerDetailPage(customerId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/owner/hours', builder: (_, _) => const OwnerHoursPage()),
      GoRoute(path: '/owner/leaves', builder: (_, _) => const OwnerLeavesPage()),
      GoRoute(path: '/owner/staff', builder: (_, _) => const OwnerStaffPage()),
      // A levélben kapott belépő link (univerzális link / app link ide érkezik).
      GoRoute(
        path: '/fiokom/belepes/:code',
        builder: (_, state) => LoginLinkPage(code: state.pathParameters['code']!),
      ),
      GoRoute(
        path: '/b/:slug',
        builder: (_, state) => BusinessPage(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/b/:slug/book/:serviceId',
        builder: (_, state) => BookingPage(slug: state.pathParameters['slug']!, serviceId: int.parse(state.pathParameters['serviceId']!)),
      ),
      // A levelekben és a weben használt útvonalak is megnyílnak az appban (univerzális link).
      GoRoute(
        path: '/b/:slug/group/:sessionId',
        builder: (_, state) =>
            GroupBookingPage(slug: state.pathParameters['slug']!, sessionId: int.parse(state.pathParameters['sessionId']!)),
      ),
      // Értékelés a levélből (a csillag-linkek `?r=1..5`-tel előre kiválasztják az értékelést).
      GoRoute(
        path: '/velemeny/:token',
        builder: (_, state) =>
            ReviewPage(token: state.pathParameters['token']!, initialRating: int.tryParse(state.uri.queryParameters['r'] ?? '') ?? 0),
      ),
      GoRoute(
        path: '/b/:slug/pass/:passTypeId',
        builder: (_, state) =>
            PassPurchasePage(slug: state.pathParameters['slug']!, passTypeId: int.parse(state.pathParameters['passTypeId']!)),
      ),
      GoRoute(
        path: '/booking/manage/:token',
        builder: (_, state) => ManageBookingPage(token: state.pathParameters['token']!),
      ),
      GoRoute(
        path: '/booking/:slug',
        builder: (_, state) => BusinessPage(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/manage/:token',
        builder: (_, state) => ManageBookingPage(token: state.pathParameters['token']!),
      ),
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
