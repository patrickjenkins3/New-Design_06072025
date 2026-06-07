import './supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarService {
  static final SupabaseClient _client = SupabaseService.instance.client;

  /// Fetches all calendar events (tasks) for the current user
  static Future<List<Map<String, dynamic>>> getCalendarEvents() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('tasks')
          .select('*')
          .eq('user_id', userId)
          .order('due_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch calendar events: $error');
    }
  }

  /// Fetches events for a specific date
  static Future<List<Map<String, dynamic>>> getEventsForDate(
      DateTime date) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final response = await _client
          .from('tasks')
          .select('*')
          .eq('user_id', userId)
          .gte('due_date', startOfDay.toIso8601String())
          .lte('due_date', endOfDay.toIso8601String())
          .order('due_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch events for date: $error');
    }
  }

  /// Fetches upcoming events (next 30 days)
  static Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final thirtyDaysLater = now.add(const Duration(days: 30));

      final response = await _client
          .from('tasks')
          .select('*')
          .eq('user_id', userId)
          .gte('due_date', now.toIso8601String())
          .lte('due_date', thirtyDaysLater.toIso8601String())
          .order('due_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch upcoming events: $error');
    }
  }

  /// Creates a new calendar event
  static Future<Map<String, dynamic>> createEvent({
    required String title,
    String? description,
    required DateTime dueDate,
    String? eventType,
    String? schoolName,
    String? assignedTo,
    String? priority,
    String? location,
    String? notes,
    bool isAllDay = false,
    String? startTime,
    String? endTime,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final eventData = {
        'user_id': userId,
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'event_type': eventType ?? 'deadline',
        'school_name': schoolName,
        'assigned_to': assignedTo ?? 'teen',
        'priority': priority ?? 'medium',
        'status': 'pending',
        'location': location,
        'notes': notes,
        'is_all_day': isAllDay,
        'start_time': startTime,
        'end_time': endTime,
      };

      final response =
          await _client.from('tasks').insert(eventData).select().single();

      return response;
    } catch (error) {
      throw Exception('Failed to create event: $error');
    }
  }

  /// Updates an existing calendar event
  static Future<Map<String, dynamic>> updateEvent({
    required String eventId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? eventType,
    String? schoolName,
    String? assignedTo,
    String? priority,
    String? status,
    String? location,
    String? notes,
    bool? isAllDay,
    String? startTime,
    String? endTime,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (dueDate != null) updateData['due_date'] = dueDate.toIso8601String();
      if (eventType != null) updateData['event_type'] = eventType;
      if (schoolName != null) updateData['school_name'] = schoolName;
      if (assignedTo != null) updateData['assigned_to'] = assignedTo;
      if (priority != null) updateData['priority'] = priority;
      if (status != null) updateData['status'] = status;
      if (location != null) updateData['location'] = location;
      if (notes != null) updateData['notes'] = notes;
      if (isAllDay != null) updateData['is_all_day'] = isAllDay;
      if (startTime != null) updateData['start_time'] = startTime;
      if (endTime != null) updateData['end_time'] = endTime;

      // Add updated timestamp
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('tasks')
          .update(updateData)
          .eq('id', eventId)
          .eq('user_id', userId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update event: $error');
    }
  }

  /// Marks an event as completed
  static Future<Map<String, dynamic>> completeEvent(String eventId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('tasks')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', eventId)
          .eq('user_id', userId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to complete event: $error');
    }
  }

  /// Deletes a calendar event
  static Future<void> deleteEvent(String eventId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from('tasks')
          .delete()
          .eq('id', eventId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Failed to delete event: $error');
    }
  }

  /// Filters events by type
  static Future<List<Map<String, dynamic>>> getEventsByType(
      String eventType) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('tasks')
          .select('*')
          .eq('user_id', userId)
          .eq('event_type', eventType)
          .order('due_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch events by type: $error');
    }
  }

  /// Filters events by assignment target
  static Future<List<Map<String, dynamic>>> getEventsByAssignment(
      String assignedTo) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('tasks')
          .select('*')
          .eq('user_id', userId)
          .eq('assigned_to', assignedTo)
          .order('due_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch events by assignment: $error');
    }
  }

  /// Gets event statistics
  static Future<Map<String, dynamic>> getEventStats() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get total events count
      final totalResponse = await _client
          .from('tasks')
          .select('id')
          .eq('user_id', userId)
          .count();

      // Get completed events count
      final completedResponse = await _client
          .from('tasks')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .count();

      // Get pending events count
      final pendingResponse = await _client
          .from('tasks')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'pending')
          .count();

      // Get overdue events count
      final overdueResponse = await _client
          .from('tasks')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'pending')
          .lt('due_date', DateTime.now().toIso8601String())
          .count();

      final totalCount = totalResponse.count ?? 0;
      final completedCount = completedResponse.count ?? 0;
      final pendingCount = pendingResponse.count ?? 0;
      final overdueCount = overdueResponse.count ?? 0;

      return {
        'total': totalCount,
        'completed': completedCount,
        'pending': pendingCount,
        'overdue': overdueCount,
        'completion_rate': totalCount > 0
            ? double.parse(
                ((completedCount / totalCount) * 100).toStringAsFixed(2))
            : 0.0,
      };
    } catch (error) {
      throw Exception('Failed to fetch event statistics: $error');
    }
  }

  /// Subscribe to real-time calendar events changes
  static RealtimeChannel subscribeToCalendarChanges({
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) {
    return _client
        .channel('calendar_events')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          callback: (payload) {
            switch (payload.eventType) {
              case PostgresChangeEvent.insert:
                onInsert(payload.newRecord);
                break;
              case PostgresChangeEvent.update:
                onUpdate(payload.newRecord);
                break;
              case PostgresChangeEvent.delete:
                onDelete(payload.oldRecord);
                break;
              case PostgresChangeEvent.all:
                // Handle all events case - this shouldn't typically occur in practice
                // but is needed for exhaustive matching
                break;
            }
          },
        )
        .subscribe();
  }
}
