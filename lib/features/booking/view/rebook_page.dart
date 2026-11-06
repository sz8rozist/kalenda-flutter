import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../model/booking_models.dart';
import '../viewmodel/business_viewmodels.dart';

/// Az újrafoglalás célútvonala: a szolgáltatás neve alapján az űrlap (a szakember nevével), ha nincs meg, a vállalkozás oldala.
String rebookTarget(String slug, List<PublicService> services, String serviceName, String? staffName) {
  final wanted = serviceName.trim().toLowerCase();
  final service = services.where((s) => s.name.trim().toLowerCase() == wanted).firstOrNull;
  if (service == null) return '/b/$slug';
  return Uri(path: '/b/$slug/book/${service.id}', queryParameters: {'staff': ?staffName}).toString();
}

/// „Újra foglalok": a korábbi foglalás szolgáltatását név szerint megkeresi a vállalkozásnál, és megnyitja a foglalási űrlapot
/// (a szakember neve előre kiválasztáshoz megy tovább). Ha a szolgáltatás már nincs meg, a vállalkozás oldalára visz.
class RebookPage extends ConsumerWidget {
  const RebookPage({super.key, required this.slug, required this.serviceName, this.staffName});

  final String slug;
  final String serviceName;
  final String? staffName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).rebook)),
      body: AsyncView(
        value: ref.watch(businessViewModelProvider(slug)),
        onRetry: () => ref.invalidate(businessViewModelProvider(slug)),
        builder: (context, business) {
          final target = rebookTarget(slug, business.services, serviceName, staffName);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.pushReplacement(target);
          });
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
