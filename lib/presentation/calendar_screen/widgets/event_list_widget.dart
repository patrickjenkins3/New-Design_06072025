import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/calendar_event_model.dart';

class EventListWidget extends StatelessWidget {
  final List<CalendarEventModel> events;
  final Function(CalendarEventModel) onEventTap;
  final Function(CalendarEventModel) onEventComplete;
  final Function(CalendarEventModel) onEventReminder;
  final Function(CalendarEventModel) onEventEdit;
  final Function(CalendarEventModel) onEventDelete;

  const EventListWidget({
    Key? key,
    required this.events,
    required this.onEventTap,
    required this.onEventComplete,
    required this.onEventReminder,
    required this.onEventEdit,
    required this.onEventDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Container(
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'calendar_month',
              size: 64,
              color: AppTheme.textSecondaryLight,
            ),
            SizedBox(height: 3.h),
            Text(
              'No upcoming events',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your calendar is clear. Add some events to get started!',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          margin: EdgeInsets.only(bottom: 3.h),
          child: Dismissible(
            key: Key(event.id),
            background: Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.successLight,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Complete',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            secondaryBackground: Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Reminder',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: 'notifications',
                    size: 24,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                onEventComplete(event);
              } else {
                onEventReminder(event);
              }
            },
            child: InkWell(
              onTap: () => onEventTap(event),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: event.isOverdue && event.status != 'completed'
                        ? AppTheme.warningLight
                        : AppTheme.borderLight,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Color(int.parse(
                                    '0xFF${event.eventTypeColor.substring(1)}'))
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: event.eventTypeIcon,
                            size: 20,
                            color: Color(int.parse(
                                '0xFF${event.eventTypeColor.substring(1)}')),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimaryLight,
                                  decoration: event.status == 'completed'
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (event.schoolName != null) ...[
                                SizedBox(height: 0.5.h),
                                Text(
                                  event.schoolName!,
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (event.status == 'completed')
                              Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.successLight
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: CustomIconWidget(
                                  iconName: 'check_circle',
                                  size: 20,
                                  color: AppTheme.successLight,
                                ),
                              )
                            else if (event.isOverdue)
                              Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningLight
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: CustomIconWidget(
                                  iconName: 'warning',
                                  size: 20,
                                  color: AppTheme.warningLight,
                                ),
                              )
                            else
                              CustomIconWidget(
                                iconName: 'chevron_right',
                                size: 20,
                                color: AppTheme.textSecondaryLight,
                              ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'calendar_today',
                          size: 16,
                          color: AppTheme.textSecondaryLight,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          event.formattedDate,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                        if (!event.isAllDay && event.startTime != null) ...[
                          SizedBox(width: 4.w),
                          CustomIconWidget(
                            iconName: 'access_time',
                            size: 16,
                            color: AppTheme.textSecondaryLight,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            event.startTime!,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          event.timeUntilDue,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color:
                                event.isOverdue && event.status != 'completed'
                                    ? AppTheme.warningLight
                                    : AppTheme.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (event.description != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        event.description!,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(int.parse(
                                    '0xFF${event.priorityColor.substring(1)}'))
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.priority.toUpperCase(),
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: Color(int.parse(
                                  '0xFF${event.priorityColor.substring(1)}')),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme
                                .lightTheme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.assignmentDisplayName,
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(int.parse(
                                    '0xFF${event.eventTypeColor.substring(1)}'))
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.eventType.toUpperCase(),
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: Color(int.parse(
                                  '0xFF${event.eventTypeColor.substring(1)}')),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
