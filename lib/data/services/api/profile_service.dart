import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:posture_detector_app/models/profile/profile_model.dart';
import 'package:posture_detector_app/data/services/network/api_response.dart';
import 'package:posture_detector_app/data/services/network/custom_http.dart';

class ProfileService {
  /// ----------------------------- Change password -------------------------------- ///
  Future<ApiResponse<bool>> changePassword(
    String toke,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      debugPrint('ProfileService: changePassword called');
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

      if (response.ok) {
        return ApiResponse.success(true);
      } else {
        final json = jsonDecode(response.error ?? '{}');
        final errorMessage = json['message']?.toString() ?? response.error ?? 'Something went wrong';

        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('ProfileService changePassword error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// ------------------------------- fetch profile info ------------------------------------- ///
  Future<ApiResponse<ProfileModel>> fetchUserInfo() async {
    try {
      final response = await CustomHttp.get(
        endpoint: 'settings/personal-info/me',
        needAuth: true,
        showFloatingError: false,
      );

      if (response.ok) {
        final json = response.data;

        final userInfo = ProfileModel.fromJson(json);

        return ApiResponse.success(userInfo);
      } else {
        final json = jsonDecode(response.error ?? '{}');
        final errorMessage = json['message']?.toString() ?? response.error ?? 'Something went wrong';

        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('ProfileService fetchUserInfo error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// ------------------------------- fetch privacy ------------------------------------- ///
  // Future<ApiResponse<List<PrivacyModel>>> fetchPrivacy() async {
  //   try {
  //     final response = await CustomHttp.get(
  //       endpoint: 'settings/user/privacy-policy',
  //       needAuth: true,
  //       showFloatingError: false,
  //     );
  //
  //     if (response.statusCode == 200 ||
  //         response.statusCode == 201 ||
  //         response.statusCode == 204) {
  //       final List<dynamic> json = response.data;
  //
  //       List<PrivacyModel> privacy = json
  //           .map((e) => PrivacyModel.fromJson(e))
  //           .toList();
  //
  //       return ApiResponse.success(privacy);
  //     } else {
  //       final json = jsonDecode(response.error!);
  //       final errorMessage = json['message'];
  //
  //       return ApiResponse.error(errorMessage!);
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //     return ApiResponse.error('Something went wrong 404');
  //   }
  // }

  /// ------------------------------- update image ------------------------------------- ///
  Future<ApiResponse<bool>> updateProfilePic(File image) async {
    try {
      File imageFile = File(image.path);

      var multipartFile = await http.MultipartFile.fromPath(
        'avatar',
        imageFile.path,
      );

      final response = await CustomHttp.multipart(
        endpoint: 'settings/personal-info/me',
        method: CommonCustomMethods.PUT,
        files: [multipartFile],
      );

      if (response.ok) {
        return ApiResponse.success(true);
      } else {
        final json = jsonDecode(response.error ?? '{}');
        final errorMessage = json['message']?.toString() ?? response.error ?? 'Something went wrong';

        return ApiResponse.error(errorMessage);
      }
    } catch (e, st) {
      debugPrint('ProfileService updateProfilePic error: ${e.runtimeType}');
      debugPrint('StackTrace: $st');
      return ApiResponse.error('Something went wrong 404');
    }
  }

  /// ------------------------------- update name ------------------------------------- ///
  Future<ApiResponse<bool>> updateName(String name) async {
    try {
      final response = await CustomHttp.put(
        endpoint: 'settings/personal-info/me',
        needAuth: true,
        showFloatingError: false,
        body: {'full_name': name},
      );

      if (response.ok) {
        return ApiResponse.success(true);
      } else {
        final json = jsonDecode(response.error ?? '{}');
        final errorMessage = json['message']?.toString() ?? response.error ?? 'Something went wrong';

        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      debugPrint('ProfileService updateName error: ${e.runtimeType}');
      return ApiResponse.error('Something went wrong 404');
    }
  }
}
