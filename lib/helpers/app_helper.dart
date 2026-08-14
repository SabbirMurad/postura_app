import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHelper {
  const AppHelper._internal();

  static const instance = AppHelper._internal();

  /// Cached SharedPreferences instance to avoid repeated disk reads.
  static SharedPreferences? _prefs;

  /// Encrypted store (Android Keystore / iOS Keychain) for auth secrets —
  /// access/refresh tokens and the reset secret_key. Never SharedPreferences,
  /// which is world-readable on rooted devices / in backups.
  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Synchronous copy of the access token, kept in sync with secure storage.
  /// Needed by image widgets that must build request headers synchronously
  /// (auth-gated capture images). Warmed in [init] and updated on token writes.
  static String? _accessTokenCache;

  /// Bearer auth headers for authenticated image requests, or null when signed
  /// out. Sending these to public images (avatars) is harmless — the server
  /// ignores auth there and only enforces it for capture (Post) images.
  static Map<String, String>? get authHeaders => _accessTokenCache == null
      ? null
      : {'Authorization': 'Bearer $_accessTokenCache'};

  static Future<SharedPreferences> get _pref async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Call once at app startup (e.g. in main()) to warm the caches.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _accessTokenCache = await _secure.read(key: 'access_token');
  }

  Future<String?> getRole() async {
    final pref = await _pref;
    return pref.getString('selected_role');
  }

  Future<bool> setRole(String role) async {
    final pref = await _pref;
    return pref.setString('selected_role', role);
  }

  Future<void> clearToken() async {
    final pref = await _pref;
    final savedLang = pref.getString('selected_language');
    await pref.clear();
    if (savedLang != null) {
      await pref.setString('selected_language', savedLang);
    }
    // Auth secrets live in the encrypted store, not prefs — wipe them too.
    _accessTokenCache = null;
    await _secure.deleteAll();
  }

  Future<String> getEmail() async {
    final pref = await _pref;
    return pref.getString('email') ?? '';
  }

  Future<String> getName() async {
    final pref = await _pref;
    return pref.getString('name') ?? '';
  }

  Future<bool> setUserId(String id) async {
    final pref = await _pref;
    return pref.setString('user_id', id);
  }

  Future<String?> getUserId() async {
    final pref = await _pref;
    return pref.getString('user_id');
  }

  Future<bool> setAccessToken(String token) async {
    _accessTokenCache = token;
    await _secure.write(key: 'access_token', value: token);
    return true;
  }

  Future<String?> getAccessToken() async {
    return _secure.read(key: 'access_token');
  }

  Future<bool> setRefToken(String refreshToken) async {
    await _secure.write(key: 'refresh_token', value: refreshToken);
    return true;
  }

  Future<String?> getRefToken() async {
    return _secure.read(key: 'refresh_token');
  }

  // The email carried through the password-reset flow (not sensitive; the user
  // typed it). Replaces passing the server's user_id back to the client.
  Future<bool> setResetEmail(String email) async {
    final pref = await _pref;
    return pref.setString('reset_email', email);
  }

  Future<String?> getResetEmail() async {
    final pref = await _pref;
    return pref.getString('reset_email');
  }

  Future<bool> setSecretKey(String secretKey) async {
    await _secure.write(key: 'secret_key', value: secretKey);
    return true;
  }

  Future<String?> getSecretKey() async {
    return _secure.read(key: 'secret_key');
  }

  Future<bool> setTokenValidity(int tokenValidity) async {
    final pref = await _pref;
    return pref.setInt('access_token_valid_till', tokenValidity);
  }

  Future<int?> getTokenValidity() async {
    final pref = await _pref;
    return pref.getInt('access_token_valid_till');
  }

  Future<String?> getAuthRole() async {
    final pref = await _pref;
    return pref.getString('role');
  }

  Future<bool> setAuthRole(String role) async {
    final pref = await _pref;
    return pref.setString('role', role);
  }

  Future<bool?> getIsonBoarding() async {
    final pref = await _pref;
    return pref.getBool('has_onboarded');
  }

  Future<bool> setIsonBoarding(bool isOnboarding) async {
    final pref = await _pref;
    return pref.setBool('has_onboarded', isOnboarding);
  }

  Future<bool?> getPhoneOnboard() async {
    final pref = await _pref;
    return pref.getBool('phone_onboard');
  }

  Future<bool> setPhoneOnboard(bool phoneOnboard) async {
    final pref = await _pref;
    return pref.setBool('phone_onboard', phoneOnboard);
  }

  Future<bool> setCookie(String cookie) async {
    final pref = await _pref;
    return pref.setString('cookie', cookie);
  }

  Future<String?> getCookie() async {
    final pref = await _pref;
    return pref.getString('cookie');
  }

  Future<bool> clearAllPrefValue() async {
    final pref = await _pref;
    try {
      final savedLang = pref.getString('selected_language');
      await pref.clear();
      if (savedLang != null) {
        await pref.setString('selected_language', savedLang);
      }
      await pref.reload();
      _accessTokenCache = null;
      await _secure.deleteAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Language ──

  Future<bool> setLanguage(String languageCode) async {
    final pref = await _pref;
    return pref.setString('selected_language', languageCode);
  }

  Future<String?> getLanguage() async {
    final pref = await _pref;
    return pref.getString('selected_language');
  }

  Future<bool> setFcmToken(String token) async {
    final pref = await _pref;
    return pref.setString('fcm_token', token);
  }

  Future<bool> removeFcmToken() async {
    final pref = await _pref;
    return pref.remove('fcm_token');
  }

  Future<String?> getFcmToken() async {
    final pref = await _pref;
    return pref.getString('fcm_token');
  }
}
