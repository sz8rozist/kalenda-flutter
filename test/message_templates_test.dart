import 'package:flutter_test/flutter_test.dart';
import 'package:kalenda_mobile/features/owner/model/message_templates.dart';
import 'package:kalenda_mobile/l10n/app_localizations_en.dart';
import 'package:kalenda_mobile/l10n/app_localizations_hu.dart';

void main() {
  test('a sablonok az ügyfél, a szolgáltatás, az időpont és a vállalkozás nevével töltődnek ki (magyarul)', () {
    final l10n = AppLocalizationsHu();

    final text = buildMessage(l10n, MessageTemplate.reminder, name: 'Éva', service: 'Hajvágás', when: 'nov. 10. 10:30', business: 'Próba Szalon');

    expect(text, allOf(contains('Éva'), contains('Hajvágás'), contains('nov. 10. 10:30'), contains('Próba Szalon')));
  });

  test('minden sablonnak van angol és magyar szövege, és a nevet tartalmazza', () {
    for (final l10n in [AppLocalizationsHu(), AppLocalizationsEn()]) {
      for (final template in MessageTemplate.values) {
        final text = buildMessage(l10n, template, name: 'Anna', service: 'Masszázs', when: 'holnap', business: 'Szalon');
        expect(text, contains('Anna'), reason: '$template');
        expect(text, contains('Szalon'), reason: '$template');
      }
    }
  });

  test('az SMS- és e-mail-hivatkozás a szöveget %20-szal kódolja, a telefonszámból elveszi a szóközt', () {
    final sms = MessageLinks.sms('+36 30 123 4567', 'Szia Éva & Béla!');
    final mail = MessageLinks.mail('eva@example.com', 'Időpontod', 'Sor 1\nSor 2');

    expect(sms.scheme, 'sms');
    expect(sms.path, '+36301234567');
    expect(sms.toString(), contains('body=Szia%20%C3%89va%20%26%20B%C3%A9la!'));
    expect(sms.toString(), isNot(contains('+Szia')));
    expect(mail.scheme, 'mailto');
    expect(mail.path, 'eva@example.com');
    expect(mail.toString(), contains('subject=Id%C5%91pontod'));
    expect(mail.toString(), contains('Sor%201%0ASor%202'));
  });
}
