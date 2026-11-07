import '../../../l10n/app_localizations.dart';

/// Gyors üzenet-sablonok a vállalkozónak az ügyfél felé (SMS / e-mail).
enum MessageTemplate { reminder, runningLate, reschedule, thanks }

/// A sablon szövege az ügyfél, a szolgáltatás, az időpont és a vállalkozás nevével kitöltve.
String buildMessage(
  AppLocalizations l10n,
  MessageTemplate template, {
  required String name,
  required String service,
  required String when,
  required String business,
}) {
  return switch (template) {
    MessageTemplate.reminder => l10n.msgReminder(name, service, when, business),
    MessageTemplate.runningLate => l10n.msgRunningLate(name, business),
    MessageTemplate.reschedule => l10n.msgReschedule(name, service, when, business),
    MessageTemplate.thanks => l10n.msgThanks(name, business),
  };
}

/// Az üzenet elküldésére szolgáló hivatkozások (a készülék SMS- / levelezőalkalmazását nyitják meg).
class MessageLinks {
  MessageLinks._();

  /// SMS a megadott számra előre kitöltött szöveggel. A szóközt `%20`-ként kódoljuk (a `+` nem minden SMS-alkalmazásban értelmezett).
  static Uri sms(String phone, String body) => Uri.parse('sms:${phone.replaceAll(RegExp(r'\s'), '')}?body=${Uri.encodeComponent(body)}');

  /// E-mail előre kitöltött tárggyal és szöveggel.
  static Uri mail(String email, String subject, String body) =>
      Uri.parse('mailto:${email.trim()}?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
}
