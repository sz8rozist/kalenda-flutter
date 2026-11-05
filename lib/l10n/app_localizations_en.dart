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
  String get newBooking => 'New booking';

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

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get findBusinessTitle => 'Find a business';

  @override
  String get findBusinessIntro =>
      'Enter the business booking address (slug) or paste its booking link.';

  @override
  String get businessSlug => 'Slug or link';

  @override
  String get open => 'Open';

  @override
  String get services => 'Services';

  @override
  String get book => 'Book';

  @override
  String get bookingTitle => 'Book an appointment';

  @override
  String get staffLabel => 'Staff';

  @override
  String get addons => 'Extras';

  @override
  String get dateLabel => 'Date';

  @override
  String get pickDate => 'Pick a day';

  @override
  String get timeLabel => 'Time';

  @override
  String get noSlots => 'No free times on this day.';

  @override
  String get yourDetails => 'Your details';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get notes => 'Notes';

  @override
  String get passCode => 'Pass code (if any)';

  @override
  String get marketingConsent => 'I would like the newsletter';

  @override
  String get confirmBooking => 'Confirm booking';

  @override
  String get payDeposit => 'Payment';

  @override
  String get bookingDone => 'Booking confirmed';

  @override
  String get bookingDoneText => 'We have emailed you the confirmation.';

  @override
  String get paymentRequired => 'Payment is required to confirm the booking.';

  @override
  String get payNow => 'Pay now';

  @override
  String get manageBooking => 'Manage booking';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get cancelConfirmTitle => 'Cancel this booking?';

  @override
  String get cancelConfirmText => 'This cannot be undone.';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get saved => 'Saved.';

  @override
  String get cancelled => 'The booking was cancelled.';

  @override
  String get status => 'Status';

  @override
  String get total => 'Total';

  @override
  String get call => 'Call';

  @override
  String get backToBookings => 'Back to bookings';

  @override
  String get required => 'This field is required.';

  @override
  String get invalidEmail => 'Invalid email address.';

  @override
  String get accountTitle => 'My account';

  @override
  String get profile => 'Profile';

  @override
  String get save => 'Save';

  @override
  String get loyaltyTitle => 'Loyalty points';

  @override
  String loyaltyBalance(int points) {
    return '$points points';
  }

  @override
  String loyaltyReward(int points, String value) {
    return '$value for $points points';
  }

  @override
  String get passesTitle => 'Passes and vouchers';

  @override
  String sessionsLeft(int count) {
    return '$count sessions left';
  }

  @override
  String balanceLeft(String value) {
    return 'Balance: $value';
  }

  @override
  String expiresOn(String date) {
    return 'Expires: $date';
  }

  @override
  String get expired => 'Expired';

  @override
  String get consentsTitle => 'Newsletter consents';

  @override
  String get nothingYet => 'Nothing here yet.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountText =>
      'Your personal data will be erased and your sign-in and devices removed. This cannot be undone. The account cannot be deleted while you have upcoming bookings.';
}
