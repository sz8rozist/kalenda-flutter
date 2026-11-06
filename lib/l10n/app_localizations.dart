import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hu'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In hu, this message translates to:
  /// **'Kalenda'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In hu, this message translates to:
  /// **'Belépés'**
  String get loginTitle;

  /// No description provided for @loginIntro.
  ///
  /// In hu, this message translates to:
  /// **'Add meg az e-mail-címed, és küldünk egy belépő linket.'**
  String get loginIntro;

  /// No description provided for @email.
  ///
  /// In hu, this message translates to:
  /// **'E-mail-cím'**
  String get email;

  /// No description provided for @sendLink.
  ///
  /// In hu, this message translates to:
  /// **'Belépő link küldése'**
  String get sendLink;

  /// No description provided for @linkSent.
  ///
  /// In hu, this message translates to:
  /// **'Ha az e-mail-cím szerepel nálunk, elküldtük a belépő linket.'**
  String get linkSent;

  /// No description provided for @tokenLabel.
  ///
  /// In hu, this message translates to:
  /// **'Kód a levélből'**
  String get tokenLabel;

  /// No description provided for @tokenHelp.
  ///
  /// In hu, this message translates to:
  /// **'Másold be a levélben kapott linket (vagy a kódot a /belepes/ után).'**
  String get tokenHelp;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In hu, this message translates to:
  /// **'Frissítés szükséges'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredText.
  ///
  /// In hu, this message translates to:
  /// **'Ez a verzió már nem támogatott. Kérjük, frissítsd az alkalmazást legalább a(z) {version} verzióra.'**
  String updateRequiredText(String version);

  /// No description provided for @updateNow.
  ///
  /// In hu, this message translates to:
  /// **'Frissítés'**
  String get updateNow;

  /// No description provided for @ownerStaff.
  ///
  /// In hu, this message translates to:
  /// **'Munkatársak'**
  String get ownerStaff;

  /// No description provided for @staffHasAccount.
  ///
  /// In hu, this message translates to:
  /// **'van fiókja'**
  String get staffHasAccount;

  /// No description provided for @upcomingBookings.
  ///
  /// In hu, this message translates to:
  /// **'{count} közelgő foglalás'**
  String upcomingBookings(int count);

  /// No description provided for @ownerManage.
  ///
  /// In hu, this message translates to:
  /// **'Kezelés'**
  String get ownerManage;

  /// No description provided for @ownerLeaves.
  ///
  /// In hu, this message translates to:
  /// **'Szabadságkérelmek'**
  String get ownerLeaves;

  /// No description provided for @noPendingLeaves.
  ///
  /// In hu, this message translates to:
  /// **'Nincs döntésre váró szabadságkérelem.'**
  String get noPendingLeaves;

  /// No description provided for @approveLeave.
  ///
  /// In hu, this message translates to:
  /// **'Jóváhagyás'**
  String get approveLeave;

  /// No description provided for @rejectLeave.
  ///
  /// In hu, this message translates to:
  /// **'Elutasítás'**
  String get rejectLeave;

  /// No description provided for @rejectNote.
  ///
  /// In hu, this message translates to:
  /// **'Indok (nem kötelező)'**
  String get rejectNote;

  /// No description provided for @ownerHours.
  ///
  /// In hu, this message translates to:
  /// **'Nyitvatartás'**
  String get ownerHours;

  /// No description provided for @closedDay.
  ///
  /// In hu, this message translates to:
  /// **'Zárva'**
  String get closedDay;

  /// No description provided for @ownerServices.
  ///
  /// In hu, this message translates to:
  /// **'Szolgáltatások'**
  String get ownerServices;

  /// No description provided for @serviceRental.
  ///
  /// In hu, this message translates to:
  /// **'Bérlés'**
  String get serviceRental;

  /// No description provided for @serviceDurationMinutes.
  ///
  /// In hu, this message translates to:
  /// **'Időtartam (perc)'**
  String get serviceDurationMinutes;

  /// No description provided for @servicePriceHuf.
  ///
  /// In hu, this message translates to:
  /// **'Ár (Ft)'**
  String get servicePriceHuf;

  /// No description provided for @ownerReports.
  ///
  /// In hu, this message translates to:
  /// **'Riportok'**
  String get ownerReports;

  /// No description provided for @previousMonth.
  ///
  /// In hu, this message translates to:
  /// **'Előző hónap'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In hu, this message translates to:
  /// **'Következő hónap'**
  String get nextMonth;

  /// No description provided for @reportRevenue.
  ///
  /// In hu, this message translates to:
  /// **'Bevétel'**
  String get reportRevenue;

  /// No description provided for @reportServices.
  ///
  /// In hu, this message translates to:
  /// **'Szolgáltatások'**
  String get reportServices;

  /// No description provided for @reportProducts.
  ///
  /// In hu, this message translates to:
  /// **'Termékek'**
  String get reportProducts;

  /// No description provided for @reportPasses.
  ///
  /// In hu, this message translates to:
  /// **'Bérletek'**
  String get reportPasses;

  /// No description provided for @reportVouchers.
  ///
  /// In hu, this message translates to:
  /// **'Utalványok'**
  String get reportVouchers;

  /// No description provided for @reportRevenueTotal.
  ///
  /// In hu, this message translates to:
  /// **'Bevétel összesen'**
  String get reportRevenueTotal;

  /// No description provided for @reportExpenses.
  ///
  /// In hu, this message translates to:
  /// **'Költségek'**
  String get reportExpenses;

  /// No description provided for @reportPayroll.
  ///
  /// In hu, this message translates to:
  /// **'Bérköltség (becslés)'**
  String get reportPayroll;

  /// No description provided for @reportMaterials.
  ///
  /// In hu, this message translates to:
  /// **'Anyagköltség'**
  String get reportMaterials;

  /// No description provided for @reportExpensesTotal.
  ///
  /// In hu, this message translates to:
  /// **'Költség összesen'**
  String get reportExpensesTotal;

  /// No description provided for @reportResult.
  ///
  /// In hu, this message translates to:
  /// **'Eredmény'**
  String get reportResult;

  /// No description provided for @reportReceivables.
  ///
  /// In hu, this message translates to:
  /// **'Kintlévőség a hónap végén'**
  String get reportReceivables;

  /// No description provided for @cashflowTitle.
  ///
  /// In hu, this message translates to:
  /// **'Cash flow előrejelzés'**
  String get cashflowTitle;

  /// No description provided for @cashflowPartial.
  ///
  /// In hu, this message translates to:
  /// **'folyamatban'**
  String get cashflowPartial;

  /// No description provided for @cashflowIn.
  ///
  /// In hu, this message translates to:
  /// **'Bevétel'**
  String get cashflowIn;

  /// No description provided for @cashflowOut.
  ///
  /// In hu, this message translates to:
  /// **'Kiadás'**
  String get cashflowOut;

  /// No description provided for @ownerInvoices.
  ///
  /// In hu, this message translates to:
  /// **'Számlák'**
  String get ownerInvoices;

  /// No description provided for @invoiceAll.
  ///
  /// In hu, this message translates to:
  /// **'Mind'**
  String get invoiceAll;

  /// No description provided for @invoiceUnpaid.
  ///
  /// In hu, this message translates to:
  /// **'Nyitott'**
  String get invoiceUnpaid;

  /// No description provided for @invoiceOverdue.
  ///
  /// In hu, this message translates to:
  /// **'Lejárt'**
  String get invoiceOverdue;

  /// No description provided for @invoicePaid.
  ///
  /// In hu, this message translates to:
  /// **'Kifizetve'**
  String get invoicePaid;

  /// No description provided for @invoiceCancelled.
  ///
  /// In hu, this message translates to:
  /// **'Sztornózva'**
  String get invoiceCancelled;

  /// No description provided for @paidOn.
  ///
  /// In hu, this message translates to:
  /// **'Kifizetve: {date}'**
  String paidOn(String date);

  /// No description provided for @dueOn.
  ///
  /// In hu, this message translates to:
  /// **'Esedékes: {date}'**
  String dueOn(String date);

  /// No description provided for @remindersSent.
  ///
  /// In hu, this message translates to:
  /// **'{count} emlékeztető elküldve'**
  String remindersSent(int count);

  /// No description provided for @payMethodCash.
  ///
  /// In hu, this message translates to:
  /// **'készpénz'**
  String get payMethodCash;

  /// No description provided for @payMethodCard.
  ///
  /// In hu, this message translates to:
  /// **'kártya'**
  String get payMethodCard;

  /// No description provided for @payMethodTransfer.
  ///
  /// In hu, this message translates to:
  /// **'átutalás'**
  String get payMethodTransfer;

  /// No description provided for @markPaidWith.
  ///
  /// In hu, this message translates to:
  /// **'Kifizetve – {method}'**
  String markPaidWith(String method);

  /// No description provided for @markUnpaid.
  ///
  /// In hu, this message translates to:
  /// **'Kifizetés visszavonása'**
  String get markUnpaid;

  /// No description provided for @sendReminder.
  ///
  /// In hu, this message translates to:
  /// **'Fizetési emlékeztető küldése'**
  String get sendReminder;

  /// No description provided for @scanQr.
  ///
  /// In hu, this message translates to:
  /// **'QR-kód beolvasása'**
  String get scanQr;

  /// No description provided for @scanQrTitle.
  ///
  /// In hu, this message translates to:
  /// **'QR-kód beolvasása'**
  String get scanQrTitle;

  /// No description provided for @scanQrHint.
  ///
  /// In hu, this message translates to:
  /// **'Irányítsd a kamerát a vállalkozás foglalási QR-kódjára.'**
  String get scanQrHint;

  /// No description provided for @cameraUnavailable.
  ///
  /// In hu, this message translates to:
  /// **'A kamera nem érhető el. Engedélyezd a kamera használatát a beállításokban.'**
  String get cameraUnavailable;

  /// No description provided for @addToCalendar.
  ///
  /// In hu, this message translates to:
  /// **'Mentés a naptárba'**
  String get addToCalendar;

  /// No description provided for @passesAndVouchers.
  ///
  /// In hu, this message translates to:
  /// **'Bérletek és utalványok'**
  String get passesAndVouchers;

  /// No description provided for @passPurchaseTitle.
  ///
  /// In hu, this message translates to:
  /// **'Bérlet / utalvány vásárlása'**
  String get passPurchaseTitle;

  /// No description provided for @sessionsCountLabel.
  ///
  /// In hu, this message translates to:
  /// **'{count} alkalom'**
  String sessionsCountLabel(int count);

  /// No description provided for @valueLabel.
  ///
  /// In hu, this message translates to:
  /// **'Érték: {value}'**
  String valueLabel(String value);

  /// No description provided for @validityDaysLabel.
  ///
  /// In hu, this message translates to:
  /// **'{days} napig érvényes'**
  String validityDaysLabel(int days);

  /// No description provided for @passBuyerEmail.
  ///
  /// In hu, this message translates to:
  /// **'Az e-mail-címed (ide megy a bizonylat és a kód)'**
  String get passBuyerEmail;

  /// No description provided for @passGift.
  ///
  /// In hu, this message translates to:
  /// **'Ajándékba veszem'**
  String get passGift;

  /// No description provided for @recipientName.
  ///
  /// In hu, this message translates to:
  /// **'A megajándékozott neve'**
  String get recipientName;

  /// No description provided for @recipientEmail.
  ///
  /// In hu, this message translates to:
  /// **'A megajándékozott e-mail-címe'**
  String get recipientEmail;

  /// No description provided for @senderName.
  ///
  /// In hu, this message translates to:
  /// **'A te neved (ajándékozó)'**
  String get senderName;

  /// No description provided for @giftMessage.
  ///
  /// In hu, this message translates to:
  /// **'Üzenet az ajándékhoz'**
  String get giftMessage;

  /// No description provided for @passBuy.
  ///
  /// In hu, this message translates to:
  /// **'Tovább a fizetéshez'**
  String get passBuy;

  /// No description provided for @passAfterPayment.
  ///
  /// In hu, this message translates to:
  /// **'A fizetés a böngészőben történik. Utána a bérleted a Fiókom fülön jelenik meg (a vásárláskor megadott e-mail-címmel belépve).'**
  String get passAfterPayment;

  /// No description provided for @reviewTitle.
  ///
  /// In hu, this message translates to:
  /// **'Értékelés'**
  String get reviewTitle;

  /// No description provided for @reviewQuestion.
  ///
  /// In hu, this message translates to:
  /// **'Hogy tetszett a szolgáltatás?'**
  String get reviewQuestion;

  /// No description provided for @reviewFeedback.
  ///
  /// In hu, this message translates to:
  /// **'Szeretnél hozzáfűzni valamit? (nem kötelező)'**
  String get reviewFeedback;

  /// No description provided for @reviewSubmit.
  ///
  /// In hu, this message translates to:
  /// **'Értékelés elküldése'**
  String get reviewSubmit;

  /// No description provided for @reviewThanks.
  ///
  /// In hu, this message translates to:
  /// **'Köszönjük az értékelésed!'**
  String get reviewThanks;

  /// No description provided for @reviewOnGoogle.
  ///
  /// In hu, this message translates to:
  /// **'Értékelés a Google-on is'**
  String get reviewOnGoogle;

  /// No description provided for @groupSessions.
  ///
  /// In hu, this message translates to:
  /// **'Csoportos alkalmak'**
  String get groupSessions;

  /// No description provided for @groupSessionTitle.
  ///
  /// In hu, this message translates to:
  /// **'Jelentkezés alkalomra'**
  String get groupSessionTitle;

  /// No description provided for @placesLeft.
  ///
  /// In hu, this message translates to:
  /// **'{count} szabad hely'**
  String placesLeft(int count);

  /// No description provided for @sessionFull.
  ///
  /// In hu, this message translates to:
  /// **'Betelt'**
  String get sessionFull;

  /// No description provided for @joinSession.
  ///
  /// In hu, this message translates to:
  /// **'Jelentkezem'**
  String get joinSession;

  /// No description provided for @joinWaitlist.
  ///
  /// In hu, this message translates to:
  /// **'Várólistára iratkozom'**
  String get joinWaitlist;

  /// No description provided for @waitlistJoined.
  ///
  /// In hu, this message translates to:
  /// **'Feliratkoztál a várólistára, értesítünk, ha felszabadul egy időpont.'**
  String get waitlistJoined;

  /// No description provided for @orSignInWith.
  ///
  /// In hu, this message translates to:
  /// **'vagy'**
  String get orSignInWith;

  /// No description provided for @continueWithApple.
  ///
  /// In hu, this message translates to:
  /// **'Folytatás Apple-fiókkal'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In hu, this message translates to:
  /// **'Folytatás Google-fiókkal'**
  String get continueWithGoogle;

  /// No description provided for @settingsTitle.
  ///
  /// In hu, this message translates to:
  /// **'Beállítások'**
  String get settingsTitle;

  /// No description provided for @appLockTitle.
  ///
  /// In hu, this message translates to:
  /// **'Zárolás biometrikus azonosítással'**
  String get appLockTitle;

  /// No description provided for @appLockSubtitle.
  ///
  /// In hu, this message translates to:
  /// **'Az app megnyitásához ujjlenyomat, arcfelismerés vagy az eszköz zárja kell.'**
  String get appLockSubtitle;

  /// No description provided for @appLockUnavailable.
  ///
  /// In hu, this message translates to:
  /// **'Az eszközön nincs beállított biometrikus azonosító vagy képernyőzár.'**
  String get appLockUnavailable;

  /// No description provided for @unlockTitle.
  ///
  /// In hu, this message translates to:
  /// **'Az alkalmazás zárolva van'**
  String get unlockTitle;

  /// No description provided for @unlockButton.
  ///
  /// In hu, this message translates to:
  /// **'Feloldás'**
  String get unlockButton;

  /// No description provided for @unlockReason.
  ///
  /// In hu, this message translates to:
  /// **'Told fel a Kalenda zárolását'**
  String get unlockReason;

  /// No description provided for @unlockFailed.
  ///
  /// In hu, this message translates to:
  /// **'Az azonosítás nem sikerült.'**
  String get unlockFailed;

  /// No description provided for @ownerNewBooking.
  ///
  /// In hu, this message translates to:
  /// **'Új foglalás'**
  String get ownerNewBooking;

  /// No description provided for @ownerCreateBooking.
  ///
  /// In hu, this message translates to:
  /// **'Foglalás felvitele'**
  String get ownerCreateBooking;

  /// No description provided for @ownerCustomerLabel.
  ///
  /// In hu, this message translates to:
  /// **'Ügyfél'**
  String get ownerCustomerLabel;

  /// No description provided for @newCustomerOption.
  ///
  /// In hu, this message translates to:
  /// **'Új ügyfél'**
  String get newCustomerOption;

  /// No description provided for @serviceLabel.
  ///
  /// In hu, this message translates to:
  /// **'Szolgáltatás'**
  String get serviceLabel;

  /// No description provided for @sendEmailLabel.
  ///
  /// In hu, this message translates to:
  /// **'Értesítő e-mail az ügyfélnek'**
  String get sendEmailLabel;

  /// No description provided for @backToStart.
  ///
  /// In hu, this message translates to:
  /// **'Vissza a kezdőlapra'**
  String get backToStart;

  /// No description provided for @signIn.
  ///
  /// In hu, this message translates to:
  /// **'Belépés'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In hu, this message translates to:
  /// **'Kijelentkezés'**
  String get signOut;

  /// No description provided for @myAppointments.
  ///
  /// In hu, this message translates to:
  /// **'Foglalásaim'**
  String get myAppointments;

  /// No description provided for @newBooking.
  ///
  /// In hu, this message translates to:
  /// **'Új foglalás'**
  String get newBooking;

  /// No description provided for @upcoming.
  ///
  /// In hu, this message translates to:
  /// **'Közelgő'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In hu, this message translates to:
  /// **'Korábbi'**
  String get past;

  /// No description provided for @noUpcoming.
  ///
  /// In hu, this message translates to:
  /// **'Nincs közelgő foglalásod.'**
  String get noUpcoming;

  /// No description provided for @noPast.
  ///
  /// In hu, this message translates to:
  /// **'Még nincs korábbi foglalásod.'**
  String get noPast;

  /// No description provided for @retry.
  ///
  /// In hu, this message translates to:
  /// **'Újra'**
  String get retry;

  /// No description provided for @genericError.
  ///
  /// In hu, this message translates to:
  /// **'Hiba történt. Próbáld újra.'**
  String get genericError;

  /// No description provided for @networkError.
  ///
  /// In hu, this message translates to:
  /// **'Nincs kapcsolat a szerverrel.'**
  String get networkError;

  /// No description provided for @priceHuf.
  ///
  /// In hu, this message translates to:
  /// **'{amount} Ft'**
  String priceHuf(String amount);

  /// No description provided for @minutes.
  ///
  /// In hu, this message translates to:
  /// **'{count} perc'**
  String minutes(int count);

  /// No description provided for @findBusinessTitle.
  ///
  /// In hu, this message translates to:
  /// **'Vállalkozás keresése'**
  String get findBusinessTitle;

  /// No description provided for @findBusinessIntro.
  ///
  /// In hu, this message translates to:
  /// **'Írd be a vállalkozás foglalási címét (azonosítóját), vagy másold be a foglalási linket.'**
  String get findBusinessIntro;

  /// No description provided for @businessSlug.
  ///
  /// In hu, this message translates to:
  /// **'Azonosító vagy link'**
  String get businessSlug;

  /// No description provided for @open.
  ///
  /// In hu, this message translates to:
  /// **'Megnyitás'**
  String get open;

  /// No description provided for @services.
  ///
  /// In hu, this message translates to:
  /// **'Szolgáltatások'**
  String get services;

  /// No description provided for @book.
  ///
  /// In hu, this message translates to:
  /// **'Foglalás'**
  String get book;

  /// No description provided for @bookingTitle.
  ///
  /// In hu, this message translates to:
  /// **'Időpontfoglalás'**
  String get bookingTitle;

  /// No description provided for @staffLabel.
  ///
  /// In hu, this message translates to:
  /// **'Munkatárs'**
  String get staffLabel;

  /// No description provided for @addons.
  ///
  /// In hu, this message translates to:
  /// **'Kiegészítők'**
  String get addons;

  /// No description provided for @dateLabel.
  ///
  /// In hu, this message translates to:
  /// **'Dátum'**
  String get dateLabel;

  /// No description provided for @pickDate.
  ///
  /// In hu, this message translates to:
  /// **'Válassz napot'**
  String get pickDate;

  /// No description provided for @timeLabel.
  ///
  /// In hu, this message translates to:
  /// **'Időpont'**
  String get timeLabel;

  /// No description provided for @noSlots.
  ///
  /// In hu, this message translates to:
  /// **'Ezen a napon nincs szabad időpont.'**
  String get noSlots;

  /// No description provided for @yourDetails.
  ///
  /// In hu, this message translates to:
  /// **'Adataid'**
  String get yourDetails;

  /// No description provided for @name.
  ///
  /// In hu, this message translates to:
  /// **'Név'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In hu, this message translates to:
  /// **'Telefonszám'**
  String get phone;

  /// No description provided for @notes.
  ///
  /// In hu, this message translates to:
  /// **'Megjegyzés'**
  String get notes;

  /// No description provided for @passCode.
  ///
  /// In hu, this message translates to:
  /// **'Bérletkód (ha van)'**
  String get passCode;

  /// No description provided for @marketingConsent.
  ///
  /// In hu, this message translates to:
  /// **'Hírlevelet kérek'**
  String get marketingConsent;

  /// No description provided for @confirmBooking.
  ///
  /// In hu, this message translates to:
  /// **'Foglalás megerősítése'**
  String get confirmBooking;

  /// No description provided for @payDeposit.
  ///
  /// In hu, this message translates to:
  /// **'Fizetés'**
  String get payDeposit;

  /// No description provided for @bookingDone.
  ///
  /// In hu, this message translates to:
  /// **'Sikeres foglalás'**
  String get bookingDone;

  /// No description provided for @bookingDoneText.
  ///
  /// In hu, this message translates to:
  /// **'A visszaigazolást elküldtük e-mailben.'**
  String get bookingDoneText;

  /// No description provided for @paymentRequired.
  ///
  /// In hu, this message translates to:
  /// **'A foglalás véglegesítéséhez fizetés szükséges.'**
  String get paymentRequired;

  /// No description provided for @payNow.
  ///
  /// In hu, this message translates to:
  /// **'Fizetés most'**
  String get payNow;

  /// No description provided for @manageBooking.
  ///
  /// In hu, this message translates to:
  /// **'Foglalás kezelése'**
  String get manageBooking;

  /// No description provided for @reschedule.
  ///
  /// In hu, this message translates to:
  /// **'Áthelyezés'**
  String get reschedule;

  /// No description provided for @cancelBooking.
  ///
  /// In hu, this message translates to:
  /// **'Lemondás'**
  String get cancelBooking;

  /// No description provided for @cancelConfirmTitle.
  ///
  /// In hu, this message translates to:
  /// **'Biztosan lemondod?'**
  String get cancelConfirmTitle;

  /// No description provided for @cancelConfirmText.
  ///
  /// In hu, this message translates to:
  /// **'A lemondás nem vonható vissza.'**
  String get cancelConfirmText;

  /// No description provided for @yes.
  ///
  /// In hu, this message translates to:
  /// **'Igen'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In hu, this message translates to:
  /// **'Nem'**
  String get no;

  /// No description provided for @saved.
  ///
  /// In hu, this message translates to:
  /// **'Mentve.'**
  String get saved;

  /// No description provided for @cancelled.
  ///
  /// In hu, this message translates to:
  /// **'A foglalást lemondtad.'**
  String get cancelled;

  /// No description provided for @status.
  ///
  /// In hu, this message translates to:
  /// **'Állapot'**
  String get status;

  /// No description provided for @total.
  ///
  /// In hu, this message translates to:
  /// **'Összesen'**
  String get total;

  /// No description provided for @call.
  ///
  /// In hu, this message translates to:
  /// **'Hívás'**
  String get call;

  /// No description provided for @backToBookings.
  ///
  /// In hu, this message translates to:
  /// **'Vissza a foglalásokhoz'**
  String get backToBookings;

  /// No description provided for @required.
  ///
  /// In hu, this message translates to:
  /// **'A mező megadása kötelező.'**
  String get required;

  /// No description provided for @invalidEmail.
  ///
  /// In hu, this message translates to:
  /// **'Érvénytelen e-mail-cím.'**
  String get invalidEmail;

  /// No description provided for @accountTitle.
  ///
  /// In hu, this message translates to:
  /// **'Fiókom'**
  String get accountTitle;

  /// No description provided for @profile.
  ///
  /// In hu, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @save.
  ///
  /// In hu, this message translates to:
  /// **'Mentés'**
  String get save;

  /// No description provided for @loyaltyTitle.
  ///
  /// In hu, this message translates to:
  /// **'Hűségpontok'**
  String get loyaltyTitle;

  /// No description provided for @loyaltyBalance.
  ///
  /// In hu, this message translates to:
  /// **'{points} pont'**
  String loyaltyBalance(int points);

  /// No description provided for @loyaltyReward.
  ///
  /// In hu, this message translates to:
  /// **'{points} pontért {value}'**
  String loyaltyReward(int points, String value);

  /// No description provided for @passesTitle.
  ///
  /// In hu, this message translates to:
  /// **'Bérletek és utalványok'**
  String get passesTitle;

  /// No description provided for @sessionsLeft.
  ///
  /// In hu, this message translates to:
  /// **'{count} alkalom van hátra'**
  String sessionsLeft(int count);

  /// No description provided for @balanceLeft.
  ///
  /// In hu, this message translates to:
  /// **'Egyenleg: {value}'**
  String balanceLeft(String value);

  /// No description provided for @expiresOn.
  ///
  /// In hu, this message translates to:
  /// **'Lejár: {date}'**
  String expiresOn(String date);

  /// No description provided for @expired.
  ///
  /// In hu, this message translates to:
  /// **'Lejárt'**
  String get expired;

  /// No description provided for @consentsTitle.
  ///
  /// In hu, this message translates to:
  /// **'Hírlevél-hozzájárulások'**
  String get consentsTitle;

  /// No description provided for @nothingYet.
  ///
  /// In hu, this message translates to:
  /// **'Még nincs itt semmi.'**
  String get nothingYet;

  /// No description provided for @deleteAccount.
  ///
  /// In hu, this message translates to:
  /// **'Fiók törlése'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In hu, this message translates to:
  /// **'Biztosan törlöd a fiókod?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountText.
  ///
  /// In hu, this message translates to:
  /// **'A személyes adataid törlődnek, a belépésed és az eszközeid megszűnnek. Ez nem vonható vissza. Közelgő foglalással nem törölhető a fiók.'**
  String get deleteAccountText;

  /// No description provided for @staffLoginLink.
  ///
  /// In hu, this message translates to:
  /// **'Munkatárs vagy vállalkozó vagyok'**
  String get staffLoginLink;

  /// No description provided for @staffLoginTitle.
  ///
  /// In hu, this message translates to:
  /// **'Belépés munkatársként'**
  String get staffLoginTitle;

  /// No description provided for @staffLoginIntro.
  ///
  /// In hu, this message translates to:
  /// **'Lépj be a Kalenda-fiókod e-mail-címével és jelszavával.'**
  String get staffLoginIntro;

  /// No description provided for @password.
  ///
  /// In hu, this message translates to:
  /// **'Jelszó'**
  String get password;

  /// No description provided for @staffToday.
  ///
  /// In hu, this message translates to:
  /// **'Ma'**
  String get staffToday;

  /// No description provided for @staffCalendar.
  ///
  /// In hu, this message translates to:
  /// **'Naptár'**
  String get staffCalendar;

  /// No description provided for @staffLeaves.
  ///
  /// In hu, this message translates to:
  /// **'Szabadság'**
  String get staffLeaves;

  /// No description provided for @staffNoProfile.
  ///
  /// In hu, this message translates to:
  /// **'Ehhez a fiókhoz nincs munkatársi profil. A vállalkozói felület egyelőre a weben érhető el.'**
  String get staffNoProfile;

  /// No description provided for @todayCount.
  ///
  /// In hu, this message translates to:
  /// **'{count} foglalás ma'**
  String todayCount(int count);

  /// No description provided for @upcomingAppointments.
  ///
  /// In hu, this message translates to:
  /// **'Következő foglalások'**
  String get upcomingAppointments;

  /// No description provided for @noAppointments.
  ///
  /// In hu, this message translates to:
  /// **'Nincs foglalás.'**
  String get noAppointments;

  /// No description provided for @clockIn.
  ///
  /// In hu, this message translates to:
  /// **'Munkakezdés'**
  String get clockIn;

  /// No description provided for @clockOut.
  ///
  /// In hu, this message translates to:
  /// **'Munkavégzés vége'**
  String get clockOut;

  /// No description provided for @clockedInSince.
  ///
  /// In hu, this message translates to:
  /// **'Bent vagy {time} óta'**
  String clockedInSince(String time);

  /// No description provided for @breakMinutes.
  ///
  /// In hu, this message translates to:
  /// **'Szünet (perc)'**
  String get breakMinutes;

  /// No description provided for @statusPending.
  ///
  /// In hu, this message translates to:
  /// **'Függő'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In hu, this message translates to:
  /// **'Megerősítve'**
  String get statusConfirmed;

  /// No description provided for @statusCancelled.
  ///
  /// In hu, this message translates to:
  /// **'Lemondva'**
  String get statusCancelled;

  /// No description provided for @statusCompleted.
  ///
  /// In hu, this message translates to:
  /// **'Lezárva'**
  String get statusCompleted;

  /// No description provided for @statusNoShow.
  ///
  /// In hu, this message translates to:
  /// **'Nem jelent meg'**
  String get statusNoShow;

  /// No description provided for @statusApproved.
  ///
  /// In hu, this message translates to:
  /// **'Jóváhagyva'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In hu, this message translates to:
  /// **'Elutasítva'**
  String get statusRejected;

  /// No description provided for @actionConfirm.
  ///
  /// In hu, this message translates to:
  /// **'Megerősítés'**
  String get actionConfirm;

  /// No description provided for @actionComplete.
  ///
  /// In hu, this message translates to:
  /// **'Megjelent / lezárás'**
  String get actionComplete;

  /// No description provided for @actionNoShow.
  ///
  /// In hu, this message translates to:
  /// **'Nem jelent meg'**
  String get actionNoShow;

  /// No description provided for @actionCancel.
  ///
  /// In hu, this message translates to:
  /// **'Lemondás'**
  String get actionCancel;

  /// No description provided for @newLeave.
  ///
  /// In hu, this message translates to:
  /// **'Szabadság kérése'**
  String get newLeave;

  /// No description provided for @leaveReason.
  ///
  /// In hu, this message translates to:
  /// **'Indok (nem kötelező)'**
  String get leaveReason;

  /// No description provided for @withdraw.
  ///
  /// In hu, this message translates to:
  /// **'Visszavonás'**
  String get withdraw;

  /// No description provided for @pickDates.
  ///
  /// In hu, this message translates to:
  /// **'Válaszd ki az időszakot'**
  String get pickDates;

  /// No description provided for @previousWeek.
  ///
  /// In hu, this message translates to:
  /// **'Előző hét'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In hu, this message translates to:
  /// **'Következő hét'**
  String get nextWeek;

  /// No description provided for @leaveDay.
  ///
  /// In hu, this message translates to:
  /// **'Szabadság'**
  String get leaveDay;

  /// No description provided for @ownerLoginLink.
  ///
  /// In hu, this message translates to:
  /// **'Vállalkozóként lépek be'**
  String get ownerLoginLink;

  /// No description provided for @ownerOverview.
  ///
  /// In hu, this message translates to:
  /// **'Áttekintés'**
  String get ownerOverview;

  /// No description provided for @ownerCustomers.
  ///
  /// In hu, this message translates to:
  /// **'Ügyfelek'**
  String get ownerCustomers;

  /// No description provided for @ownerNoBusiness.
  ///
  /// In hu, this message translates to:
  /// **'Ehhez a fiókhoz nem tartozik vállalkozás.'**
  String get ownerNoBusiness;

  /// No description provided for @weekRevenueTitle.
  ///
  /// In hu, this message translates to:
  /// **'Heti bevétel'**
  String get weekRevenueTitle;

  /// No description provided for @weekRevenueSoFar.
  ///
  /// In hu, this message translates to:
  /// **'Eddig: {amount}'**
  String weekRevenueSoFar(String amount);

  /// No description provided for @weekRevenueChange.
  ///
  /// In hu, this message translates to:
  /// **'{percent}% az előző héthez képest'**
  String weekRevenueChange(String percent);

  /// No description provided for @receivablesTitle.
  ///
  /// In hu, this message translates to:
  /// **'Kintlévőségek'**
  String get receivablesTitle;

  /// No description provided for @receivablesOutstanding.
  ///
  /// In hu, this message translates to:
  /// **'Nyitott: {amount} ({count} db)'**
  String receivablesOutstanding(String amount, int count);

  /// No description provided for @receivablesOverdue.
  ///
  /// In hu, this message translates to:
  /// **'Lejárt: {amount} ({count} db)'**
  String receivablesOverdue(String amount, int count);

  /// No description provided for @lowStock.
  ///
  /// In hu, this message translates to:
  /// **'{count} termék fogy'**
  String lowStock(int count);

  /// No description provided for @todaysBookings.
  ///
  /// In hu, this message translates to:
  /// **'Mai foglalások'**
  String get todaysBookings;

  /// No description provided for @searchCustomers.
  ///
  /// In hu, this message translates to:
  /// **'Keresés név, e-mail vagy telefon szerint'**
  String get searchCustomers;

  /// No description provided for @customerStats.
  ///
  /// In hu, this message translates to:
  /// **'{total} foglalás · {spent} · {noShow} meg nem jelenés'**
  String customerStats(int total, String spent, int noShow);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
