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
  String get newBooking => 'Új foglalás';

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

  @override
  String minutes(int count) {
    return '$count perc';
  }

  @override
  String get findBusinessTitle => 'Vállalkozás keresése';

  @override
  String get findBusinessIntro =>
      'Írd be a vállalkozás foglalási címét (azonosítóját), vagy másold be a foglalási linket.';

  @override
  String get businessSlug => 'Azonosító vagy link';

  @override
  String get open => 'Megnyitás';

  @override
  String get services => 'Szolgáltatások';

  @override
  String get book => 'Foglalás';

  @override
  String get bookingTitle => 'Időpontfoglalás';

  @override
  String get staffLabel => 'Munkatárs';

  @override
  String get addons => 'Kiegészítők';

  @override
  String get dateLabel => 'Dátum';

  @override
  String get pickDate => 'Válassz napot';

  @override
  String get timeLabel => 'Időpont';

  @override
  String get noSlots => 'Ezen a napon nincs szabad időpont.';

  @override
  String get yourDetails => 'Adataid';

  @override
  String get name => 'Név';

  @override
  String get phone => 'Telefonszám';

  @override
  String get notes => 'Megjegyzés';

  @override
  String get passCode => 'Bérletkód (ha van)';

  @override
  String get marketingConsent => 'Hírlevelet kérek';

  @override
  String get confirmBooking => 'Foglalás megerősítése';

  @override
  String get payDeposit => 'Fizetés';

  @override
  String get bookingDone => 'Sikeres foglalás';

  @override
  String get bookingDoneText => 'A visszaigazolást elküldtük e-mailben.';

  @override
  String get paymentRequired =>
      'A foglalás véglegesítéséhez fizetés szükséges.';

  @override
  String get payNow => 'Fizetés most';

  @override
  String get manageBooking => 'Foglalás kezelése';

  @override
  String get reschedule => 'Áthelyezés';

  @override
  String get cancelBooking => 'Lemondás';

  @override
  String get cancelConfirmTitle => 'Biztosan lemondod?';

  @override
  String get cancelConfirmText => 'A lemondás nem vonható vissza.';

  @override
  String get yes => 'Igen';

  @override
  String get no => 'Nem';

  @override
  String get saved => 'Mentve.';

  @override
  String get cancelled => 'A foglalást lemondtad.';

  @override
  String get status => 'Állapot';

  @override
  String get total => 'Összesen';

  @override
  String get call => 'Hívás';

  @override
  String get backToBookings => 'Vissza a foglalásokhoz';

  @override
  String get required => 'A mező megadása kötelező.';

  @override
  String get invalidEmail => 'Érvénytelen e-mail-cím.';

  @override
  String get accountTitle => 'Fiókom';

  @override
  String get profile => 'Profil';

  @override
  String get save => 'Mentés';

  @override
  String get loyaltyTitle => 'Hűségpontok';

  @override
  String loyaltyBalance(int points) {
    return '$points pont';
  }

  @override
  String loyaltyReward(int points, String value) {
    return '$points pontért $value';
  }

  @override
  String get passesTitle => 'Bérletek és utalványok';

  @override
  String sessionsLeft(int count) {
    return '$count alkalom van hátra';
  }

  @override
  String balanceLeft(String value) {
    return 'Egyenleg: $value';
  }

  @override
  String expiresOn(String date) {
    return 'Lejár: $date';
  }

  @override
  String get expired => 'Lejárt';

  @override
  String get consentsTitle => 'Hírlevél-hozzájárulások';

  @override
  String get nothingYet => 'Még nincs itt semmi.';

  @override
  String get deleteAccount => 'Fiók törlése';

  @override
  String get deleteAccountTitle => 'Biztosan törlöd a fiókod?';

  @override
  String get deleteAccountText =>
      'A személyes adataid törlődnek, a belépésed és az eszközeid megszűnnek. Ez nem vonható vissza. Közelgő foglalással nem törölhető a fiók.';
}
