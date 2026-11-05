import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/social_sign_in_gateway.dart';
import '../data/customer_auth_repository.dart';
import 'customer_session_viewmodel.dart';

/// A belépő képernyő állapota: 1) e-mail → link kérése, 2) a levélben kapott kód beírása.
class LoginState {
  const LoginState({this.busy = false, this.linkSent = false, this.error});

  final bool busy;
  final bool linkSent;
  final Object? error;
}

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<void> requestLink(String email) async {
    state = LoginState(busy: true, linkSent: state.linkSent);
    try {
      await ref.read(customerAuthRepositoryProvider).requestLoginLink(email.trim());
      state = const LoginState(linkSent: true);
    } catch (e) {
      state = LoginState(linkSent: state.linkSent, error: e);
    }
  }

  /// Belépés Google-fiókkal. A megszakított belépés nem hiba.
  Future<void> signInWithGoogle() => _social((gateway) => gateway.google(), (session, c) => session.signInWithGoogle(c));

  /// Belépés Apple-fiókkal (Sign in with Apple). A megszakított belépés nem hiba.
  Future<void> signInWithApple() => _social((gateway) => gateway.apple(), (session, c) => session.signInWithApple(c));

  Future<void> _social(
    Future<SocialCredential?> Function(SocialSignInGateway gateway) obtain,
    Future<void> Function(CustomerSessionViewModel session, SocialCredential credential) exchange,
  ) async {
    state = LoginState(busy: true, linkSent: state.linkSent);
    try {
      final credential = await obtain(ref.read(socialSignInGatewayProvider));
      if (credential != null) await exchange(ref.read(customerSessionProvider.notifier), credential);
      state = LoginState(linkSent: state.linkSent);
    } catch (e) {
      state = LoginState(linkSent: state.linkSent, error: e);
    }
  }

  /// A beírt kód vagy a levélből beillesztett teljes link (`…/fiokom/belepes/{kód}`) → a belépő kód.
  static String extractCode(String input) {
    final text = input.trim();
    final uri = Uri.tryParse(text);
    if (uri != null && uri.hasScheme && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.where((s) => s.isNotEmpty).last;
    }
    return text;
  }

  /// Siker esetén a munkamenet-ViewModel frissül, és a felület magától továbblép.
  Future<void> signIn(String codeOrLink) async {
    state = LoginState(busy: true, linkSent: state.linkSent);
    try {
      await ref.read(customerSessionProvider.notifier).signIn(extractCode(codeOrLink));
      state = const LoginState(linkSent: true);
    } catch (e) {
      state = LoginState(linkSent: state.linkSent, error: e);
    }
  }
}

final loginViewModelProvider = NotifierProvider.autoDispose<LoginViewModel, LoginState>(LoginViewModel.new);
