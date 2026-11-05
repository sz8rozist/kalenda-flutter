// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kalenda';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginIntro =>
      'Enter your email and we will send you a sign-in link.';

  @override
  String get email => 'Email';

  @override
  String get sendLink => 'Send sign-in link';

  @override
  String get linkSent =>
      'If the address is known to us, we have sent a sign-in link.';

  @override
  String get tokenLabel => 'Code from the email';

  @override
  String get tokenHelp =>
      'Paste the code from the link in the email (the part after /belepes/).';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get myAppointments => 'My bookings';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get noUpcoming => 'You have no upcoming bookings.';

  @override
  String get noPast => 'You have no past bookings yet.';

  @override
  String get retry => 'Retry';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get networkError => 'Cannot reach the server.';

  @override
  String priceHuf(String amount) {
    return '$amount HUF';
  }
}
