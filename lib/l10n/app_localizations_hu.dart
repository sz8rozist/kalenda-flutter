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
      'Másold be a levélben kapott linket (vagy a kódot a /belepes/ után).';

  @override
  String get updateRequiredTitle => 'Frissítés szükséges';

  @override
  String updateRequiredText(String version) {
    return 'Ez a verzió már nem támogatott. Kérjük, frissítsd az alkalmazást legalább a(z) $version verzióra.';
  }

  @override
  String get updateNow => 'Frissítés';

  @override
  String get ok => 'Rendben';

  @override
  String get bookingIncomplete =>
      'Válaszd ki a munkatársat, a napot és az időpontot.';

  @override
  String get errorTitleGeneric => 'Hiba történt';

  @override
  String get errorTitleNetwork => 'Nincs kapcsolat';

  @override
  String get errorNetworkText =>
      'Nem érjük el a szervert. Ellenőrizd az internetkapcsolatod, és próbáld újra.';

  @override
  String get errorTitleSession => 'Lejárt a munkamenet';

  @override
  String get errorSessionText => 'Kérjük, lépj be újra.';

  @override
  String get errorTitleDenied => 'Nincs jogosultságod';

  @override
  String get errorTitleNotFound => 'Nem található';

  @override
  String get errorTitleValidation => 'Ellenőrizd az adatokat';

  @override
  String get errorTitleTooMany => 'Túl sok kérés';

  @override
  String get errorTooManyText => 'Kérjük, várj egy kicsit, és próbáld újra.';

  @override
  String get errorTitleServer => 'Szerverhiba';

  @override
  String get errorServerText =>
      'Valami félresiklott a szerveren. Próbáld újra egy kicsit később.';

  @override
  String get welcomeTitle => 'Foglalj időpontot pár koppintással';

  @override
  String get welcomeText =>
      'Keresd meg kedvenc szalonod, stúdiód vagy edződ, és foglalj online.';

  @override
  String get splashTagline => 'Időpontfoglalás egyszerűen';

  @override
  String get ownerStaff => 'Munkatársak';

  @override
  String get staffHasAccount => 'van fiókja';

  @override
  String upcomingBookings(int count) {
    return '$count közelgő foglalás';
  }

  @override
  String get ownerManage => 'Kezelés';

  @override
  String get ownerLeaves => 'Szabadságkérelmek';

  @override
  String get noPendingLeaves => 'Nincs döntésre váró szabadságkérelem.';

  @override
  String get approveLeave => 'Jóváhagyás';

  @override
  String get rejectLeave => 'Elutasítás';

  @override
  String get rejectNote => 'Indok (nem kötelező)';

  @override
  String get ownerHours => 'Nyitvatartás';

  @override
  String get closedDay => 'Zárva';

  @override
  String get ownerServices => 'Szolgáltatások';

  @override
  String get serviceRental => 'Bérlés';

  @override
  String get serviceDurationMinutes => 'Időtartam (perc)';

  @override
  String get servicePriceHuf => 'Ár (Ft)';

  @override
  String get ownerReports => 'Riportok';

  @override
  String get previousMonth => 'Előző hónap';

  @override
  String get nextMonth => 'Következő hónap';

  @override
  String get reportRevenue => 'Bevétel';

  @override
  String get reportServices => 'Szolgáltatások';

  @override
  String get reportProducts => 'Termékek';

  @override
  String get reportPasses => 'Bérletek';

  @override
  String get reportVouchers => 'Utalványok';

  @override
  String get reportRevenueTotal => 'Bevétel összesen';

  @override
  String get reportExpenses => 'Költségek';

  @override
  String get reportPayroll => 'Bérköltség (becslés)';

  @override
  String get reportMaterials => 'Anyagköltség';

  @override
  String get reportExpensesTotal => 'Költség összesen';

  @override
  String get reportResult => 'Eredmény';

  @override
  String get reportReceivables => 'Kintlévőség a hónap végén';

  @override
  String get cashflowTitle => 'Cash flow előrejelzés';

  @override
  String get cashflowPartial => 'folyamatban';

  @override
  String get cashflowIn => 'Bevétel';

  @override
  String get cashflowOut => 'Kiadás';

  @override
  String get ownerInvoices => 'Számlák';

  @override
  String get invoiceAll => 'Mind';

  @override
  String get invoiceUnpaid => 'Nyitott';

  @override
  String get invoiceOverdue => 'Lejárt';

  @override
  String get invoicePaid => 'Kifizetve';

  @override
  String get invoiceCancelled => 'Sztornózva';

  @override
  String paidOn(String date) {
    return 'Kifizetve: $date';
  }

  @override
  String dueOn(String date) {
    return 'Esedékes: $date';
  }

  @override
  String remindersSent(int count) {
    return '$count emlékeztető elküldve';
  }

  @override
  String get payMethodCash => 'készpénz';

  @override
  String get payMethodCard => 'kártya';

  @override
  String get payMethodTransfer => 'átutalás';

  @override
  String markPaidWith(String method) {
    return 'Kifizetve – $method';
  }

  @override
  String get markUnpaid => 'Kifizetés visszavonása';

  @override
  String get sendReminder => 'Fizetési emlékeztető küldése';

  @override
  String get scanQr => 'QR-kód beolvasása';

  @override
  String get scanQrTitle => 'QR-kód beolvasása';

  @override
  String get scanQrHint =>
      'Irányítsd a kamerát a vállalkozás foglalási QR-kódjára.';

  @override
  String get cameraUnavailable =>
      'A kamera nem érhető el. Engedélyezd a kamera használatát a beállításokban.';

  @override
  String get addToCalendar => 'Mentés a naptárba';

  @override
  String get passesAndVouchers => 'Bérletek és utalványok';

  @override
  String get passPurchaseTitle => 'Bérlet / utalvány vásárlása';

  @override
  String sessionsCountLabel(int count) {
    return '$count alkalom';
  }

  @override
  String valueLabel(String value) {
    return 'Érték: $value';
  }

  @override
  String validityDaysLabel(int days) {
    return '$days napig érvényes';
  }

  @override
  String get passBuyerEmail =>
      'Az e-mail-címed (ide megy a bizonylat és a kód)';

  @override
  String get passGift => 'Ajándékba veszem';

  @override
  String get recipientName => 'A megajándékozott neve';

  @override
  String get recipientEmail => 'A megajándékozott e-mail-címe';

  @override
  String get senderName => 'A te neved (ajándékozó)';

  @override
  String get giftMessage => 'Üzenet az ajándékhoz';

  @override
  String get passBuy => 'Tovább a fizetéshez';

  @override
  String get passAfterPayment =>
      'A fizetés a böngészőben történik. Utána a bérleted a Fiókom fülön jelenik meg (a vásárláskor megadott e-mail-címmel belépve).';

  @override
  String get reviewTitle => 'Értékelés';

  @override
  String get reviewQuestion => 'Hogy tetszett a szolgáltatás?';

  @override
  String get reviewFeedback => 'Szeretnél hozzáfűzni valamit? (nem kötelező)';

  @override
  String get reviewSubmit => 'Értékelés elküldése';

  @override
  String get reviewThanks => 'Köszönjük az értékelésed!';

  @override
  String get reviewOnGoogle => 'Értékelés a Google-on is';

  @override
  String get groupSessions => 'Csoportos alkalmak';

  @override
  String get groupSessionTitle => 'Jelentkezés alkalomra';

  @override
  String placesLeft(int count) {
    return '$count szabad hely';
  }

  @override
  String get sessionFull => 'Betelt';

  @override
  String get joinSession => 'Jelentkezem';

  @override
  String get joinWaitlist => 'Várólistára iratkozom';

  @override
  String get waitlistJoined =>
      'Feliratkoztál a várólistára, értesítünk, ha felszabadul egy időpont.';

  @override
  String get orSignInWith => 'vagy';

  @override
  String get continueWithApple => 'Folytatás Apple-fiókkal';

  @override
  String get continueWithGoogle => 'Folytatás Google-fiókkal';

  @override
  String get settingsTitle => 'Beállítások';

  @override
  String get appLockTitle => 'Zárolás biometrikus azonosítással';

  @override
  String get appLockSubtitle =>
      'Az app megnyitásához ujjlenyomat, arcfelismerés vagy az eszköz zárja kell.';

  @override
  String get appLockUnavailable =>
      'Az eszközön nincs beállított biometrikus azonosító vagy képernyőzár.';

  @override
  String get unlockTitle => 'Az alkalmazás zárolva van';

  @override
  String get unlockButton => 'Feloldás';

  @override
  String get unlockReason => 'Told fel a Kalenda zárolását';

  @override
  String get unlockFailed => 'Az azonosítás nem sikerült.';

  @override
  String get ownerNewBooking => 'Új foglalás';

  @override
  String get ownerCreateBooking => 'Foglalás felvitele';

  @override
  String get ownerCustomerLabel => 'Ügyfél';

  @override
  String get newCustomerOption => 'Új ügyfél';

  @override
  String get serviceLabel => 'Szolgáltatás';

  @override
  String get sendEmailLabel => 'Értesítő e-mail az ügyfélnek';

  @override
  String get backToStart => 'Vissza a kezdőlapra';

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

  @override
  String get staffLoginLink => 'Munkatárs vagy vállalkozó vagyok';

  @override
  String get staffLoginTitle => 'Belépés munkatársként';

  @override
  String get staffLoginIntro =>
      'Lépj be a Kalenda-fiókod e-mail-címével és jelszavával.';

  @override
  String get password => 'Jelszó';

  @override
  String get staffToday => 'Ma';

  @override
  String get staffCalendar => 'Naptár';

  @override
  String get staffLeaves => 'Szabadság';

  @override
  String get staffNoProfile =>
      'Ehhez a fiókhoz nincs munkatársi profil. A vállalkozói felület egyelőre a weben érhető el.';

  @override
  String todayCount(int count) {
    return '$count foglalás ma';
  }

  @override
  String get upcomingAppointments => 'Következő foglalások';

  @override
  String get noAppointments => 'Nincs foglalás.';

  @override
  String get clockIn => 'Munkakezdés';

  @override
  String get clockOut => 'Munkavégzés vége';

  @override
  String clockedInSince(String time) {
    return 'Bent vagy $time óta';
  }

  @override
  String get breakMinutes => 'Szünet (perc)';

  @override
  String get statusPending => 'Függő';

  @override
  String get statusConfirmed => 'Megerősítve';

  @override
  String get statusCancelled => 'Lemondva';

  @override
  String get statusCompleted => 'Lezárva';

  @override
  String get statusNoShow => 'Nem jelent meg';

  @override
  String get statusApproved => 'Jóváhagyva';

  @override
  String get statusRejected => 'Elutasítva';

  @override
  String get actionConfirm => 'Megerősítés';

  @override
  String get actionComplete => 'Megjelent / lezárás';

  @override
  String get actionNoShow => 'Nem jelent meg';

  @override
  String get actionCancel => 'Lemondás';

  @override
  String get newLeave => 'Szabadság kérése';

  @override
  String get leaveReason => 'Indok (nem kötelező)';

  @override
  String get withdraw => 'Visszavonás';

  @override
  String get pickDates => 'Válaszd ki az időszakot';

  @override
  String get previousWeek => 'Előző hét';

  @override
  String get nextWeek => 'Következő hét';

  @override
  String get leaveDay => 'Szabadság';

  @override
  String get ownerLoginLink => 'Vállalkozóként lépek be';

  @override
  String get ownerOverview => 'Áttekintés';

  @override
  String get ownerCustomers => 'Ügyfelek';

  @override
  String get ownerNoBusiness => 'Ehhez a fiókhoz nem tartozik vállalkozás.';

  @override
  String get weekRevenueTitle => 'Heti bevétel';

  @override
  String weekRevenueSoFar(String amount) {
    return 'Eddig: $amount';
  }

  @override
  String weekRevenueChange(String percent) {
    return '$percent% az előző héthez képest';
  }

  @override
  String get receivablesTitle => 'Kintlévőségek';

  @override
  String receivablesOutstanding(String amount, int count) {
    return 'Nyitott: $amount ($count db)';
  }

  @override
  String receivablesOverdue(String amount, int count) {
    return 'Lejárt: $amount ($count db)';
  }

  @override
  String lowStock(int count) {
    return '$count termék fogy';
  }

  @override
  String get todaysBookings => 'Mai foglalások';

  @override
  String get searchCustomers => 'Keresés név, e-mail vagy telefon szerint';

  @override
  String customerStats(int total, String spent, int noShow) {
    return '$total foglalás · $spent · $noShow meg nem jelenés';
  }

  @override
  String get favorites => 'Kedvenceid';

  @override
  String get recentBusinesses => 'Legutóbb megnyitott';

  @override
  String get addFavorite => 'Hozzáadás a kedvencekhez';

  @override
  String get removeFavorite => 'Eltávolítás a kedvencek közül';

  @override
  String get offlineBanner => 'Nincs internetkapcsolat';

  @override
  String get next => 'Tovább';

  @override
  String get skip => 'Kihagyom';

  @override
  String get getStarted => 'Kezdjük';

  @override
  String get onboardingTitle1 => 'Találd meg a helyed';

  @override
  String get onboardingText1 =>
      'Szalonok, stúdiók, edzők – keresd meg név szerint, link alapján vagy olvasd be a QR-kódot.';

  @override
  String get onboardingTitle2 => 'Foglalj pár koppintással';

  @override
  String get onboardingText2 =>
      'Válassz szolgáltatást, szakembert és szabad időpontot, a visszaigazolás azonnal megvan.';

  @override
  String get onboardingTitle3 => 'Mindig tudsz róla';

  @override
  String get onboardingText3 =>
      'Emlékeztetőt kapsz, a foglalásaidat egy helyen látod, és bármikor áthelyezheted vagy lemondhatod.';

  @override
  String get stepStaff => 'Kivel és mit?';

  @override
  String get stepDateTime => 'Mikor?';

  @override
  String get stepDetails => 'Adataid';

  @override
  String get pickAnotherDate => 'Másik nap';

  @override
  String get dayToday => 'Ma';

  @override
  String get dayTomorrow => 'Holnap';

  @override
  String get bookingDoneTitle => 'Sikeres foglalás!';

  @override
  String get statusLabelPrefix => 'Állapot';

  @override
  String get customerLabel => 'Ügyfél';

  @override
  String get offlineShowingSaved => 'Mentett adatok látszanak';

  @override
  String get remindersTitle => 'Értesítések';

  @override
  String get profileInitial => 'Profil';

  @override
  String get actionDelete => 'Törlés';

  @override
  String get actionAdd => 'Új';

  @override
  String get dialogCancel => 'Mégse';

  @override
  String get fieldDescription => 'Leírás';

  @override
  String get fieldColor => 'Szín';

  @override
  String get fieldActive => 'Aktív';

  @override
  String get fieldAddress => 'Cím';

  @override
  String get newService => 'Új szolgáltatás';

  @override
  String get editService => 'Szolgáltatás szerkesztése';

  @override
  String get depositTypeLabel => 'Előleg';

  @override
  String get depositNone => 'Nincs';

  @override
  String get depositPercentage => 'Százalék';

  @override
  String get depositFull => 'Teljes összeg';

  @override
  String get depositPercentLabel => 'Előleg (%)';

  @override
  String get bufferBefore => 'Előkészület (perc)';

  @override
  String get bufferAfter => 'Pihenő utána (perc)';

  @override
  String get groupServiceLabel => 'Csoportos alkalom';

  @override
  String get rentalServiceLabel => 'Bérelhető (pálya, terem)';

  @override
  String get maxDurationLabel => 'Legfeljebb (perc)';

  @override
  String get durationStepLabel => 'Időtartam lépésköz (perc)';

  @override
  String get deleteServiceTitle => 'Törlöd a szolgáltatást?';

  @override
  String get deleteServiceText =>
      'A szolgáltatás nem lesz többé foglalható. Ha már vannak foglalások rá, a szerver megakadályozhatja a törlést.';

  @override
  String get newStaff => 'Új munkatárs';

  @override
  String get editStaff => 'Munkatárs szerkesztése';

  @override
  String get staffBio => 'Bemutatkozás';

  @override
  String get staffKindLabel => 'Típus';

  @override
  String get staffKindPerson => 'Személy';

  @override
  String get staffKindResource => 'Erőforrás (pálya, terem)';

  @override
  String get staffServicesTitle => 'Szolgáltatások';

  @override
  String get inviteStaff => 'Meghívó küldése';

  @override
  String get inviteSent => 'A meghívó elment.';

  @override
  String get revokeAccess => 'Hozzáférés megvonása';

  @override
  String get deleteStaffTitle => 'Törlöd a munkatársat?';

  @override
  String get deleteStaffText => 'A munkatárs nem lesz többé foglalható.';

  @override
  String get customerDetailsTitle => 'Ügyfél adatai';

  @override
  String get customerBookings => 'Foglalások';

  @override
  String get customerCompleted => 'Teljesített';

  @override
  String get customerCancelled => 'Lemondott';

  @override
  String get customerNoShows => 'Meg nem jelent';

  @override
  String get customerSpent => 'Összes költés';

  @override
  String get customerNote => 'Belső megjegyzés';

  @override
  String get customerDepositExempt => 'Előleg alól mentesítve';

  @override
  String get customerNoShowFlag => 'Figyelmeztetés: többször nem jelent meg';

  @override
  String get billingTitle => 'Számlázási adatok';

  @override
  String get billingPostCode => 'Irányítószám';

  @override
  String get billingCity => 'Település';

  @override
  String get billingTaxNumber => 'Adószám';

  @override
  String get billingEmail => 'Számlázási e-mail';

  @override
  String get loyaltyTitleOwner => 'Hűségpontok';

  @override
  String get loyaltyAdjust => 'Pontok módosítása';

  @override
  String get loyaltyAdjustPoints => 'Pont (negatív is lehet)';

  @override
  String get loyaltyRedeem => 'Jutalom beváltása';

  @override
  String loyaltyRedeemed(String discount) {
    return 'Beváltva: $discount kedvezmény';
  }

  @override
  String get loyaltyNoReward => 'Nincs elég pont a jutalomhoz.';

  @override
  String get loyaltyHistory => 'Előzmények';

  @override
  String get ownerExpenses => 'Költségek';

  @override
  String get ownerReviews => 'Értékelések';

  @override
  String get ownerPasses => 'Bérletek és utalványok';

  @override
  String get ownerWaitlist => 'Várólista';

  @override
  String get ownerActivityLog => 'Tevékenység-napló';

  @override
  String get newExpense => 'Új költség';

  @override
  String get expenseCategory => 'Kategória';

  @override
  String get expenseAmount => 'Összeg (Ft)';

  @override
  String get expenseVendor => 'Szállító';

  @override
  String get expenseRecurring => 'Ismétlődő költség';

  @override
  String get expenseDate => 'Dátum';

  @override
  String expensesTotal(String total) {
    return 'Összesen: $total';
  }

  @override
  String get deleteExpenseTitle => 'Törlöd a költséget?';

  @override
  String get deleteExpenseText => 'A költség kikerül a kimutatásokból.';

  @override
  String get reviewsEnabled => 'Értékelés-kérés a látogatás után';

  @override
  String get googleReviewUrl => 'Google-értékelés linkje';

  @override
  String reviewsSummary(String average, int count) {
    return '$average átlag · $count értékelés';
  }

  @override
  String get passKindPass => 'Bérlet';

  @override
  String get passKindVoucher => 'Utalvány';

  @override
  String passRecipient(String name) {
    return 'Címzett: $name';
  }

  @override
  String get waitlistNotify => 'Értesítés küldése';

  @override
  String get waitlistNotified => 'Értesítve';

  @override
  String get waitlistWaiting => 'Vár';

  @override
  String get waitlistBooked => 'Lefoglalta';

  @override
  String get waitlistExpired => 'Lejárt';

  @override
  String get waitlistRemove => 'Eltávolítás';

  @override
  String get activitySearch => 'Keresés a naplóban';

  @override
  String get ownerMore => 'Továbbiak';

  @override
  String get menuGroupBooking => 'Foglalás és ügyfelek';

  @override
  String get menuGroupSales => 'Értékesítés és marketing';

  @override
  String get menuGroupFinance => 'Pénzügy';

  @override
  String get menuGroupOperations => 'Működés';

  @override
  String get menuGroupSettings => 'Beállítások';

  @override
  String get menuNotInPlan => 'A csomagod nem tartalmazza';

  @override
  String get subscriptionTitle => 'Előfizetés';

  @override
  String planName(String plan) {
    return 'Csomag: $plan';
  }

  @override
  String get planTrial => 'Próba';

  @override
  String get planBasic => 'Alap';

  @override
  String get planProfessional => 'Profi';

  @override
  String trialDaysLeft(int days) {
    return 'A próbaidőszakból $days nap van hátra.';
  }

  @override
  String get subscriptionLocked =>
      'A vállalkozás zárolva van, a csomag lejárt vagy felfüggesztették.';

  @override
  String subscriptionRenewsOn(String date) {
    return 'A csomag érvényes eddig: $date';
  }

  @override
  String get subscriptionCancelsAtEnd =>
      'Az előfizetés az időszak végén lejár.';

  @override
  String get subscriptionManageOnWeb =>
      'Az előfizetés vásárlása és módosítása a webes felületen történik. Az alkalmazás csak a jelenlegi csomagot mutatja.';

  @override
  String get openWebApp => 'Megnyitás a weben';

  @override
  String get subscriptionFeatures => 'A csomag funkciói';

  @override
  String get appointmentDetailTitle => 'Foglalás részletei';

  @override
  String get paymentsTitle => 'Fizetés';

  @override
  String paidAmount(String amount) {
    return 'Befizetve: $amount';
  }

  @override
  String dueAmount(String amount) {
    return 'Fizetendő: $amount';
  }

  @override
  String get coveredByPass => 'Bérlet fedezi';

  @override
  String get documentsTitle => 'Bizonylatok';

  @override
  String get docReceipt => 'Nyugta';

  @override
  String get docReceiptDeposit => 'Nyugta (előleg)';

  @override
  String get docInvoice => 'Számla';

  @override
  String get docInvoiceDeposit => 'Előlegszámla';

  @override
  String get docInvoiceFinal => 'Végszámla';

  @override
  String get docCancelled => 'Sztornózva';

  @override
  String get docCancel => 'Sztornó';

  @override
  String get docCancelReason => 'Sztornó oka';

  @override
  String get docCancelTitle => 'Sztornózod a bizonylatot?';

  @override
  String get docOpenPdf => 'PDF megnyitása';

  @override
  String get docPdfFailed => 'Nincs alkalmazás a PDF megnyitásához.';

  @override
  String issueDocument(String document) {
    return '$document kiállítása';
  }

  @override
  String get payMethod => 'Fizetés módja';

  @override
  String get methodOnline => 'Online bankkártya';

  @override
  String get methodCard => 'Bankkártya (helyszínen)';

  @override
  String get methodCash => 'Készpénz';

  @override
  String get methodTransfer => 'Átutalás';

  @override
  String get methodOther => 'Egyéb';

  @override
  String get methodVoucher => 'Utalvány';

  @override
  String get refundAsk => 'Visszatérítsd a befizetett összeget is?';

  @override
  String get refundYes => 'Igen, visszatérítés';

  @override
  String get refundNo => 'Nem';

  @override
  String get bookingAddons => 'Kiegészítők';

  @override
  String get newInvoice => 'Új számla';

  @override
  String get invoiceCustomerName => 'Ügyfél neve';

  @override
  String get invoiceItemsTitle => 'Tételek';

  @override
  String get invoiceItemName => 'Megnevezés';

  @override
  String get invoiceItemQty => 'Menny.';

  @override
  String get invoiceItemPrice => 'Bruttó egységár (Ft)';

  @override
  String get invoiceAddItem => 'Új tétel';

  @override
  String get invoiceDueDays => 'Fizetési határidő (nap)';

  @override
  String get invoiceAlreadyPaid => 'Már ki van fizetve';

  @override
  String invoiceTotalLine(String total) {
    return 'Összesen: $total';
  }

  @override
  String get invoiceNeedsItem => 'Adj meg legalább egy tételt névvel és árral.';

  @override
  String get ownerRegister => 'Pénztár';

  @override
  String get registerIncome => 'Bevétel';

  @override
  String get registerCashIn => 'Befizetés';

  @override
  String get registerCashOut => 'Kivét';

  @override
  String get registerOpening => 'Nyitó készpénz';

  @override
  String get registerExpected => 'Várható készpénz';

  @override
  String get registerOnline => 'Online fizetések';

  @override
  String get registerUnpaid => 'Kifizetetlen foglalások';

  @override
  String get registerNoEntries => 'Ezen a napon még nincs tétel.';

  @override
  String get registerNewEntry => 'Új tétel';

  @override
  String get registerDescription => 'Leírás (pl. borravaló, váltópénz)';

  @override
  String get registerClose => 'Nap zárása';

  @override
  String get registerCounted => 'Leszámolt készpénz (Ft)';

  @override
  String get registerClosed => 'A nap le van zárva';

  @override
  String registerDifference(String amount) {
    return 'Eltérés: $amount';
  }

  @override
  String get registerReopen => 'Zárás visszavonása';

  @override
  String registerPayWith(String method) {
    return 'Kifizetés: $method';
  }

  @override
  String get registerDeleteTitle => 'Törlöd a tételt?';

  @override
  String get registerToday => 'Ma';

  @override
  String get ownerProducts => 'Termékek és készlet';

  @override
  String get ownerSuppliers => 'Beszállítók';

  @override
  String get ownerPurchasing => 'Beszerzés';

  @override
  String get newProduct => 'Új termék';

  @override
  String get editProduct => 'Termék szerkesztése';

  @override
  String get productPrice => 'Eladási ár (Ft)';

  @override
  String get productCost => 'Beszerzési ár (Ft)';

  @override
  String get productStock => 'Készlet (db)';

  @override
  String get productSku => 'Cikkszám';

  @override
  String get productLowThreshold => 'Alacsony készlet küszöbe';

  @override
  String get productLowStock => 'Alacsony készlet';

  @override
  String get productsLowOnly => 'Csak alacsony készlet';

  @override
  String get productSell => 'Eladás';

  @override
  String get sellQuantity => 'Mennyiség';

  @override
  String get productSold => 'Az eladás rögzítve.';

  @override
  String stockLabel(int count) {
    return 'Készlet: $count';
  }

  @override
  String get deleteProductTitle => 'Törlöd a terméket?';

  @override
  String get newSupplier => 'Új beszállító';

  @override
  String get editSupplier => 'Beszállító szerkesztése';

  @override
  String get supplierContact => 'Kapcsolattartó';

  @override
  String get supplierTax => 'Adószám';

  @override
  String get deleteSupplierTitle => 'Törlöd a beszállítót?';

  @override
  String get newOrder => 'Új rendelés';

  @override
  String get orderSupplier => 'Beszállító';

  @override
  String get orderLines => 'Tételek';

  @override
  String get orderLineDescription => 'Megnevezés';

  @override
  String get orderLineQty => 'Db';

  @override
  String get orderLineCost => 'Egységár (Ft)';

  @override
  String get orderAddLine => 'Új tétel';

  @override
  String get orderStatusDraft => 'Piszkozat';

  @override
  String get orderStatusOrdered => 'Leadva';

  @override
  String get orderStatusReceived => 'Bevételezve';

  @override
  String get orderStatusCancelled => 'Sztornózva';

  @override
  String get orderMarkOrdered => 'Leadás';

  @override
  String get orderReceive => 'Bevételezés';

  @override
  String get orderCancel => 'Sztornó';

  @override
  String orderExpected(String date) {
    return 'Várható: $date';
  }

  @override
  String get orderNeedsSupplier => 'Előbb vegyél fel egy beszállítót.';

  @override
  String get orderNeedsLine => 'Adj meg legalább egy tételt.';

  @override
  String get orderReceivedQty => 'Beérkezett (db)';

  @override
  String get ownerPassTypes => 'Bérlet- és utalvány-típusok';

  @override
  String get ownerLoyalty => 'Hűségprogram';

  @override
  String get ownerCampaigns => 'Kampányok';

  @override
  String get newPassType => 'Új típus';

  @override
  String get passTypeKind => 'Fajta';

  @override
  String get passTypeSessions => 'Alkalmak száma';

  @override
  String get passTypeValue => 'Névérték (Ft)';

  @override
  String get passTypePrice => 'Ár (Ft)';

  @override
  String get passTypeValidity => 'Érvényesség (nap)';

  @override
  String get passTypeService => 'Szolgáltatás (nem kötelező)';

  @override
  String get passTypeAnyService => 'Bármelyik';

  @override
  String passTypeSoldCount(int count) {
    return '$count eladva';
  }

  @override
  String get passTypeSell => 'Eladás';

  @override
  String get passTypePurchaserEmail => 'Vevő e-mail-címe';

  @override
  String get passTypeRecipient => 'Címzett neve (ajándéknál)';

  @override
  String get passTypeDeleteTitle => 'Törlöd a típust?';

  @override
  String get passTypeInactive => 'Kikapcsolva';

  @override
  String get loyaltyEnabled => 'Hűségprogram bekapcsolva';

  @override
  String get loyaltyPointsPer1000 => 'Pont minden 1000 Ft után';

  @override
  String get loyaltyRewardPointsLabel => 'Jutalomhoz szükséges pont';

  @override
  String get loyaltyRewardValueLabel => 'Jutalom értéke (Ft)';

  @override
  String loyaltyMembers(int count) {
    return 'Tagok: $count';
  }

  @override
  String loyaltyOutstanding(int count) {
    return 'Ki nem váltott pont: $count';
  }

  @override
  String get loyaltyLeaderboard => 'Ranglista';

  @override
  String get newCampaign => 'Új kampány';

  @override
  String get editCampaign => 'Kampány szerkesztése';

  @override
  String get campaignName => 'Belső név';

  @override
  String get campaignSubject => 'Levél tárgya';

  @override
  String get campaignBody => 'Levél szövege';

  @override
  String get campaignSegmentLabel => 'Célcsoport';

  @override
  String get segAll => 'Minden hozzájárult vendég';

  @override
  String get segInactive => 'Rég nem járt nálunk';

  @override
  String get segNew => 'Új vendégek';

  @override
  String get segService => 'Adott szolgáltatást igénybe vevők';

  @override
  String get segLoyalty => 'Hűségpontjuk már beváltható';

  @override
  String get segDays => 'Napok száma';

  @override
  String campaignAudience(int count) {
    return 'Ennyien kapnák meg: $count';
  }

  @override
  String get campaignStatusDraft => 'Piszkozat';

  @override
  String get campaignStatusSent => 'Elküldve';

  @override
  String get campaignSendTest => 'Próbalevél nekem';

  @override
  String campaignTestSent(String email) {
    return 'A próbalevél elment ide: $email';
  }

  @override
  String get campaignSend => 'Kiküldés';

  @override
  String get campaignSendConfirm =>
      'Kiküldöd a kampányt a célcsoportnak? Ez nem vonható vissza.';

  @override
  String campaignSent(int count) {
    return 'Kiküldve $count címzettnek.';
  }

  @override
  String get campaignDeleteTitle => 'Törlöd a kampányt?';

  @override
  String campaignConsents(int count, int limit) {
    return 'Hozzájárult vendégek: $count · napi limit: $limit';
  }

  @override
  String get ownerGroupSessions => 'Csoportos alkalmak';

  @override
  String get ownerBreaks => 'Szünetek';

  @override
  String get ownerTimesheet => 'Munkaidő';

  @override
  String get newGroupSession => 'Új alkalom';

  @override
  String get groupCapacity => 'Férőhely';

  @override
  String get groupRepeatWeeks => 'Ismétlés (hét)';

  @override
  String get groupTime => 'Kezdés (ÓÓ:PP)';

  @override
  String groupBooked(int booked, int capacity) {
    return '$booked/$capacity fő';
  }

  @override
  String get groupAddAttendee => 'Résztvevő felvétele';

  @override
  String get groupCancelTitle => 'Lemondod az alkalmat?';

  @override
  String get groupCancelText => 'A jelentkezők értesítést kapnak.';

  @override
  String get groupCancelled => 'Lemondva';

  @override
  String get groupNoAttendees => 'Még nincs jelentkező.';

  @override
  String get breaksNone => 'Nincs szünet felvéve.';

  @override
  String get newBreak => 'Új szünet';

  @override
  String get breakDay => 'Nap';

  @override
  String get breakFrom => 'Kezdete (ÓÓ:PP)';

  @override
  String get breakTo => 'Vége (ÓÓ:PP)';

  @override
  String get breakLabel => 'Megnevezés (pl. ebéd)';

  @override
  String get weekdaySun => 'Vasárnap';

  @override
  String get weekdayMon => 'Hétfő';

  @override
  String get weekdayTue => 'Kedd';

  @override
  String get weekdayWed => 'Szerda';

  @override
  String get weekdayThu => 'Csütörtök';

  @override
  String get weekdayFri => 'Péntek';

  @override
  String get weekdaySat => 'Szombat';

  @override
  String timesheetWorked(String hours) {
    return 'Ledolgozott: $hours';
  }

  @override
  String timesheetPlanned(String hours) {
    return 'Tervezett: $hours';
  }

  @override
  String timesheetOvertime(String hours) {
    return 'Túlóra: $hours';
  }

  @override
  String timesheetPay(String amount) {
    return 'Becsült bér: $amount';
  }

  @override
  String get timesheetClosed => 'A hónap le van zárva';

  @override
  String get timesheetClose => 'Hónap zárása';

  @override
  String get timesheetReopen => 'Zárás visszavonása';

  @override
  String timesheetStale(int count) {
    return '$count nyitva felejtett műszak';
  }

  @override
  String get timesheetNewEntry => 'Műszak felvétele';

  @override
  String get timesheetStaff => 'Munkatárs';

  @override
  String get timesheetIn => 'Kezdés';

  @override
  String get timesheetOut => 'Vége';

  @override
  String get timesheetBreakMinutes => 'Szünet (perc)';

  @override
  String get timesheetEntries => 'Műszakok';

  @override
  String timesheetOpenSince(String time) {
    return 'Bent van: $time';
  }

  @override
  String get ownerSettings => 'Beállítások';

  @override
  String get settingsBusiness => 'Vállalkozás adatai';

  @override
  String get settingsBookingPage => 'Foglalási oldal';

  @override
  String get settingsPolicy => 'Szabályzat';

  @override
  String get settingsPayments => 'Fizetés';

  @override
  String get settingsInvoicing => 'Számlázás';

  @override
  String get settingsCalendarSync => 'Naptár-szinkron';

  @override
  String get settingsMode => 'Szóló mód (egy munkatárs)';

  @override
  String get businessCity => 'Település';

  @override
  String get businessDescription => 'Bemutatkozás';

  @override
  String get bookingExtraInfo => 'Kiegészítő információ a foglalási oldalon';

  @override
  String get bookingGroupEnabled => 'Csoportos alkalmak a foglalási oldalon';

  @override
  String get bookingRentalsEnabled => 'Bérelhető erőforrások (pálya, terem)';

  @override
  String get bookingLogo => 'Logó';

  @override
  String get bookingCover => 'Borítókép';

  @override
  String get imageUpload => 'Feltöltés';

  @override
  String get imageRemove => 'Törlés';

  @override
  String get policyCancelHours => 'Lemondási határidő (óra)';

  @override
  String get policyReschedule => 'Az ügyfél áthelyezheti a foglalást';

  @override
  String get policyNoShowThreshold => 'Meg nem jelenés küszöb (alkalom)';

  @override
  String get policyNoShowDeposit => 'Előleg a küszöb után (%)';

  @override
  String get paymentRefundCutoff => 'Visszatérítés határideje (óra)';

  @override
  String get paymentOnline => 'Online fizetés bekapcsolva';

  @override
  String get paymentStripeNotConnected => 'A Stripe-fiók még nincs összekötve.';

  @override
  String get paymentStripeConnect => 'Stripe-fiók összekötése';

  @override
  String get paymentStripeContinue => 'Beállítás folytatása a Stripe-nál';

  @override
  String get paymentStripeDashboard => 'Stripe-irányítópult';

  @override
  String get paymentStripeSync => 'Állapot frissítése';

  @override
  String get paymentStripeReady => 'A Stripe-fiók készen áll a fogadásra.';

  @override
  String get paymentStripePending =>
      'A Stripe-fiók beállítása még nem fejeződött be.';

  @override
  String paymentFee(String percent) {
    return 'Platformdíj: $percent%';
  }

  @override
  String get invoicingEnabled => 'Automatikus számlázás';

  @override
  String get invoicingProvider => 'Szolgáltató';

  @override
  String get invoicingDocType => 'Bizonylat típusa';

  @override
  String get invoicingVat => 'ÁFA-kulcs';

  @override
  String get invoicingAutoSend => 'Küldés az ügyfélnek';

  @override
  String get invoicingApiKey => 'API-kulcs';

  @override
  String get invoicingAgentKey => 'Ügynök-kulcs (Számlázz.hu)';

  @override
  String get invoicingKeySet => 'Megadva (üresen hagyva marad)';

  @override
  String get invoicingBlock => 'Számlatömb azonosítója';

  @override
  String get invoicingReceiptBlock => 'Nyugtatömb azonosítója';

  @override
  String get calendarBusinessFeed => 'A vállalkozás naptára';

  @override
  String get calendarCopy => 'Hivatkozás másolása';

  @override
  String get calendarCopied => 'A hivatkozás a vágólapon van.';

  @override
  String get calendarRegenerate => 'Új hivatkozás';

  @override
  String get calendarRegenerateTitle => 'Új hivatkozást generálsz?';

  @override
  String get calendarRegenerateText =>
      'A régi hivatkozás megszűnik, a naptáraidban újra fel kell venned az újat.';

  @override
  String get settingsSaved => 'Mentve';

  @override
  String get forgotPassword => 'Elfelejtett jelszó';

  @override
  String get forgotPasswordText =>
      'Add meg az e-mail-címed, és küldünk egy linket az új jelszó beállításához.';

  @override
  String get forgotPasswordSent =>
      'Ha a cím szerepel a rendszerben, elküldtük a levelet.';

  @override
  String get sendLinkShort => 'Küldés';

  @override
  String get registerBusinessLink => 'Új vállalkozást indítok';

  @override
  String get registerTitle => 'Regisztráció';

  @override
  String get registerIntro =>
      'Hozd létre a fiókod, utána pár perc alatt beállíthatod a vállalkozásod.';

  @override
  String get passwordMin => 'A jelszó legalább 8 karakter legyen.';

  @override
  String get createAccount => 'Fiók létrehozása';

  @override
  String get setupTitle => 'Vállalkozás létrehozása';

  @override
  String get setupIntro =>
      'Pár adat, és kész a foglalási oldalad. Mindent később is módosíthatsz.';

  @override
  String get setupBusinessName => 'A vállalkozás neve';

  @override
  String get setupSolo => 'Egyedül dolgozom';

  @override
  String get setupServices => 'Első szolgáltatásaid';

  @override
  String get setupStaff => 'Munkatársak';

  @override
  String get setupAddService => 'Újabb szolgáltatás';

  @override
  String get setupAddStaff => 'Újabb munkatárs';

  @override
  String get setupCreate => 'Létrehozás';

  @override
  String get setupNeedsService =>
      'Adj meg legalább egy szolgáltatást névvel és időtartammal.';

  @override
  String get setupCta => 'Még nincs vállalkozásod';

  @override
  String get setupCtaText =>
      'Hozd létre az elsőt, és elkezdheted fogadni a foglalásokat.';

  @override
  String get accountSecurityTitle => 'Fiók és visszajelzés';

  @override
  String get currentPassword => 'Jelenlegi jelszó';

  @override
  String get newPassword => 'Új jelszó';

  @override
  String get changePassword => 'Jelszó módosítása';

  @override
  String get feedbackTitle => 'Visszajelzés';

  @override
  String get feedbackTypeBug => 'Hiba';

  @override
  String get feedbackTypeFeature => 'Ötlet';

  @override
  String get feedbackSubject => 'Tárgy';

  @override
  String get feedbackMessage => 'Üzenet';

  @override
  String get feedbackSend => 'Küldés';

  @override
  String get feedbackThanks => 'Köszönjük a visszajelzést!';

  @override
  String get adminTitle => 'Adminisztráció';

  @override
  String get adminOverview => 'Áttekintés';

  @override
  String get adminBusinesses => 'Vállalkozások';

  @override
  String get adminAppointments => 'Foglalások';

  @override
  String get adminFeedback => 'Visszajelzések';

  @override
  String adminUsers(int count) {
    return 'Felhasználók: $count';
  }

  @override
  String adminBusinessCount(int count) {
    return 'Vállalkozások: $count';
  }

  @override
  String adminAppointmentCount(int count) {
    return 'Foglalások: $count';
  }

  @override
  String adminToday(int count) {
    return 'Ma: $count';
  }

  @override
  String adminThisMonth(int count) {
    return 'Ebben a hónapban: $count';
  }

  @override
  String adminActiveSubscriptions(int count) {
    return 'Aktív előfizetés: $count';
  }

  @override
  String adminPlans(int free, int basic, int pro) {
    return 'Csomagok: próba $free · alap $basic · profi $pro';
  }

  @override
  String get adminActive => 'Aktív';

  @override
  String get adminInactive => 'Kikapcsolva';

  @override
  String get adminAllStatuses => 'Mind';

  @override
  String get feedbackStatusNew => 'Beérkezett';

  @override
  String get feedbackStatusInProgress => 'Folyamatban';

  @override
  String get feedbackStatusResolved => 'Megoldva';

  @override
  String get feedbackStatusRejected => 'Elutasítva';

  @override
  String get feedbackAnswer => 'Válasz';

  @override
  String get feedbackAnswerPlaceholder =>
      'Válasz a felhasználónak (nem kötelező)';

  @override
  String get ownerAddons => 'Kiegészítők';

  @override
  String get newAddon => 'Új kiegészítő';

  @override
  String get addonPrice => 'Ár (Ft)';

  @override
  String get addonMinutes => 'Időtartam (perc)';

  @override
  String get addonServices => 'Mely szolgáltatásokhoz';

  @override
  String get addonDeleteTitle => 'Törlöd a kiegészítőt?';

  @override
  String get staffHoursButton => 'Munkaidő';

  @override
  String get staffPayButton => 'Bér és jutalék';

  @override
  String get staffPhotoButton => 'Fotó feltöltése';

  @override
  String get dayOff => 'Szabadnap';

  @override
  String get payType => 'Bérezés módja';

  @override
  String get payTypeNone => 'Nincs megadva';

  @override
  String get payTypeHourly => 'Órabér';

  @override
  String get payTypeMonthly => 'Havi bér';

  @override
  String get payRate => 'Díj (Ft)';

  @override
  String get payHoursSource => 'Órák forrása';

  @override
  String get payHoursSchedule => 'Beosztás';

  @override
  String get payHoursClock => 'Időmérés';

  @override
  String get payHoursAppointments => 'Foglalások';

  @override
  String get payServiceCommission => 'Szolgáltatás-jutalék (%)';

  @override
  String get payProductCommission => 'Termék-jutalék (%)';

  @override
  String get serviceMaterials => 'Anyagfelhasználás';

  @override
  String get serviceImage => 'Kép feltöltése';

  @override
  String get materialQuantity => 'Mennyiség alkalmanként';

  @override
  String get portalTimesheetTitle => 'Munkaidőm';

  @override
  String get portalProfileTitle => 'Profilom';

  @override
  String get portalCalendarFeed => 'Naptár-hivatkozásom';

  @override
  String portalPlanned(String hours) {
    return 'Tervezett: $hours';
  }

  @override
  String portalClocked(String hours) {
    return 'Bélyegzett: $hours';
  }

  @override
  String get ownerPayouts => 'Kifizetések';

  @override
  String get ownerMissingDocuments => 'Hiányzó bizonylatok';

  @override
  String get missingDocumentsNone => 'Nincs kimaradt bizonylat.';

  @override
  String get payoutLines => 'A kifizetés tételei';

  @override
  String payoutGross(String amount) {
    return 'Bruttó: $amount';
  }

  @override
  String payoutFee(String amount) {
    return 'Díj: $amount';
  }

  @override
  String payoutNet(String amount) {
    return 'Nettó: $amount';
  }

  @override
  String get exportLabel => 'Exportálás';

  @override
  String get exportAccountingLabel => 'Könyvelői csomag letöltése';

  @override
  String get fileNotOpened => 'Nincs alkalmazás a fájl megnyitásához.';

  @override
  String get receiptUpload => 'Bizonylat feltöltése';

  @override
  String get receiptOpen => 'Bizonylat megnyitása';

  @override
  String get ownerAddLeave => 'Szabadság / zárva tartás';

  @override
  String get leaveWholeBusiness => 'Az egész vállalkozás';

  @override
  String get leaveCancelAffected => 'Az érintett foglalások lemondása';

  @override
  String leaveAffected(int count) {
    return '$count foglalást érint';
  }

  @override
  String leaveCreatedAffected(int count) {
    return 'Felvéve. Érintett foglalás: $count.';
  }

  @override
  String get ownerNotifications => 'Értesítések';

  @override
  String get markAllRead => 'Mind olvasott';

  @override
  String get customerInvoicesTitle => 'Számláim';

  @override
  String get invoiceOpenPdf => 'Számla megnyitása';

  @override
  String get rentalsTitle => 'Bérelhető';

  @override
  String rentalPricePerHour(String price) {
    return '$price / óra';
  }

  @override
  String get waitlistRemoveTitle => 'Leiratkozás a várólistáról';

  @override
  String get waitlistRemoveDone =>
      'Leiratkoztál a várólistáról, több értesítést nem küldünk.';

  @override
  String get unsubscribeTitle => 'Leiratkozás a hírlevélről';

  @override
  String get unsubscribeText => 'A leiratkozást a böngészőben fejezheted be.';

  @override
  String get openInBrowser => 'Megnyitás a böngészőben';

  @override
  String homeGreeting(String name) {
    return 'Szia, $name!';
  }

  @override
  String get homeGreetingGuest => 'Szia!';

  @override
  String get homeQuestion => 'Mikor jössz legközelebb?';

  @override
  String get nextAppointmentLabel => 'Következő időpontod';

  @override
  String get languageTitle => 'Nyelv';

  @override
  String get languageSystem => 'Rendszer';

  @override
  String get rebook => 'Újra foglalok';

  @override
  String get mapOpen => 'Térkép';

  @override
  String get mapDirections => 'Útvonal';
}
