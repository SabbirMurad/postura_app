import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:posture_detector_app/models/auth/sign_in_model.dart';
import 'package:posture_detector_app/data/services/network/api_response.dart';
import 'package:posture_detector_app/data/services/network/custom_http.dart';

import 'package:posture_detector_app/data/helpers/app_helper.dart';

class AuthService {
  /// -------------------------------- Private signup ------------------------------------ ///
  Future<ApiResponse<bool>> privateSignup(
    String mode,
    String language,
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await CustomHttp.post(
        endpoint: 'auth/sign-up',
        body: {
          "mode": mode,
          "language": language,
          "full_name": name,
          "email_address": email,
          "password": password,
        },
        needAuth: false,
        showFloatingError: false,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        AppHelper.instance.setUserId(response.data['user_id']);
        return ApiResponse.success(true);
      } else {
        final json = jsonDecode(response.error ?? '{}');
        final errorMessage = json['message']?.toString() ?? response.error ?? 'Something went wrong';

        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('AuthService error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// -------------------------------- Private signIn ------------------------------------ ///
  Future<ApiResponse<PrivateSignInModel>> privateSignIn(
    String mode,
    String email,
    String password,
  ) async {
    try {
      final response = await CustomHttp.post(
        endpoint: 'auth/sign-in',
        body: {"mode": mode, "email_address": email, "password": password},
        needAuth: false,
        showFloatingError: false,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        AppHelper.instance.setAccessToken(response.data['access_token']);
        AppHelper.instance.setRefToken(response.data['refresh_token']);
        AppHelper.instance.setTokenValidity(response.data['expires_at']);
        AppHelper.instance.setUserId(response.data['user']['id']);
        AppHelper.instance.setAuthRole(response.data['user']['role']);
        AppHelper.instance.setIsonBoarding(
          response.data['user']['has_onboarded'],
        );

        final data = PrivateSignInModel.fromJson(response.data);

        return ApiResponse.success(data);
      } else {
        final json = jsonDecode(response.error ?? '{}');
        final errorMessage = json['message']?.toString() ?? response.error ?? 'Something went wrong';

        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('AuthService error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// -------------------------------- business signup ------------------------------------ ///
  Future<ApiResponse<bool>> businessSignup(
    String mode,
    String language,
    String name,
    String email,
    String password,
    String companyCode,
    int employeeId,
    String deskLocation,
    String department,
    String deskRole,
  ) async {
    try {
      final response = await CustomHttp.post(
        endpoint: 'auth/sign-up',
        body: {
          "mode": mode,
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
        showFloatingError: false,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return ApiResponse.success(true);
      } else {
        final json = jsonDecode(response.error ?? '{}');
        final errorMessage = json['message']?.toString() ?? response.error ?? 'Something went wrong';

        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('AuthService error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// -------------------------------- business signIn ------------------------------------ ///
  Future<ApiResponse<PrivateSignInModel>> businessSignIn(
    String mode,
    String email,
    String password,
  ) async {
    try {
      final response = await CustomHttp.post(
        endpoint: 'auth/sign-in',
        body: {"mode": mode, "email_address": email, "password": password},
        needAuth: false,
        showFloatingError: false,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        AppHelper.instance.setAccessToken(response.data['access_token']);
        AppHelper.instance.setRefToken(response.data['refresh_token']);
        AppHelper.instance.setTokenValidity(response.data['expires_at']);
        AppHelper.instance.setUserId(response.data['user']['id']);
        AppHelper.instance.setAuthRole(response.data['user']['role']);
        AppHelper.instance.setIsonBoarding(
          response.data['user']['has_onboarded'],
        );

        final data = PrivateSignInModel.fromJson(response.data);

        return ApiResponse.success(data);
      } else {
        final json = jsonDecode(response.error ?? '{}');
        final errorMessage = json['message']?.toString() ?? response.error ?? 'Something went wrong';

        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('AuthService error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// -------------------------------- business signIn ------------------------------------ ///
  Future<ApiResponse<PrivateSignInModel>> cpeSignIn(
    String mode,
    String email,
    String password,
  ) async {
    try {
      final response = await CustomHttp.post(
        endpoint: 'auth/sign-in',
        body: {
          "mode": "ERGONOMIST",
          "email_address": email,
          "password": password,
        },
        needAuth: false,
        showFloatingError: false,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        AppHelper.instance.setAccessToken(response.data['access_token']);
        AppHelper.instance.setRefToken(response.data['refresh_token']);
        AppHelper.instance.setTokenValidity(response.data['expires_at']);
        AppHelper.instance.setUserId(response.data['user']['id']);
        AppHelper.instance.setAuthRole(response.data['user']['role']);

        final data = PrivateSignInModel.fromJson(response.data);

        return ApiResponse.success(data);
      } else {
        final json = jsonDecode(response.error ?? '{}');
        final errorMessage = json['message']?.toString() ?? response.error ?? 'Something went wrong';

        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('AuthService error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// ------------------------- forget password or reset password   --------------------------------- ///
  Future<ApiResponse<bool>> forgetPassEmailVerify(String email) async {
    try {
      final response = await CustomHttp.post(
        endpoint: 'auth/forgot-password',
        body: {'email_address': email},
        needAuth: false,
        showFloatingError: false,
      );

      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 204) {
        await AppHelper.instance.setUserId(response.data['user_id']);

        return ApiResponse.success(true);
      } else {
        final decoded = jsonDecode(response.error ?? 'something went wrong');
        String emailError = decoded['message'] ?? 'Unknown error';

        return ApiResponse.error(emailError);
      }
    } catch (e) {
      debugPrint('AuthService error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// ------------------------- forget password Email OTP verification --------------------------------- ///
  Future<ApiResponse<bool>> resetPassOtpVerify(
    int userId,
    String verificationCode,
  ) async {
    try {
      final response = await CustomHttp.post(
        endpoint: 'auth/verify-reset-code',
        body: {'user_id': userId, 'verification_code': verificationCode},
        needAuth: false,
        showFloatingError: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppHelper.instance.setSecretKey(response.data['secret_key']);
        return ApiResponse(success: true, data: true);
      } else {
        final json = jsonDecode(response.error ?? '{}');
        final errorMessage = json['message']?.toString() ?? response.error ?? 'Something went wrong';

        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('AuthService error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// ------------------------- reset Password --------------------------------- ///
  Future<ApiResponse<bool>> resetPass(
    int userId,
    String secretKey,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await CustomHttp.post(
        endpoint: 'auth/reset-password',
        body: {
          'user_id': userId,
          'secret_key': secretKey,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
        needAuth: false,
        showFloatingError: false,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return ApiResponse(data: true, success: true);
      } else {
        final decoded = jsonDecode(response.error ?? 'something went wrong');
        String emailError = decoded['message'] ?? 'Unknown error';

        return ApiResponse.error(emailError);
      }
    } catch (e) {
      debugPrint('AuthService error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// ------------------------- resend OTP --------------------------------- ///
  Future<ApiResponse<bool>> resendOtp(int userId) async {
    try {
      final response = await CustomHttp.post(
        endpoint: 'auth/resend-verification-code',
        body: {'user_id': userId},
        needAuth: false,
        showFloatingError: false,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return ApiResponse(data: true, success: true);
      } else {
        final decoded = jsonDecode(response.error ?? 'something went wrong');
        String emailError = decoded['message'] ?? 'Unknown error';

        return ApiResponse.error(emailError);
      }
    } catch (e) {
      debugPrint('AuthService error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// -------------------------- verify user PRIVATE ---------------------------------- ///
  Future<ApiResponse<bool>> verifyUserOtp(
    int userId,
    String verificationCode,
  ) async {
    try {
      final response = await CustomHttp.post(
        endpoint: 'auth/verify-email',
        body: {'user_id': userId, 'verification_code': verificationCode},
        needAuth: false,
        showFloatingError: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppHelper.instance.setAccessToken(response.data['access_token']);
        AppHelper.instance.setRefToken(response.data['refresh_token']);
        AppHelper.instance.setIsonBoarding(response.data['has_onboarded']);
        return ApiResponse(success: true, data: true);
      } else {
        final json = jsonDecode(response.error ?? '{}');
        final errorMessage = json['message']?.toString() ?? response.error ?? 'Something went wrong';

        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('AuthService error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }
}
