import 'package:flutter_test/flutter_test.dart';

import 'package:kalenda_mobile/core/api/api_exception.dart';
import 'package:kalenda_mobile/features/account/model/account_models.dart';

void main() {
  test('a foglalás helyi falióra-időt kap, nem UTC-t', () {
    final item = AccountAppointment.fromJson({
      'id': 1,
      'business': 'Szalon',
      'service': 'Hajvágás',
      'starts_at': '2026-10-05T08:17:00',
      'status': 'confirmed',
    });

    expect(item.startsAt.isUtc, isFalse);
    expect(item.startsAt.hour, 8);
  });

  test('az ApiException az első mezőhibát adja', () {
    final e = ApiException(statusCode: 422, message: 'x', fieldErrors: {
      'email': ['Érvénytelen e-mail cím.']
    });

    expect(e.firstMessage, 'Érvénytelen e-mail cím.');
  });
}
