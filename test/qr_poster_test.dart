import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/features/owner/model/business_info.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  test('a vállalkozás adataiból kiolvasható a foglalási oldal címe', () {
    final info = BusinessInfo.fromJson(<String, dynamic>{'id': 1, 'name': 'Szalon', 'slug': 'szalon', 'booking_url': 'https://kalenda.example/booking/szalon'});

    expect(info.bookingUrl, 'https://kalenda.example/booking/szalon');
    expect(BusinessInfo.fromJson(<String, dynamic>{'id': 2, 'name': 'X'}).bookingUrl, isNull);
  });

  testWidgets('a QR-kód a foglalási címet kódolja, és nagy felbontásban lerenderelhető', (tester) async {
    const url = 'https://kalenda.example/booking/szalon';
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: QrImageView(data: url, size: 200)))));

    expect(find.byType(QrImageView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
