import 'package:go_router/go_router.dart';
import 'package:kalenda_mobile/core/push/push_service.dart';

/// Push-szolgáltatás Firebase nélkül: a hívásokat számolja, semmit nem csinál.
class NoPush extends PushService {
  NoPush(super.ref);

  int registerCalls = 0;
  int enableAfterBookingCalls = 0;

  @override
  Future<void> registerIfAllowed() async => registerCalls++;

  @override
  Future<void> enableAfterBooking() async => enableAfterBookingCalls++;

  @override
  Future<void> listenForTaps(GoRouter router) async {}

  @override
  void reset() {}
}
