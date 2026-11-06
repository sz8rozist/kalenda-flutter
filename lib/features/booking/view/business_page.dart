import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/format.dart';
import '../../../shared/ui/app_image.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/haptics.dart';
import '../../favorites/model/saved_business.dart';
import '../../favorites/viewmodel/saved_businesses_viewmodel.dart';
import '../model/booking_models.dart';
import '../viewmodel/business_viewmodels.dart';
import '../viewmodel/group_session_viewmodels.dart';

/// A vállalkozás nyilvános oldala (View): borítóképes fejléc, elérhetőségek, szolgáltatások, csoportos alkalmak, bérletek.
class BusinessPage extends ConsumerWidget {
  const BusinessPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(businessViewModelProvider(slug));

    return Scaffold(
      body: AsyncView<PublicBusiness>(
        value: business,
        onRetry: () => ref.invalidate(businessViewModelProvider(slug)),
        builder: (context, data) => _Content(business: data),
      ),
      // Betöltés / hiba alatt is legyen vissza-nyíl.
      appBar: business.hasValue ? null : AppBar(),
    );
  }
}

class _Content extends ConsumerStatefulWidget {
  const _Content({required this.business});

  final PublicBusiness business;

  @override
  ConsumerState<_Content> createState() => _ContentState();
}

class _ContentState extends ConsumerState<_Content> {
  PublicBusiness get business => widget.business;

  SavedBusiness get _saved => SavedBusiness(slug: business.slug, name: business.name, logoUrl: business.logoUrl);

  @override
  void initState() {
    super.initState();
    // A megnyitott vállalkozás bekerül a „legutóbbiak" közé.
    Future.microtask(() {
      if (mounted) ref.read(savedBusinessesProvider.notifier).recordVisit(_saved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          backgroundColor: AppColors.brandDark,
          foregroundColor: Colors.white,
          title: Text(business.name),
          actions: [_FavoriteButton(business: _saved)],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(url: business.coverUrl, fallback: const _CoverFallback()),
                // Sötétítés, hogy a cím és a vissza-nyíl mindig olvasható legyen.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x66000000), Color(0x00000000), Color(0x99000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: AppDimens.pagePadding,
                  right: AppDimens.pagePadding,
                  bottom: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Hero(
                        tag: 'business-logo-${business.slug}',
                        child: _LogoAvatar(url: business.logoUrl),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          business.name,
                          style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          sliver: SliverList.list(
            children: [
              if (business.description != null && business.description!.isNotEmpty) ...[
                Text(business.description!, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
              ],
              _ContactCard(business: business),
              const SizedBox(height: 24),
              Text(l10n.services, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              if (business.services.isEmpty) EmptyNote(l10n.nothingYet, icon: Icons.content_cut_rounded),
              for (final service in business.services) _ServiceCard(service: service, slug: business.slug),
              _GroupSessionsSection(slug: business.slug),
              _RentalsSection(slug: business.slug),
              if (business.hasPasses && business.passTypes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l10n.passesAndVouchers, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final type in business.passTypes)
                  Card(
                    child: ListTile(
                      leading: _IconTile(type.isVoucher ? Icons.card_giftcard_rounded : Icons.confirmation_number_outlined),
                      title: Text(type.name),
                      subtitle: Text(formatHuf(context, type.priceHuf)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/b/${business.slug}/pass/${type.id}'),
                    ),
                  ),
              ],
              if (business.extraInfo != null && business.extraInfo!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(business.extraInfo!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) => const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.heroGradient));
}

class _LogoAvatar extends StatelessWidget {
  const _LogoAvatar({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: AppImage(
        url: url,
        fallback: const Icon(Icons.storefront_rounded, color: AppColors.brand),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.business});

  final PublicBusiness business;

  @override
  Widget build(BuildContext context) {
    final hasAddress = business.fullAddress.isNotEmpty;
    final hasPhone = business.phone != null && business.phone!.isNotEmpty;
    if (!hasAddress && !hasPhone) return const SizedBox.shrink();

    return Card(
      child: Column(
        children: [
          if (hasAddress)
            ListTile(
              leading: const _IconTile(Icons.place_outlined),
              title: Text(business.fullAddress),
              onTap: () => launchUrl(
                Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': business.fullAddress}),
                mode: LaunchMode.externalApplication,
              ),
            ),
          if (hasAddress && hasPhone) const Divider(indent: 16, endIndent: 16),
          if (hasPhone)
            ListTile(
              leading: const _IconTile(Icons.phone_outlined),
              title: Text(business.phone!),
              onTap: () => launchUrl(Uri(scheme: 'tel', path: business.phone)),
            ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.slug});

  final PublicService service;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => context.push('/b/$slug/book/${service.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (service.imageUrl != null && service.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: AppImage(url: service.imageUrl, fallback: const SizedBox.shrink()),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name, style: theme.textTheme.titleMedium),
                    if (service.description != null && service.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        service.description!,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 15, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(l10n.minutes(service.durationMinutes), style: theme.textTheme.bodySmall),
                        if (service.priceHuf != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            formatHuf(context, service.priceHuf!),
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: () => context.push('/b/$slug/book/${service.id}'),
                style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
                child: Text(l10n.book),
              ),
            ],
          ),
        ),
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
        const SizedBox(height: 12),
        Text(l10n.groupSessions, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final s in sessions)
          Card(
            child: ListTile(
              leading: const _IconTile(Icons.groups_rounded),
              title: Text(s.serviceName),
              subtitle: Text(
                [
                  formatDateTime(context, s.startsAt),
                  s.full ? l10n.sessionFull : l10n.placesLeft(s.placesLeft),
                  if (s.priceHuf != null) formatHuf(context, s.priceHuf!),
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/b/$slug/group/${s.id}'),
            ),
          ),
      ],
    );
  }
}

/// Kedvenc-jelölő szív a fejlécben.
class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.business});

  final SavedBusiness business;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final favorite = ref.watch(savedBusinessesProvider).value?.isFavorite(business.slug) ?? false;

    return IconButton(
      tooltip: favorite ? l10n.removeFavorite : l10n.addFavorite,
      icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
      onPressed: () {
        Haptics.light();
        ref.read(savedBusinessesProvider.notifier).toggleFavorite(business);
      },
    );
  }
}

/// A bérelhető erőforrások (pálya, terem), ha a vállalkozás használ ilyet; koppintásra az időtartam és időpont választó nyílik.
class _RentalsSection extends ConsumerWidget {
  const _RentalsSection({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rentals = ref.watch(rentalsProvider(slug)).value ?? const <PublicRental>[];
    if (rentals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(l10n.rentalsTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final r in rentals)
          Card(
            child: ListTile(
              leading: const _IconTile(Icons.sports_tennis_rounded),
              title: Text(r.name),
              subtitle: Text(
                [
                  if (r.pricePerHourHuf != null) l10n.rentalPricePerHour(formatHuf(context, r.pricePerHourHuf!)),
                  r.resources.map((e) => e.name).join(', '),
                ].where((s) => s.isNotEmpty).join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/b/$slug/book/${r.id}?rental=1'),
            ),
          ),
      ],
    );
  }
}
