import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme_notifier.dart';
import '../../core/utils/responsive_utils.dart';
import '../../routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final ThemeNotifier _themeNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ThemeNotifier();
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.settings,
          style: TextStyle(
            fontSize: context.responsiveFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.maxContentWidth,
          ),
          child: Padding(
            padding: context.responsivePadding(),
            child: Column(
              children: [
                _buildThemeSection(),
                SizedBox(height: 3.h),
                _buildAccountSection(),
                SizedBox(height: 3.h),
                _buildNotificationSection(),
                SizedBox(height: 3.h),
                _buildSupportSection(),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, themeMode, child) {
        return _buildSettingsSection(
          title: AppStrings.themeSettings,
          icon: Icons.palette_outlined,
          children: [
            _buildThemeOption(
              title: AppStrings.lightTheme,
              subtitle: 'Clean and bright interface',
              value: ThemeMode.light,
              groupValue: themeMode,
              onChanged: _themeNotifier.setTheme,
            ),
            _buildThemeOption(
              title: AppStrings.darkTheme,
              subtitle: 'Easy on the eyes in low light',
              value: ThemeMode.dark,
              groupValue: themeMode,
              onChanged: _themeNotifier.setTheme,
            ),
            _buildThemeOption(
              title: AppStrings.systemTheme,
              subtitle: 'Follows your device settings',
              value: ThemeMode.system,
              groupValue: themeMode,
              onChanged: _themeNotifier.setTheme,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountSection() {
    return _buildSettingsSection(
      title: AppStrings.accountSettings,
      icon: Icons.person_outline,
      children: [
        _buildSettingsTile(
          title: AppStrings.editProfile,
          subtitle: 'Update your personal information',
          icon: Icons.edit_outlined,
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.profileSettingsScreen),
        ),
        _buildSettingsTile(
          title: AppStrings.changePassword,
          subtitle: 'Update your account password',
          icon: Icons.lock_outline,
          onTap: () {
            // Navigate to change password
          },
        ),
        _buildSettingsTile(
          title: AppStrings.privacySettings,
          subtitle: 'Manage your privacy preferences',
          icon: Icons.privacy_tip_outlined,
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.aboutUsScreen),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSettingsSection(
      title: AppStrings.notificationSettings,
      icon: Icons.notifications_outlined,
      children: [
        _buildSettingsTile(
          title: 'Push Notifications',
          subtitle: 'Receive notifications on your device',
          icon: Icons.phone_android,
          trailing: Switch(
            value: true,
            onChanged: (value) {
              // Handle notification toggle
            },
          ),
        ),
        _buildSettingsTile(
          title: 'Email Notifications',
          subtitle: 'Receive updates via email',
          icon: Icons.email_outlined,
          trailing: Switch(
            value: false,
            onChanged: (value) {
              // Handle email toggle
            },
          ),
        ),
        _buildSettingsTile(
          title: 'Deadline Reminders',
          subtitle: 'Get notified about upcoming deadlines',
          icon: Icons.schedule,
          trailing: Switch(
            value: true,
            onChanged: (value) {
              // Handle deadline reminders toggle
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSettingsSection(
      title: AppStrings.help,
      icon: Icons.help_outline,
      children: [
        _buildSettingsTile(
          title: AppStrings.contactSupport,
          subtitle: 'Get help from our support team',
          icon: Icons.support_agent,
          onTap: () => Navigator.pushNamed(context, AppRoutes.aboutUsScreen),
        ),
        _buildSettingsTile(
          title: AppStrings.faq,
          subtitle: 'Find answers to common questions',
          icon: Icons.quiz_outlined,
          onTap: () {
            // Navigate to FAQ
          },
        ),
        _buildSettingsTile(
          title: AppStrings.about,
          subtitle: 'Learn more about ${AppStrings.appName}',
          icon: Icons.info_outline,
          onTap: () => Navigator.pushNamed(context, AppRoutes.aboutUsScreen),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: context.responsivePadding(),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: context.iconSize(baseSize: 24),
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 3.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(18),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: context.iconSize(baseSize: 24),
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: context.responsiveFontSize(16),
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: context.responsiveFontSize(14),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  size: context.iconSize(baseSize: 24),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : null),
      onTap: onTap,
      contentPadding: context.responsivePadding(),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required ThemeMode value,
    required ThemeMode groupValue,
    required Function(ThemeMode) onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(
        title,
        style: TextStyle(
          fontSize: context.responsiveFontSize(16),
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: context.responsiveFontSize(14),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: (ThemeMode? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      contentPadding: context.responsivePadding(),
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}