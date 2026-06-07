import 'package:supabase_flutter/supabase_flutter.dart';

class ScholarshipService {
  static const String _scholarshipsTable = 'scholarships';
  static const String _applicationsTable = 'scholarship_applications';
  static const String _bookmarksTable = 'scholarship_bookmarks';

  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all active scholarships with user's application and bookmark status
  Future<List<Map<String, dynamic>>> getScholarships() async {
    try {
      final user = _supabase.auth.currentUser;

      // Get scholarships
      final scholarshipsResponse = await _supabase
          .from(_scholarshipsTable)
          .select('*')
          .eq('status', 'active')
          .order('deadline', ascending: true);

      final scholarships = scholarshipsResponse as List<dynamic>;

      if (user != null) {
        // Get user's applications
        final applicationsResponse = await _supabase
            .from(_applicationsTable)
            .select('scholarship_id, status')
            .eq('user_id', user.id);

        final applications = applicationsResponse as List<dynamic>;

        // Get user's bookmarks
        final bookmarksResponse = await _supabase
            .from(_bookmarksTable)
            .select('scholarship_id')
            .eq('user_id', user.id);

        final bookmarks = bookmarksResponse as List<dynamic>;

        // Create lookup maps
        final applicationMap = <String, String>{};
        for (final app in applications) {
          applicationMap[app['scholarship_id']] = app['status'];
        }

        final bookmarkSet = bookmarks.map((b) => b['scholarship_id']).toSet();

        // Merge data
        for (var scholarship in scholarships) {
          final id = scholarship['id'];
          scholarship['application_status'] =
              applicationMap[id] ?? 'not_applied';
          scholarship['isBookmarked'] = bookmarkSet.contains(id);
        }
      } else {
        // For non-authenticated users, set defaults
        for (var scholarship in scholarships) {
          scholarship['application_status'] = 'not_applied';
          scholarship['isBookmarked'] = false;
        }
      }

      return scholarships.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching scholarships: $e');
      return [];
    }
  }

  // Mark scholarship as applied
  Future<bool> markAsApplied(String scholarshipId, {String? notes}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Check if application already exists
      final existingResponse =
          await _supabase
              .from(_applicationsTable)
              .select('id')
              .eq('user_id', user.id)
              .eq('scholarship_id', scholarshipId)
              .maybeSingle();

      if (existingResponse != null) {
        // Update existing application
        await _supabase
            .from(_applicationsTable)
            .update({
              'status': 'applied',
              'notes': notes,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingResponse['id']);
      } else {
        // Insert new application
        await _supabase.from(_applicationsTable).insert({
          'user_id': user.id,
          'scholarship_id': scholarshipId,
          'status': 'applied',
          'notes': notes,
        });
      }

      return true;
    } catch (e) {
      print('Error marking scholarship as applied: $e');
      return false;
    }
  }

  // Toggle bookmark status
  Future<bool> toggleBookmark(String scholarshipId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Check if bookmark exists
      final existingResponse =
          await _supabase
              .from(_bookmarksTable)
              .select('id')
              .eq('user_id', user.id)
              .eq('scholarship_id', scholarshipId)
              .maybeSingle();

      if (existingResponse != null) {
        // Remove bookmark
        await _supabase
            .from(_bookmarksTable)
            .delete()
            .eq('id', existingResponse['id']);
        return false; // Not bookmarked anymore
      } else {
        // Add bookmark
        await _supabase.from(_bookmarksTable).insert({
          'user_id': user.id,
          'scholarship_id': scholarshipId,
        });
        return true; // Now bookmarked
      }
    } catch (e) {
      print('Error toggling scholarship bookmark: $e');
      return false;
    }
  }

  // Get user's scholarship applications
  Future<List<Map<String, dynamic>>> getUserApplications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from(_applicationsTable)
          .select('''
            *,
            scholarships!inner(
              title,
              sponsor,
              award_display,
              deadline,
              application_url
            )
          ''')
          .eq('user_id', user.id)
          .order('applied_at', ascending: false);

      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching user applications: $e');
      return [];
    }
  }

  // Get user's bookmarked scholarships
  Future<List<Map<String, dynamic>>> getUserBookmarks() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from(_bookmarksTable)
          .select('''
            *,
            scholarships!inner(*)
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching user bookmarks: $e');
      return [];
    }
  }

  // Search scholarships
  Future<List<Map<String, dynamic>>> searchScholarships(
    String query, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      var queryBuilder = _supabase
          .from(_scholarshipsTable)
          .select('*')
          .eq('status', 'active');

      // Add text search
      if (query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'title.ilike.%$query%,'
          'sponsor.ilike.%$query%,'
          'description.ilike.%$query%,'
          'category.ilike.%$query%',
        );
      }

      // Apply filters
      if (filters != null) {
        if (filters['category'] != null) {
          queryBuilder = queryBuilder.eq('category', filters['category']);
        }
        if (filters['difficulty'] != null) {
          queryBuilder = queryBuilder.eq('difficulty', filters['difficulty']);
        }
        if (filters['minAward'] != null) {
          queryBuilder = queryBuilder.gte(
            'award_range_min',
            filters['minAward'],
          );
        }
        if (filters['maxAward'] != null) {
          queryBuilder = queryBuilder.lte(
            'award_range_max',
            filters['maxAward'],
          );
        }
      }

      final response = await queryBuilder.order('deadline', ascending: true);
      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error searching scholarships: $e');
      return [];
    }
  }
}
