import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:posture_detector_app/constants/credential.dart';
import 'package:posture_detector_app/utils/print_helper.dart';

class Auth0Service {
  static final _auth0 = Auth0(
    AppCredentials.auth0Domain,
    AppCredentials.auth0ClientId,
  );

  static Future<Credentials?> login() async {
    try {
      return await _auth0
          .webAuthentication(scheme: AppCredentials.auth0Scheme)
          .login(scopes: {'openid', 'profile', 'email', 'offline_access'});
    } catch (e) {
      printLine('Auth0 login error: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      await _auth0
          .webAuthentication(scheme: AppCredentials.auth0Scheme)
          .logout();
    } catch (e) {
      printLine('Auth0 logout error: $e');
    }
  }
}