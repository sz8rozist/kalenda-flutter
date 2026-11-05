/// A mobil PaymentSheet indításához szükséges adatok (`POST /public/bookings/{token}/payment/sheet`).
class PaymentSheetData {
  const PaymentSheetData({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.publishableKey,
    required this.stripeAccountId,
    required this.amountHuf,
  });

  final String clientSecret;
  final String paymentIntentId;
  final String publishableKey;

  /// A vállalkozó Connect-fiókja (direct charge): a Stripe SDK-nak ezt is meg kell adni.
  final String stripeAccountId;
  final int amountHuf;

  factory PaymentSheetData.fromJson(Map<String, dynamic> j) => PaymentSheetData(
        clientSecret: j['client_secret'] as String,
        paymentIntentId: j['payment_intent_id'] as String,
        publishableKey: j['publishable_key'] as String,
        stripeAccountId: j['stripe_account_id'] as String,
        amountHuf: (j['amount_huf'] as num).toInt(),
      );
}

/// A PaymentSheet kimenete: kifizetve, vagy az ügyfél megszakította.
enum PaymentOutcome { paid, cancelled }
