class AppCredentials {
  // Android emulator → 10.0.2.2 maps to the host machine's loopback.
  // For a physical device on the LAN instead, use the host IP 10.10.29.65:8080.
  static const String domain = 'http://52.59.246.89';
  // static const String domain = 'http://10.10.29.65:8080';
  // static const String domain = 'http://10.10.29.65:8080'; // physical device (LAN)
  // static const String wsDomain = 'ws://10.0.2.2:8080';
  // static const String wsDomain = 'ws://10.10.29.65:8080'; // physical device (LAN)

  // Enterprise SSO (Okta OIDC). The issuer + client id are per-company and fetched
  // at runtime; only the app's own redirect URI is fixed here. The scheme must
  // match the appAuthRedirectScheme manifest placeholder (Android) / URL scheme
  // (iOS), and the full URI must be registered as a redirect in the Okta app.
  static const String oktaRedirectScheme = 'com.sabbir.postura';
  static const String oktaRedirectUri = 'com.sabbir.postura://callback';
}
