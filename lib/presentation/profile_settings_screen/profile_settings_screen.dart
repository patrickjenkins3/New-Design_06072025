import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/cf_bottom_nav.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});
  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await AuthService.instance.getUserProfile();
    if (mounted) setState(() { _profile = p; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = _profile?['full_name'] as String? ?? 'Alex Johnson';
    final email = AuthService.instance.currentUser?.email ?? 'alex@email.com';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.primaryBlack : AppTheme.grey50,
      body: SafeArea(
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(slivers: [
              SliverAppBar(
                title: const Text('Profile Settings'),
                floating: true,
                backgroundColor: isDark ? AppTheme.surfaceBlack : AppTheme.white,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
                  child: Divider(height: 1, color: isDark ? AppTheme.dividerBlack : AppTheme.grey100)),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  // Avatar
                  Center(child: Stack(children: [
                    CircleAvatar(radius: 40, backgroundColor: AppTheme.primaryBlack,
                      child: Text(name.isNotEmpty ? name[0] : 'A',
                        style: const TextStyle(fontSize: 32, color: AppTheme.white, fontWeight: FontWeight.w700))),
                    Positioned(right: 0, bottom: 0,
                      child: Container(width: 28, height: 28,
                        decoration: BoxDecoration(color: AppTheme.teal, shape: BoxShape.circle, border: Border.all(color: AppTheme.white, width: 2)),
                        child: const Icon(Icons.edit, size: 14, color: AppTheme.white))),
                  ])),
                  const SizedBox(height: 16),
                  Center(child: Text(name, style: Theme.of(context).textTheme.headlineSmall)),
                  const SizedBox(height: 4),
                  Center(child: Text(email, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grey500))),
                  const SizedBox(height: 28),

                  _SectionLabel('PROFILE'),
                  _SettingsTile(icon: Icons.person_outline, title: 'Personal Information', subtitle: 'Name, email, photo', onTap: () {}),
                  _SettingsTile(icon: Icons.school_outlined, title: 'Educational Information', subtitle: 'GPA, test scores, interests', onTap: () {}),

                  const SizedBox(height: 8),
                  _SectionLabel('PREFERENCES'),
                  _SettingsTile(icon: Icons.notifications_outlined, title: 'Notifications', subtitle: 'Manage your alerts', onTap: () {}),
                  _SettingsTile(icon: Icons.palette_outlined, title: 'Theme', subtitle: isDark ? 'Dark mode' : 'Light mode', onTap: () {}),

                  const SizedBox(height: 8),
                  _SectionLabel('SECURITY'),
                  _SettingsTile(icon: Icons.lock_outline, title: 'Security Settings', subtitle: 'Password, biometrics, sessions',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.settingsScreen)),

                  const SizedBox(height: 8),
                  _SectionLabel('SUPPORT'),
                  _SettingsTile(icon: Icons.help_outline, title: 'Help Center', subtitle: 'Get help from our team', onTap: () {}),
                  _SettingsTile(icon: Icons.info_outline, title: 'Contact Support', subtitle: 'Get help from our team', onTap: () {}),

                  const SizedBox(height: 20),
                  // Sign Out
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmSignOut(),
                      icon: const Icon(Icons.logout, color: AppTheme.errorRed, size: 18),
                      label: const Text('Sign Out', style: TextStyle(color: AppTheme.errorRed)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.errorRed),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(child: Text('CollegePath v1.0.0', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.grey300))),
                  const SizedBox(height: 80),
                ])),
              ),
            ]),
      ),
      bottomNavigationBar: CFBottomNav(currentIndex: 3, onTap: (i) {
        if (i == 0) Navigator.pushReplacementNamed(context, AppRoutes.dashboardScreen);
        else if (i == 1) Navigator.pushReplacementNamed(context, AppRoutes.calendarScreen);
        else if (i == 2) Navigator.pushReplacementNamed(context, AppRoutes.scholarshipFeedScreen);
      }),
    );
  }

  void _confirmSignOut() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(Icons.logout, size: 20), SizedBox(width: 8), Text('Sign Out'),
      ]),
      content: const Text('Are you sure you want to sign out of your account?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await AuthService.instance.signOut();
            if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
          child: const Text('Sign Out'),
        ),
      ],
    ));
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.grey500, letterSpacing: 1.2)),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(color: isDark ? AppTheme.cardBlack : AppTheme.white),
      child: ListTile(
        leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: isDark ? AppTheme.dividerBlack : AppTheme.grey100, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: isDark ? AppTheme.grey300 : AppTheme.grey700)),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grey500)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.grey300),
        onTap: onTap,
      ),
    );
  }
}
