import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/features/account/model/account_models.dart';
import 'package:kalenda_mobile/features/app_gate/model/app_config.dart';
import 'package:kalenda_mobile/features/booking/model/booking_models.dart';
import 'package:kalenda_mobile/features/booking/model/booking_request.dart';
import 'package:kalenda_mobile/features/owner/model/owner_models.dart';
import 'package:kalenda_mobile/features/staff/model/staff_models.dart';

void main() {
  group('verzió-összehasonlítás (isOutdated)', () {
    test('kisebb verzió elavult', () {
      expect(isOutdated('1.0.0', '1.2.0'), isTrue);
      expect(isOutdated('1.9.9', '2.0.0'), isTrue);
      expect(isOutdated('1.2.0', '1.2.1'), isTrue);
    });

    test('egyenlő vagy nagyobb nem elavult', () {
      expect(isOutdated('1.2.0', '1.2.0'), isFalse);
      expect(isOutdated('2.0.0', '1.9.9'), isFalse);
    });

    test('a build-szám és az előtag nem számít, a hiányzó tag 0', () {
      expect(isOutdated('1.2.0+7', '1.2.0'), isFalse);
      expect(isOutdated('1.2.0-beta', '1.2.0'), isFalse);
      expect(isOutdated('1.2', '1.2.0'), isFalse);
      expect(isOutdated('1.2', '1.2.1'), isTrue);
    });

    test('minimum nélkül nincs kényszer', () {
      expect(isOutdated('0.0.1', null), isFalse);
      expect(isOutdated('0.0.1', ' '), isFalse);
    });
  });

  group('SlotQuery', () {
    SlotQuery query(List<int> addons, {DateTime? date}) =>
        SlotQuery(slug: 'szalon', serviceId: 1, staffId: 2, date: date ?? DateTime(2026, 11, 5, 14, 30), addonIds: addons);

    test('a kiegészítők sorrendje nem számít (provider-kulcs egyenlőség)', () {
      expect(query([3, 1, 2]), equals(query([1, 2, 3])));
      expect(query([3, 1, 2]).hashCode, query([1, 2, 3]).hashCode);
    });

    test('a nap időpontja nélkül hasonlít', () {
      expect(query([], date: DateTime(2026, 11, 5, 8)), equals(query([], date: DateTime(2026, 11, 5, 23))));
    });

    test('más kiegészítő vagy nap eltér', () {
      expect(query([1]), isNot(equals(query([2]))));
      expect(query([1], date: DateTime(2026, 11, 6)), isNot(equals(query([1]))));
    });
  });

  group('foglalási modellek', () {
    test('a helyi falióra-idő nem lesz UTC', () {
      final booking = ManagedBooking.fromJson({
        'starts_at': '2026-10-05T08:17:00',
        'ends_at': '2026-10-05T09:17:00',
        'status': 'confirmed',
        'service': {'name': 'Hajvágás'},
        'business': {'name': 'Szalon', 'address': 'Fő utca 1.', 'city': 'Pécs'},
        'can_modify': true,
        'can_cancel': false,
        'payment': {'required': true, 'status': 'pending'},
      });

      expect(booking.startsAt.isUtc, isFalse);
      expect(booking.startsAt.hour, 8);
      expect(booking.endsAt.hour, 9);
      expect(booking.address, 'Fő utca 1., Pécs');
      expect(booking.canModify, isTrue);
      expect(booking.canCancel, isFalse);
      expect(booking.paymentRequired, isTrue);
      expect(booking.paymentStatus, 'pending');
    });

    test('a vállalkozás adatlapja: szolgáltatások, munkatársak, kiegészítők, bérlet-típusok', () {
      final business = PublicBusiness.fromJson({
        'name': 'Szalon',
        'slug': 'szalon',
        'has_waitlist': true,
        'has_passes': true,
        'services': [
          {'id': 1, 'name': 'Hajvágás', 'duration_minutes': 30, 'price_huf': 5000},
        ],
        'staff': [
          {'id': 7, 'name': 'Anna', 'service_ids': [1]},
          {'id': 8, 'name': 'Béla', 'service_ids': [2]},
        ],
        'addons_by_service': {
          '1': [
            {'id': 5, 'name': 'Hajmosás', 'price_huf': 1000, 'duration_minutes': 10},
          ],
        },
        'pass_types': [
          {'id': 3, 'kind': 'voucher', 'name': 'Ajándékutalvány', 'price_huf': 10000, 'validity_days': 365, 'value_huf': 10000},
        ],
      });

      expect(business.hasWaitlist, isTrue);
      expect(business.staffFor(1).map((s) => s.name), ['Anna']);
      expect(business.addonsByService[1]!.single.name, 'Hajmosás');
      expect(business.passTypes.single.isVoucher, isTrue);
      expect(business.service(1)!.priceHuf, 5000);
      expect(business.service(99), isNull);
    });

    test('csoportos alkalom', () {
      final session = GroupSession.fromJson({
        'id': 4,
        'starts_at': '2026-11-10T18:00:00',
        'ends_at': '2026-11-10T19:00:00',
        'capacity': 12,
        'places_left': 0,
        'full': true,
        'service': {'name': 'Jóga', 'duration_minutes': 60},
        'staff_name': 'Anna',
      });

      expect(session.full, isTrue);
      expect(session.serviceName, 'Jóga');
      expect(session.durationMinutes, 60);
    });
  });

  group('ügyfélfiók', () {
    test('a foglalás-kezelő token a link utolsó szakasza', () {
      final item = AccountAppointment.fromJson({
        'id': 1,
        'business': 'Szalon',
        'service': 'Hajvágás',
        'starts_at': '2026-10-05T08:17:00',
        'status': 'confirmed',
        'manage_url': 'https://kalenda.example/booking/manage/abc123',
      });

      expect(item.manageToken, 'abc123');
    });

    test('lemondott foglalásnál nincs kezelő link', () {
      final item = AccountAppointment.fromJson({
        'id': 2,
        'business': 'Szalon',
        'service': 'Hajvágás',
        'starts_at': '2026-10-05T08:17:00',
        'status': 'cancelled',
      });

      expect(item.manageToken, isNull);
    });
  });

  group('munkatársi és vállalkozói modellek', () {
    test('a /me válaszból a szerepkörök és a vállalkozás', () {
      final user = StaffUser.fromJson({
        'name': 'Kovács Anna',
        'email': 'anna@example.com',
        'roles': {'staff': false, 'business_owner': true},
        'business': {'id': 12, 'name': 'Szalon', 'slug': 'szalon'},
      });

      expect(user.isOwner, isTrue);
      expect(user.isStaff, isFalse);
      expect(user.businessId, 12);
      expect(user.businessSlug, 'szalon');
      expect(user.businessName, 'Szalon');
    });

    test('munkatárs: a vállalkozás a staff.business alól jön', () {
      final user = StaffUser.fromJson({
        'name': 'Béla',
        'email': 'bela@example.com',
        'roles': {'staff': true, 'business_owner': false},
        'staff': {
          'business': {'id': 3, 'name': 'Másik szalon', 'slug': 'masik'}
        },
      });

      expect(user.isStaff, isTrue);
      expect(user.businessId, 3);
    });

    test('a kicsekkolt / bent lévő állapot', () {
      expect(ClockState.fromJson(null).isClockedIn, isFalse);
      expect(ClockState.fromJson({'open_since': '2026-11-05T08:00:00'}).isClockedIn, isTrue);
    });

    test('nyitvatartás: a 00:00 zárt napnál értelmes alapértékre cserélődik, a zárt nap nem küld időt', () {
      final closed = HourRow.fromJson({'day_of_week': 0, 'open_at': '00:00:00', 'close_at': '00:00:00', 'is_closed': true});
      expect(closed.openAt, '09:00');
      expect(closed.toJson(), {'day_of_week': 0, 'is_closed': true});

      final open = HourRow.fromJson({'day_of_week': 1, 'open_at': '08:30:00', 'close_at': '17:00:00', 'is_closed': false});
      expect(open.toJson(), {'day_of_week': 1, 'is_closed': false, 'open_at': '08:30', 'close_at': '17:00'});
    });

    test('számla: állapot és sztornó', () {
      final invoice = InvoiceItem.fromJson({
        'id': 1,
        'number': 'KAL-2026-1',
        'total_huf': 12000,
        'payment_state': 'overdue',
        'reminder_count': 2,
        'cancelled_at': '2026-11-01T10:00:00',
        'customer': {'name': 'Kiss Péter'},
      });

      expect(invoice.isPaid, isFalse);
      expect(invoice.cancelled, isTrue);
      expect(invoice.customerName, 'Kiss Péter');
    });

    test('heti bevétel változása az előző héthez képest', () {
      expect(WeekRevenue(total: 0, toDateTotal: 120, previousToDateTotal: 100).changePercent, closeTo(20, 0.001));
      expect(WeekRevenue(total: 0, toDateTotal: 50, previousToDateTotal: 0).changePercent, isNull);
    });

    test('naptár-tétel a munkatársi foglalás-modellre képezve', () {
      final a = calendarAppointment({
        'id': 9,
        'title': 'Hajvágás',
        'start': '2026-11-05T10:00:00',
        'end': '2026-11-05T10:30:00',
        'status': 'confirmed',
        'customer_name': 'Nagy Éva',
      });

      expect(a.serviceName, 'Hajvágás');
      expect(a.customerName, 'Nagy Éva');
      expect(a.canManage, isTrue);
    });
  });
}
