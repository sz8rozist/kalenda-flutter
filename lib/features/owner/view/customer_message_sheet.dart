import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/format.dart';
import '../model/message_templates.dart';

/// Üzenet az ügyfélnek (alulról felcsúszó lap): sablon-választó, szerkeszthető szöveg, küldés SMS-ben vagy e-mailben
/// a készülék saját alkalmazásával. Nincs szerveroldali küldés, a vállalkozó a saját nevében üzen.
Future<void> showCustomerMessageSheet(
  BuildContext context, {
  required String customerName,
  required String serviceName,
  required DateTime startsAt,
  required String businessName,
  String? phone,
  String? email,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _MessageSheet(
      customerName: customerName,
      serviceName: serviceName,
      startsAt: startsAt,
      businessName: businessName,
      phone: phone,
      email: email,
    ),
  );
}

class _MessageSheet extends StatefulWidget {
  const _MessageSheet({
    required this.customerName,
    required this.serviceName,
    required this.startsAt,
    required this.businessName,
    this.phone,
    this.email,
  });

  final String customerName;
  final String serviceName;
  final DateTime startsAt;
  final String businessName;
  final String? phone;
  final String? email;

  @override
  State<_MessageSheet> createState() => _MessageSheetState();
}

class _MessageSheetState extends State<_MessageSheet> {
  MessageTemplate _template = MessageTemplate.reminder;
  final _text = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _apply(AppLocalizations l10n, MessageTemplate template) {
    _template = template;
    _text.text = buildMessage(
      l10n,
      template,
      name: widget.customerName.split(' ').first,
      service: widget.serviceName,
      when: formatDateTime(context, widget.startsAt),
      business: widget.businessName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!_filled) {
      _filled = true;
      _apply(l10n, _template);
    }
    final hasPhone = widget.phone != null && widget.phone!.trim().isNotEmpty;
    final hasEmail = widget.email != null && widget.email!.trim().isNotEmpty;
    final labels = {
      MessageTemplate.reminder: l10n.msgTemplateReminder,
      MessageTemplate.runningLate: l10n.msgTemplateLate,
      MessageTemplate.reschedule: l10n.msgTemplateReschedule,
      MessageTemplate.thanks: l10n.msgTemplateThanks,
    };

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.messageCustomer, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in labels.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _template == entry.key,
                    onSelected: (_) => setState(() => _apply(l10n, entry.key)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _text, maxLines: 5, decoration: const InputDecoration()),
            const SizedBox(height: 12),
            Row(
              spacing: 12,
              children: [
                if (hasPhone)
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.sms_outlined),
                      label: Text(l10n.msgSendSms),
                      onPressed: () => launchUrl(MessageLinks.sms(widget.phone!, _text.text)),
                    ),
                  ),
                if (hasEmail)
                  Expanded(
                    child: (hasPhone ? OutlinedButton.icon : FilledButton.icon)(
                      icon: const Icon(Icons.mail_outline),
                      label: Text(l10n.msgSendEmail),
                      onPressed: () => launchUrl(MessageLinks.mail(widget.email!, l10n.msgEmailSubject(widget.businessName), _text.text)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
