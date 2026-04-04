import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:posture_detector_app/constants/app_credential.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/services/network/connectivity_helper.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:posture_detector_app/utils/print_helper.dart';

class CustomHttpResult {
  final dynamic data;
  final int status_code;
  final String? error;
  final bool ok;

  const CustomHttpResult({
    required this.ok,
    this.data,
    required this.status_code,
    this.error,
  });

  void operator [](String other) {}
}

enum CommonCustomMethods { POST, PUT, PATCH, DELETE }

class CustomHttp {
  /// Default timeouts
  static const _requestTimeout = Duration(seconds: 30);
  static const _refreshTimeout = Duration(seconds: 10);
  static const _multipartTimeout = Duration(seconds: 120);

  /// Token refresh deduplication — only one refresh at a time
  static Future<bool>? _refreshFuture;

  // ─── GET ────────────────────────────────────────────────────────────
  static Future<CustomHttpResult> get({
    required String endpoint,
    bool showFloatingError = true,
    bool needAuth = true,
    Map<String, String>? headers,
    Map<String, dynamic>? queries,
  }) async {
    if (!await has_internet(show_error: true)) {
      return const CustomHttpResult(
        ok: false,
        status_code: -1,
        error: 'No internet connection found!',
      );
    }

    try {
      final headers0 = await _buildHeaders(needAuth: needAuth, extra: headers);
      if (headers0 == null) {
        return const CustomHttpResult(
          ok: false,
          status_code: 401,
          error: 'Session expired, Please sign in again!',
        );
      }

      var url = '${AppCredentials.domain}/api/$endpoint';
      if (queries != null) {
        final queryParts = <String>[];
        queries.forEach((key, value) {
          if (value is List) {
            for (var item in value) {
              queryParts.add('$key=$item');
            }
          } else {
            queryParts.add('$key=$value');
          }
        });
        url += '?${queryParts.join('&')}';
      }

      final uri = Uri.parse(url);
      debugPrint('<===== GET =====> $url');

      final response = await http
          .get(uri, headers: headers0)
          .timeout(_requestTimeout);

      return _handle_response(response, showFloatingError);
    } on TimeoutException {
      return const CustomHttpResult(
        ok: false,
        status_code: -3,
        error: 'Request timed out. Please try again.',
      );
    } catch (e) {
      debugPrint('GET ERROR [$endpoint]: $e');
      return CustomHttpResult(ok: false, status_code: -2, error: e.toString());
    }
  }

  // ─── POST / PUT / PATCH / DELETE shortcuts ──────────────────────────
  static Future<CustomHttpResult> post({
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    bool showFloatingError = true,
    bool needAuth = true,
  }) => commonRequests(
    endpoint: endpoint,
    headers: headers,
    body: body,
    showFloatingError: showFloatingError,
    needAuth: needAuth,
    method: CommonCustomMethods.POST,
  );

  static Future<CustomHttpResult> patch({
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    bool showFloatingError = true,
    bool needAuth = true,
  }) => commonRequests(
    endpoint: endpoint,
    headers: headers,
    body: body,
    showFloatingError: showFloatingError,
    needAuth: needAuth,
    method: CommonCustomMethods.PATCH,
  );

  static Future<CustomHttpResult> put({
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    bool showFloatingError = true,
    bool needAuth = true,
  }) => commonRequests(
    endpoint: endpoint,
    headers: headers,
    body: body,
    showFloatingError: showFloatingError,
    needAuth: needAuth,
    method: CommonCustomMethods.PUT,
  );

  static Future<CustomHttpResult> delete({
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    bool showFloatingError = true,
    bool needAuth = true,
  }) => commonRequests(
    endpoint: endpoint,
    headers: headers,
    body: body,
    showFloatingError: showFloatingError,
    needAuth: needAuth,
    method: CommonCustomMethods.DELETE,
  );

