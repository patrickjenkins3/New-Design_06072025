import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActivityItemWidget extends StatelessWidget {
  final String title;
  final String description;
  final String timestamp;
  final String userType;
  final String actionType;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ActivityItemWidget({
    super.key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.userType,
    required this.actionType,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _getActionColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: _getActionIcon(),
                color: _getActionColor(),
                size: 4.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: userType == 'parent'
                              ? AppTheme.lightTheme.primaryColor
                                  .withValues(alpha: 0.1)
                              : const Color(0xFF4A90A4).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          userType == 'parent' ? 'Parent' : 'Student',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: userType == 'parent'
                                ? AppTheme.lightTheme.primaryColor
                                : const Color(0xFF4A90A4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    timestamp,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor() {
    switch (actionType.toLowerCase()) {
      case 'school_added':
        return const Color(0xFF2A9D8F);
      case 'scholarship_saved':
        return const Color(0xFFF4A261);
      case 'deadline_set':
        return const Color(0xFFE76F51);
      case 'application_started':
        return AppTheme.lightTheme.primaryColor;
      default:
        return const Color(0xFF4A90A4);
    }
  }

  String _getActionIcon() {
    switch (actionType.toLowerCase()) {
      case 'school_added':
        return 'school';
      case 'scholarship_saved':
        return 'monetization_on';
      case 'deadline_set':
        return 'schedule';
      case 'application_started':
        return 'description';
      default:
        return 'info';
    }
  }
}
