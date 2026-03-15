import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:posture_detector_app/models/analysis/analysis_data_model.dart';
import 'package:posture_detector_app/data/services/network/api_response.dart';
import 'package:posture_detector_app/data/services/network/custom_http.dart';

class OnboardingService {
  Future<ApiResponse<AnalysisDataModel>> onboardingFlow({
    required String scan_type,
    required File image,
    required List<String> bodyRegions,
    required Map<String, int> painIntensity,
    required String durationPattern,
    required Map<String, String> workHabits,
    required List<String> symptoms,
  }) async {
    try {
      File imageFile = File(image.path);

      var multipartFile = await http.MultipartFile.fromPath(
        'captured_image',
        imageFile.path,
      );

      debugPrint('===== ONBOARDING REQUEST =====');
      debugPrint('Endpoint: assessments/scan-analyse');
      debugPrint('Scan type: $scan_type');

      final connection = await CustomHttp.multipart(
        endpoint: 'assessments/scan-analyse',
        method: CommonCustomMethods.POST,
        fields: {
          'scan_type': scan_type,
          'body_regions': jsonEncode(bodyRegions),
          'pain_intensity': jsonEncode(painIntensity),
          'duration_pattern': durationPattern,
          'work_pattern': jsonEncode(workHabits),
          'symptoms': jsonEncode(symptoms),
        },
        files: [multipartFile],
      );

      debugPrint('===== ONBOARDING RESPONSE =====');
      debugPrint('Status code: ${connection.statusCode}');

      if (connection.statusCode == 200 ||
          connection.statusCode == 201 ||
          connection.statusCode == 204) {
        // Check if connection.data is null
        if (connection.data == null) {
          debugPrint('ERROR: connection.data is null');
          return ApiResponse.error('Server returned empty response');
        }

        // Parse the response data
        Map<String, dynamic> jsonData;

        if (connection.data is String) {
          // If data is a string, decode it
          debugPrint('Data is String, decoding...');
          jsonData = jsonDecode(connection.data as String);
        } else if (connection.data is Map) {
          // If data is already a Map, use it directly
          debugPrint('Data is already a Map');
          jsonData = connection.data as Map<String, dynamic>;
        } else {
          debugPrint('ERROR: Unexpected data type: ${connection.data.runtimeType}');
          return ApiResponse.error('Invalid response format from server');
        }

        // Check if the response has the expected structure
        if (!jsonData.containsKey('ai_result')) {
          debugPrint('WARNING: Response missing ai_result key');
          debugPrint('Available keys: ${jsonData.keys.toList()}');
        }

        try {
          final data = AnalysisDataModel.fromJson(jsonData);
          debugPrint('Successfully parsed UserAnalysisDataModel');
          return ApiResponse.success(data);
        } catch (parseError, stackTrace) {
          debugPrint('ERROR parsing UserAnalysisDataModel: $parseError');
          debugPrint('Stack trace: $stackTrace');
          return ApiResponse.error(
            'Failed to parse server response: $parseError',
          );
        }
      } else {
        debugPrint('ERROR: Non-success status code: ${connection.statusCode}');

        try {
          final json = connection.error != null
              ? (connection.error is String
                    ? jsonDecode(connection.error!)
                    : connection.error)
              : {'message': 'Unknown error'};

          final errorMessage =
              json['message'] ??
              json['error'] ??
              json['detail'] ??
              'Request failed';
          debugPrint('Error message: $errorMessage');

          return ApiResponse.error(errorMessage.toString());
        } catch (e) {
          debugPrint('Error parsing error response: ${e.runtimeType}');
          return ApiResponse.error(
            'Request failed with status ${connection.statusCode}',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('===== EXCEPTION IN ONBOARDING SERVICE =====');
      debugPrint('Error: ${e.runtimeType}');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error('Something went wrong');
    }
  }

  /// Fetch user's assessment reports
  Future<ApiResponse<AnalysisDataModel>> fetchMyReports() async {
    try {
      debugPrint('===== FETCH MY REPORTS REQUEST =====');
      debugPrint('Endpoint: /assessments/my-reports');

      final connection = await CustomHttp.get(
        endpoint: 'assessments/my-reports',
      );

      debugPrint('===== FETCH MY REPORTS RESPONSE =====');
      debugPrint('Status code: ${connection.statusCode}');

      if (connection.statusCode == 200 || connection.statusCode == 201) {
        // Check if connection.data is null
        if (connection.data == null) {
          debugPrint('ERROR: connection.data is null');
          return ApiResponse.error('Server returned empty response');
        }

        // Parse the response data
        Map<String, dynamic> jsonData;

        if (connection.data is String) {
          // If data is a string, decode it
          debugPrint('Data is String, decoding...');
          jsonData = jsonDecode(connection.data as String);
        } else if (connection.data is Map) {
          // If data is already a Map, use it directly
          debugPrint('Data is already a Map');
          jsonData = connection.data as Map<String, dynamic>;
        } else {
          debugPrint('ERROR: Unexpected data type: ${connection.data.runtimeType}');
          return ApiResponse.error('Invalid response format from server');
        }

        // Check if the response has the expected structure
        if (!jsonData.containsKey('ai_result')) {
          debugPrint('WARNING: Response missing ai_result key');
          debugPrint('Available keys: ${jsonData.keys.toList()}');
        }

        try {
          final data = AnalysisDataModel.fromJson(jsonData);
          debugPrint('Successfully parsed AnalysisDataModel from my-reports');
          return ApiResponse.success(data);
        } catch (parseError, stackTrace) {
          debugPrint('ERROR parsing AnalysisDataModel: $parseError');
          debugPrint('Stack trace: $stackTrace');
          return ApiResponse.error(
            'Failed to parse server response: $parseError',
          );
        }
      } else {
        debugPrint('ERROR: Non-success status code: ${connection.statusCode}');

        try {
          final json = connection.error != null
              ? (connection.error is String
                    ? jsonDecode(connection.error!)
                    : connection.error)
              : {'message': 'Unknown error'};

          final errorMessage =
              json['message'] ??
              json['error'] ??
              json['detail'] ??
              'Request failed';
          debugPrint('Error message: $errorMessage');

          return ApiResponse.error(errorMessage.toString());
        } catch (e) {
          debugPrint('Error parsing error response: ${e.runtimeType}');
          return ApiResponse.error(
            'Request failed with status ${connection.statusCode}',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('===== EXCEPTION IN FETCH MY REPORTS SERVICE =====');
      debugPrint('Error: ${e.runtimeType}');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error('Something went wrong');
    }
  }

  /// Export report as PDF
  Future<ApiResponse<String>> exportReportPDF({
    required int assessmentId,
  }) async {
    try {
      debugPrint('===== EXPORT REPORT PDF REQUEST =====');
      debugPrint('Endpoint: api/assessments/$assessmentId/export-pdf');

      final connection = await CustomHttp.get(
        endpoint: 'api/assessments/$assessmentId/export-pdf',
      );

      debugPrint('===== EXPORT REPORT PDF RESPONSE =====');
      debugPrint('Status code: ${connection.statusCode}');

      if (connection.statusCode == 200) {
        debugPrint('PDF exported successfully');
        // Assuming the response contains a download URL or file path
        final data = connection.data;

        if (data is String) {
          return ApiResponse.success(data);
        } else if (data is Map) {
          final url = data['pdf_url'] ?? data['url'] ?? data['download_url'];
          return ApiResponse.success(url);
        }

        return ApiResponse.error('Unable to extract PDF URL from response');
      } else {
        debugPrint('ERROR: Non-success status code: ${connection.statusCode}');
        return ApiResponse.error('Failed to export PDF');
      }
    } catch (e, stackTrace) {
      debugPrint('===== EXCEPTION IN EXPORT PDF SERVICE =====');
      debugPrint('Error: ${e.runtimeType}');
      debugPrint('Stack trace: $stackTrace');
      return ApiResponse.error('Something went wrong');
    }
  }
}
