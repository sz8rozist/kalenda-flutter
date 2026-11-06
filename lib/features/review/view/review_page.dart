import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/flash.dart';
import '../model/review_models.dart';
import '../viewmodel/review_viewmodels.dart';

/// Értékelés a foglalás után (View): a levélből megnyitott `/velemeny/{token}` link; az `initialRating` az e-mailben
/// megkoppintott csillag.
class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key, required this.token, this.initialRating = 0});

  final String token;
  final int initialRating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).reviewTitle)),
      body: AsyncView<ReviewInfo>(
        value: ref.watch(reviewViewModelProvider(token)),
        onRetry: () => ref.invalidate(reviewViewModelProvider(token)),
        builder: (context, info) =>
            info.alreadySubmitted ? _Thanks(info: info) : _Form(token: token, initialRating: initialRating, info: info),
      ),
    );
  }
}

class _Thanks extends StatelessWidget {
  const _Thanks({required this.info});

  final ReviewInfo info;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_outline, size: 56),
            const SizedBox(height: 12),
            Text(l10n.reviewThanks, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            if (info.rating != null) ...[const SizedBox(height: 8), _Stars(rating: info.rating!)],
            // Jó értékelés után a vállalkozás Google-oldalára is el lehet vinni a vendéget.
            if (info.googleReviewUrl != null && (info.rating ?? 0) >= 4) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => launchUrl(Uri.parse(info.googleReviewUrl!), mode: LaunchMode.externalApplication),
                child: Text(l10n.reviewOnGoogle),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(onPressed: () => context.go('/'), child: Text(l10n.backToStart)),
          ],
        ),
      ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.token, required this.initialRating, required this.info});

  final String token;
  final int initialRating;
  final ReviewInfo info;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  final _feedback = TextEditingController();

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = reviewFormViewModelProvider((token: widget.token, initialRating: widget.initialRating));
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);
    listenError(ref, context, provider.select((s) => s.error));

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(widget.info.businessName, style: theme.textTheme.titleLarge),
        Text([widget.info.serviceName, if (widget.info.appointmentDate != null) widget.info.appointmentDate!].join(' · ')),
        const SizedBox(height: 24),
        Text(l10n.reviewQuestion, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                iconSize: 40,
                tooltip: '$i',
                icon: Icon(i <= state.rating ? Icons.star : Icons.star_border, color: Colors.amber.shade700),
                onPressed: () => viewModel.setRating(i),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _feedback,
          maxLines: 4,
          decoration: InputDecoration(labelText: l10n.reviewFeedback),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: (state.rating < 1 || state.busy) ? null : () => viewModel.submit(_feedback.text.trim()),
          child: Text(l10n.reviewSubmit),
        ),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [for (var i = 1; i <= 5; i++) Icon(i <= rating ? Icons.star : Icons.star_border, color: Colors.amber.shade700)],
  );
}
