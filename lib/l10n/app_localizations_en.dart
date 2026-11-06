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
  String get ok => 'OK';

  @override
  String get bookingIncomplete =>
      'Please choose a staff member, a day and a time.';

  @override
  String get errorTitleGeneric => 'Something went wrong';

  @override
  String get errorTitleNetwork => 'No connection';

  @override
  String get errorNetworkText =>
      'We cannot reach the server. Check your internet connection and try again.';

  @override
  String get errorTitleSession => 'Session expired';

  @override
  String get errorSessionText => 'Please sign in again.';

  @override
  String get errorTitleDenied => 'Access denied';

  @override
  String get errorTitleNotFound => 'Not found';

  @override
  String get errorTitleValidation => 'Please check your details';

  @override
  String get errorTitleTooMany => 'Too many requests';

  @override
  String get errorTooManyText => 'Please wait a moment and try again.';

  @override
  String get errorTitleServer => 'Server error';

  @override
  String get errorServerText =>
      'Something went wrong on the server. Please try again a little later.';

  @override
  String get welcomeTitle => 'Book appointments in a few taps';

  @override
  String get welcomeText =>
      'Find your favourite salon, studio or trainer and book online.';

  @override
  String get splashTagline => 'Appointment booking made simple';

  @override
  String get ownerStaff => 'Staff';

  @override
  String get staffHasAccount => 'has an account';

  @override
  String upcomingBookings(int count) {
    return '$count upcoming bookings';
  }

  @override
  String get ownerManage => 'Manage';

  @override
  String get ownerLeaves => 'Time-off requests';

  @override
  String get noPendingLeaves => 'No time-off requests waiting for a decision.';

  @override
  String get approveLeave => 'Approve';

  @override
  String get rejectLeave => 'Reject';

  @override
  String get rejectNote => 'Reason (optional)';

  @override
  String get ownerHours => 'Opening hours';

  @override
  String get closedDay => 'Closed';

  @override
  String get ownerServices => 'Services';

  @override
  String get serviceRental => 'Rental';

  @override
  String get serviceDurationMinutes => 'Duration (minutes)';

  @override
  String get servicePriceHuf => 'Price (HUF)';

  @override
  String get ownerReports => 'Reports';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get reportRevenue => 'Revenue';

  @override
  String get reportServices => 'Services';

  @override
  String get reportProducts => 'Products';

  @override
  String get reportPasses => 'Passes';

  @override
  String get reportVouchers => 'Vouchers';

  @override
  String get reportRevenueTotal => 'Total revenue';

  @override
  String get reportExpenses => 'Expenses';

  @override
  String get reportPayroll => 'Payroll (estimate)';

  @override
  String get reportMaterials => 'Materials';

  @override
  String get reportExpensesTotal => 'Total expenses';

  @override
  String get reportResult => 'Result';

  @override
  String get reportReceivables => 'Receivables at month end';

  @override
  String get cashflowTitle => 'Cash flow forecast';

  @override
  String get cashflowPartial => 'in progress';

  @override
  String get cashflowIn => 'Inflow';

  @override
  String get cashflowOut => 'Outflow';

  @override
  String get ownerInvoices => 'Invoices';

  @override
  String get invoiceAll => 'All';

  @override
  String get invoiceUnpaid => 'Open';

  @override
  String get invoiceOverdue => 'Overdue';

  @override
  String get invoicePaid => 'Paid';

  @override
  String get invoiceCancelled => 'Cancelled';

  @override
  String paidOn(String date) {
    return 'Paid: $date';
  }

  @override
  String dueOn(String date) {
    return 'Due: $date';
  }

  @override
  String remindersSent(int count) {
    return '$count reminders sent';
  }

  @override
  String get payMethodCash => 'cash';

  @override
  String get payMethodCard => 'card';

  @override
  String get payMethodTransfer => 'transfer';

  @override
  String markPaidWith(String method) {
    return 'Paid – $method';
  }

  @override
  String get markUnpaid => 'Undo payment';

  @override
  String get sendReminder => 'Send payment reminder';

  @override
  String get scanQr => 'Scan QR code';

  @override
  String get scanQrTitle => 'Scan QR code';

  @override
  String get scanQrHint => 'Point the camera at the business booking QR code.';

  @override
  String get cameraUnavailable =>
      'The camera is not available. Allow camera access in the settings.';

  @override
  String get addToCalendar => 'Add to calendar';

  @override
  String get passesAndVouchers => 'Passes and vouchers';

  @override
  String get passPurchaseTitle => 'Buy a pass / voucher';

  @override
  String sessionsCountLabel(int count) {
    return '$count sessions';
  }

  @override
  String valueLabel(String value) {
    return 'Value: $value';
  }

  @override
  String validityDaysLabel(int days) {
    return 'valid for $days days';
  }

  @override
  String get passBuyerEmail =>
      'Your email (the receipt and code are sent here)';

  @override
  String get passGift => 'It is a gift';

  @override
  String get recipientName => 'Recipient name';

  @override
  String get recipientEmail => 'Recipient email';

  @override
  String get senderName => 'Your name (sender)';

  @override
  String get giftMessage => 'Gift message';

  @override
  String get passBuy => 'Continue to payment';

  @override
  String get passAfterPayment =>
      'Payment happens in the browser. Afterwards the pass appears under My account (sign in with the email used for the purchase).';

  @override
  String get reviewTitle => 'Review';

  @override
  String get reviewQuestion => 'How did you like the service?';

  @override
  String get reviewFeedback => 'Anything to add? (optional)';

  @override
  String get reviewSubmit => 'Send review';

  @override
  String get reviewThanks => 'Thank you for your review!';

  @override
  String get reviewOnGoogle => 'Review on Google too';

  @override
  String get groupSessions => 'Group sessions';

  @override
  String get groupSessionTitle => 'Join a session';

  @override
  String placesLeft(int count) {
    return '$count places left';
  }

  @override
  String get sessionFull => 'Full';

  @override
  String get joinSession => 'Sign up';

  @override
  String get joinWaitlist => 'Join the waitlist';

  @override
  String get waitlistJoined =>
      'You are on the waitlist; we will notify you when a time frees up.';

  @override
  String get orSignInWith => 'or';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appLockTitle => 'Lock with biometrics';

  @override
  String get appLockSubtitle =>
      'Opening the app requires your fingerprint, face or device lock.';

  @override
  String get appLockUnavailable =>
      'This device has no biometrics or screen lock set up.';

  @override
  String get unlockTitle => 'The app is locked';

  @override
  String get unlockButton => 'Unlock';

  @override
  String get unlockReason => 'Unlock Kalenda';

  @override
  String get unlockFailed => 'Authentication failed.';

  @override
  String get ownerNewBooking => 'New booking';

  @override
  String get ownerCreateBooking => 'Create booking';

  @override
  String get ownerCustomerLabel => 'Customer';

  @override
  String get newCustomerOption => 'New customer';

  @override
  String get serviceLabel => 'Service';

  @override
  String get sendEmailLabel => 'Email the customer a confirmation';

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

  @override
  String get favorites => 'Your favorites';

  @override
  String get recentBusinesses => 'Recently opened';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get offlineBanner => 'No internet connection';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get started';

  @override
  String get onboardingTitle1 => 'Find your place';

  @override
  String get onboardingText1 =>
      'Salons, studios, trainers – search by name, open a link or scan a QR code.';

  @override
  String get onboardingTitle2 => 'Book in a few taps';

  @override
  String get onboardingText2 =>
      'Pick a service, a specialist and a free slot, and get your confirmation instantly.';

  @override
  String get onboardingTitle3 => 'Always in the loop';

  @override
  String get onboardingText3 =>
      'Get reminders, see your bookings in one place and reschedule or cancel any time.';

  @override
  String get stepStaff => 'Who and what?';

  @override
  String get stepDateTime => 'When?';

  @override
  String get stepDetails => 'Your details';

  @override
  String get pickAnotherDate => 'Other date';

  @override
  String get dayToday => 'Today';

  @override
  String get dayTomorrow => 'Tomorrow';

  @override
  String get bookingDoneTitle => 'Booking confirmed!';

  @override
  String get statusLabelPrefix => 'Status';

  @override
  String get customerLabel => 'Customer';

  @override
  String get offlineShowingSaved => 'Showing saved data';

  @override
  String get remindersTitle => 'Notifications';

  @override
  String get profileInitial => 'Profile';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionAdd => 'New';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldColor => 'Color';

  @override
  String get fieldActive => 'Active';

  @override
  String get fieldAddress => 'Address';

  @override
  String get newService => 'New service';

  @override
  String get editService => 'Edit service';

  @override
  String get depositTypeLabel => 'Deposit';

  @override
  String get depositNone => 'None';

  @override
  String get depositPercentage => 'Percentage';

  @override
  String get depositFull => 'Full amount';

  @override
  String get depositPercentLabel => 'Deposit (%)';

  @override
  String get bufferBefore => 'Preparation (min)';

  @override
  String get bufferAfter => 'Rest after (min)';

  @override
  String get groupServiceLabel => 'Group session';

  @override
  String get rentalServiceLabel => 'Rentable (court, room)';

  @override
  String get maxDurationLabel => 'Up to (min)';

  @override
  String get durationStepLabel => 'Duration step (min)';

  @override
  String get deleteServiceTitle => 'Delete this service?';

  @override
  String get deleteServiceText =>
      'The service can no longer be booked. If it already has bookings, the server may refuse to delete it.';

  @override
  String get newStaff => 'New team member';

  @override
  String get editStaff => 'Edit team member';

  @override
  String get staffBio => 'Bio';

  @override
  String get staffKindLabel => 'Type';

  @override
  String get staffKindPerson => 'Person';

  @override
  String get staffKindResource => 'Resource (court, room)';

  @override
  String get staffServicesTitle => 'Services';

  @override
  String get inviteStaff => 'Send invitation';

  @override
  String get inviteSent => 'The invitation was sent.';

  @override
  String get revokeAccess => 'Revoke access';

  @override
  String get deleteStaffTitle => 'Delete this team member?';

  @override
  String get deleteStaffText => 'They can no longer be booked.';

  @override
  String get customerDetailsTitle => 'Customer';

  @override
  String get customerBookings => 'Bookings';

  @override
  String get customerCompleted => 'Completed';

  @override
  String get customerCancelled => 'Cancelled';

  @override
  String get customerNoShows => 'No-shows';

  @override
  String get customerSpent => 'Total spent';

  @override
  String get customerNote => 'Internal note';

  @override
  String get customerDepositExempt => 'Exempt from deposit';

  @override
  String get customerNoShowFlag => 'Warning: repeated no-shows';

  @override
  String get billingTitle => 'Billing details';

  @override
  String get billingPostCode => 'Post code';

  @override
  String get billingCity => 'City';

  @override
  String get billingTaxNumber => 'Tax number';

  @override
  String get billingEmail => 'Billing email';

  @override
  String get loyaltyTitleOwner => 'Loyalty points';

  @override
  String get loyaltyAdjust => 'Adjust points';

  @override
  String get loyaltyAdjustPoints => 'Points (can be negative)';

  @override
  String get loyaltyRedeem => 'Redeem reward';

  @override
  String loyaltyRedeemed(String discount) {
    return 'Redeemed: $discount discount';
  }

  @override
  String get loyaltyNoReward => 'Not enough points for the reward.';

  @override
  String get loyaltyHistory => 'History';

  @override
  String get ownerExpenses => 'Expenses';

  @override
  String get ownerReviews => 'Reviews';

  @override
  String get ownerPasses => 'Passes and vouchers';

  @override
  String get ownerWaitlist => 'Waitlist';

  @override
  String get ownerActivityLog => 'Activity log';

  @override
  String get newExpense => 'New expense';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseAmount => 'Amount (HUF)';

  @override
  String get expenseVendor => 'Vendor';

  @override
  String get expenseRecurring => 'Recurring expense';

  @override
  String get expenseDate => 'Date';

  @override
  String expensesTotal(String total) {
    return 'Total: $total';
  }

  @override
  String get deleteExpenseTitle => 'Delete this expense?';

  @override
  String get deleteExpenseText => 'It will be removed from the reports.';

  @override
  String get reviewsEnabled => 'Ask for a review after the visit';

  @override
  String get googleReviewUrl => 'Google review link';

  @override
  String reviewsSummary(String average, int count) {
    return '$average average · $count reviews';
  }

  @override
  String get passKindPass => 'Pass';

  @override
  String get passKindVoucher => 'Voucher';

  @override
  String passRecipient(String name) {
    return 'Recipient: $name';
  }

  @override
  String get waitlistNotify => 'Send notification';

  @override
  String get waitlistNotified => 'Notified';

  @override
  String get waitlistWaiting => 'Waiting';

  @override
  String get waitlistBooked => 'Booked';

  @override
  String get waitlistExpired => 'Expired';

  @override
  String get waitlistRemove => 'Remove';

  @override
  String get activitySearch => 'Search the log';

  @override
  String get ownerMore => 'More';

  @override
  String get menuGroupBooking => 'Bookings and customers';

  @override
  String get menuGroupSales => 'Sales and marketing';

  @override
  String get menuGroupFinance => 'Finance';

  @override
  String get menuGroupOperations => 'Operations';

  @override
  String get menuGroupSettings => 'Settings';

  @override
  String get menuNotInPlan => 'Not included in your plan';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String planName(String plan) {
    return 'Plan: $plan';
  }

  @override
  String get planTrial => 'Trial';

  @override
  String get planBasic => 'Basic';

  @override
  String get planProfessional => 'Professional';

  @override
  String trialDaysLeft(int days) {
    return '$days days left in your trial.';
  }

  @override
  String get subscriptionLocked =>
      'The business is locked because the plan expired or was suspended.';

  @override
  String subscriptionRenewsOn(String date) {
    return 'Plan valid until: $date';
  }

  @override
  String get subscriptionCancelsAtEnd =>
      'The subscription ends at the end of the period.';

  @override
  String get subscriptionManageOnWeb =>
      'Buying and changing the subscription is done on the web. The app only shows your current plan.';

  @override
  String get openWebApp => 'Open on the web';

  @override
  String get subscriptionFeatures => 'Plan features';

  @override
  String get appointmentDetailTitle => 'Booking details';

  @override
  String get paymentsTitle => 'Payment';

  @override
  String paidAmount(String amount) {
    return 'Paid: $amount';
  }

  @override
  String dueAmount(String amount) {
    return 'Due: $amount';
  }

  @override
  String get coveredByPass => 'Covered by a pass';

  @override
  String get documentsTitle => 'Documents';

  @override
  String get docReceipt => 'Receipt';

  @override
  String get docReceiptDeposit => 'Receipt (deposit)';

  @override
  String get docInvoice => 'Invoice';

  @override
  String get docInvoiceDeposit => 'Deposit invoice';

  @override
  String get docInvoiceFinal => 'Final invoice';

  @override
  String get docCancelled => 'Cancelled';

  @override
  String get docCancel => 'Cancel document';

  @override
  String get docCancelReason => 'Reason';

  @override
  String get docCancelTitle => 'Cancel this document?';

  @override
  String get docOpenPdf => 'Open PDF';

  @override
  String get docPdfFailed => 'No app available to open the PDF.';

  @override
  String issueDocument(String document) {
    return 'Issue $document';
  }

  @override
  String get payMethod => 'Payment method';

  @override
  String get methodOnline => 'Online card payment';

  @override
  String get methodCard => 'Card (on site)';

  @override
  String get methodCash => 'Cash';

  @override
  String get methodTransfer => 'Bank transfer';

  @override
  String get methodOther => 'Other';

  @override
  String get methodVoucher => 'Voucher';

  @override
  String get refundAsk => 'Refund the amount already paid?';

  @override
  String get refundYes => 'Yes, refund';

  @override
  String get refundNo => 'No';

  @override
  String get bookingAddons => 'Add-ons';

  @override
  String get newInvoice => 'New invoice';

  @override
  String get invoiceCustomerName => 'Customer name';

  @override
  String get invoiceItemsTitle => 'Items';

  @override
  String get invoiceItemName => 'Description';

  @override
  String get invoiceItemQty => 'Qty';

  @override
  String get invoiceItemPrice => 'Gross unit price (HUF)';

  @override
  String get invoiceAddItem => 'Add item';

  @override
  String get invoiceDueDays => 'Payment due (days)';

  @override
  String get invoiceAlreadyPaid => 'Already paid';

  @override
  String invoiceTotalLine(String total) {
    return 'Total: $total';
  }

  @override
  String get invoiceNeedsItem =>
      'Enter at least one item with a name and price.';

  @override
  String get ownerRegister => 'Cash register';

  @override
  String get registerIncome => 'Income';

  @override
  String get registerCashIn => 'Cash in';

  @override
  String get registerCashOut => 'Cash out';

  @override
  String get registerOpening => 'Opening cash';

  @override
  String get registerExpected => 'Expected cash';

  @override
  String get registerOnline => 'Online payments';

  @override
  String get registerUnpaid => 'Unpaid bookings';

  @override
  String get registerNoEntries => 'No entries on this day yet.';

  @override
  String get registerNewEntry => 'New entry';

  @override
  String get registerDescription => 'Description (e.g. tip, change)';

  @override
  String get registerClose => 'Close the day';

  @override
  String get registerCounted => 'Counted cash (HUF)';

  @override
  String get registerClosed => 'The day is closed';

  @override
  String registerDifference(String amount) {
    return 'Difference: $amount';
  }

  @override
  String get registerReopen => 'Reopen';

  @override
  String registerPayWith(String method) {
    return 'Pay: $method';
  }

  @override
  String get registerDeleteTitle => 'Delete this entry?';

  @override
  String get registerToday => 'Today';

  @override
  String get ownerProducts => 'Products and stock';

  @override
  String get ownerSuppliers => 'Suppliers';

  @override
  String get ownerPurchasing => 'Purchasing';

  @override
  String get newProduct => 'New product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get productPrice => 'Selling price (HUF)';

  @override
  String get productCost => 'Cost price (HUF)';

  @override
  String get productStock => 'Stock (pcs)';

  @override
  String get productSku => 'SKU';

  @override
  String get productLowThreshold => 'Low stock threshold';

  @override
  String get productLowStock => 'Low stock';

  @override
  String get productsLowOnly => 'Low stock only';

  @override
  String get productSell => 'Sell';

  @override
  String get sellQuantity => 'Quantity';

  @override
  String get productSold => 'The sale was recorded.';

  @override
  String stockLabel(int count) {
    return 'Stock: $count';
  }

  @override
  String get deleteProductTitle => 'Delete this product?';

  @override
  String get newSupplier => 'New supplier';

  @override
  String get editSupplier => 'Edit supplier';

  @override
  String get supplierContact => 'Contact person';

  @override
  String get supplierTax => 'Tax number';

  @override
  String get deleteSupplierTitle => 'Delete this supplier?';

  @override
  String get newOrder => 'New order';

  @override
  String get orderSupplier => 'Supplier';

  @override
  String get orderLines => 'Items';

  @override
  String get orderLineDescription => 'Description';

  @override
  String get orderLineQty => 'Qty';

  @override
  String get orderLineCost => 'Unit cost (HUF)';

  @override
  String get orderAddLine => 'Add item';

  @override
  String get orderStatusDraft => 'Draft';

  @override
  String get orderStatusOrdered => 'Ordered';

  @override
  String get orderStatusReceived => 'Received';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderMarkOrdered => 'Place order';

  @override
  String get orderReceive => 'Receive';

  @override
  String get orderCancel => 'Cancel order';

  @override
  String orderExpected(String date) {
    return 'Expected: $date';
  }

  @override
  String get orderNeedsSupplier => 'Add a supplier first.';

  @override
  String get orderNeedsLine => 'Add at least one item.';

  @override
  String get orderReceivedQty => 'Received (pcs)';

  @override
  String get ownerPassTypes => 'Pass and voucher types';

  @override
  String get ownerLoyalty => 'Loyalty program';

  @override
  String get ownerCampaigns => 'Campaigns';

  @override
  String get newPassType => 'New type';

  @override
  String get passTypeKind => 'Kind';

  @override
  String get passTypeSessions => 'Number of sessions';

  @override
  String get passTypeValue => 'Face value (HUF)';

  @override
  String get passTypePrice => 'Price (HUF)';

  @override
  String get passTypeValidity => 'Valid for (days)';

  @override
  String get passTypeService => 'Service (optional)';

  @override
  String get passTypeAnyService => 'Any';

  @override
  String passTypeSoldCount(int count) {
    return '$count sold';
  }

  @override
  String get passTypeSell => 'Sell';

  @override
  String get passTypePurchaserEmail => 'Buyer email';

  @override
  String get passTypeRecipient => 'Recipient name (for gifts)';

  @override
  String get passTypeDeleteTitle => 'Delete this type?';

  @override
  String get passTypeInactive => 'Disabled';

  @override
  String get loyaltyEnabled => 'Loyalty program enabled';

  @override
  String get loyaltyPointsPer1000 => 'Points per 1000 HUF';

  @override
  String get loyaltyRewardPointsLabel => 'Points needed for a reward';

  @override
  String get loyaltyRewardValueLabel => 'Reward value (HUF)';

  @override
  String loyaltyMembers(int count) {
    return 'Members: $count';
  }

  @override
  String loyaltyOutstanding(int count) {
    return 'Outstanding points: $count';
  }

  @override
  String get loyaltyLeaderboard => 'Leaderboard';

  @override
  String get newCampaign => 'New campaign';

  @override
  String get editCampaign => 'Edit campaign';

  @override
  String get campaignName => 'Internal name';

  @override
  String get campaignSubject => 'Email subject';

  @override
  String get campaignBody => 'Email text';

  @override
  String get campaignSegmentLabel => 'Audience';

  @override
  String get segAll => 'All customers who agreed';

  @override
  String get segInactive => 'Haven\'t visited in a while';

  @override
  String get segNew => 'New customers';

  @override
  String get segService => 'Customers of a given service';

  @override
  String get segLoyalty => 'Can already redeem a reward';

  @override
  String get segDays => 'Days';

  @override
  String campaignAudience(int count) {
    return 'Would reach: $count';
  }

  @override
  String get campaignStatusDraft => 'Draft';

  @override
  String get campaignStatusSent => 'Sent';

  @override
  String get campaignSendTest => 'Send me a test';

  @override
  String campaignTestSent(String email) {
    return 'Test email sent to $email';
  }

  @override
  String get campaignSend => 'Send';

  @override
  String get campaignSendConfirm =>
      'Send the campaign to the audience? This cannot be undone.';

  @override
  String campaignSent(int count) {
    return 'Sent to $count recipients.';
  }

  @override
  String get campaignDeleteTitle => 'Delete this campaign?';

  @override
  String campaignConsents(int count, int limit) {
    return 'Customers who agreed: $count · daily limit: $limit';
  }

  @override
  String get ownerGroupSessions => 'Group sessions';

  @override
  String get ownerBreaks => 'Breaks';

  @override
  String get ownerTimesheet => 'Timesheet';

  @override
  String get newGroupSession => 'New session';

  @override
  String get groupCapacity => 'Capacity';

  @override
  String get groupRepeatWeeks => 'Repeat (weeks)';

  @override
  String get groupTime => 'Start (HH:MM)';

  @override
  String groupBooked(int booked, int capacity) {
    return '$booked/$capacity people';
  }

  @override
  String get groupAddAttendee => 'Add attendee';

  @override
  String get groupCancelTitle => 'Cancel this session?';

  @override
  String get groupCancelText => 'The attendees will be notified.';

  @override
  String get groupCancelled => 'Cancelled';

  @override
  String get groupNoAttendees => 'No attendees yet.';

  @override
  String get breaksNone => 'No breaks added.';

  @override
  String get newBreak => 'New break';

  @override
  String get breakDay => 'Day';

  @override
  String get breakFrom => 'From (HH:MM)';

  @override
  String get breakTo => 'To (HH:MM)';

  @override
  String get breakLabel => 'Label (e.g. lunch)';

  @override
  String get weekdaySun => 'Sunday';

  @override
  String get weekdayMon => 'Monday';

  @override
  String get weekdayTue => 'Tuesday';

  @override
  String get weekdayWed => 'Wednesday';

  @override
  String get weekdayThu => 'Thursday';

  @override
  String get weekdayFri => 'Friday';

  @override
  String get weekdaySat => 'Saturday';

  @override
  String timesheetWorked(String hours) {
    return 'Worked: $hours';
  }

  @override
  String timesheetPlanned(String hours) {
    return 'Planned: $hours';
  }

  @override
  String timesheetOvertime(String hours) {
    return 'Overtime: $hours';
  }

  @override
  String timesheetPay(String amount) {
    return 'Estimated pay: $amount';
  }

  @override
  String get timesheetClosed => 'The month is closed';

  @override
  String get timesheetClose => 'Close the month';

  @override
  String get timesheetReopen => 'Reopen';

  @override
  String timesheetStale(int count) {
    return '$count shifts left open';
  }

  @override
  String get timesheetNewEntry => 'Add a shift';

  @override
  String get timesheetStaff => 'Team member';

  @override
  String get timesheetIn => 'Start';

  @override
  String get timesheetOut => 'End';

  @override
  String get timesheetBreakMinutes => 'Break (min)';

  @override
  String get timesheetEntries => 'Shifts';

  @override
  String timesheetOpenSince(String time) {
    return 'Clocked in: $time';
  }

  @override
  String get ownerSettings => 'Settings';

  @override
  String get settingsBusiness => 'Business details';

  @override
  String get settingsBookingPage => 'Booking page';

  @override
  String get settingsPolicy => 'Policy';

  @override
  String get settingsPayments => 'Payments';

  @override
  String get settingsInvoicing => 'Invoicing';

  @override
  String get settingsCalendarSync => 'Calendar sync';

  @override
  String get settingsMode => 'Solo mode (one team member)';

  @override
  String get businessCity => 'City';

  @override
  String get businessDescription => 'About';

  @override
  String get bookingExtraInfo => 'Extra information on the booking page';

  @override
  String get bookingGroupEnabled => 'Group sessions on the booking page';

  @override
  String get bookingRentalsEnabled => 'Rentable resources (court, room)';

  @override
  String get bookingLogo => 'Logo';

  @override
  String get bookingCover => 'Cover image';

  @override
  String get imageUpload => 'Upload';

  @override
  String get imageRemove => 'Remove';

  @override
  String get policyCancelHours => 'Cancellation deadline (hours)';

  @override
  String get policyReschedule => 'Customers can reschedule';

  @override
  String get policyNoShowThreshold => 'No-show threshold (times)';

  @override
  String get policyNoShowDeposit => 'Deposit after the threshold (%)';

  @override
  String get paymentRefundCutoff => 'Refund cutoff (hours)';

  @override
  String get paymentOnline => 'Online payments enabled';

  @override
  String get paymentStripeNotConnected =>
      'The Stripe account is not connected yet.';

  @override
  String get paymentStripeConnect => 'Connect Stripe account';

  @override
  String get paymentStripeContinue => 'Continue setup on Stripe';

  @override
  String get paymentStripeDashboard => 'Stripe dashboard';

  @override
  String get paymentStripeSync => 'Refresh status';

  @override
  String get paymentStripeReady =>
      'The Stripe account is ready to accept payments.';

  @override
  String get paymentStripePending =>
      'The Stripe account setup is not finished yet.';

  @override
  String paymentFee(String percent) {
    return 'Platform fee: $percent%';
  }

  @override
  String get invoicingEnabled => 'Automatic invoicing';

  @override
  String get invoicingProvider => 'Provider';

  @override
  String get invoicingDocType => 'Document type';

  @override
  String get invoicingVat => 'VAT code';

  @override
  String get invoicingAutoSend => 'Send to the customer';

  @override
  String get invoicingApiKey => 'API key';

  @override
  String get invoicingAgentKey => 'Agent key (Számlázz.hu)';

  @override
  String get invoicingKeySet => 'Set (leave empty to keep)';

  @override
  String get invoicingBlock => 'Invoice block ID';

  @override
  String get invoicingReceiptBlock => 'Receipt block ID';

  @override
  String get calendarBusinessFeed => 'Business calendar';

  @override
  String get calendarCopy => 'Copy link';

  @override
  String get calendarCopied => 'The link is on the clipboard.';

  @override
  String get calendarRegenerate => 'New link';

  @override
  String get calendarRegenerateTitle => 'Generate a new link?';

  @override
  String get calendarRegenerateText =>
      'The old link stops working; add the new one to your calendars again.';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get forgotPasswordText =>
      'Enter your email and we\'ll send a link to set a new password.';

  @override
  String get forgotPasswordSent =>
      'If the address exists in the system, we sent the email.';

  @override
  String get sendLinkShort => 'Send';

  @override
  String get registerBusinessLink => 'I\'m starting a business';

  @override
  String get registerTitle => 'Sign up';

  @override
  String get registerIntro =>
      'Create your account, then set up your business in a few minutes.';

  @override
  String get passwordMin => 'The password must be at least 8 characters.';

  @override
  String get createAccount => 'Create account';

  @override
  String get setupTitle => 'Create your business';

  @override
  String get setupIntro =>
      'A few details and your booking page is ready. You can change everything later.';

  @override
  String get setupBusinessName => 'Business name';

  @override
  String get setupSolo => 'I work alone';

  @override
  String get setupServices => 'Your first services';

  @override
  String get setupStaff => 'Team members';

  @override
  String get setupAddService => 'Add service';

  @override
  String get setupAddStaff => 'Add team member';

  @override
  String get setupCreate => 'Create';

  @override
  String get setupNeedsService =>
      'Add at least one service with a name and duration.';

  @override
  String get setupCta => 'You don\'t have a business yet';

  @override
  String get setupCtaText => 'Create your first one and start taking bookings.';

  @override
  String get accountSecurityTitle => 'Account and feedback';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get changePassword => 'Change password';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackTypeBug => 'Bug';

  @override
  String get feedbackTypeFeature => 'Idea';

  @override
  String get feedbackSubject => 'Subject';

  @override
  String get feedbackMessage => 'Message';

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackThanks => 'Thanks for your feedback!';

  @override
  String get adminTitle => 'Administration';

  @override
  String get adminOverview => 'Overview';

  @override
  String get adminBusinesses => 'Businesses';

  @override
  String get adminAppointments => 'Bookings';

  @override
  String get adminFeedback => 'Feedback';

  @override
  String adminUsers(int count) {
    return 'Users: $count';
  }

  @override
  String adminBusinessCount(int count) {
    return 'Businesses: $count';
  }

  @override
  String adminAppointmentCount(int count) {
    return 'Bookings: $count';
  }

  @override
  String adminToday(int count) {
    return 'Today: $count';
  }

  @override
  String adminThisMonth(int count) {
    return 'This month: $count';
  }

  @override
  String adminActiveSubscriptions(int count) {
    return 'Active subscriptions: $count';
  }

  @override
  String adminPlans(int free, int basic, int pro) {
    return 'Plans: trial $free · basic $basic · pro $pro';
  }

  @override
  String get adminActive => 'Active';

  @override
  String get adminInactive => 'Disabled';

  @override
  String get adminAllStatuses => 'All';

  @override
  String get feedbackStatusNew => 'New';

  @override
  String get feedbackStatusInProgress => 'In progress';

  @override
  String get feedbackStatusResolved => 'Resolved';

  @override
  String get feedbackStatusRejected => 'Rejected';

  @override
  String get feedbackAnswer => 'Reply';

  @override
  String get feedbackAnswerPlaceholder => 'Reply to the user (optional)';

  @override
  String get ownerAddons => 'Add-ons';

  @override
  String get newAddon => 'New add-on';

  @override
  String get addonPrice => 'Price (HUF)';

  @override
  String get addonMinutes => 'Duration (min)';

  @override
  String get addonServices => 'For which services';

  @override
  String get addonDeleteTitle => 'Delete this add-on?';

  @override
  String get staffHoursButton => 'Working hours';

  @override
  String get staffPayButton => 'Pay and commission';

  @override
  String get staffPhotoButton => 'Upload photo';

  @override
  String get dayOff => 'Day off';

  @override
  String get payType => 'Pay type';

  @override
  String get payTypeNone => 'Not set';

  @override
  String get payTypeHourly => 'Hourly';

  @override
  String get payTypeMonthly => 'Monthly';

  @override
  String get payRate => 'Rate (HUF)';

  @override
  String get payHoursSource => 'Hours source';

  @override
  String get payHoursSchedule => 'Schedule';

  @override
  String get payHoursClock => 'Time clock';

  @override
  String get payHoursAppointments => 'Bookings';

  @override
  String get payServiceCommission => 'Service commission (%)';

  @override
  String get payProductCommission => 'Product commission (%)';

  @override
  String get serviceMaterials => 'Materials used';

  @override
  String get serviceImage => 'Upload image';

  @override
  String get materialQuantity => 'Quantity per visit';

  @override
  String get portalTimesheetTitle => 'My hours';

  @override
  String get portalProfileTitle => 'My profile';

  @override
  String get portalCalendarFeed => 'My calendar link';

  @override
  String portalPlanned(String hours) {
    return 'Planned: $hours';
  }

  @override
  String portalClocked(String hours) {
    return 'Clocked: $hours';
  }

  @override
  String get ownerPayouts => 'Payouts';

  @override
  String get ownerMissingDocuments => 'Missing documents';

  @override
  String get missingDocumentsNone => 'No missing documents.';

  @override
  String get payoutLines => 'Payout items';

  @override
  String payoutGross(String amount) {
    return 'Gross: $amount';
  }

  @override
  String payoutFee(String amount) {
    return 'Fee: $amount';
  }

  @override
  String payoutNet(String amount) {
    return 'Net: $amount';
  }

  @override
  String get exportLabel => 'Export';

  @override
  String get exportAccountingLabel => 'Download accountant package';

  @override
  String get fileNotOpened => 'No app available to open the file.';

  @override
  String get receiptUpload => 'Upload receipt';

  @override
  String get receiptOpen => 'Open receipt';

  @override
  String get ownerAddLeave => 'Time off / closed';

  @override
  String get leaveWholeBusiness => 'The whole business';

  @override
  String get leaveCancelAffected => 'Cancel the affected bookings';

  @override
  String leaveAffected(int count) {
    return 'Affects $count bookings';
  }

  @override
  String leaveCreatedAffected(int count) {
    return 'Added. Affected bookings: $count.';
  }

  @override
  String get ownerNotifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get customerInvoicesTitle => 'My invoices';

  @override
  String get invoiceOpenPdf => 'Open invoice';

  @override
  String get rentalsTitle => 'Rentals';

  @override
  String rentalPricePerHour(String price) {
    return '$price / hour';
  }

  @override
  String get waitlistRemoveTitle => 'Leave the waitlist';

  @override
  String get waitlistRemoveDone =>
      'You left the waitlist, we won\'t send more notifications.';

  @override
  String get unsubscribeTitle => 'Unsubscribe from emails';

  @override
  String get unsubscribeText => 'You can finish unsubscribing in the browser.';

  @override
  String get openInBrowser => 'Open in browser';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get homeGreetingGuest => 'Hi there!';

  @override
  String get homeQuestion => 'When are you coming next?';

  @override
  String get nextAppointmentLabel => 'Your next appointment';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System';
}
