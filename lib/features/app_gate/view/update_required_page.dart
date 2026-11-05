import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../model/app_config.dart';

/// Kötelező frissítés képernyő (View): az elavult app nem használható tovább.
class UpdateRequiredPage extends StatelessWidget {
  const UpdateRequiredPage({super.key, required this.requirement});

  final UpdateRequired requirement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final storeUrl = requirement.storeUrl;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update, size: 64),
                const SizedBox(height: 16),
                Text(l10n.updateRequiredTitle, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(l10n.updateRequiredText(requirement.minVersion), textAlign: TextAlign.center),
                if (storeUrl != null) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => launchUrl(Uri.parse(storeUrl), mode: LaunchMode.externalApplication),
                    child: Text(l10n.updateNow),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
