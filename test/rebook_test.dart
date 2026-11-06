import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/features/account/model/account_models.dart';
import 'package:kalenda_mobile/features/booking/model/booking_models.dart';
import 'package:kalenda_mobile/features/booking/view/rebook_page.dart';

void main() {
  final services = [
    PublicService(id: 4, name: 'Hajvágás', durationMinutes: 30),
    PublicService(id: 5, name: 'Festés', durationMinutes: 90),
  ];

  test('az újrafoglalás a szolgáltatás nevéből (kis-nagybetű nélkül) az űrlapra visz, a szakember nevével', () {
    expect(rebookTarget('szalon', services, ' hajvágás ', 'Kata'), '/b/szalon/book/4?staff=Kata');
    expect(rebookTarget('szalon', services, 'Festés', null), '/b/szalon/book/5');
  });

  test('ha a szolgáltatás már nincs meg, a vállalkozás oldalára visz', () {
    expect(rebookTarget('szalon', services, 'Régi kezelés', 'Kata'), '/b/szalon');
  });

  test('a foglalás a vállalkozás azonosítóját is tartalmazza', () {
    final a = AccountAppointment.fromJson({
      'id': 1,
      'business': 'Szalon',
      'business_slug': 'szalon',
      'service': 'Hajvágás',
      'starts_at': '2026-11-01T10:00:00',
      'status': 'completed',
    });

    expect(a.businessSlug, 'szalon');
  });
}
