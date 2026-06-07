class CalendarEventModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String eventType;
  final String? schoolName;
  final String assignedTo;
  final String priority;
  final String status;
  final String? location;
  final String? notes;
  final bool isAllDay;
  final String? startTime;
  final String? endTime;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CalendarEventModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.eventType,
    this.schoolName,
    required this.assignedTo,
    required this.priority,
    required this.status,
    this.location,
    this.notes,
    required this.isAllDay,
    this.startTime,
    this.endTime,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to create CalendarEventModel from JSON
  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      eventType: json['event_type'] ?? 'deadline',
      schoolName: json['school_name'],
      assignedTo: json['assigned_to'] ?? 'teen',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      location: json['location'],
      notes: json['notes'],
      isAllDay: json['is_all_day'] ?? false,
      startTime: json['start_time'],
      endTime: json['end_time'],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  /// Convert CalendarEventModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'event_type': eventType,
      'school_name': schoolName,
      'assigned_to': assignedTo,
      'priority': priority,
      'status': status,
      'location': location,
      'notes': notes,
      'is_all_day': isAllDay,
      'start_time': startTime,
      'end_time': endTime,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of CalendarEventModel with some updated fields
  CalendarEventModel copyWith({
    String? id,
    String? userId,
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
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      eventType: eventType ?? this.eventType,
      schoolName: schoolName ?? this.schoolName,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isAllDay: isAllDay ?? this.isAllDay,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if the event is overdue
  bool get isOverdue {
    if (status == 'completed') return false;
    return dueDate.isBefore(DateTime.now());
  }

  /// Check if the event is today
  bool get isToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  /// Check if the event is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return dueDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        dueDate.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Get formatted date string
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${months[dueDate.month - 1]} ${dueDate.day}, ${dueDate.year}';
  }

  /// Get time until due date
  String get timeUntilDue {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      final overdue = now.difference(dueDate);
      if (overdue.inDays > 0) {
        return '${overdue.inDays} days overdue';
      } else if (overdue.inHours > 0) {
        return '${overdue.inHours} hours overdue';
      } else {
        return 'Overdue';
      }
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} days left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes left';
    } else {
      return 'Due now';
    }
  }

  /// Get priority color
  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return '#FF5252'; // Red
      case 'high':
        return '#FF9800'; // Orange
      case 'medium':
        return '#2196F3'; // Blue
      case 'low':
        return '#4CAF50'; // Green
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get event type icon
  String get eventTypeIcon {
    switch (eventType.toLowerCase()) {
      case 'application':
        return 'assignment';
      case 'scholarship':
        return 'monetization_on';
      case 'test':
        return 'quiz';
      case 'visit':
        return 'location_on';
      case 'deadline':
        return 'schedule';
      case 'meeting':
        return 'group';
      default:
        return 'event';
    }
  }

  /// Get event type color
  String get eventTypeColor {
    switch (eventType.toLowerCase()) {
      case 'application':
        return '#FF9800'; // Orange
      case 'scholarship':
        return '#4CAF50'; // Green
      case 'test':
        return '#2196F3'; // Blue
      case 'visit':
        return '#9C27B0'; // Purple
      case 'deadline':
        return '#FF5722'; // Deep Orange
      case 'meeting':
        return '#607D8B'; // Blue Grey
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get assignment target display name
  String get assignmentDisplayName {
    switch (assignedTo.toLowerCase()) {
      case 'teen':
        return 'Student';
      case 'parent':
        return 'Parent';
      case 'both':
        return 'Family';
      case 'family':
        return 'Family';
      default:
        return assignedTo;
    }
  }

  @override
  String toString() {
    return 'CalendarEventModel(id: $id, title: $title, dueDate: $dueDate, eventType: $eventType, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CalendarEventModel &&
        other.id == id &&
        other.title == title &&
        other.dueDate == dueDate &&
        other.eventType == eventType &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        dueDate.hashCode ^
        eventType.hashCode ^
        status.hashCode;
  }
}
