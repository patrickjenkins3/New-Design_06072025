import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Get dashboard statistics from live data
  Future<Map<String, dynamic>> getDashboardStats() async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      // Get schools count (this would be from a saved schools list table if it exists)
      // For now, return 0 as we don't have schools saved by users yet
      final schoolsCount = 0;

      // Get scholarships count from live data
      final scholarshipsResponse = await _client
          .from('scholarships')
          .select('id')
          .eq('status', 'active')
          .count();

      // Get tasks count
      final tasksResponse = await _client
          .from('tasks')
          .select('id')
          .eq('user_id', currentUserId!)
          .count();

      // Get applications count
      final applicationsResponse = await _client
          .from('scholarship_applications')
          .select('id')
          .eq('user_id', currentUserId!)
          .count();

      return {
        'schools': schoolsCount,
        'scholarships': scholarshipsResponse.count ?? 0,
        'tasks': tasksResponse.count ?? 0,
        'applications': applicationsResponse.count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch dashboard stats: $error');
    }
  }

  /// Get upcoming deadlines from live data
  Future<List<Map<String, dynamic>>> getUpcomingDeadlines() async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));

      final response = await _client
          .from('tasks')
          .select('*')
          .eq('user_id', currentUserId!)
          .neq('status', 'completed')
          .gte('due_date', now.toIso8601String())
          .lte('due_date', thirtyDaysFromNow.toIso8601String())
          .order('due_date', ascending: true)
          .limit(5);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch upcoming deadlines: $error');
    }
  }

  /// Get recent activity from live data
  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      // Get recent scholarship applications
      final applicationsResponse = await _client
          .from('scholarship_applications')
          .select('''
            *,
            scholarships!inner(title, sponsor)
          ''')
          .eq('user_id', currentUserId!)
          .order('created_at', ascending: false)
          .limit(3);

      // Get recent tasks
      final tasksResponse = await _client
          .from('tasks')
          .select('*')
          .eq('user_id', currentUserId!)
          .order('created_at', ascending: false)
          .limit(3);

      List<Map<String, dynamic>> activities = [];

      // Add scholarship applications to activities
      for (final app in applicationsResponse) {
        activities.add({
          'id': app['id'],
          'title': 'Applied to ${app['scholarships']['title']}',
          'description': 'Scholarship from ${app['scholarships']['sponsor']}',
          'timestamp': app['applied_at'] ?? app['created_at'],
          'type': 'scholarship_application',
          'userType': 'teen',
        });
      }

      // Add tasks to activities
      for (final task in tasksResponse) {
        activities.add({
          'id': task['id'],
          'title': task['status'] == 'completed'
              ? 'Completed: ${task['title']}'
              : 'Created: ${task['title']}',
          'description': task['description'] ?? 'Task ${task['status']}',
          'timestamp': task['status'] == 'completed'
              ? task['completed_at'] ?? task['updated_at']
              : task['created_at'],
          'type':
              task['status'] == 'completed' ? 'task_completed' : 'task_created',
          'userType': task['assigned_to'] == 'parent' ? 'parent' : 'teen',
        });
      }

      // Sort by timestamp descending and take top 5
      activities.sort((a, b) {
        final aTime = DateTime.parse(a['timestamp']);
        final bTime = DateTime.parse(b['timestamp']);
        return bTime.compareTo(aTime);
      });

      return activities.take(5).toList();
    } catch (error) {
      throw Exception('Failed to fetch recent activity: $error');
    }
  }

  /// Get user profile information
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated) {
      return null;
    }

    try {
      final response = await _client
          .from('user_profiles')
          .select('*')
          .eq('id', currentUserId!)
          .maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }
}
