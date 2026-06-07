import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InfoCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String iconName;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const InfoCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconName,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use white text when backgroundColor is provided for better contrast
    final bool useWhiteText = backgroundColor != null;
    final Color textColor =
        useWhiteText ? Colors.white : AppTheme.lightTheme.primaryColor;
    final Color titleColor =
        useWhiteText ? Colors.white : AppTheme.lightTheme.colorScheme.onSurface;
    final Color subtitleColor =
        useWhiteText
            ? Colors.white.withAlpha(204)
            : AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    final Color iconColor =
        useWhiteText ? Colors.white : AppTheme.lightTheme.primaryColor;
    final Color chevronColor =
        useWhiteText
            ? Colors.white.withAlpha(204)
            : AppTheme.lightTheme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow.withValues(
                alpha: 0.08,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color:
                        useWhiteText
                            ? Colors.white.withAlpha(51)
                            : AppTheme.lightTheme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: iconName,
                    color: iconColor,
                    size: 5.w,
                  ),
                ),
                if (onTap != null)
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: chevronColor,
                    size: 4.w,
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: subtitleColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
