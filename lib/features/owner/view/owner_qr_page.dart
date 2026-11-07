import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/share/share_gateway.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/async_view.dart';
import '../../../shared/ui/app_alerts.dart';
import '../../../shared/ui/app_logo.dart';
import '../../staff/viewmodel/staff_session_viewmodel.dart';
import '../model/business_info.dart';
import '../viewmodel/owner_tools_viewmodels.dart';

/// A vállalkozás nyomtatható / megosztható QR-plakátja (View): az ügyfelek a kamerával beolvasva rögtön a foglalási oldalra jutnak.
class OwnerQrPage extends ConsumerStatefulWidget {
  const OwnerQrPage({super.key});

  @override
  ConsumerState<OwnerQrPage> createState() => _OwnerQrPageState();
}

class _OwnerQrPageState extends ConsumerState<OwnerQrPage> {
  final _posterKey = GlobalKey();

  /// A plakát lerenderelése PNG-be (3× felbontás, hogy nyomtatva is éles legyen).
  Future<Uint8List?> _capture() async {
    final boundary = _posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  Future<void> _shareImage(BusinessInfo info) async {
    final png = await _capture();
    if (png == null) return;
    await ref.read(shareGatewayProvider).shareImage(png, 'kalenda-qr-${info.slug ?? info.id}.png', text: info.bookingUrl);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final businessId = ref.watch(staffSessionProvider).value?.businessId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownerQr)),
      body: businessId == null
          ? Center(child: Text(l10n.ownerNoBusiness))
          : AsyncView<BusinessInfo>(
              value: ref.watch(businessInfoProvider(businessId)),
              onRetry: () => ref.invalidate(businessInfoProvider(businessId)),
              builder: (context, info) {
                final url = info.bookingUrl;
                if (url == null || url.isEmpty) return Center(child: Text(l10n.genericError));

                return ListView(
                  padding: const EdgeInsets.all(AppDimens.pagePadding),
                  children: [
                    Center(
                      child: RepaintBoundary(
                        key: _posterKey,
                        child: _Poster(name: info.name, url: url),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      icon: const Icon(Icons.ios_share_rounded),
                      label: Text(l10n.qrShareImage),
                      onPressed: () => _shareImage(info),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.link_rounded),
                      label: Text(l10n.qrCopyLink),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: url));
                        if (context.mounted) showToast(context, l10n.qrLinkCopied);
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}

/// A plakát: márkás fejléc, a vállalkozás neve, nagy QR-kód és a hivatkozás. Fix, világos színekkel, hogy nyomtatva is jól nézzen ki.
class _Poster extends StatelessWidget {
  const _Poster({required this.name, required this.url});

  final String name;
  final String url;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: 320,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimens.radius)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            child: Column(
              children: [
                const AppLogo(size: 40),
                const SizedBox(height: 12),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 4),
                Text(l10n.qrPosterTitle, style: const TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                QrImageView(
                  data: url,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: AppColors.navy),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: AppColors.navy),
                ),
                const SizedBox(height: 12),
                Text(l10n.qrPosterHint, style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  url,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.brand, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
