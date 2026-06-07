import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/cf_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;
  String _userName = 'Alex';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final profile = await AuthService.instance.getUserProfile();
    if (mounted && profile != null) {
      setState(() => _userName = (profile['full_name'] as String? ?? 'Alex').split(' ').first);
    }
  }

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    switch (i) {
      case 0: setState(() => _navIndex = 0); break;
      case 1: Navigator.pushNamed(context, AppRoutes.calendarScreen); break;
      case 2: Navigator.pushNamed(context, AppRoutes.scholarshipFeedScreen); break;
      case 3: Navigator.pushNamed(context, AppRoutes.profileSettingsScreen); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.primaryBlack : AppTheme.grey50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ───────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: isDark ? AppTheme.surfaceBlack : AppTheme.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title: Row(children: [
                Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.teal, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.school, color: AppTheme.white, size: 18)),
                const SizedBox(width: 8),
                Text('CollabFuture', style: Theme.of(context).textTheme.titleLarge),
              ]),
              actions: [
                IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
                const SizedBox(width: 4),
              ],
              bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
                child: Divider(height: 1, color: isDark ? AppTheme.dividerBlack : AppTheme.grey100)),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // ── Greeting ──────────────────────────────────────
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Welcome back, $_userName!', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text("Let's continue planning your future", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.grey500)),
                  ])),
                  IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.pushNamed(context, AppRoutes.settingsScreen)),
                ]),
                const SizedBox(height: 20),

                // ── Stats row ─────────────────────────────────────
                Row(children: [
                  _StatCard(label: 'Saved Schools', value: '8', icon: Icons.school_outlined),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Applications', value: '3', icon: Icons.description_outlined),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Scholarships', value: '12', icon: Icons.card_giftcard_outlined),
                ]),
                const SizedBox(height: 24),

                // ── Upcoming Deadlines ────────────────────────────
                _SectionHeader(title: 'Upcoming Deadlines', onViewAll: () => Navigator.pushNamed(context, AppRoutes.calendarScreen)),
                const SizedBox(height: 12),
                _DeadlineCard(title: 'UC Application Deadline', subtitle: 'Due: November 30, 2025', daysLeft: 3, color: AppTheme.errorRed),
                const SizedBox(height: 8),
                _DeadlineCard(title: 'MIT Campus Visit', subtitle: 'Dec 5, 2025 at 10:00 AM', daysLeft: 10, color: AppTheme.warningAmber),
                const SizedBox(height: 8),
                _DeadlineCard(title: 'Merit Scholarship Application', subtitle: 'Due: December 31, 2025', daysLeft: 15, color: AppTheme.teal),
                const SizedBox(height: 24),

                // ── Scholarship Matches ───────────────────────────
                _SectionHeader(title: 'New Scholarship Matches', onViewAll: () => Navigator.pushNamed(context, AppRoutes.scholarshipFeedScreen)),
                const SizedBox(height: 12),
                _ScholarshipMatchCard(
                  title: '5 new scholarships match your profile',
                  items: const ['National Merit Scholarships  \$2,500', 'STEM Excellence Award  \$5,000'],
                ),
                const SizedBox(height: 24),

                // ── Comparing Schools ─────────────────────────────
                _SectionHeader(title: 'Comparing Schools', onViewAll: () => Navigator.pushNamed(context, AppRoutes.schoolSearchScreen)),
                const SizedBox(height: 12),
                _ComparingSchoolsCard(),
                const SizedBox(height: 24),

                // ── Applications in Progress ──────────────────────
                _SectionHeader(title: 'Applications in Progress', onViewAll: () {}),
                const SizedBox(height: 12),
                _ApplicationCard(school: 'Stanford University', stage: 'Essay Review', progress: 0.75),
                const SizedBox(height: 8),
                _ApplicationCard(school: 'MIT', stage: 'Letters of Rec', progress: 0.5),
                const SizedBox(height: 8),
                _ApplicationCard(school: 'UC Berkeley', stage: 'Final Review', progress: 0.9),
                const SizedBox(height: 24),

                // ── Saved Schools ─────────────────────────────────
                _SectionHeader(title: 'Saved Schools', onViewAll: () => Navigator.pushNamed(context, AppRoutes.schoolSearchScreen)),
                const SizedBox(height: 12),
                Row(children: [
                  _SavedSchoolChip(name: 'Stanford University', location: 'Stanford, CA', acceptance: '4%'),
                  const SizedBox(width: 12),
                  _SavedSchoolChip(name: 'MIT', location: 'Cambridge, MA', acceptance: '4%'),
                ]),
                const SizedBox(height: 80),
              ])),
            ),
          ],
        ),
      ),
      // ── AI Support FAB ────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.aiSupportScreen),
        backgroundColor: AppTheme.primaryBlack,
        child: const Icon(Icons.chat_bubble_outline, color: AppTheme.white),
      ),
      bottomNavigationBar: CFBottomNav(currentIndex: _navIndex, onTap: _onNavTap),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title; final VoidCallback onViewAll;
  const _SectionHeader({required this.title, required this.onViewAll});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
    TextButton(onPressed: onViewAll, child: const Text('View All', style: TextStyle(fontSize: 13))),
  ]);
}

