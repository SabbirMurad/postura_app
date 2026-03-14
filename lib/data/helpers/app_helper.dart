import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AppHelper {
  const AppHelper._internal();

  static const instance = AppHelper._internal();

  /// Cached SharedPreferences instance to avoid repeated disk reads.
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _pref async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Call once at app startup (e.g. in main()) to warm the cache.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
  }

  Future<String> getEmail() async {
    final pref = await _pref;
    return pref.getString('email') ?? '';
  }

  Future<String> getName() async {
    final pref = await _pref;
    return pref.getString('name') ?? '';
  }

  Future<bool> setUserId(int id) async {
    final pref = await _pref;
    return pref.setInt('user_id', id);
  }

  Future<int?> getUserId() async {
    final pref = await _pref;
    return pref.getInt('user_id');
  }

  Future<bool> setAccessToken(String token) async {
    final pref = await _pref;
    return pref.setString('access_token', token);
  }

  Future<String?> getAccessToken() async {
    final pref = await _pref;
    return pref.getString('access_token');
  }

  Future<bool> setRefToken(String refreshToken) async {
    final pref = await _pref;
    return pref.setString('refresh_token', refreshToken);
  }

  Future<String?> getRefToken() async {
    final pref = await _pref;
    return pref.getString('refresh_token');
  }

  Future<bool> setSecretKey(String secretKey) async {
    final pref = await _pref;
    return pref.setString('secret_key', secretKey);
  }

  Future<String?> getSecretKey() async {
    final pref = await _pref;
    return pref.getString('secret_key');
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
}
