import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config.dart';

/// A szolgáltató által adott azonosító (id-token) – a szerver ellenőrzi és cseréli ügyfél-tokenre.
class SocialCredential {
  const SocialCredential({required this.idToken, this.name});

  final String idToken;

  /// Az Apple a nevet csak az első belépéskor adja (és nem az id-tokenben).
  final String? name;
}

/// A Google- és Apple-belépés SDK-i – szolgáltatás a ViewModel-ek alatt. Ha az ügyfél megszakítja a belépést, az
/// eredmény `null` (nem hiba).
class SocialSignInGateway {
  bool _googleInitialized = false;

  /// Az Apple belépés csak Apple-eszközön érhető el (Androidon webes átirányítás kellene).
  bool get appleSupported => Platform.isIOS || Platform.isMacOS;

  Future<SocialCredential?> google() async {
    if (!_googleInitialized) {
      // A serverClientId a "web" típusú OAuth-kliens azonosítója: az id-token `aud` mezője ez lesz (a szerver ezt várja).
      await GoogleSignIn.instance.initialize(
        serverClientId: AppConfig.googleServerClientId.isEmpty ? null : AppConfig.googleServerClientId,
      );
      _googleInitialized = true;
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      return idToken == null ? null : SocialCredential(idToken: idToken, name: account.displayName);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<SocialCredential?> apple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final idToken = credential.identityToken;
      if (idToken == null) return null;

      final name = [credential.givenName, credential.familyName].whereType<String>().where((s) => s.isNotEmpty).join(' ');
      return SocialCredential(idToken: idToken, name: name.isEmpty ? null : name);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }
}

final socialSignInGatewayProvider = Provider<SocialSignInGateway>((ref) => SocialSignInGateway());
