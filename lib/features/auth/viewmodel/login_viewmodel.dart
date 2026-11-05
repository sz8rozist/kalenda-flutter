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

  /// Siker esetén a munkamenet-ViewModel frissül, és a felület magától továbblép.
  Future<void> signIn(String code) async {
    state = LoginState(busy: true, linkSent: state.linkSent);
    try {
      await ref.read(customerSessionProvider.notifier).signIn(code);
      state = const LoginState(linkSent: true);
    } catch (e) {
      state = LoginState(linkSent: state.linkSent, error: e);
    }
  }
}

final loginViewModelProvider = NotifierProvider.autoDispose<LoginViewModel, LoginState>(LoginViewModel.new);
