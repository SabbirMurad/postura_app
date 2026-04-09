import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:posture_detector_app/models/analysis/analysis_data_model.dart';
import 'package:posture_detector_app/services/network/api_response.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/utils/print_helper.dart';

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

      printLine('===== ONBOARDING REQUEST =====');
      printLine('Endpoint: assessments/scan-analyse');
      printLine('Scan type: $scan_type');

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

      if (connection.ok) {
        // Check if connection.data is null
        if (connection.data == null) {
          printLine('ERROR: connection.data is null');
          return ApiResponse.error('Server returned empty response');
        }

        try {
          final data = AnalysisDataModel.fromJson(connection.data);
          printLine('Successfully parsed UserAnalysisDataModel');
          return ApiResponse.success(data);
        } catch (parseError, stackTrace) {
          printLine('ERROR parsing UserAnalysisDataModel: $parseError');
          printLine('Stack trace: $stackTrace');
          return ApiResponse.error(
            'Failed to parse server response: $parseError',
          );
        }
      } else {
        return ApiResponse.error(
          'Status ${connection.status_code}, Error: ${connection.error}',
        );
      }
    } catch (e, stackTrace) {
      printLine('===== EXCEPTION IN ONBOARDING SERVICE =====');
      printLine('Error: ${e.runtimeType}');
      printLine('Stack trace: $stackTrace');
      return ApiResponse.error('Something went wrong');
    }
  }

  /// Fetch user's assessment reports
  Future<ApiResponse<AnalysisDataModel>> fetchMyReports() async {
    try {
      final connection = await CustomHttp.get(
        endpoint: 'assessments/my-reports',
      );

      if (connection.ok) {
        // Check if connection.data is null
        if (connection.data == null) {
          printLine('ERROR: connection.data is null');
          return ApiResponse.error('Server returned empty response');
        }

        try {
          final data = AnalysisDataModel.fromJson(connection.data);
          printLine('Successfully parsed AnalysisDataModel from my-reports');
          return ApiResponse.success(data);
        } catch (parseError, stackTrace) {
          printLine('ERROR parsing AnalysisDataModel: $parseError');
          printLine('Stack trace: $stackTrace');
          return ApiResponse.error(
            'Failed to parse server response: $parseError',
          );
        }
      } else {
        return ApiResponse.error(
          connection.error ?? 'Status ${connection.status_code}',
        );
      }
    } catch (e, stackTrace) {
      printLine('===== EXCEPTION IN FETCH MY REPORTS SERVICE =====');
      printLine('Error: ${e.runtimeType}');
      printLine('Stack trace: $stackTrace');
      return ApiResponse.error('Something went wrong');
    }
  }

  /// Export report as PDF
  Future<ApiResponse<String>> exportReportPDF({
    required int assessmentId,
  }) async {
    try {
      printLine('===== EXPORT REPORT PDF REQUEST =====');
      printLine('Endpoint: api/assessments/$assessmentId/export-pdf');

      final connection = await CustomHttp.get(
        endpoint: 'api/assessments/$assessmentId/export-pdf',
      );

      printLine('===== EXPORT REPORT PDF RESPONSE =====');
      printLine('Status code: ${connection.status_code}');

      if (connection.ok) {
        printLine('PDF exported successfully');
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
        printLine('ERROR: Non-success status code: ${connection.status_code}');
        return ApiResponse.error('Failed to export PDF');
      }
    } catch (e, stackTrace) {
      printLine('===== EXCEPTION IN EXPORT PDF SERVICE =====');
      printLine('Error: ${e.runtimeType}');
      printLine('Stack trace: $stackTrace');
      return ApiResponse.error('Something went wrong');
    }
  }
}
