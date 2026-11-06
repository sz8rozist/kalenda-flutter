import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/ui/empty_state.dart';
import '../data/booking_repository.dart';

/// A levélben kapott „leiratkozás a várólistáról" link (View): megnyitáskor leiratkoztat.
final waitlistRemovalProvider = FutureProvider.autoDispose.family<void, String>(
  (ref, token) => ref.read(bookingRepositoryProvider).removeFromWaitlist(token),
);

class WaitlistRemovalPage extends ConsumerWidget {
  const WaitlistRemovalPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.waitlistRemoveTitle)),
      body: AsyncView<void>(
        value: ref.watch(waitlistRemovalProvider(token)),
        onRetry: () => ref.invalidate(waitlistRemovalProvider(token)),
        builder: (context, _) => EmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: l10n.waitlistRemoveDone,
          actionLabel: l10n.backToBookings,
          onAction: () => context.go('/'),
        ),
      ),
    );
  }
}

/// A levélben kapott „leiratkozás a hírlevélről" link: a szerver saját oldalán fejeződik be, ezért a böngészőt nyitjuk meg.
class MarketingUnsubscribePage extends StatelessWidget {
  const MarketingUnsubscribePage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.unsubscribeTitle)),
      body: EmptyState(
        icon: Icons.mark_email_read_outlined,
        title: l10n.unsubscribeText,
        actionLabel: l10n.openInBrowser,
        onAction: () => launchUrl(Uri.parse('${AppConfig.webBaseUrl}/leiratkozas/$token'), mode: LaunchMode.externalApplication),
      ),
    );
  }
}
