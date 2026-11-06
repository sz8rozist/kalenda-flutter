import 'package:kalenda_mobile/core/api/api_client.dart';
import 'package:kalenda_mobile/core/api/api_exception.dart';
import 'package:kalenda_mobile/features/app_gate/data/app_config_repository.dart';
import 'package:kalenda_mobile/features/auth/data/customer_auth_repository.dart';
import 'package:kalenda_mobile/features/booking/data/booking_repository.dart';
import 'package:kalenda_mobile/features/booking/model/booking_models.dart';
import 'package:kalenda_mobile/features/booking/model/booking_request.dart';

/// Hálózat nélküli API-kliens a fake repository-khoz (a hívásokat a fake felülírja, ide nem jut el kérés).
ApiClient offlineClient() => ApiClient(readCustomerToken: () async => null, readStaffToken: () async => null);

class FakeCustomerAuthRepository extends CustomerAuthRepository {
  FakeCustomerAuthRepository({this.token = 'kalenda_tok', this.failWith}) : super(offlineClient());

  final String token;
  ApiException? failWith;
  String? lastCode;
  String? lastGoogleIdToken;
  String? lastAppleName;
  bool loggedOut = false;
  bool accountDeleted = false;

  @override
  Future<String> login(String code) async {
    lastCode = code;
    if (failWith != null) throw failWith!;
    return token;
  }

  @override
  Future<String> loginWithGoogle(String idToken) async {
    lastGoogleIdToken = idToken;
    return token;
  }

  @override
  Future<String> loginWithApple(String idToken, {String? name}) async {
    lastAppleName = name;
    return token;
  }

  @override
  Future<void> logout() async => loggedOut = true;

  @override
  Future<void> deleteAccount() async {
    if (failWith != null) throw failWith!;
    accountDeleted = true;
  }
}

class FakeBookingRepository extends BookingRepository {
  FakeBookingRepository(this.data, {this.bookFails}) : super(offlineClient());

  final PublicBusiness data;
  ApiException? bookFails;
  BookingRequest? lastBooking;
  WaitlistRequest? lastWaitlist;

  @override
  Future<PublicBusiness> business(String slug) async => data;

  @override
  Future<BookedResult> book(String slug, BookingRequest r) async {
    lastBooking = r;
    if (bookFails != null) throw bookFails!;
    return BookedResult(
      booking: ManagedBooking(
        startsAt: DateTime(2026, 11, 10, 10),
        endsAt: DateTime(2026, 11, 10, 11),
        status: 'pending',
        serviceName: 'Hajvágás',
        businessName: 'Szalon',
        canModify: true,
        canCancel: true,
      ),
      manageToken: 'manage-token',
      requiresPayment: false,
    );
  }

  @override
  Future<String> joinWaitlist(String slug, WaitlistRequest r) async {
    lastWaitlist = r;
    return 'Feliratkoztál.';
  }
}

/// A telepített app-verzió beállítható (a PackageInfo platform nélkül nem olvasható).
class FakeAppConfigRepository extends AppConfigRepository {
  FakeAppConfigRepository(this.version) : super(offlineClient());

  final String version;

  @override
  Future<String> installedVersion() async => version;
}
