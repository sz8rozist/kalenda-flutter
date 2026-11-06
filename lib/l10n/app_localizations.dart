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

  /// No description provided for @ok.
  ///
  /// In hu, this message translates to:
  /// **'Rendben'**
  String get ok;

  /// No description provided for @bookingIncomplete.
  ///
  /// In hu, this message translates to:
  /// **'Válaszd ki a munkatársat, a napot és az időpontot.'**
  String get bookingIncomplete;

  /// No description provided for @errorTitleGeneric.
  ///
  /// In hu, this message translates to:
  /// **'Hiba történt'**
  String get errorTitleGeneric;

  /// No description provided for @errorTitleNetwork.
  ///
  /// In hu, this message translates to:
  /// **'Nincs kapcsolat'**
  String get errorTitleNetwork;

  /// No description provided for @errorNetworkText.
  ///
  /// In hu, this message translates to:
  /// **'Nem érjük el a szervert. Ellenőrizd az internetkapcsolatod, és próbáld újra.'**
  String get errorNetworkText;

  /// No description provided for @errorTitleSession.
  ///
  /// In hu, this message translates to:
  /// **'Lejárt a munkamenet'**
  String get errorTitleSession;

  /// No description provided for @errorSessionText.
  ///
  /// In hu, this message translates to:
  /// **'Kérjük, lépj be újra.'**
  String get errorSessionText;

  /// No description provided for @errorTitleDenied.
  ///
  /// In hu, this message translates to:
  /// **'Nincs jogosultságod'**
  String get errorTitleDenied;

  /// No description provided for @errorTitleNotFound.
  ///
  /// In hu, this message translates to:
  /// **'Nem található'**
  String get errorTitleNotFound;

  /// No description provided for @errorTitleValidation.
  ///
  /// In hu, this message translates to:
  /// **'Ellenőrizd az adatokat'**
  String get errorTitleValidation;

  /// No description provided for @errorTitleTooMany.
  ///
  /// In hu, this message translates to:
  /// **'Túl sok kérés'**
  String get errorTitleTooMany;

  /// No description provided for @errorTooManyText.
  ///
  /// In hu, this message translates to:
  /// **'Kérjük, várj egy kicsit, és próbáld újra.'**
  String get errorTooManyText;

  /// No description provided for @errorTitleServer.
  ///
  /// In hu, this message translates to:
  /// **'Szerverhiba'**
  String get errorTitleServer;

  /// No description provided for @errorServerText.
  ///
  /// In hu, this message translates to:
  /// **'Valami félresiklott a szerveren. Próbáld újra egy kicsit később.'**
  String get errorServerText;

  /// No description provided for @welcomeTitle.
  ///
  /// In hu, this message translates to:
  /// **'Foglalj időpontot pár koppintással'**
  String get welcomeTitle;

  /// No description provided for @welcomeText.
  ///
  /// In hu, this message translates to:
  /// **'Keresd meg kedvenc szalonod, stúdiód vagy edződ, és foglalj online.'**
  String get welcomeText;

  /// No description provided for @splashTagline.
  ///
  /// In hu, this message translates to:
  /// **'Időpontfoglalás egyszerűen'**
  String get splashTagline;

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

  /// No description provided for @favorites.
  ///
  /// In hu, this message translates to:
  /// **'Kedvenceid'**
  String get favorites;

  /// No description provided for @recentBusinesses.
  ///
  /// In hu, this message translates to:
  /// **'Legutóbb megnyitott'**
  String get recentBusinesses;

  /// No description provided for @addFavorite.
  ///
  /// In hu, this message translates to:
  /// **'Hozzáadás a kedvencekhez'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In hu, this message translates to:
  /// **'Eltávolítás a kedvencek közül'**
  String get removeFavorite;

  /// No description provided for @offlineBanner.
  ///
  /// In hu, this message translates to:
  /// **'Nincs internetkapcsolat'**
  String get offlineBanner;

  /// No description provided for @next.
  ///
  /// In hu, this message translates to:
  /// **'Tovább'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In hu, this message translates to:
  /// **'Kihagyom'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In hu, this message translates to:
  /// **'Kezdjük'**
  String get getStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In hu, this message translates to:
  /// **'Találd meg a helyed'**
  String get onboardingTitle1;

  /// No description provided for @onboardingText1.
  ///
  /// In hu, this message translates to:
  /// **'Szalonok, stúdiók, edzők – keresd meg név szerint, link alapján vagy olvasd be a QR-kódot.'**
  String get onboardingText1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In hu, this message translates to:
  /// **'Foglalj pár koppintással'**
  String get onboardingTitle2;

  /// No description provided for @onboardingText2.
  ///
  /// In hu, this message translates to:
  /// **'Válassz szolgáltatást, szakembert és szabad időpontot, a visszaigazolás azonnal megvan.'**
  String get onboardingText2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In hu, this message translates to:
  /// **'Mindig tudsz róla'**
  String get onboardingTitle3;

  /// No description provided for @onboardingText3.
  ///
  /// In hu, this message translates to:
  /// **'Emlékeztetőt kapsz, a foglalásaidat egy helyen látod, és bármikor áthelyezheted vagy lemondhatod.'**
  String get onboardingText3;

  /// No description provided for @stepStaff.
  ///
  /// In hu, this message translates to:
  /// **'Kivel és mit?'**
  String get stepStaff;

  /// No description provided for @stepDateTime.
  ///
  /// In hu, this message translates to:
  /// **'Mikor?'**
  String get stepDateTime;

  /// No description provided for @stepDetails.
  ///
  /// In hu, this message translates to:
  /// **'Adataid'**
  String get stepDetails;

  /// No description provided for @pickAnotherDate.
  ///
  /// In hu, this message translates to:
  /// **'Másik nap'**
  String get pickAnotherDate;

  /// No description provided for @dayToday.
  ///
  /// In hu, this message translates to:
  /// **'Ma'**
  String get dayToday;

  /// No description provided for @dayTomorrow.
  ///
  /// In hu, this message translates to:
  /// **'Holnap'**
  String get dayTomorrow;

  /// No description provided for @bookingDoneTitle.
  ///
  /// In hu, this message translates to:
  /// **'Sikeres foglalás!'**
  String get bookingDoneTitle;

  /// No description provided for @statusLabelPrefix.
  ///
  /// In hu, this message translates to:
  /// **'Állapot'**
  String get statusLabelPrefix;

  /// No description provided for @customerLabel.
  ///
  /// In hu, this message translates to:
  /// **'Ügyfél'**
  String get customerLabel;

  /// No description provided for @offlineShowingSaved.
  ///
  /// In hu, this message translates to:
  /// **'Mentett adatok látszanak'**
  String get offlineShowingSaved;

  /// No description provided for @remindersTitle.
  ///
  /// In hu, this message translates to:
  /// **'Értesítések'**
  String get remindersTitle;

  /// No description provided for @profileInitial.
  ///
  /// In hu, this message translates to:
  /// **'Profil'**
  String get profileInitial;

  /// No description provided for @actionDelete.
  ///
  /// In hu, this message translates to:
  /// **'Törlés'**
  String get actionDelete;

  /// No description provided for @actionAdd.
  ///
  /// In hu, this message translates to:
  /// **'Új'**
  String get actionAdd;

  /// No description provided for @dialogCancel.
  ///
  /// In hu, this message translates to:
  /// **'Mégse'**
  String get dialogCancel;

  /// No description provided for @fieldDescription.
  ///
  /// In hu, this message translates to:
  /// **'Leírás'**
  String get fieldDescription;

  /// No description provided for @fieldColor.
  ///
  /// In hu, this message translates to:
  /// **'Szín'**
  String get fieldColor;

  /// No description provided for @fieldActive.
  ///
  /// In hu, this message translates to:
  /// **'Aktív'**
  String get fieldActive;

  /// No description provided for @fieldAddress.
  ///
  /// In hu, this message translates to:
  /// **'Cím'**
  String get fieldAddress;

  /// No description provided for @newService.
  ///
  /// In hu, this message translates to:
  /// **'Új szolgáltatás'**
  String get newService;

  /// No description provided for @editService.
  ///
  /// In hu, this message translates to:
  /// **'Szolgáltatás szerkesztése'**
  String get editService;

  /// No description provided for @depositTypeLabel.
  ///
  /// In hu, this message translates to:
  /// **'Előleg'**
  String get depositTypeLabel;

  /// No description provided for @depositNone.
  ///
  /// In hu, this message translates to:
  /// **'Nincs'**
  String get depositNone;

  /// No description provided for @depositPercentage.
  ///
  /// In hu, this message translates to:
  /// **'Százalék'**
  String get depositPercentage;

  /// No description provided for @depositFull.
  ///
  /// In hu, this message translates to:
  /// **'Teljes összeg'**
  String get depositFull;

  /// No description provided for @depositPercentLabel.
  ///
  /// In hu, this message translates to:
  /// **'Előleg (%)'**
  String get depositPercentLabel;

  /// No description provided for @bufferBefore.
  ///
  /// In hu, this message translates to:
  /// **'Előkészület (perc)'**
  String get bufferBefore;

  /// No description provided for @bufferAfter.
  ///
  /// In hu, this message translates to:
  /// **'Pihenő utána (perc)'**
  String get bufferAfter;

  /// No description provided for @groupServiceLabel.
  ///
  /// In hu, this message translates to:
  /// **'Csoportos alkalom'**
  String get groupServiceLabel;

  /// No description provided for @rentalServiceLabel.
  ///
  /// In hu, this message translates to:
  /// **'Bérelhető (pálya, terem)'**
  String get rentalServiceLabel;

  /// No description provided for @maxDurationLabel.
  ///
  /// In hu, this message translates to:
  /// **'Legfeljebb (perc)'**
  String get maxDurationLabel;

  /// No description provided for @durationStepLabel.
  ///
  /// In hu, this message translates to:
  /// **'Időtartam lépésköz (perc)'**
  String get durationStepLabel;

  /// No description provided for @deleteServiceTitle.
  ///
  /// In hu, this message translates to:
  /// **'Törlöd a szolgáltatást?'**
  String get deleteServiceTitle;

  /// No description provided for @deleteServiceText.
  ///
  /// In hu, this message translates to:
  /// **'A szolgáltatás nem lesz többé foglalható. Ha már vannak foglalások rá, a szerver megakadályozhatja a törlést.'**
  String get deleteServiceText;

  /// No description provided for @newStaff.
  ///
  /// In hu, this message translates to:
  /// **'Új munkatárs'**
  String get newStaff;

  /// No description provided for @editStaff.
  ///
  /// In hu, this message translates to:
  /// **'Munkatárs szerkesztése'**
  String get editStaff;

  /// No description provided for @staffBio.
  ///
  /// In hu, this message translates to:
  /// **'Bemutatkozás'**
  String get staffBio;

  /// No description provided for @staffKindLabel.
  ///
  /// In hu, this message translates to:
  /// **'Típus'**
  String get staffKindLabel;

  /// No description provided for @staffKindPerson.
  ///
  /// In hu, this message translates to:
  /// **'Személy'**
  String get staffKindPerson;

  /// No description provided for @staffKindResource.
  ///
  /// In hu, this message translates to:
  /// **'Erőforrás (pálya, terem)'**
  String get staffKindResource;

  /// No description provided for @staffServicesTitle.
  ///
  /// In hu, this message translates to:
  /// **'Szolgáltatások'**
  String get staffServicesTitle;

  /// No description provided for @inviteStaff.
  ///
  /// In hu, this message translates to:
  /// **'Meghívó küldése'**
  String get inviteStaff;

  /// No description provided for @inviteSent.
  ///
  /// In hu, this message translates to:
  /// **'A meghívó elment.'**
  String get inviteSent;

  /// No description provided for @revokeAccess.
  ///
  /// In hu, this message translates to:
  /// **'Hozzáférés megvonása'**
  String get revokeAccess;

  /// No description provided for @deleteStaffTitle.
  ///
  /// In hu, this message translates to:
  /// **'Törlöd a munkatársat?'**
  String get deleteStaffTitle;

  /// No description provided for @deleteStaffText.
  ///
  /// In hu, this message translates to:
  /// **'A munkatárs nem lesz többé foglalható.'**
  String get deleteStaffText;

  /// No description provided for @customerDetailsTitle.
  ///
  /// In hu, this message translates to:
  /// **'Ügyfél adatai'**
  String get customerDetailsTitle;

  /// No description provided for @customerBookings.
  ///
  /// In hu, this message translates to:
  /// **'Foglalások'**
  String get customerBookings;

  /// No description provided for @customerCompleted.
  ///
  /// In hu, this message translates to:
  /// **'Teljesített'**
  String get customerCompleted;

  /// No description provided for @customerCancelled.
  ///
  /// In hu, this message translates to:
  /// **'Lemondott'**
  String get customerCancelled;

  /// No description provided for @customerNoShows.
  ///
  /// In hu, this message translates to:
  /// **'Meg nem jelent'**
  String get customerNoShows;

  /// No description provided for @customerSpent.
  ///
  /// In hu, this message translates to:
  /// **'Összes költés'**
  String get customerSpent;

  /// No description provided for @customerNote.
  ///
  /// In hu, this message translates to:
  /// **'Belső megjegyzés'**
  String get customerNote;

  /// No description provided for @customerDepositExempt.
  ///
  /// In hu, this message translates to:
  /// **'Előleg alól mentesítve'**
  String get customerDepositExempt;

  /// No description provided for @customerNoShowFlag.
  ///
  /// In hu, this message translates to:
  /// **'Figyelmeztetés: többször nem jelent meg'**
  String get customerNoShowFlag;

  /// No description provided for @billingTitle.
  ///
  /// In hu, this message translates to:
  /// **'Számlázási adatok'**
  String get billingTitle;

  /// No description provided for @billingPostCode.
  ///
  /// In hu, this message translates to:
  /// **'Irányítószám'**
  String get billingPostCode;

  /// No description provided for @billingCity.
  ///
  /// In hu, this message translates to:
  /// **'Település'**
  String get billingCity;

  /// No description provided for @billingTaxNumber.
  ///
  /// In hu, this message translates to:
  /// **'Adószám'**
  String get billingTaxNumber;

  /// No description provided for @billingEmail.
  ///
  /// In hu, this message translates to:
  /// **'Számlázási e-mail'**
  String get billingEmail;

  /// No description provided for @loyaltyTitleOwner.
  ///
  /// In hu, this message translates to:
  /// **'Hűségpontok'**
  String get loyaltyTitleOwner;

  /// No description provided for @loyaltyAdjust.
  ///
  /// In hu, this message translates to:
  /// **'Pontok módosítása'**
  String get loyaltyAdjust;

  /// No description provided for @loyaltyAdjustPoints.
  ///
  /// In hu, this message translates to:
  /// **'Pont (negatív is lehet)'**
  String get loyaltyAdjustPoints;

  /// No description provided for @loyaltyRedeem.
  ///
  /// In hu, this message translates to:
  /// **'Jutalom beváltása'**
  String get loyaltyRedeem;

  /// No description provided for @loyaltyRedeemed.
  ///
  /// In hu, this message translates to:
  /// **'Beváltva: {discount} kedvezmény'**
  String loyaltyRedeemed(String discount);

  /// No description provided for @loyaltyNoReward.
  ///
  /// In hu, this message translates to:
  /// **'Nincs elég pont a jutalomhoz.'**
  String get loyaltyNoReward;

  /// No description provided for @loyaltyHistory.
  ///
  /// In hu, this message translates to:
  /// **'Előzmények'**
  String get loyaltyHistory;

  /// No description provided for @ownerExpenses.
  ///
  /// In hu, this message translates to:
  /// **'Költségek'**
  String get ownerExpenses;

  /// No description provided for @ownerReviews.
  ///
  /// In hu, this message translates to:
  /// **'Értékelések'**
  String get ownerReviews;

  /// No description provided for @ownerPasses.
  ///
  /// In hu, this message translates to:
  /// **'Bérletek és utalványok'**
  String get ownerPasses;

  /// No description provided for @ownerWaitlist.
  ///
  /// In hu, this message translates to:
  /// **'Várólista'**
  String get ownerWaitlist;

  /// No description provided for @ownerActivityLog.
  ///
  /// In hu, this message translates to:
  /// **'Tevékenység-napló'**
  String get ownerActivityLog;

  /// No description provided for @newExpense.
  ///
  /// In hu, this message translates to:
  /// **'Új költség'**
  String get newExpense;

  /// No description provided for @expenseCategory.
  ///
  /// In hu, this message translates to:
  /// **'Kategória'**
  String get expenseCategory;

  /// No description provided for @expenseAmount.
  ///
  /// In hu, this message translates to:
  /// **'Összeg (Ft)'**
  String get expenseAmount;

  /// No description provided for @expenseVendor.
  ///
  /// In hu, this message translates to:
  /// **'Szállító'**
  String get expenseVendor;

  /// No description provided for @expenseRecurring.
  ///
  /// In hu, this message translates to:
  /// **'Ismétlődő költség'**
  String get expenseRecurring;

  /// No description provided for @expenseDate.
  ///
  /// In hu, this message translates to:
  /// **'Dátum'**
  String get expenseDate;

  /// No description provided for @expensesTotal.
  ///
  /// In hu, this message translates to:
  /// **'Összesen: {total}'**
  String expensesTotal(String total);

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In hu, this message translates to:
  /// **'Törlöd a költséget?'**
  String get deleteExpenseTitle;

  /// No description provided for @deleteExpenseText.
  ///
  /// In hu, this message translates to:
  /// **'A költség kikerül a kimutatásokból.'**
  String get deleteExpenseText;

  /// No description provided for @reviewsEnabled.
  ///
  /// In hu, this message translates to:
  /// **'Értékelés-kérés a látogatás után'**
  String get reviewsEnabled;

  /// No description provided for @googleReviewUrl.
  ///
  /// In hu, this message translates to:
  /// **'Google-értékelés linkje'**
  String get googleReviewUrl;

  /// No description provided for @reviewsSummary.
  ///
  /// In hu, this message translates to:
  /// **'{average} átlag · {count} értékelés'**
  String reviewsSummary(String average, int count);

  /// No description provided for @passKindPass.
  ///
  /// In hu, this message translates to:
  /// **'Bérlet'**
  String get passKindPass;

  /// No description provided for @passKindVoucher.
  ///
  /// In hu, this message translates to:
  /// **'Utalvány'**
  String get passKindVoucher;

  /// No description provided for @passRecipient.
  ///
  /// In hu, this message translates to:
  /// **'Címzett: {name}'**
  String passRecipient(String name);

  /// No description provided for @waitlistNotify.
  ///
  /// In hu, this message translates to:
  /// **'Értesítés küldése'**
  String get waitlistNotify;

  /// No description provided for @waitlistNotified.
  ///
  /// In hu, this message translates to:
  /// **'Értesítve'**
  String get waitlistNotified;

  /// No description provided for @waitlistWaiting.
  ///
  /// In hu, this message translates to:
  /// **'Vár'**
  String get waitlistWaiting;

  /// No description provided for @waitlistBooked.
  ///
  /// In hu, this message translates to:
  /// **'Lefoglalta'**
  String get waitlistBooked;

  /// No description provided for @waitlistExpired.
  ///
  /// In hu, this message translates to:
  /// **'Lejárt'**
  String get waitlistExpired;

  /// No description provided for @waitlistRemove.
  ///
  /// In hu, this message translates to:
  /// **'Eltávolítás'**
  String get waitlistRemove;

  /// No description provided for @activitySearch.
  ///
  /// In hu, this message translates to:
  /// **'Keresés a naplóban'**
  String get activitySearch;

  /// No description provided for @ownerMore.
  ///
  /// In hu, this message translates to:
  /// **'Továbbiak'**
  String get ownerMore;

  /// No description provided for @menuGroupBooking.
  ///
  /// In hu, this message translates to:
  /// **'Foglalás és ügyfelek'**
  String get menuGroupBooking;

  /// No description provided for @menuGroupSales.
  ///
  /// In hu, this message translates to:
  /// **'Értékesítés és marketing'**
  String get menuGroupSales;

  /// No description provided for @menuGroupFinance.
  ///
  /// In hu, this message translates to:
  /// **'Pénzügy'**
  String get menuGroupFinance;

  /// No description provided for @menuGroupOperations.
  ///
  /// In hu, this message translates to:
  /// **'Működés'**
  String get menuGroupOperations;

  /// No description provided for @menuGroupSettings.
  ///
  /// In hu, this message translates to:
  /// **'Beállítások'**
  String get menuGroupSettings;

  /// No description provided for @menuNotInPlan.
  ///
  /// In hu, this message translates to:
  /// **'A csomagod nem tartalmazza'**
  String get menuNotInPlan;

  /// No description provided for @subscriptionTitle.
  ///
  /// In hu, this message translates to:
  /// **'Előfizetés'**
  String get subscriptionTitle;

  /// No description provided for @planName.
  ///
  /// In hu, this message translates to:
  /// **'Csomag: {plan}'**
  String planName(String plan);

  /// No description provided for @planTrial.
  ///
  /// In hu, this message translates to:
  /// **'Próba'**
  String get planTrial;

  /// No description provided for @planBasic.
  ///
  /// In hu, this message translates to:
  /// **'Alap'**
  String get planBasic;

  /// No description provided for @planProfessional.
  ///
  /// In hu, this message translates to:
  /// **'Profi'**
  String get planProfessional;

  /// No description provided for @trialDaysLeft.
  ///
  /// In hu, this message translates to:
  /// **'A próbaidőszakból {days} nap van hátra.'**
  String trialDaysLeft(int days);

  /// No description provided for @subscriptionLocked.
  ///
  /// In hu, this message translates to:
  /// **'A vállalkozás zárolva van, a csomag lejárt vagy felfüggesztették.'**
  String get subscriptionLocked;

  /// No description provided for @subscriptionRenewsOn.
  ///
  /// In hu, this message translates to:
  /// **'A csomag érvényes eddig: {date}'**
  String subscriptionRenewsOn(String date);

  /// No description provided for @subscriptionCancelsAtEnd.
  ///
  /// In hu, this message translates to:
  /// **'Az előfizetés az időszak végén lejár.'**
  String get subscriptionCancelsAtEnd;

  /// No description provided for @subscriptionManageOnWeb.
  ///
  /// In hu, this message translates to:
  /// **'Az előfizetés vásárlása és módosítása a webes felületen történik. Az alkalmazás csak a jelenlegi csomagot mutatja.'**
  String get subscriptionManageOnWeb;

  /// No description provided for @openWebApp.
  ///
  /// In hu, this message translates to:
  /// **'Megnyitás a weben'**
  String get openWebApp;

  /// No description provided for @subscriptionFeatures.
  ///
  /// In hu, this message translates to:
  /// **'A csomag funkciói'**
  String get subscriptionFeatures;

  /// No description provided for @appointmentDetailTitle.
  ///
  /// In hu, this message translates to:
  /// **'Foglalás részletei'**
  String get appointmentDetailTitle;

  /// No description provided for @paymentsTitle.
  ///
  /// In hu, this message translates to:
  /// **'Fizetés'**
  String get paymentsTitle;

  /// No description provided for @paidAmount.
  ///
  /// In hu, this message translates to:
  /// **'Befizetve: {amount}'**
  String paidAmount(String amount);

  /// No description provided for @dueAmount.
  ///
  /// In hu, this message translates to:
  /// **'Fizetendő: {amount}'**
  String dueAmount(String amount);

  /// No description provided for @coveredByPass.
  ///
  /// In hu, this message translates to:
  /// **'Bérlet fedezi'**
  String get coveredByPass;

  /// No description provided for @documentsTitle.
  ///
  /// In hu, this message translates to:
  /// **'Bizonylatok'**
  String get documentsTitle;

  /// No description provided for @docReceipt.
  ///
  /// In hu, this message translates to:
  /// **'Nyugta'**
  String get docReceipt;

  /// No description provided for @docReceiptDeposit.
  ///
  /// In hu, this message translates to:
  /// **'Nyugta (előleg)'**
  String get docReceiptDeposit;

  /// No description provided for @docInvoice.
  ///
  /// In hu, this message translates to:
  /// **'Számla'**
  String get docInvoice;

  /// No description provided for @docInvoiceDeposit.
  ///
  /// In hu, this message translates to:
  /// **'Előlegszámla'**
  String get docInvoiceDeposit;

  /// No description provided for @docInvoiceFinal.
  ///
  /// In hu, this message translates to:
  /// **'Végszámla'**
  String get docInvoiceFinal;

  /// No description provided for @docCancelled.
  ///
  /// In hu, this message translates to:
  /// **'Sztornózva'**
  String get docCancelled;

  /// No description provided for @docCancel.
  ///
  /// In hu, this message translates to:
  /// **'Sztornó'**
  String get docCancel;

  /// No description provided for @docCancelReason.
  ///
  /// In hu, this message translates to:
  /// **'Sztornó oka'**
  String get docCancelReason;

  /// No description provided for @docCancelTitle.
  ///
  /// In hu, this message translates to:
  /// **'Sztornózod a bizonylatot?'**
  String get docCancelTitle;

  /// No description provided for @docOpenPdf.
  ///
  /// In hu, this message translates to:
  /// **'PDF megnyitása'**
  String get docOpenPdf;

  /// No description provided for @docPdfFailed.
  ///
  /// In hu, this message translates to:
  /// **'Nincs alkalmazás a PDF megnyitásához.'**
  String get docPdfFailed;

  /// No description provided for @issueDocument.
  ///
  /// In hu, this message translates to:
  /// **'{document} kiállítása'**
  String issueDocument(String document);

  /// No description provided for @payMethod.
  ///
  /// In hu, this message translates to:
  /// **'Fizetés módja'**
  String get payMethod;

  /// No description provided for @methodOnline.
  ///
  /// In hu, this message translates to:
  /// **'Online bankkártya'**
  String get methodOnline;

  /// No description provided for @methodCard.
  ///
  /// In hu, this message translates to:
  /// **'Bankkártya (helyszínen)'**
  String get methodCard;

  /// No description provided for @methodCash.
  ///
  /// In hu, this message translates to:
  /// **'Készpénz'**
  String get methodCash;

  /// No description provided for @methodTransfer.
  ///
  /// In hu, this message translates to:
  /// **'Átutalás'**
  String get methodTransfer;

  /// No description provided for @methodOther.
  ///
  /// In hu, this message translates to:
  /// **'Egyéb'**
  String get methodOther;

  /// No description provided for @methodVoucher.
  ///
  /// In hu, this message translates to:
  /// **'Utalvány'**
  String get methodVoucher;

  /// No description provided for @refundAsk.
  ///
  /// In hu, this message translates to:
  /// **'Visszatérítsd a befizetett összeget is?'**
  String get refundAsk;

  /// No description provided for @refundYes.
  ///
  /// In hu, this message translates to:
  /// **'Igen, visszatérítés'**
  String get refundYes;

  /// No description provided for @refundNo.
  ///
  /// In hu, this message translates to:
  /// **'Nem'**
  String get refundNo;

  /// No description provided for @bookingAddons.
  ///
  /// In hu, this message translates to:
  /// **'Kiegészítők'**
  String get bookingAddons;

  /// No description provided for @newInvoice.
  ///
  /// In hu, this message translates to:
  /// **'Új számla'**
  String get newInvoice;

  /// No description provided for @invoiceCustomerName.
  ///
  /// In hu, this message translates to:
  /// **'Ügyfél neve'**
  String get invoiceCustomerName;

  /// No description provided for @invoiceItemsTitle.
  ///
  /// In hu, this message translates to:
  /// **'Tételek'**
  String get invoiceItemsTitle;

  /// No description provided for @invoiceItemName.
  ///
  /// In hu, this message translates to:
  /// **'Megnevezés'**
  String get invoiceItemName;

  /// No description provided for @invoiceItemQty.
  ///
  /// In hu, this message translates to:
  /// **'Menny.'**
  String get invoiceItemQty;

  /// No description provided for @invoiceItemPrice.
  ///
  /// In hu, this message translates to:
  /// **'Bruttó egységár (Ft)'**
  String get invoiceItemPrice;

  /// No description provided for @invoiceAddItem.
  ///
  /// In hu, this message translates to:
  /// **'Új tétel'**
  String get invoiceAddItem;

  /// No description provided for @invoiceDueDays.
  ///
  /// In hu, this message translates to:
  /// **'Fizetési határidő (nap)'**
  String get invoiceDueDays;

  /// No description provided for @invoiceAlreadyPaid.
  ///
  /// In hu, this message translates to:
  /// **'Már ki van fizetve'**
  String get invoiceAlreadyPaid;

  /// No description provided for @invoiceTotalLine.
  ///
  /// In hu, this message translates to:
  /// **'Összesen: {total}'**
  String invoiceTotalLine(String total);

  /// No description provided for @invoiceNeedsItem.
  ///
  /// In hu, this message translates to:
  /// **'Adj meg legalább egy tételt névvel és árral.'**
  String get invoiceNeedsItem;

  /// No description provided for @ownerRegister.
  ///
  /// In hu, this message translates to:
  /// **'Pénztár'**
  String get ownerRegister;

  /// No description provided for @registerIncome.
  ///
  /// In hu, this message translates to:
  /// **'Bevétel'**
  String get registerIncome;

  /// No description provided for @registerCashIn.
  ///
  /// In hu, this message translates to:
  /// **'Befizetés'**
  String get registerCashIn;

  /// No description provided for @registerCashOut.
  ///
  /// In hu, this message translates to:
  /// **'Kivét'**
  String get registerCashOut;

  /// No description provided for @registerOpening.
  ///
  /// In hu, this message translates to:
  /// **'Nyitó készpénz'**
  String get registerOpening;

  /// No description provided for @registerExpected.
  ///
  /// In hu, this message translates to:
  /// **'Várható készpénz'**
  String get registerExpected;

  /// No description provided for @registerOnline.
  ///
  /// In hu, this message translates to:
  /// **'Online fizetések'**
  String get registerOnline;

  /// No description provided for @registerUnpaid.
  ///
  /// In hu, this message translates to:
  /// **'Kifizetetlen foglalások'**
  String get registerUnpaid;

  /// No description provided for @registerNoEntries.
  ///
  /// In hu, this message translates to:
  /// **'Ezen a napon még nincs tétel.'**
  String get registerNoEntries;

  /// No description provided for @registerNewEntry.
  ///
  /// In hu, this message translates to:
  /// **'Új tétel'**
  String get registerNewEntry;

  /// No description provided for @registerDescription.
  ///
  /// In hu, this message translates to:
  /// **'Leírás (pl. borravaló, váltópénz)'**
  String get registerDescription;

  /// No description provided for @registerClose.
  ///
  /// In hu, this message translates to:
  /// **'Nap zárása'**
  String get registerClose;

  /// No description provided for @registerCounted.
  ///
  /// In hu, this message translates to:
  /// **'Leszámolt készpénz (Ft)'**
  String get registerCounted;

  /// No description provided for @registerClosed.
  ///
  /// In hu, this message translates to:
  /// **'A nap le van zárva'**
  String get registerClosed;

  /// No description provided for @registerDifference.
  ///
  /// In hu, this message translates to:
  /// **'Eltérés: {amount}'**
  String registerDifference(String amount);

  /// No description provided for @registerReopen.
  ///
  /// In hu, this message translates to:
  /// **'Zárás visszavonása'**
  String get registerReopen;

  /// No description provided for @registerPayWith.
  ///
  /// In hu, this message translates to:
  /// **'Kifizetés: {method}'**
  String registerPayWith(String method);

  /// No description provided for @registerDeleteTitle.
  ///
  /// In hu, this message translates to:
  /// **'Törlöd a tételt?'**
  String get registerDeleteTitle;

  /// No description provided for @registerToday.
  ///
  /// In hu, this message translates to:
  /// **'Ma'**
  String get registerToday;

  /// No description provided for @ownerProducts.
  ///
  /// In hu, this message translates to:
  /// **'Termékek és készlet'**
  String get ownerProducts;

  /// No description provided for @ownerSuppliers.
  ///
  /// In hu, this message translates to:
  /// **'Beszállítók'**
  String get ownerSuppliers;

  /// No description provided for @ownerPurchasing.
  ///
  /// In hu, this message translates to:
  /// **'Beszerzés'**
  String get ownerPurchasing;

  /// No description provided for @newProduct.
  ///
  /// In hu, this message translates to:
  /// **'Új termék'**
  String get newProduct;

  /// No description provided for @editProduct.
  ///
  /// In hu, this message translates to:
  /// **'Termék szerkesztése'**
  String get editProduct;

  /// No description provided for @productPrice.
  ///
  /// In hu, this message translates to:
  /// **'Eladási ár (Ft)'**
  String get productPrice;

  /// No description provided for @productCost.
  ///
  /// In hu, this message translates to:
  /// **'Beszerzési ár (Ft)'**
  String get productCost;

  /// No description provided for @productStock.
  ///
  /// In hu, this message translates to:
  /// **'Készlet (db)'**
  String get productStock;

  /// No description provided for @productSku.
  ///
  /// In hu, this message translates to:
  /// **'Cikkszám'**
  String get productSku;

  /// No description provided for @productLowThreshold.
  ///
  /// In hu, this message translates to:
  /// **'Alacsony készlet küszöbe'**
  String get productLowThreshold;

  /// No description provided for @productLowStock.
  ///
  /// In hu, this message translates to:
  /// **'Alacsony készlet'**
  String get productLowStock;

  /// No description provided for @productsLowOnly.
  ///
  /// In hu, this message translates to:
  /// **'Csak alacsony készlet'**
  String get productsLowOnly;

  /// No description provided for @productSell.
  ///
  /// In hu, this message translates to:
  /// **'Eladás'**
  String get productSell;

  /// No description provided for @sellQuantity.
  ///
  /// In hu, this message translates to:
  /// **'Mennyiség'**
  String get sellQuantity;

  /// No description provided for @productSold.
  ///
  /// In hu, this message translates to:
  /// **'Az eladás rögzítve.'**
  String get productSold;

  /// No description provided for @stockLabel.
  ///
  /// In hu, this message translates to:
  /// **'Készlet: {count}'**
  String stockLabel(int count);

  /// No description provided for @deleteProductTitle.
  ///
  /// In hu, this message translates to:
  /// **'Törlöd a terméket?'**
  String get deleteProductTitle;

  /// No description provided for @newSupplier.
  ///
  /// In hu, this message translates to:
  /// **'Új beszállító'**
  String get newSupplier;

  /// No description provided for @editSupplier.
  ///
  /// In hu, this message translates to:
  /// **'Beszállító szerkesztése'**
  String get editSupplier;

  /// No description provided for @supplierContact.
  ///
  /// In hu, this message translates to:
  /// **'Kapcsolattartó'**
  String get supplierContact;

  /// No description provided for @supplierTax.
  ///
  /// In hu, this message translates to:
  /// **'Adószám'**
  String get supplierTax;

  /// No description provided for @deleteSupplierTitle.
  ///
  /// In hu, this message translates to:
  /// **'Törlöd a beszállítót?'**
  String get deleteSupplierTitle;

  /// No description provided for @newOrder.
  ///
  /// In hu, this message translates to:
  /// **'Új rendelés'**
  String get newOrder;

  /// No description provided for @orderSupplier.
  ///
  /// In hu, this message translates to:
  /// **'Beszállító'**
  String get orderSupplier;

  /// No description provided for @orderLines.
  ///
  /// In hu, this message translates to:
  /// **'Tételek'**
  String get orderLines;

  /// No description provided for @orderLineDescription.
  ///
  /// In hu, this message translates to:
  /// **'Megnevezés'**
  String get orderLineDescription;

  /// No description provided for @orderLineQty.
  ///
  /// In hu, this message translates to:
  /// **'Db'**
  String get orderLineQty;

  /// No description provided for @orderLineCost.
  ///
  /// In hu, this message translates to:
  /// **'Egységár (Ft)'**
  String get orderLineCost;

  /// No description provided for @orderAddLine.
  ///
  /// In hu, this message translates to:
  /// **'Új tétel'**
  String get orderAddLine;

  /// No description provided for @orderStatusDraft.
  ///
  /// In hu, this message translates to:
  /// **'Piszkozat'**
  String get orderStatusDraft;

  /// No description provided for @orderStatusOrdered.
  ///
  /// In hu, this message translates to:
  /// **'Leadva'**
  String get orderStatusOrdered;

  /// No description provided for @orderStatusReceived.
  ///
  /// In hu, this message translates to:
  /// **'Bevételezve'**
  String get orderStatusReceived;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In hu, this message translates to:
  /// **'Sztornózva'**
  String get orderStatusCancelled;

  /// No description provided for @orderMarkOrdered.
  ///
  /// In hu, this message translates to:
  /// **'Leadás'**
  String get orderMarkOrdered;

  /// No description provided for @orderReceive.
  ///
  /// In hu, this message translates to:
  /// **'Bevételezés'**
  String get orderReceive;

  /// No description provided for @orderCancel.
  ///
  /// In hu, this message translates to:
  /// **'Sztornó'**
  String get orderCancel;

  /// No description provided for @orderExpected.
  ///
  /// In hu, this message translates to:
  /// **'Várható: {date}'**
  String orderExpected(String date);

  /// No description provided for @orderNeedsSupplier.
  ///
  /// In hu, this message translates to:
  /// **'Előbb vegyél fel egy beszállítót.'**
  String get orderNeedsSupplier;

  /// No description provided for @orderNeedsLine.
  ///
  /// In hu, this message translates to:
  /// **'Adj meg legalább egy tételt.'**
  String get orderNeedsLine;

  /// No description provided for @orderReceivedQty.
  ///
  /// In hu, this message translates to:
  /// **'Beérkezett (db)'**
  String get orderReceivedQty;

  /// No description provided for @ownerPassTypes.
  ///
  /// In hu, this message translates to:
  /// **'Bérlet- és utalvány-típusok'**
  String get ownerPassTypes;

  /// No description provided for @ownerLoyalty.
  ///
  /// In hu, this message translates to:
  /// **'Hűségprogram'**
  String get ownerLoyalty;

  /// No description provided for @ownerCampaigns.
  ///
  /// In hu, this message translates to:
  /// **'Kampányok'**
  String get ownerCampaigns;

  /// No description provided for @newPassType.
  ///
  /// In hu, this message translates to:
  /// **'Új típus'**
  String get newPassType;

  /// No description provided for @passTypeKind.
  ///
  /// In hu, this message translates to:
  /// **'Fajta'**
  String get passTypeKind;

  /// No description provided for @passTypeSessions.
  ///
  /// In hu, this message translates to:
  /// **'Alkalmak száma'**
  String get passTypeSessions;

  /// No description provided for @passTypeValue.
  ///
  /// In hu, this message translates to:
  /// **'Névérték (Ft)'**
  String get passTypeValue;

  /// No description provided for @passTypePrice.
  ///
  /// In hu, this message translates to:
  /// **'Ár (Ft)'**
  String get passTypePrice;

  /// No description provided for @passTypeValidity.
  ///
  /// In hu, this message translates to:
  /// **'Érvényesség (nap)'**
  String get passTypeValidity;

  /// No description provided for @passTypeService.
  ///
  /// In hu, this message translates to:
  /// **'Szolgáltatás (nem kötelező)'**
  String get passTypeService;

  /// No description provided for @passTypeAnyService.
  ///
  /// In hu, this message translates to:
  /// **'Bármelyik'**
  String get passTypeAnyService;

  /// No description provided for @passTypeSoldCount.
  ///
  /// In hu, this message translates to:
  /// **'{count} eladva'**
  String passTypeSoldCount(int count);

  /// No description provided for @passTypeSell.
  ///
  /// In hu, this message translates to:
  /// **'Eladás'**
  String get passTypeSell;

  /// No description provided for @passTypePurchaserEmail.
  ///
  /// In hu, this message translates to:
  /// **'Vevő e-mail-címe'**
  String get passTypePurchaserEmail;

  /// No description provided for @passTypeRecipient.
  ///
  /// In hu, this message translates to:
  /// **'Címzett neve (ajándéknál)'**
  String get passTypeRecipient;

  /// No description provided for @passTypeDeleteTitle.
  ///
  /// In hu, this message translates to:
  /// **'Törlöd a típust?'**
  String get passTypeDeleteTitle;

  /// No description provided for @passTypeInactive.
  ///
  /// In hu, this message translates to:
  /// **'Kikapcsolva'**
  String get passTypeInactive;

  /// No description provided for @loyaltyEnabled.
  ///
  /// In hu, this message translates to:
  /// **'Hűségprogram bekapcsolva'**
  String get loyaltyEnabled;

  /// No description provided for @loyaltyPointsPer1000.
  ///
  /// In hu, this message translates to:
  /// **'Pont minden 1000 Ft után'**
  String get loyaltyPointsPer1000;

  /// No description provided for @loyaltyRewardPointsLabel.
  ///
  /// In hu, this message translates to:
  /// **'Jutalomhoz szükséges pont'**
  String get loyaltyRewardPointsLabel;

  /// No description provided for @loyaltyRewardValueLabel.
  ///
  /// In hu, this message translates to:
  /// **'Jutalom értéke (Ft)'**
  String get loyaltyRewardValueLabel;

  /// No description provided for @loyaltyMembers.
  ///
  /// In hu, this message translates to:
  /// **'Tagok: {count}'**
  String loyaltyMembers(int count);

  /// No description provided for @loyaltyOutstanding.
  ///
  /// In hu, this message translates to:
  /// **'Ki nem váltott pont: {count}'**
  String loyaltyOutstanding(int count);

  /// No description provided for @loyaltyLeaderboard.
  ///
  /// In hu, this message translates to:
  /// **'Ranglista'**
  String get loyaltyLeaderboard;

  /// No description provided for @newCampaign.
  ///
  /// In hu, this message translates to:
  /// **'Új kampány'**
  String get newCampaign;

  /// No description provided for @editCampaign.
  ///
  /// In hu, this message translates to:
  /// **'Kampány szerkesztése'**
  String get editCampaign;

  /// No description provided for @campaignName.
  ///
  /// In hu, this message translates to:
  /// **'Belső név'**
  String get campaignName;

  /// No description provided for @campaignSubject.
  ///
  /// In hu, this message translates to:
  /// **'Levél tárgya'**
  String get campaignSubject;

  /// No description provided for @campaignBody.
  ///
  /// In hu, this message translates to:
  /// **'Levél szövege'**
  String get campaignBody;

  /// No description provided for @campaignSegmentLabel.
  ///
  /// In hu, this message translates to:
  /// **'Célcsoport'**
  String get campaignSegmentLabel;

  /// No description provided for @segAll.
  ///
  /// In hu, this message translates to:
  /// **'Minden hozzájárult vendég'**
  String get segAll;

  /// No description provided for @segInactive.
  ///
  /// In hu, this message translates to:
  /// **'Rég nem járt nálunk'**
  String get segInactive;

  /// No description provided for @segNew.
  ///
  /// In hu, this message translates to:
  /// **'Új vendégek'**
  String get segNew;

  /// No description provided for @segService.
  ///
  /// In hu, this message translates to:
  /// **'Adott szolgáltatást igénybe vevők'**
  String get segService;

  /// No description provided for @segLoyalty.
  ///
  /// In hu, this message translates to:
  /// **'Hűségpontjuk már beváltható'**
  String get segLoyalty;

  /// No description provided for @segDays.
  ///
  /// In hu, this message translates to:
  /// **'Napok száma'**
  String get segDays;

  /// No description provided for @campaignAudience.
  ///
  /// In hu, this message translates to:
  /// **'Ennyien kapnák meg: {count}'**
  String campaignAudience(int count);

  /// No description provided for @campaignStatusDraft.
  ///
  /// In hu, this message translates to:
  /// **'Piszkozat'**
  String get campaignStatusDraft;

  /// No description provided for @campaignStatusSent.
  ///
  /// In hu, this message translates to:
  /// **'Elküldve'**
  String get campaignStatusSent;

  /// No description provided for @campaignSendTest.
  ///
  /// In hu, this message translates to:
  /// **'Próbalevél nekem'**
  String get campaignSendTest;

  /// No description provided for @campaignTestSent.
  ///
  /// In hu, this message translates to:
  /// **'A próbalevél elment ide: {email}'**
  String campaignTestSent(String email);

  /// No description provided for @campaignSend.
  ///
  /// In hu, this message translates to:
  /// **'Kiküldés'**
  String get campaignSend;

  /// No description provided for @campaignSendConfirm.
  ///
  /// In hu, this message translates to:
  /// **'Kiküldöd a kampányt a célcsoportnak? Ez nem vonható vissza.'**
  String get campaignSendConfirm;

  /// No description provided for @campaignSent.
  ///
  /// In hu, this message translates to:
  /// **'Kiküldve {count} címzettnek.'**
  String campaignSent(int count);

  /// No description provided for @campaignDeleteTitle.
  ///
  /// In hu, this message translates to:
  /// **'Törlöd a kampányt?'**
  String get campaignDeleteTitle;

  /// No description provided for @campaignConsents.
  ///
  /// In hu, this message translates to:
  /// **'Hozzájárult vendégek: {count} · napi limit: {limit}'**
  String campaignConsents(int count, int limit);

  /// No description provided for @ownerGroupSessions.
  ///
  /// In hu, this message translates to:
  /// **'Csoportos alkalmak'**
  String get ownerGroupSessions;

  /// No description provided for @ownerBreaks.
  ///
  /// In hu, this message translates to:
  /// **'Szünetek'**
  String get ownerBreaks;

  /// No description provided for @ownerTimesheet.
  ///
  /// In hu, this message translates to:
  /// **'Munkaidő'**
  String get ownerTimesheet;

  /// No description provided for @newGroupSession.
  ///
  /// In hu, this message translates to:
  /// **'Új alkalom'**
  String get newGroupSession;

  /// No description provided for @groupCapacity.
  ///
  /// In hu, this message translates to:
  /// **'Férőhely'**
  String get groupCapacity;

  /// No description provided for @groupRepeatWeeks.
  ///
  /// In hu, this message translates to:
  /// **'Ismétlés (hét)'**
  String get groupRepeatWeeks;

  /// No description provided for @groupTime.
  ///
  /// In hu, this message translates to:
  /// **'Kezdés (ÓÓ:PP)'**
  String get groupTime;

  /// No description provided for @groupBooked.
  ///
  /// In hu, this message translates to:
  /// **'{booked}/{capacity} fő'**
  String groupBooked(int booked, int capacity);

  /// No description provided for @groupAddAttendee.
  ///
  /// In hu, this message translates to:
  /// **'Résztvevő felvétele'**
  String get groupAddAttendee;

  /// No description provided for @groupCancelTitle.
  ///
  /// In hu, this message translates to:
  /// **'Lemondod az alkalmat?'**
  String get groupCancelTitle;

  /// No description provided for @groupCancelText.
  ///
  /// In hu, this message translates to:
  /// **'A jelentkezők értesítést kapnak.'**
  String get groupCancelText;

  /// No description provided for @groupCancelled.
  ///
  /// In hu, this message translates to:
  /// **'Lemondva'**
  String get groupCancelled;

  /// No description provided for @groupNoAttendees.
  ///
  /// In hu, this message translates to:
  /// **'Még nincs jelentkező.'**
  String get groupNoAttendees;

  /// No description provided for @breaksNone.
  ///
  /// In hu, this message translates to:
  /// **'Nincs szünet felvéve.'**
  String get breaksNone;

  /// No description provided for @newBreak.
  ///
  /// In hu, this message translates to:
  /// **'Új szünet'**
  String get newBreak;

  /// No description provided for @breakDay.
  ///
  /// In hu, this message translates to:
  /// **'Nap'**
  String get breakDay;

  /// No description provided for @breakFrom.
  ///
  /// In hu, this message translates to:
  /// **'Kezdete (ÓÓ:PP)'**
  String get breakFrom;

  /// No description provided for @breakTo.
  ///
  /// In hu, this message translates to:
  /// **'Vége (ÓÓ:PP)'**
  String get breakTo;

  /// No description provided for @breakLabel.
  ///
  /// In hu, this message translates to:
  /// **'Megnevezés (pl. ebéd)'**
  String get breakLabel;

  /// No description provided for @weekdaySun.
  ///
  /// In hu, this message translates to:
  /// **'Vasárnap'**
  String get weekdaySun;

  /// No description provided for @weekdayMon.
  ///
  /// In hu, this message translates to:
  /// **'Hétfő'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In hu, this message translates to:
  /// **'Kedd'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In hu, this message translates to:
  /// **'Szerda'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In hu, this message translates to:
  /// **'Csütörtök'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In hu, this message translates to:
  /// **'Péntek'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In hu, this message translates to:
  /// **'Szombat'**
  String get weekdaySat;

  /// No description provided for @timesheetWorked.
  ///
  /// In hu, this message translates to:
  /// **'Ledolgozott: {hours}'**
  String timesheetWorked(String hours);

  /// No description provided for @timesheetPlanned.
  ///
  /// In hu, this message translates to:
  /// **'Tervezett: {hours}'**
  String timesheetPlanned(String hours);

  /// No description provided for @timesheetOvertime.
  ///
  /// In hu, this message translates to:
  /// **'Túlóra: {hours}'**
  String timesheetOvertime(String hours);

  /// No description provided for @timesheetPay.
  ///
  /// In hu, this message translates to:
  /// **'Becsült bér: {amount}'**
  String timesheetPay(String amount);

  /// No description provided for @timesheetClosed.
  ///
  /// In hu, this message translates to:
  /// **'A hónap le van zárva'**
  String get timesheetClosed;

  /// No description provided for @timesheetClose.
  ///
  /// In hu, this message translates to:
  /// **'Hónap zárása'**
  String get timesheetClose;

  /// No description provided for @timesheetReopen.
  ///
  /// In hu, this message translates to:
  /// **'Zárás visszavonása'**
  String get timesheetReopen;

  /// No description provided for @timesheetStale.
  ///
  /// In hu, this message translates to:
  /// **'{count} nyitva felejtett műszak'**
  String timesheetStale(int count);

  /// No description provided for @timesheetNewEntry.
  ///
  /// In hu, this message translates to:
  /// **'Műszak felvétele'**
  String get timesheetNewEntry;

  /// No description provided for @timesheetStaff.
  ///
  /// In hu, this message translates to:
  /// **'Munkatárs'**
  String get timesheetStaff;

  /// No description provided for @timesheetIn.
  ///
  /// In hu, this message translates to:
  /// **'Kezdés'**
  String get timesheetIn;

  /// No description provided for @timesheetOut.
  ///
  /// In hu, this message translates to:
  /// **'Vége'**
  String get timesheetOut;

  /// No description provided for @timesheetBreakMinutes.
  ///
  /// In hu, this message translates to:
  /// **'Szünet (perc)'**
  String get timesheetBreakMinutes;

  /// No description provided for @timesheetEntries.
  ///
  /// In hu, this message translates to:
  /// **'Műszakok'**
  String get timesheetEntries;

  /// No description provided for @timesheetOpenSince.
  ///
  /// In hu, this message translates to:
  /// **'Bent van: {time}'**
  String timesheetOpenSince(String time);
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
