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
  /// **'Másold be a levélben kapott linkből a kódot (a /belepes/ utáni rész).'**
  String get tokenHelp;

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
