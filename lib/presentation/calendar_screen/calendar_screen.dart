import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_export.dart';
import '../../models/calendar_event_model.dart';
import '../../services/calendar_service.dart';
import './widgets/add_event_dialog.dart';
import './widgets/calendar_view_widget.dart';
import './widgets/day_events_widget.dart';
import './widgets/event_list_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _isCalendarView = true;
  bool _isLoading = false;

  List<CalendarEventModel> _events = [];
  List<CalendarEventModel> _selectedDayEvents = [];
  List<CalendarEventModel> _upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isCalendarView = _tabController.index == 0;
      });
    });
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load all events from database
  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final eventsData = await CalendarService.getCalendarEvents();
      final events =
          eventsData.map((data) => CalendarEventModel.fromJson(data)).toList();

      setState(() {
        _events = events;
        _selectedDayEvents = _getEventsForDay(_selectedDay);
        _upcomingEvents = _getAllUpcomingEvents();
      });
    } catch (error) {
      _showErrorSnackBar('Failed to load events: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get events for a specific day
  List<CalendarEventModel> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      return isSameDay(event.dueDate, day);
    }).toList();
  }

  /// Get all upcoming events
  List<CalendarEventModel> _getAllUpcomingEvents() {
    final now = DateTime.now();
    return _events
        .where((event) =>
            event.dueDate.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Handle day selection
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedDayEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  /// Add new event
  Future<void> _addEvent(Map<String, dynamic> eventData) async {
    try {
      await CalendarService.createEvent(
        title: eventData['title'],
        description: eventData['description'],
        dueDate: eventData['date'],
        eventType: eventData['type'],
        schoolName: eventData['school'],
        assignedTo: eventData['assignedTo'],
        priority: eventData['priority'],
        location: eventData['location'],
        notes: eventData['notes'],
        isAllDay: eventData['isAllDay'] ?? true,
      );

      _showSuccessSnackBar('Event "${eventData['title']}" added successfully');
      _loadEvents(); // Refresh events
    } catch (error) {
      _showErrorSnackBar('Failed to add event: $error');
    }
  }

  /// Show add event dialog
  void _showAddEventDialog({DateTime? selectedDate}) {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        selectedDate: selectedDate ?? _selectedDay,
        onEventAdded: _addEvent,
      ),
    );
  }

  /// Handle event tap
  void _onEventTap(CalendarEventModel event) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: 70.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Color(int.parse(
                                    '0xFF${event.eventTypeColor.substring(1)}'))
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomIconWidget(
                            iconName: event.eventTypeIcon,
                            size: 24,
                            color: Color(int.parse(
                                '0xFF${event.eventTypeColor.substring(1)}')),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (event.schoolName != null) ...[
                                SizedBox(height: 0.5.h),
                                Text(
                                  event.schoolName!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    if (event.description != null) ...[
                      Text(
                        'Description',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        event.description!,
                        style: theme.textTheme.bodyMedium,
                      ),
                      SizedBox(height: 3.h),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            'Date',
                            event.formattedDate,
                            'calendar_today',
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: _buildDetailItem(
                            'Priority',
                            event.priority.toUpperCase(),
                            'flag',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            'Assigned To',
                            event.assignmentDisplayName,
                            'person',
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: _buildDetailItem(
                            'Status',
                            event.status.toUpperCase(),
                            'info',
                          ),
                        ),
                      ],
                    ),
                    if (event.location != null) ...[
                      SizedBox(height: 2.h),
                      _buildDetailItem(
                        'Location',
                        event.location!,
                        'location_on',
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _onEventEdit(event);
                            },
                            icon: CustomIconWidget(
                              iconName: 'edit',
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            label: const Text('Edit'),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _onEventComplete(event);
                            },
                            icon: CustomIconWidget(
                              iconName: 'check',
                              size: 18,
                              color: theme.colorScheme.onPrimary,
                            ),
                            label: const Text('Complete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build detail item widget
  Widget _buildDetailItem(String label, String value, String iconName) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Complete event
  Future<void> _onEventComplete(CalendarEventModel event) async {
    try {
      await CalendarService.completeEvent(event.id);
      _showSuccessSnackBar('Event "${event.title}" marked as complete');
      _loadEvents(); // Refresh events
    } catch (error) {
      _showErrorSnackBar('Failed to complete event: $error');
    }
  }

  /// Set reminder for event
  void _onEventReminder(CalendarEventModel event) {
    _showInfoSnackBar('Reminder set for "${event.title}"');
  }

  /// Edit event
  void _onEventEdit(CalendarEventModel event) {
    _showInfoSnackBar('Edit functionality for "${event.title}" coming soon');
  }

  /// Delete event
  void _onEventDelete(CalendarEventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await CalendarService.deleteEvent(event.id);
                _showSuccessSnackBar('Event "${event.title}" deleted');
                _loadEvents(); // Refresh events
              } catch (error) {
                _showErrorSnackBar('Failed to delete event: $error');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Refresh events
  Future<void> _refreshEvents() async {
    await _loadEvents();
    _showSuccessSnackBar('Events refreshed');
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.brightness == Brightness.light
            ? AppTheme.successLight
            : AppTheme.successDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.brightness == Brightness.light
            ? AppTheme.warningLight
            : AppTheme.warningDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show info snackbar
  void _showInfoSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.brightness == Brightness.light
            ? AppTheme.accentLight
            : AppTheme.accentDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Educational Calendar'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshEvents,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'refresh',
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/profile-settings-screen'),
            icon: CustomIconWidget(
              iconName: 'settings',
              size: 24,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'calendar_month',
                size: 20,
                color: _isCalendarView
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              text: 'Calendar',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'list',
                size: 20,
                color: !_isCalendarView
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              text: 'List View',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEvents,
        color: theme.colorScheme.primary,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Calendar View
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  CalendarViewWidget(
                    selectedDay: _selectedDay,
                    focusedDay: _focusedDay,
                    onDaySelected: _onDaySelected,
                    events: _events,
                  ),
                  DayEventsWidget(
                    selectedDay: _selectedDay,
                    events: _selectedDayEvents,
                    onEventTap: _onEventTap,
                    onAddEvent: () =>
                        _showAddEventDialog(selectedDate: _selectedDay),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            // List View
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          size: 20,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'Swipe right to complete, left for reminders',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  EventListWidget(
                    events: _upcomingEvents,
                    onEventTap: _onEventTap,
                    onEventComplete: _onEventComplete,
                    onEventReminder: _onEventReminder,
                    onEventEdit: _onEventEdit,
                    onEventDelete: _onEventDelete,
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        child: CustomIconWidget(
            iconName: 'add',
            size: 24,
            color: theme.floatingActionButtonTheme.foregroundColor ??
                Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Calendar tab index
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              size: 24,
              color: theme.bottomNavigationBarTheme.unselectedItemColor,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'search',
              size: 24,
              color: theme.bottomNavigationBarTheme.unselectedItemColor,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'monetization_on',
              size: 24,
              color: theme.bottomNavigationBarTheme.unselectedItemColor,
            ),
            label: 'Scholarships',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'calendar_month',
              size: 24,
              color: theme.bottomNavigationBarTheme.selectedItemColor,
            ),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              size: 24,
              color: theme.bottomNavigationBarTheme.unselectedItemColor,
            ),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/dashboard-screen');
              break;
            case 1:
              Navigator.pushNamed(context, '/school-search-screen');
              break;
            case 2:
              Navigator.pushNamed(context, '/scholarship-feed-screen');
              break;
            case 3:
              // Current screen
              break;
            case 4:
              Navigator.pushNamed(context, '/profile-settings-screen');
              break;
          }
        },
      ),
    );
  }
}
