class AppCredentials {
  // Android emulator → 10.0.2.2 maps to the host machine's loopback.
  // For a physical device on the LAN instead, use the host IP 10.10.29.65:8080.
  static const String domain = 'http://10.10.29.65:8080';
  // static const String domain = 'http://10.10.29.65:8080'; // physical device (LAN)
  static const String wsDomain = 'ws://10.0.2.2:8080';
  // static const String wsDomain = 'ws://10.10.29.65:8080'; // physical device (LAN)

  static const String auth0Domain = 'dev-szo7suomco3ger7p.us.auth0.com';
  static const String auth0ClientId = 'm52Ov0zfXqgrXvCM8Ljz3HBXoTL7EawV';
  static const String auth0Scheme = 'com.sabbir.postura';
}
