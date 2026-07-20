import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:posture_detector_app/constants/credential.dart';
import 'package:posture_detector_app/utils/print_helper.dart';

/// Enterprise SSO via OIDC (Okta). The issuer + clientId are per-company and are
/// discovered at runtime (POST /auth/okta-config) — nothing Okta-specific is
/// hard-coded except the app's own redirect URI.
class OktaOidcService {
  static const _appAuth = FlutterAppAuth();

  /// Runs the OIDC authorization-code flow against [issuer] and returns the ID
  /// token, or null on cancel/failure. The backend validates the token.
  static Future<String?> login({
    required String issuer,
    required String clientId,
  }) async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          AppCredentials.oktaRedirectUri,
          issuer: issuer,
          scopes: const ['openid', 'profile', 'email'],
          promptValues: const ['login'],
        ),
      );
      return result?.idToken;
    } catch (e) {
      printLine('Okta login error: $e');
      return null;
    }
  }
}
