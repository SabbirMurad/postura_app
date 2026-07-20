import 'dart:io';

import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:posture_detector_app/models/prepared_image.dart';
import 'package:posture_detector_app/models/profile/author_model.dart';
import 'package:posture_detector_app/models/user_type.dart';
import 'package:posture_detector_app/services/auth/okta_oidc_service.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/utils/media.dart' as media;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'author.g.dart';

@Riverpod(keepAlive: true)
class AuthorNotifier extends _$AuthorNotifier {
  @override
  Future<AuthorModel?> build() async {
    final token = await AppHelper.instance.getAccessToken();
    if (token == null) return null;
    return _fetchProfile();
  }

  Future<AuthorModel?> _fetchProfile() async {
    final response = await CustomHttp.get(
      endpoint: 'settings/personal-info/me',
      needAuth: true,
      showFloatingError: false,
    );
    if (!response.ok) return null;

    return AuthorModel.fromJson(response.data);
  }

  Future<void> refreshProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchProfile);
  }

  Future<bool> updateName(String name) async {
    final response = await CustomHttp.put(
      endpoint: 'settings/personal-info/me',
      needAuth: true,
      showFloatingError: false,
      body: {'full_name': name},
    );

    if (!response.ok) {
      showCustomToast(text: response.error ?? 'Something went wrong');
      return false;
    }

    await refreshProfile();
    return true;
  }

  Future<bool> updateImage(File image) async {
    // Upload the picked image first (as a temporary asset), then attach it to the
    // profile by id — the backend promotes it to a permanent image on save.
    final prepared = PreparedImage.fromFile(image);
    prepared.meta = await prepared.get_prepare_meta();
    prepared.prepared = true;

    final imageIds = await media.upload_images(
      images: [prepared],
      used_at: media.AssetUsedAt.ProfilePic,
      temporary: true,
    );
    if (imageIds == null || imageIds.isEmpty) {
      showCustomToast(text: 'Failed to upload image');
      return false;
    }

    final response = await CustomHttp.put(
      endpoint: 'settings/personal-info/me',
      needAuth: true,
      showFloatingError: false,
      body: {'avatar': imageIds.first},
    );
    if (!response.ok) {
      showCustomToast(text: response.error ?? 'Something went wrong');
      return false;
    }
    await refreshProfile();
    return true;
  }

  /// Returns true (onboarded), false (not onboarded), or null (error).
  Future<bool?> signIn({
    required UserType user_type,
    required String email_address,
    required String password,
  }) async {
    final response = await CustomHttp.post(
      endpoint: 'auth/sign-in',
      body: {
        "mode": user_type.name,
        "email_address": email_address,
        "password": password,
      },
      needAuth: false,
    );

    if (!response.ok) {
      return null;
    }

    AppHelper.instance.setAccessToken(response.data['access_token']);
    AppHelper.instance.setRefToken(response.data['refresh_token']);
    AppHelper.instance.setTokenValidity(response.data['expires_at']);
    AppHelper.instance.setUserId(response.data['user']['uuid']);
    AppHelper.instance.setAuthRole(response.data['user']['role']);

    // Persist the server's onboarding flag locally for every app user (employee
    // and private alike) so the splash screen routes to home — not onboarding —
    // when they've already completed an assessment on this or another device.
    final hasOnboarded = response.data['user']['has_onboarded'] == true;
    await AppHelper.instance.setIsonBoarding(hasOnboarded);

    if (user_type == UserType.EMPLOYEE) {
      return hasOnboarded;
    }

    await refreshProfile();

    return true;
  }

  /// Returns true on success, null on error.
  Future<bool?> signUp({
    required String language,
    required String name,
    required String email,
    required String password,
    required String companyCode,
    required String employeeId,
    required String deskLocation,
    required String department,
    required String deskRole,
  }) async {
    final response = await CustomHttp.post(
      endpoint: 'auth/sign-up',
      body: {
        "mode": UserType.EMPLOYEE.name,
        "language": language,
        "full_name": name,
        "email_address": email,
        "password": password,
        "company_code": companyCode,
        "employee_id": employeeId,
        "desk_location": deskLocation,
        "department": department,
        "desk_role": deskRole,
      },
      needAuth: false,
    );

    return response.ok;
  }

  Future<bool> verifyEmail(String email) async {
    final response = await CustomHttp.post(
      endpoint: 'auth/forgot-password',
      body: {'email_address': email},
      needAuth: false,
    );

    if (!response.ok) {
      showCustomToast(text: response.error ?? 'Something went wrong');
      return false;
    }

    // The flow now carries the email (the server no longer returns a user_id).
    await AppHelper.instance.setResetEmail(email);
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    final email = await AppHelper.instance.getResetEmail();
    if (email == null) return false;

    final response = await CustomHttp.post(
      endpoint: 'auth/verify-reset-code',
      body: {'email_address': email, 'verification_code': otp},
      needAuth: false,
    );

    if (!response.ok) {
      showCustomToast(text: response.error ?? 'Something went wrong');
      return false;
    }

    AppHelper.instance.setSecretKey(response.data['secret_key']);
    return true;
  }

  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    final email = await AppHelper.instance.getResetEmail();
    final secretKey = await AppHelper.instance.getSecretKey();
    if (email == null || secretKey == null) return false;

    final response = await CustomHttp.post(
      endpoint: 'auth/reset-password',
      body: {
        'email_address': email,
        'secret_key': secretKey,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
      needAuth: false,
    );

    return response.ok;
  }

  /// Returns true on success, false on error.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await CustomHttp.post(
      endpoint: 'auth/change-password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
      needAuth: true,
      showFloatingError: false,
    );

    return response.ok;
  }

  /// Enterprise SSO sign-in via Okta (OIDC). Discovers the company's Okta config
  /// by [companyCode], runs the OIDC flow, then exchanges the ID token with the
  /// backend. Returns true (onboarded), false (not onboarded), or null (error).
  Future<bool?> signInWithOkta({required String companyCode}) async {
    // 1. Discover the company's Okta org.
    final cfg = await CustomHttp.post(
      endpoint: 'auth/okta-config',
      body: {'company_code': companyCode},
      needAuth: false,
    );
    if (!cfg.ok || cfg.data['sso_enabled'] != true) {
      showCustomToast(text: 'SSO is not enabled for this company.');
      return null;
    }
    final issuer = cfg.data['okta_issuer'] as String?;
    final clientId = cfg.data['okta_client_id'] as String?;
    if (issuer == null || clientId == null) {
      showCustomToast(text: 'SSO is not configured for this company.');
      return null;
    }

    // 2. Run the OIDC flow to get an ID token.
    final idToken = await OktaOidcService.login(issuer: issuer, clientId: clientId);
    if (idToken == null) return null;

    // 3. Exchange it for app tokens.
    final response = await CustomHttp.post(
      endpoint: 'auth/oauth-sign-in',
      body: {'company_code': companyCode, 'id_token': idToken},
      needAuth: false,
    );
    if (!response.ok) {
      showCustomToast(text: response.error ?? 'SSO sign-in failed.');
      return null;
    }

    AppHelper.instance.setAccessToken(response.data['access_token']);
    AppHelper.instance.setRefToken(response.data['refresh_token']);
    AppHelper.instance.setTokenValidity(response.data['expires_at']);
    AppHelper.instance.setUserId(response.data['user']['uuid']);
    AppHelper.instance.setAuthRole(response.data['user']['role']);

    final hasOnboarded = response.data['user']['has_onboarded'] == true;
    await AppHelper.instance.setIsonBoarding(hasOnboarded);
    return hasOnboarded;
  }

  Future<void> resendOtp() async {
    final userId = await AppHelper.instance.getUserId();
    if (userId == null) return;

    final response = await CustomHttp.post(
      endpoint: 'auth/resend-verification-code',
      body: {'user_id': userId},
      needAuth: false,
    );

    if (response.ok) {
      showCustomToast(
        text: 'OTP sent to your email',
        toastType: ToastTypesInfo(ToastTypes.success),
      );
    } else {
      showCustomToast(text: response.error ?? 'Something went wrong');
    }
  }
}
