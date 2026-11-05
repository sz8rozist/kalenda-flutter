import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../features/booking/model/payment_sheet.dart';

/// A Stripe SDK (PaymentSheet) elérése – szolgáltatás a ViewModel-ek alatt. A fizetés a vállalkozó Connect-fiókján
/// történik (direct charge), ezért a fiók azonosítóját is az SDK-nak kell adni. Apple Pay / Google Pay a PaymentSheetben.
class StripePaymentGateway {
  /// Megnyitja a PaymentSheetet. Kifizetve → [PaymentOutcome.paid]; ha az ügyfél bezárja → [PaymentOutcome.cancelled].
  /// Más hibánál a [StripeException] továbbmegy.
  Future<PaymentOutcome> pay(PaymentSheetData data, {required String merchantName}) async {
    Stripe.publishableKey = data.publishableKey;
    Stripe.stripeAccountId = data.stripeAccountId;
    await Stripe.instance.applySettings();

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: data.clientSecret,
        merchantDisplayName: merchantName,
        applePay: const PaymentSheetApplePay(merchantCountryCode: 'HU'),
        googlePay: PaymentSheetGooglePay(merchantCountryCode: 'HU', currencyCode: 'HUF', testEnv: kDebugMode),
      ),
    );

    try {
      await Stripe.instance.presentPaymentSheet();
      return PaymentOutcome.paid;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return PaymentOutcome.cancelled;
      rethrow;
    }
  }
}

final stripePaymentGatewayProvider = Provider<StripePaymentGateway>((ref) => StripePaymentGateway());
