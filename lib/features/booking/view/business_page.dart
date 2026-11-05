import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/format.dart';
import '../model/booking_models.dart';
import '../viewmodel/business_viewmodels.dart';
import '../viewmodel/group_session_viewmodels.dart';

/// A vállalkozás nyilvános oldala: adatok és szolgáltatások, innen indul a foglalás (View).
class BusinessPage extends ConsumerWidget {
  const BusinessPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessViewModelProvider(slug));

    return Scaffold(
      appBar: AppBar(title: Text(business.value?.name ?? '')),
      body: AsyncView<PublicBusiness>(
        value: business,
        onRetry: () => ref.invalidate(businessViewModelProvider(slug)),
        builder: (context, data) => _Content(business: data),
      ),
    );
  }
}

/// A meghirdetett csoportos alkalmak (ha a vállalkozás használ ilyet); koppintásra jelentkezés.
class _GroupSessionsSection extends ConsumerWidget {
  const _GroupSessionsSection({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessions = ref.watch(groupSessionsViewModelProvider(slug)).value ?? const <GroupSession>[];
    if (sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(l10n.groupSessions, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final s in sessions)
          Card(
            child: ListTile(
              title: Text(s.serviceName),
              subtitle: Text([
                formatDateTime(context, s.startsAt),
                s.full ? l10n.sessionFull : l10n.placesLeft(s.placesLeft),
                if (s.priceHuf != null) formatHuf(context, s.priceHuf!),
              ].join(' · ')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/b/$slug/group/${s.id}'),
            ),
          ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.business});

  final PublicBusiness business;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (business.coverUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(business.coverUrl!, height: 160, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink()),
          ),
        const SizedBox(height: 12),
        Text(business.name, style: theme.textTheme.headlineSmall),
        if (business.description != null) ...[
          const SizedBox(height: 8),
          Text(business.description!),
        ],
        if (business.fullAddress.isNotEmpty)
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.place_outlined), title: Text(business.fullAddress)),
        if (business.phone != null && business.phone!.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.phone_outlined),
            title: Text(business.phone!),
            onTap: () => launchUrl(Uri(scheme: 'tel', path: business.phone)),
          ),
        const SizedBox(height: 8),
        Text(l10n.services, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final service in business.services)
          Card(
            child: ListTile(
              title: Text(service.name),
              subtitle: Text([
                l10n.minutes(service.durationMinutes),
                if (service.priceHuf != null) formatHuf(context, service.priceHuf!),
              ].join(' · ')),
              trailing: FilledButton.tonal(
                onPressed: () => context.push('/b/${business.slug}/book/${service.id}'),
                child: Text(l10n.book),
              ),
            ),
          ),
        _GroupSessionsSection(slug: business.slug),
        if (business.hasPasses && business.passTypes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.passesAndVouchers, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final type in business.passTypes)
            Card(
              child: ListTile(
                leading: Icon(type.isVoucher ? Icons.card_giftcard : Icons.confirmation_number_outlined),
                title: Text(type.name),
                subtitle: Text(formatHuf(context, type.priceHuf)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/b/${business.slug}/pass/${type.id}'),
              ),
            ),
        ],
        if (business.extraInfo != null && business.extraInfo!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(business.extraInfo!, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}
