import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/app_logo.dart';
import '../viewmodel/business_viewmodels.dart';

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

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hero: gradiens fejléc a márkajellel és az üdvözléssel.
          Container(
            padding: EdgeInsets.fromLTRB(AppDimens.pagePadding, MediaQuery.paddingOf(context).top + 28, AppDimens.pagePadding, 56),
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(size: 52),
                const SizedBox(height: 24),
                Text(
                  l10n.welcomeTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, height: 1.15),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.welcomeText,
                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          // A kereső kártya félig belelóg a fejlécbe.
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
              child: Card(
                elevation: 6,
                shadowColor: AppColors.navy.withValues(alpha: 0.25),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.findBusinessTitle, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        l10n.findBusinessIntro,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.go,
                        onSubmitted: (_) => _open(),
                        decoration: InputDecoration(
                          labelText: l10n.businessSlug,
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _open, child: Text(l10n.open)),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: Text(l10n.scanQr),
                        onPressed: () => context.push('/scan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
