import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'customer_session_viewmodel.dart';

/// Belépés a levélből megnyitott linkkel (`/fiokom/belepes/{kód}`): a képernyő megnyitásakor azonnal belép.
/// Az érték üres (`void`); betöltés közben a belépés fut, hiba esetén a View a hibát mutatja.
class LoginLinkViewModel extends AsyncNotifier<void> {
  LoginLinkViewModel(this.code);

  final String code;

  @override
  Future<void> build() => ref.read(customerSessionProvider.notifier).signIn(code);
}

final loginLinkProvider = AsyncNotifierProvider.autoDispose.family<LoginLinkViewModel, void, String>(LoginLinkViewModel.new);
