// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'Kalenda';

  @override
  String get loginTitle => 'Belépés';

  @override
  String get loginIntro =>
      'Add meg az e-mail-címed, és küldünk egy belépő linket.';

  @override
  String get email => 'E-mail-cím';

  @override
  String get sendLink => 'Belépő link küldése';

  @override
  String get linkSent =>
      'Ha az e-mail-cím szerepel nálunk, elküldtük a belépő linket.';

  @override
  String get tokenLabel => 'Kód a levélből';

  @override
  String get tokenHelp =>
      'Másold be a levélben kapott linkből a kódot (a /belepes/ utáni rész).';

  @override
  String get signIn => 'Belépés';

  @override
  String get signOut => 'Kijelentkezés';

  @override
  String get myAppointments => 'Foglalásaim';

  @override
  String get upcoming => 'Közelgő';

  @override
  String get past => 'Korábbi';

  @override
  String get noUpcoming => 'Nincs közelgő foglalásod.';

  @override
  String get noPast => 'Még nincs korábbi foglalásod.';

  @override
  String get retry => 'Újra';

  @override
  String get genericError => 'Hiba történt. Próbáld újra.';

  @override
  String get networkError => 'Nincs kapcsolat a szerverrel.';

  @override
  String priceHuf(String amount) {
    return '$amount Ft';
  }
}