  // ─── MULTIPART ──────────────────────────────────────────────────────
  static Future<CustomHttpResult> multipart({
    required String endpoint,
    required CommonCustomMethods method,
    Map<String, String>? headers,
    Map<String, String> fields = const {},
    List<http.MultipartFile> files = const [],
  }) async {
    try {
      final url = '${AppCredentials.domain}/api/$endpoint';
      final uri = Uri.parse(url);
      final token = await AppHelper.instance.getAccessToken();

      var request = http.MultipartRequest(method.name, uri);
      Map<String, String> headers0 = {'Authorization': 'Bearer $token'};
      headers0.addAll(headers ?? {});

      request.headers.addAll(headers0);
      fields.forEach((key, value) => request.fields[key] = value);
      for (var file in files) {
        request.files.add(file);
      }

      debugPrint('<===== ${method.name} MULTIPART =====> $url');

      var response = await request.send().timeout(_multipartTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        printLine('Response body: ${json}');
        return CustomHttpResult(
          ok: true,
          status_code: response.statusCode,
          data: json,
        );
      } else {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);

        return CustomHttpResult(
          ok: false,
          status_code: response.statusCode,
          error: json["message"],
        );
      }
    } on TimeoutException {
      return const CustomHttpResult(
        ok: false,
        status_code: -3,
        error: 'Upload timed out. Please try again.',
      );
    } catch (e) {
      debugPrint('MULTIPART ERROR: $e');
      return CustomHttpResult(ok: false, status_code: -2, error: e.toString());
    }
  }

  // ─── COMMON REQUESTS (POST/PUT/PATCH/DELETE) ────────────────────────
  static Future<CustomHttpResult> commonRequests({
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    bool showFloatingError = true,
    bool needAuth = true,
    required CommonCustomMethods method,
    bool retry = true,
  }) async {
    if (!await has_internet(show_error: true)) {
      return const CustomHttpResult(
        ok: false,
        status_code: -1,
        error: 'No internet connection found!',
      );
    }

    try {
      final headers0 = await _buildHeaders(needAuth: needAuth, extra: headers);
      if (headers0 == null) {
        return const CustomHttpResult(
          ok: false,
          status_code: 401,
          error: 'Session expired, Please sign in again!',
        );
      }

      final url = '${AppCredentials.domain}/api/$endpoint';
      final uri = Uri.parse(url);
      final encodedBody = jsonEncode(body ?? {});
      final encoding = Encoding.getByName('utf-8');

      debugPrint('<===== ${method.name} =====> $url');

      late http.Response response;

      switch (method) {
        case CommonCustomMethods.POST:
          response = await http
              .post(
                uri,
                body: encodedBody,
                headers: headers0,
                encoding: encoding,
              )
              .timeout(_requestTimeout);
        case CommonCustomMethods.PUT:
          response = await http
              .put(
                uri,
                body: encodedBody,
                headers: headers0,
                encoding: encoding,
              )
              .timeout(_requestTimeout);
        case CommonCustomMethods.PATCH:
          response = await http
              .patch(
                uri,
                body: encodedBody,
                headers: headers0,
                encoding: encoding,
              )
              .timeout(_requestTimeout);
        case CommonCustomMethods.DELETE:
          response = await http
              .delete(
                uri,
                body: encodedBody,
                headers: headers0,
                encoding: encoding,
              )
              .timeout(_requestTimeout);
      }

      // Save cookie if returned
      final setCookie = response.headers['set-cookie'];
      if (setCookie != null) {
        await AppHelper.instance.setCookie(setCookie);
      }

      // Auto retry on 401
      if (response.statusCode == 401 && retry) {
        bool refreshed = await _refreshTokenSafe();
        if (refreshed) {
          return commonRequests(
            endpoint: endpoint,
            headers: headers,
            body: body,
            showFloatingError: showFloatingError,
            needAuth: needAuth,
            method: method,
            retry: false,
          );
        }
      }

      return _handle_response(response, showFloatingError);
    } on TimeoutException {
      return const CustomHttpResult(
        ok: false,
        status_code: -3,
        error: 'Request timed out. Please try again.',
      );
    } catch (e) {
      debugPrint('${method.name} ERROR [$endpoint]: $e');
      return CustomHttpResult(ok: false, status_code: -2, error: e.toString());
    }
  }

  // ─── BUILD HEADERS (shared logic) ──────────────────────────────────
  static Future<Map<String, String>?> _buildHeaders({
    required bool needAuth,
    Map<String, String>? extra,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (needAuth) {
      final tokenValidity = await AppHelper.instance.getTokenValidity();
      final now = DateTime.now().millisecondsSinceEpoch;

      if (tokenValidity == null || tokenValidity < now) {
        if (!await _refreshTokenSafe()) {
          return null;
        }
      }

      final accessToken = await AppHelper.instance.getAccessToken();
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final cookie = await AppHelper.instance.getCookie();
      if (cookie != null) {
        headers['Cookie'] = cookie;
      }
    }

    if (extra != null) {
      headers.addAll(extra);
    }

    return headers;
  }

  // ─── TOKEN REFRESH (deduplicated) ──────────────────────────────────
  static Future<bool> _refreshTokenSafe() {
    // If a refresh is already in progress, reuse that future.
    _refreshFuture ??= _doRefreshToken().whenComplete(() {
      _refreshFuture = null;
    });
    return _refreshFuture!;
  }

  static Future<bool> _doRefreshToken() async {
    try {
      final refreshToken = await AppHelper.instance.getRefToken();
      final userId = await AppHelper.instance.getUserId();

      if (refreshToken == null || userId == null) {
        await AppHelper.instance.clearAllPrefValue();
        return false;
      }

      final response = await http
          .post(
            Uri.parse('${AppCredentials.domain}/api/auth/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $refreshToken',
            },
          )
          .timeout(_refreshTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await AppHelper.instance.setAccessToken(data['accessToken']);
        await AppHelper.instance.setTokenValidity(
          int.parse(data['decodedData']['exp'].toString()),
        );
        return true;
      } else {
        await AppHelper.instance.clearAllPrefValue();
        return false;
      }
    } on TimeoutException {
      debugPrint('Token refresh timed out');
      return false;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  // Keep this public for backward compat
  static Future<bool> setNewAccessToken() => _refreshTokenSafe();

  /// Parses an [http.Response] into a [CustomHttpResult].
  static CustomHttpResult _handle_response(
    http.Response response,
    bool show_floating_error,
  ) {
    const success_codes = {200, 201, 202, 203, 204};

    if (success_codes.contains(response.statusCode)) {
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return CustomHttpResult(
        ok: true,
        status_code: response.statusCode,
        data: data,
      );
    }

    final message = _parse_error_message(response);

    if (show_floating_error) showCustomToast(text: message);

    return CustomHttpResult(
      status_code: response.statusCode,
      error: message,
      ok: false,
    );
  }

  static String _parse_error_message(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] as String? ?? 'Something went wrong.';
    } catch (_) {
      if (response.statusCode == 404) return 'Endpoint not found!';
      if (response.statusCode == 400) return response.body;
      debugPrint(
        'Unhandled HTTP error: ${response.statusCode}\n${response.body}',
      );
      return 'Something went wrong.';
    }
  }
}
