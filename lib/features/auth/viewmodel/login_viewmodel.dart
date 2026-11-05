import 'package:flutter_riverpod/flutter_riverpod.dart';

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
