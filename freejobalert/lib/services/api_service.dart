import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://www.freejobalert.com/production/controller/get_jobs.php';
  static const String contentUrl =
      'https://www.freejobalert.com/production/controller/get_content.php';

  // HTTP request timeout
  static const Duration requestTimeout = Duration(seconds: 30);

  // Fetch all jobs (homepage) - 50 per page
  static Future<ApiResponse> fetchJobs({int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl?get_app_page=$page');
      final response = await http.get(url).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        // Parse JSON in background isolate to avoid UI jank
        final jsonData = await compute(_parseJobListJson, response.body);
        return ApiResponse.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        final jsonData = await compute(_parseJobListJson, response.body);
        return ApiResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching jobs: $e');
    }
  }

  // Fetch jobs by category - 50 per page
  static Future<ApiResponse> fetchJobsByCategory({
    required String categoryGroup,
    int page = 1,
  }) async {
    try {
      final url = Uri.parse('$baseUrl?cat_group=$categoryGroup&get_app_page=$page');
      final response = await http.get(url).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        // Parse JSON in background isolate to avoid UI jank
        final jsonData = await compute(_parseJobListJson, response.body);
        return ApiResponse.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        final jsonData = await compute(_parseJobListJson, response.body);
        return ApiResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching jobs: $e');
    }
  }

  // Fetch job details by post_id
  static Future<JobDetailResponse> fetchJobDetail({required String jobId}) async {
    try {
      final url = Uri.parse('$contentUrl?job_id=$jobId');
      final response = await http.get(url).timeout(
        requestTimeout,
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        // Parse JSON in background isolate to avoid UI jank
        final jsonData = await compute(_parseJobDetailJson, response.body);
        return JobDetailResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load job details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching job details: $e');
    }
  }

  // Helper function to parse JSON in isolate (must be top-level or static)
  static Map<String, dynamic> _parseJobListJson(String responseBody) {
    return json.decode(responseBody) as Map<String, dynamic>;
  }

  static Map<String, dynamic> _parseJobDetailJson(String responseBody) {
    return json.decode(responseBody) as Map<String, dynamic>;
  }
}

// API Response Model for job list
class ApiResponse {
  final bool success;
  final String message;
  final List<dynamic>? data;
  final int? totalJobs;
  final Pagination? pagination;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.totalJobs,
    this.pagination,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] as List<dynamic>?,
      totalJobs: json['totalJobs'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

// Pagination Model
class Pagination {
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasNext: json['hasNext'] ?? false,
      hasPrevious: json['hasPrevious'] ?? false,
    );
  }
}

// Job Detail Response Model
class JobDetailResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  JobDetailResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory JobDetailResponse.fromJson(Map<String, dynamic> json) {
    return JobDetailResponse(
      success: json['success'] ?? true,
      message: json['message'],
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}