class _StatCard extends StatelessWidget {
  final String label, value; final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBlack : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.dividerBlack : AppTheme.grey100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: AppTheme.teal),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.grey500)),
      ]),
    ));
  }
}

class _DeadlineCard extends StatelessWidget {
  final String title, subtitle; final int daysLeft; final Color color;
  const _DeadlineCard({required this.title, required this.subtitle, required this.daysLeft, required this.color});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBlack : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.dividerBlack : AppTheme.grey100),
      ),
      child: Row(children: [
        Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grey500)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
          child: Text('$daysLeft days', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _ScholarshipMatchCard extends StatelessWidget {
  final String title; final List<String> items;
  const _ScholarshipMatchCard({required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.teal.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.teal.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome, color: AppTheme.teal, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.teal))),
        ]),
        const SizedBox(height: 10),
        ...items.map((i) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.teal, size: 14),
            const SizedBox(width: 6),
            Text(i, style: Theme.of(context).textTheme.bodySmall),
          ]),
        )),
      ]),
    );
  }
}

class _ComparingSchoolsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBlack : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.dividerBlack : AppTheme.grey100),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('3 Schools', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grey500)),
          TextButton(onPressed: () {}, child: const Text('View Details', style: TextStyle(fontSize: 12))),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: ['S', 'M', 'L'].map((l) =>
          CircleAvatar(radius: 22, backgroundColor: AppTheme.primaryBlack, child: Text(l, style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600))),
        ).toList()),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('Stanford\n4%', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.grey500)),
          Text('MIT\n4%', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.grey500)),
          Text('UC Davis\n44%', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.grey500)),
        ]),
      ]),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final String school, stage; final double progress;
  const _ApplicationCard({required this.school, required this.stage, required this.progress});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBlack : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.dividerBlack : AppTheme.grey100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(school, style: Theme.of(context).textTheme.titleSmall),
          Text('${(progress * 100).round()}%', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.teal)),
        ]),
        const SizedBox(height: 4),
        Text(stage, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grey500)),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: progress, backgroundColor: AppTheme.grey100,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.teal), borderRadius: BorderRadius.circular(4), minHeight: 6),
      ]),
    );
  }
}

class _SavedSchoolChip extends StatelessWidget {
  final String name, location, acceptance;
  const _SavedSchoolChip({required this.name, required this.location, required this.acceptance});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBlack : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.dividerBlack : AppTheme.grey100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 16, backgroundColor: AppTheme.primaryBlack,
          child: Text(name[0], style: const TextStyle(color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.w600))),
        const SizedBox(height: 8),
        Text(name, style: Theme.of(context).textTheme.labelMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(location, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.grey500)),
        const SizedBox(height: 2),
        Text('✓ $acceptance acceptance', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.teal)),
      ]),
    ));
  }
}
