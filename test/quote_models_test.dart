import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/features/owner/model/quote_models.dart';

void main() {
  test('az ajánlat a válaszból: vevő, tételek, összeg, érvényesség', () {
    final quote = Quote.fromJson({
      'id': 7,
      'status': 'sent',
      'total_huf': 15000,
      'valid_until': '2026-12-01',
      'customer': {'id': 4, 'name': 'Teszt Vevő', 'email': 'vevo@example.com'},
      'items': [
        {'name': 'Hajvágás', 'qty': 3, 'unit_price_huf': 5000, 'vat': null},
      ],
    });

    expect(quote.id, 7);
    expect(quote.customerName, 'Teszt Vevő');
    expect(quote.customerEmail, 'vevo@example.com');
    expect(quote.totalHuf, 15000);
    expect(quote.items.single.qty, 3.0);
    expect(quote.items.single.unitPriceHuf, 5000);
    expect(quote.validUntil, DateTime(2026, 12, 1));
    expect(quote.isDraft, isFalse);
    expect(quote.isConverted, isFalse);
  });

  test('hiányzó mezőknél biztonságos alapértékek', () {
    final quote = Quote.fromJson({'id': 1});

    expect(quote.status, 'draft');
    expect(quote.isDraft, isTrue);
    expect(quote.items, isEmpty);
    expect(quote.customerName, '');
    expect(quote.validUntil, isNull);
  });
}
