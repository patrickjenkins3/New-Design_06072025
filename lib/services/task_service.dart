import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class TaskService {
  final SupabaseClient _client;

  TaskService() : _client = Supabase.instance.client;

  /// Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Get all tasks for the current user
  Future<List<Task>> getAllTasks({String? status}) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      var query = _client.from('tasks').select().eq('user_id', currentUserId!);

      // Apply status filter if provided
      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);

      return response.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch tasks: $error');
    }
  }

  /// Get tasks by priority
  Future<List<Task>> getTasksByPriority(String priority) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', currentUserId!)
          .eq('priority', priority)
          .order('due_date', ascending: true);

      return response.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch tasks by priority: $error');
    }
  }

  /// Get upcoming tasks (due in next 7 days)
  Future<List<Task>> getUpcomingTasks() async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final nextWeek = DateTime.now().add(const Duration(days: 7));

      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', currentUserId!)
          .neq('status', 'completed')
          .lte('due_date', nextWeek.toIso8601String())
          .order('due_date', ascending: true);

      return response.map<Task>((json) => Task.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch upcoming tasks: $error');
    }
  }

  /// Create a new task
  Future<Task> createTask({
    required String title,
    String? description,
    String status = 'pending',
    String priority = 'medium',
    DateTime? dueDate,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final taskData = {
        'user_id': currentUserId!,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
        'due_date': dueDate?.toIso8601String(),
      };

      final response =
          await _client.from('tasks').insert(taskData).select().single();

      return Task.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create task: $error');
    }
  }

  /// Update a task
  Future<Task> updateTask(
    String taskId, {
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (status != null) {
        updateData['status'] = status;
        if (status == 'completed') {
          updateData['completed_at'] = DateTime.now().toIso8601String();
        }
      }
      if (priority != null) updateData['priority'] = priority;
      if (dueDate != null) updateData['due_date'] = dueDate.toIso8601String();

      final response =
          await _client
              .from('tasks')
              .update(updateData)
              .eq('id', taskId)
              .eq(
                'user_id',
                currentUserId!,
              ) // Ensure user can only update their own tasks
              .select()
              .single();

      return Task.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update task: $error');
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      await _client
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq(
            'user_id',
            currentUserId!,
          ); // Ensure user can only delete their own tasks
    } catch (error) {
      throw Exception('Failed to delete task: $error');
    }
  }

  /// Get task statistics for the current user
  Future<Map<String, int>> getTaskStatistics() async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final allTasks = await getAllTasks();

      return {
        'total': allTasks.length,
        'pending': allTasks.where((t) => t.status == 'pending').length,
        'in_progress': allTasks.where((t) => t.status == 'in_progress').length,
        'completed': allTasks.where((t) => t.status == 'completed').length,
        'cancelled': allTasks.where((t) => t.status == 'cancelled').length,
        'high_priority': allTasks.where((t) => t.priority == 'high').length,
        'urgent': allTasks.where((t) => t.priority == 'urgent').length,
      };
    } catch (error) {
      throw Exception('Failed to get task statistics: $error');
    }
  }

  /// Mark task as completed
  Future<Task> completeTask(String taskId) async {
    return updateTask(taskId, status: 'completed');
  }

  /// Toggle task status between pending and completed
  Future<Task> toggleTaskStatus(String taskId, String currentStatus) async {
    final newStatus = currentStatus == 'completed' ? 'pending' : 'completed';
    return updateTask(taskId, status: newStatus);
  }
}
