import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:posture_detector_app/models/profile/author_model.dart';
import 'package:posture_detector_app/models/user_type.dart';
import 'package:posture_detector_app/services/auth/auth_o_service.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/utils/print_helper.dart';
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

    printLine(response.data);

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
    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      image.path,
    );
    final response = await CustomHttp.multipart(
      endpoint: 'settings/personal-info/me',
      method: CommonCustomMethods.PUT,
      files: [multipartFile],
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
    AppHelper.instance.setUserId(response.data['user']['id']);
    AppHelper.instance.setAuthRole(response.data['user']['role']);

    if (user_type == UserType.EMPLOYEE) {
      AppHelper.instance.setIsonBoarding(
        response.data['user']['has_onboarded'],
      );
      final isOnboarded = await AppHelper.instance.getIsonBoarding();
      return isOnboarded == true;
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
    required int employeeId,
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

    await AppHelper.instance.setUserId(response.data['user_id']);
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    final userId = await AppHelper.instance.getUserId();
    if (userId == null) return false;

    final response = await CustomHttp.post(
      endpoint: 'auth/verify-reset-code',
      body: {'user_id': userId, 'verification_code': otp},
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
    final userId = await AppHelper.instance.getUserId();
    final secretKey = await AppHelper.instance.getSecretKey();
    if (userId == null || secretKey == null) return false;

    final response = await CustomHttp.post(
      endpoint: 'auth/reset-password',
      body: {
        'user_id': userId,
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

  /// Signs in via Auth0 browser flow, then exchanges the token with the backend.
  /// Backend must implement POST /api/auth/oauth-sign-in accepting
  /// { mode, access_token, id_token } and returning the same shape as sign-in.
  Future<bool?> signInWithAuth0({required UserType userType}) async {
    final credentials = await Auth0Service.login();
    if (credentials == null) return null;

    final response = await CustomHttp.post(
      endpoint: 'auth/oauth-sign-in',
      body: {
        'mode': userType.name,
        'access_token': credentials.accessToken,
        'id_token': credentials.idToken,
      },
      needAuth: false,
    );

    if (!response.ok) return null;

    AppHelper.instance.setAccessToken(response.data['access_token']);
    AppHelper.instance.setRefToken(response.data['refresh_token']);
    AppHelper.instance.setTokenValidity(response.data['expires_at']);
    AppHelper.instance.setUserId(response.data['user']['id']);
    AppHelper.instance.setAuthRole(response.data['user']['role']);

    if (userType == UserType.EMPLOYEE) {
      AppHelper.instance.setIsonBoarding(
        response.data['user']['has_onboarded'],
      );
      final isOnboarded = await AppHelper.instance.getIsonBoarding();
      return isOnboarded == true;
    }

    await refreshProfile();
    return true;
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
