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
      'Paste the link from the email (or the code after /belepes/).';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String updateRequiredText(String version) {
    return 'This version is no longer supported. Please update the app to version $version or newer.';
  }

  @override
  String get updateNow => 'Update';

  @override
  String get backToStart => 'Back to start';

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

  @override
  String get staffLoginLink => 'I am staff or a business owner';

  @override
  String get staffLoginTitle => 'Staff sign-in';

  @override
  String get staffLoginIntro =>
      'Sign in with your Kalenda account email and password.';

  @override
  String get password => 'Password';

  @override
  String get staffToday => 'Today';

  @override
  String get staffCalendar => 'Calendar';

  @override
  String get staffLeaves => 'Time off';

  @override
  String get staffNoProfile =>
      'This account has no staff profile. The business tools are available on the web for now.';

  @override
  String todayCount(int count) {
    return '$count bookings today';
  }

  @override
  String get upcomingAppointments => 'Upcoming bookings';

  @override
  String get noAppointments => 'No bookings.';

  @override
  String get clockIn => 'Clock in';

  @override
  String get clockOut => 'Clock out';

  @override
  String clockedInSince(String time) {
    return 'Clocked in since $time';
  }

  @override
  String get breakMinutes => 'Break (minutes)';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusNoShow => 'No-show';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionComplete => 'Attended / complete';

  @override
  String get actionNoShow => 'No-show';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get newLeave => 'Request time off';

  @override
  String get leaveReason => 'Reason (optional)';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get pickDates => 'Pick the period';

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get leaveDay => 'Time off';

  @override
  String get ownerLoginLink => 'I am signing in as a business owner';

  @override
  String get ownerOverview => 'Overview';

  @override
  String get ownerCustomers => 'Customers';

  @override
  String get ownerNoBusiness => 'This account has no business.';

  @override
  String get weekRevenueTitle => 'Revenue this week';

  @override
  String weekRevenueSoFar(String amount) {
    return 'So far: $amount';
  }

  @override
  String weekRevenueChange(String percent) {
    return '$percent% vs last week';
  }

  @override
  String get receivablesTitle => 'Receivables';

  @override
  String receivablesOutstanding(String amount, int count) {
    return 'Outstanding: $amount ($count)';
  }

  @override
  String receivablesOverdue(String amount, int count) {
    return 'Overdue: $amount ($count)';
  }

  @override
  String lowStock(int count) {
    return '$count products running low';
  }

  @override
  String get todaysBookings => 'Today\'s bookings';

  @override
  String get searchCustomers => 'Search by name, email or phone';

  @override
  String customerStats(int total, String spent, int noShow) {
    return '$total bookings · $spent · $noShow no-shows';
  }
}
