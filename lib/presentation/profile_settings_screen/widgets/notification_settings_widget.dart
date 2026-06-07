import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './settings_tile_widget.dart';

class NotificationSettingsWidget extends StatefulWidget {
  final Map<String, bool> notificationSettings;
  final Function(String, bool) onSettingChanged;

  const NotificationSettingsWidget({
    Key? key,
    required this.notificationSettings,
    required this.onSettingChanged,
  }) : super(key: key);

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  final List<Map<String, dynamic>> notificationTypes = [
    {
      'key': 'deadlines',
      'title': 'Deadline Alerts',
      'subtitle': 'Application and scholarship deadlines',
      'icon': 'schedule',
    },
    {
      'key': 'scholarships',
      'title': 'Scholarship Matches',
      'subtitle': 'New scholarships matching your profile',
      'icon': 'school',
    },
    {
      'key': 'applications',
      'title': 'Application Reminders',
      'subtitle': 'Reminders for incomplete applications',
      'icon': 'assignment',
    },
    {
      'key': 'family',
      'title': 'Family Activity',
      'subtitle': 'Updates from family members',
      'icon': 'family_restroom',
    },
    {
      'key': 'news',
      'title': 'School News',
      'subtitle': 'News from your saved schools',
      'icon': 'newspaper',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: notificationTypes.map((notification) {
        final key = notification['key'] as String;
        final isEnabled = widget.notificationSettings[key] ?? true;

        return SettingsTileWidget(
          title: notification['title'] as String,
          subtitle: notification['subtitle'] as String,
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: notification['icon'] as String,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          trailing: Switch(
            value: isEnabled,
            onChanged: (value) => widget.onSettingChanged(key, value),
            activeColor: AppTheme.lightTheme.colorScheme.primary,
          ),
          showDisclosure: false,
        );
      }).toList(),
    );
  }
}
