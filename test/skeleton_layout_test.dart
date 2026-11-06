import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/shared/ui/skeleton.dart';

void main() {
  testWidgets('a vázlat-betöltés ListView-ba és Column-ba ágyazva is kirajzolódik (nincs határtalan magasság)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: const [
              Text('fent'),
              ListSkeleton(items: 2),
              Text('lent'),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('fent'), findsOneWidget);
    expect(find.byType(ListSkeleton), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(mainAxisSize: MainAxisSize.min, children: [ListSkeleton(items: 1)]),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
