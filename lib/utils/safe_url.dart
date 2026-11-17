import 'package:flutter/foundation.dart';
import 'package:posture_detector_app/constants/credential.dart';

/// Decides whether a URL that came from outside the app (an API response, a
/// push notification payload) may be opened or fetched.
///
/// Such a URL is only data. If it is passed straight to `launchUrl` or
/// `http.get`, whoever can influence it can send the user to a phishing page,
/// trigger another app through a custom `scheme://` link, or make the device
/// request an arbitrary address. So only one shape is accepted: `https` on the
/// app's own API host (or a subdomain of it).
///
/// Debug builds also accept the scheme of the configured API domain, so a
/// local `http://` development server keeps working.
class SafeUrl {
  const SafeUrl._();

  /// The parsed URI if [raw] is acceptable, otherwise null.
  static Uri? trusted(Object? raw) {
    if (raw is! String || raw.trim().isEmpty) return null;

    final uri = Uri.tryParse(raw.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;

    final api = Uri.tryParse(AppCredentials.domain);
    if (api == null || api.host.isEmpty) return null;

    final schemeOk =
        uri.scheme == 'https' || (kDebugMode && uri.scheme == api.scheme);
    if (!schemeOk) return null;

    // Credentials in a URL ("https://postura.tech@evil.example/") are a
    // classic way to disguise the real host.
    if (uri.userInfo.isNotEmpty) return null;

    final host = uri.host.toLowerCase();
    final apiHost = api.host.toLowerCase();
    if (host != apiHost && !host.endsWith('.$apiHost')) return null;

    return uri;
  }
}
