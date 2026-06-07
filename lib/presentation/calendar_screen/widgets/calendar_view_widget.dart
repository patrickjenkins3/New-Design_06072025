import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';
import '../../../models/calendar_event_model.dart';

class CalendarViewWidget extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<CalendarEventModel> events;

  const CalendarViewWidget({
    Key? key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.events,
  }) : super(key: key);

  List<CalendarEventModel> _getEventsForDay(DateTime day) {
    return events.where((event) {
      return isSameDay(event.dueDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<CalendarEventModel>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        eventLoader: _getEventsForDay,
        onDaySelected: onDaySelected,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ) ??
              const TextStyle(),
          leftChevronIcon: CustomIconWidget(
            iconName: 'chevron_left',
            size: 24,
            color: AppTheme.primaryLight,
          ),
          rightChevronIcon: CustomIconWidget(
            iconName: 'chevron_right',
            size: 24,
            color: AppTheme.primaryLight,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryLight,
              ) ??
              const TextStyle(),
          weekendStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryLight,
              ) ??
              const TextStyle(),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimaryLight,
              ) ??
              const TextStyle(),
          holidayTextStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryLight,
              ) ??
              const TextStyle(),
          selectedDecoration: BoxDecoration(
            color: AppTheme.primaryLight,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppTheme.successLight,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          canMarkersOverflow: true,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            final dayEvents = events.cast<CalendarEventModel>();
            if (dayEvents.isEmpty) return const SizedBox.shrink();

            return Positioned(
              bottom: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: dayEvents.take(3).map((event) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: Color(int.parse(
                          '0xFF${event.eventTypeColor.substring(1)}')),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            final dayEvents = _getEventsForDay(day);
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (dayEvents.isNotEmpty)
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            final dayEvents = _getEventsForDay(day);
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryLight,
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (dayEvents.isNotEmpty)
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
