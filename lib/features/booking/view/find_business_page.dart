import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/app_image.dart';
import '../../../shared/ui/app_logo.dart';
import '../../favorites/model/saved_business.dart';
import '../../favorites/viewmodel/saved_businesses_viewmodel.dart';
import '../viewmodel/business_viewmodels.dart';
import '../../settings/view/language_tile.dart';
import '../../account/model/account_models.dart';
import '../../account/viewmodel/account_viewmodel.dart';
import '../../auth/viewmodel/customer_session_viewmodel.dart';
import '../../home/viewmodel/home_viewmodel.dart';
import '../../../shared/format.dart';

/// Kezdőoldal (View): üdvözlő fejléc a márka-gradienssel, alatta a vállalkozás megnyitása azonosítóval / linkkel / QR-kóddal.
class FindBusinessPage extends ConsumerStatefulWidget {
  const FindBusinessPage({super.key});

  @override
  ConsumerState<FindBusinessPage> createState() => _FindBusinessPageState();
}

class _FindBusinessPageState extends ConsumerState<FindBusinessPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    final slug = ref.read(findBusinessViewModelProvider.notifier).resolveSlug(_controller.text);
    if (slug != null) context.push('/b/$slug');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final saved = ref.watch(savedBusinessesProvider).value ?? const SavedBusinesses();
    final signedIn = ref.watch(customerSessionProvider).value ?? false;
    final overview = signedIn ? ref.watch(accountViewModelProvider).value : null;
    final name = overview?.profile.name.split(' ').first;
    final next = overview?.upcoming.firstOrNull;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hero: gradiens fejléc üdvözléssel, a keresőmező közvetlenül benne.
          Container(
            padding: EdgeInsets.fromLTRB(AppDimens.pagePadding, MediaQuery.paddingOf(context).top + 20, AppDimens.pagePadding, 28),
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppDimens.radiusLarge + 6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppLogo(size: 36),
                    const SizedBox(width: 10),
                    Text('Kalenda', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                    const Spacer(),
                    IconButton(
                      tooltip: l10n.languageTitle,
                      color: Colors.white,
                      icon: const Icon(Icons.language_rounded),
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (_) => const SafeArea(child: Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 16), child: LanguageTile())),
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: l10n.scanQr,
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18), foregroundColor: Colors.white),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      onPressed: () => context.push('/scan'),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  name == null ? l10n.homeGreetingGuest : l10n.homeGreeting(name),
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(l10n.homeQuestion, style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, height: 1.15)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(left: 4, right: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimens.radiusLarge)),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (_) => _open(),
                          style: const TextStyle(color: Color(0xFF111827)),
                          decoration: InputDecoration(
                            hintText: l10n.businessSlug,
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton.filled(tooltip: l10n.open, icon: const Icon(Icons.arrow_forward_rounded), onPressed: _open),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (next != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 20, AppDimens.pagePadding, 0),
              child: _NextAppointmentCard(appointment: next),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 20, AppDimens.pagePadding, 8),
            child: Row(
              spacing: 12,
              children: [
                _QuickTile(
                  icon: Icons.qr_code_scanner_rounded,
                  label: l10n.scanQr,
                  background: AppColors.blueSoft,
                  foreground: AppColors.brand,
                  onTap: () => context.push('/scan'),
                ),
                _QuickTile(
                  icon: Icons.event_note_rounded,
                  label: signedIn ? l10n.myAppointments : l10n.signIn,
                  background: AppColors.indigoSoft,
                  foreground: AppColors.indigo,
                  onTap: () => ref.read(homeTabProvider.notifier).select(1),
                ),
                _QuickTile(
                  icon: signedIn ? Icons.person_rounded : Icons.login_rounded,
                  label: signedIn ? l10n.accountTitle : l10n.signIn,
                  background: AppColors.greenSoft,
                  foreground: AppColors.success,
                  onTap: () => ref.read(homeTabProvider.notifier).select(signedIn ? 2 : 1),
                ),
              ],
            ),
          ),
          _SavedSection(title: l10n.favorites, items: saved.favorites, icon: Icons.favorite_rounded),
          _SavedSection(title: l10n.recentBusinesses, items: saved.recentWithoutFavorites, icon: Icons.history_rounded),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// A következő közelgő foglalás kiemelve a kezdőlapon (gradiens kártya); koppintásra megnyílik.
class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({required this.appointment});

  final AccountAppointment appointment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final token = appointment.manageToken;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.indigo, AppColors.brand]),
          borderRadius: BorderRadius.circular(AppDimens.radius),
          boxShadow: const [BoxShadow(color: Color(0x334F46E5), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radius),
          onTap: token == null ? null : () => context.push('/manage/$token'),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.nextAppointmentLabel, style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text(
                        appointment.service,
                        style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatDateTime(context, appointment.startsAt)} · ${appointment.business}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pasztell gyors-csempe ikonnal és felirattal.
class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.icon, required this.label, required this.background, required this.foreground, required this.onTap});

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: dark ? foreground.withValues(alpha: 0.16) : background,
        borderRadius: BorderRadius.circular(AppDimens.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: foreground, size: 26),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: dark ? Colors.white : foreground, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kedvenc / legutóbbi vállalkozások: vízszintesen görgethető kártyák logóval.
class _SavedSection extends StatelessWidget {
  const _SavedSection({required this.title, required this.items, required this.icon});

  final String title;
  final List<SavedBusiness> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
            child: Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final b = items[i];
                return SizedBox(
                  width: 112,
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () => context.push('/b/${b.slug}'),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'business-logo-${b.slug}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: AppImage(
                                    url: b.logoUrl,
                                    fallback: ColoredBox(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                      child: Icon(Icons.storefront_rounded, color: theme.colorScheme.primary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              b.name,
                              style: theme.textTheme.labelMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
