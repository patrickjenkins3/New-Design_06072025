import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class DataExportService {
  static const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  final SupabaseClient _client = SupabaseService.instance.client;
  final Dio _dio = Dio();

  DataExportService() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_anonKey',
    };
  }

  /// Get user's scholarship data for export
  Future<List<Map<String, dynamic>>> getUserScholarshipData() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get scholarships with bookmarks and applications
      final scholarships = await _client.from('scholarships').select('''
            *,
            scholarship_bookmarks!inner(created_at),
            scholarship_applications(status, applied_at, notes)
          ''').eq('scholarship_bookmarks.user_id', userId);

      return scholarships.map<Map<String, dynamic>>((scholarship) {
        final application =
            scholarship['scholarship_applications']?.isNotEmpty == true
                ? scholarship['scholarship_applications'][0]
                : null;

        // Guard the bookmarks embed: it may be null or empty for a malformed
        // response even though the !inner join normally guarantees a row.
        final bookmarks = scholarship['scholarship_bookmarks'];
        final bookmarkDate =
            (bookmarks is List && bookmarks.isNotEmpty) ? bookmarks[0]['created_at'] : null;

        return {
          'scholarship_name': scholarship['title'] ?? '',
          'sponsor': scholarship['sponsor'] ?? '',
          'category': scholarship['category'] ?? '',
          'award_amount': scholarship['award_display'] ?? '',
          'deadline': scholarship['deadline'] ?? '',
          'difficulty': scholarship['difficulty'] ?? '',
          'status': application?['status'] ?? 'bookmarked',
          'application_date': application?['applied_at'] ?? bookmarkDate,
          'notes': application?['notes'] ?? '',
          'match_percentage':
              scholarship['match_percentage']?.toString() ?? '0',
          'requirements':
              (scholarship['requirements'] as List?)?.join('; ') ?? '',
          'eligibility':
              (scholarship['eligibility'] as List?)?.join('; ') ?? '',
        };
      }).toList();
    } catch (error) {
      throw Exception('Failed to fetch scholarship data: $error');
    }
  }

  /// Get user's application progress data
  Future<Map<String, dynamic>> getUserApplicationProgress() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get application statistics
      final applications = await _client
          .from('scholarship_applications')
          .select('status, applied_at, scholarships(title, deadline)')
          .eq('user_id', userId);

      final bookmarks = await _client
          .from('scholarship_bookmarks')
          .select('id')
          .eq('user_id', userId);

      // Calculate statistics
      final totalApplications = applications.length;
      final appliedCount =
          applications.where((app) => app['status'] == 'applied').length;
      final inReviewCount =
          applications.where((app) => app['status'] == 'in_review').length;
      final acceptedCount =
          applications.where((app) => app['status'] == 'accepted').length;
      final rejectedCount =
          applications.where((app) => app['status'] == 'rejected').length;
      final totalBookmarks = bookmarks.length;

      // Get upcoming deadlines
      final now = DateTime.now();
      final upcomingDeadlines = applications
          .where((app) {
            // The scholarships embed is a non-inner join, so it can be null.
            final scholarship = app['scholarships'];
            final deadline =
                DateTime.tryParse(scholarship?['deadline'] ?? '');
            return deadline != null && deadline.isAfter(now);
          })
          .map((app) {
            final scholarship = app['scholarships'];
            return {
              'scholarship': scholarship?['title'],
              'deadline': scholarship?['deadline'],
              'status': app['status'],
            };
          })
          .toList();

      return {
        'export_date': DateTime.now().toIso8601String(),
        'total_applications': totalApplications,
        'total_bookmarks': totalBookmarks,
        'applied_count': appliedCount,
        'in_review_count': inReviewCount,
        'accepted_count': acceptedCount,
        'rejected_count': rejectedCount,
        'success_rate': totalApplications > 0
            ? (acceptedCount / totalApplications * 100).toStringAsFixed(1)
            : '0.0',
        'upcoming_deadlines': upcomingDeadlines,
      };
    } catch (error) {
      throw Exception('Failed to fetch application progress: $error');
    }
  }

  /// Generate CSV content from scholarship data
  String generateScholarshipCSV(List<Map<String, dynamic>> scholarships) {
    if (scholarships.isEmpty) {
      return 'scholarship_name,sponsor,category,award_amount,deadline,difficulty,status,application_date,notes,match_percentage,requirements,eligibility\n';
    }

    final buffer = StringBuffer();
    // Add header
    buffer.writeln(
        'scholarship_name,sponsor,category,award_amount,deadline,difficulty,status,application_date,notes,match_percentage,requirements,eligibility');

    // Add data rows
    for (final scholarship in scholarships) {
      buffer.writeln([
        _escapeCSVField(scholarship['scholarship_name']?.toString() ?? ''),
        _escapeCSVField(scholarship['sponsor']?.toString() ?? ''),
        _escapeCSVField(scholarship['category']?.toString() ?? ''),
        _escapeCSVField(scholarship['award_amount']?.toString() ?? ''),
        _escapeCSVField(scholarship['deadline']?.toString() ?? ''),
        _escapeCSVField(scholarship['difficulty']?.toString() ?? ''),
        _escapeCSVField(scholarship['status']?.toString() ?? ''),
        _escapeCSVField(scholarship['application_date']?.toString() ?? ''),
        _escapeCSVField(scholarship['notes']?.toString() ?? ''),
        _escapeCSVField(scholarship['match_percentage']?.toString() ?? ''),
        _escapeCSVField(scholarship['requirements']?.toString() ?? ''),
        _escapeCSVField(scholarship['eligibility']?.toString() ?? ''),
      ].join(','));
    }

    return buffer.toString();
  }

  /// Generate JSON content from application progress
  String generateApplicationProgressJSON(Map<String, dynamic> progress) {
    return JsonEncoder.withIndent('  ').convert(progress);
  }

  /// Send CSV file via email
  Future<void> sendDataViaEmail({
    required String email,
    required String filename,
    required String csvContent,
    String? userFullName,
  }) async {
    try {
      final functionUrl = '$_supabaseUrl/functions/v1/send-data-export';

      final response = await _dio.post(
        functionUrl,
        data: {
          'email': email,
          'filename': filename,
          'csvContent': csvContent,
          'userFullName': userFullName,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send email: ${response.statusMessage}');
      }

      final responseData = response.data;
      if (responseData['success'] != true) {
        throw Exception(responseData['error'] ?? 'Email sending failed');
      }
    } catch (error) {
      throw Exception('Failed to send data via email: $error');
    }
  }

  /// Get current user information
  Future<Map<String, String?>> getCurrentUserInfo() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return {'email': null, 'full_name': null};
      }

      final userProfile = await _client
          .from('user_profiles')
          .select('email, full_name')
          .eq('id', userId)
          .single();

      return {
        'email': userProfile['email'],
        'full_name': userProfile['full_name'],
      };
    } catch (error) {
      // Fallback to auth user email if profile doesn't exist
      final authUser = _client.auth.currentUser;
      return {
        'email': authUser?.email,
        'full_name': authUser?.userMetadata?['full_name'],
      };
    }
  }

  /// Helper method to escape CSV fields
  String _escapeCSVField(String field) {
    if (field.isEmpty) return '';

    // If field contains comma, quote, or newline, wrap in quotes and escape internal quotes
    if (field.contains(',') ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
