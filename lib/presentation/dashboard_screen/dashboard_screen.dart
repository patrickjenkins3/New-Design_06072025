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
  void initState() { super.initState(); _loadUser(); }

  Future<void> _loadUser() async {
    final p = await AuthService.instance.getUserProfile();
    if (mounted && p != null) setState(() => _userName = (p['full_name'] as String? ?? 'Alex').split(' ').first);
  }

  void _onNavTap(int i) {
    switch (i) {
      case 0: setState(() => _navIndex = 0);
      case 1: Navigator.pushNamed(context, AppRoutes.calendarScreen);
      case 2: Navigator.pushNamed(context, AppRoutes.scholarshipFeedScreen);
      case 3: Navigator.pushNamed(context, AppRoutes.profileSettingsScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          // ── App bar ─────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: isDark ? AppTheme.navyDark : AppTheme.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.school, color: AppTheme.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text('CollabFuture', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isDark ? AppTheme.white : AppTheme.navy)),
            ]),
            actions: [
              IconButton(icon: Icon(Icons.notifications_outlined, color: isDark ? AppTheme.white : AppTheme.navy), onPressed: () {}),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight)),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // ── Greeting ──────────────────────────────────────
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Welcome back, $_userName! 👋', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text("Let's continue planning your future",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted)),
                ])),
                IconButton(
                  icon: Icon(Icons.settings_outlined, color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.settingsScreen)),
              ]),
              const SizedBox(height: 20),

              // ── Stats row ─────────────────────────────────────
              Row(children: [
                _StatCard(label: 'Saved Schools', value: '8',  icon: Icons.school_outlined,        color: AppTheme.navy),
                const SizedBox(width: 10),
                _StatCard(label: 'Applications',  value: '3',  icon: Icons.description_outlined,   color: AppTheme.skyBlue),
                const SizedBox(width: 10),
                _StatCard(label: 'Scholarships',  value: '12', icon: Icons.card_giftcard_outlined,  color: AppTheme.sage),
              ]),
              const SizedBox(height: 24),

              // ── Upcoming Deadlines ────────────────────────────
              _SectionHeader(title: 'Upcoming Deadlines',
                onViewAll: () => Navigator.pushNamed(context, AppRoutes.calendarScreen)),
              const SizedBox(height: 12),
              _DeadlineCard(title: 'UC Application Deadline', subtitle: 'Due: November 30, 2025',    daysLeft: 3,  urgency: _Urgency.high),
              const SizedBox(height: 8),
              _DeadlineCard(title: 'MIT Campus Visit',        subtitle: 'Dec 5, 2025 at 10:00 AM',  daysLeft: 10, urgency: _Urgency.medium),
              const SizedBox(height: 8),
              _DeadlineCard(title: 'Merit Scholarship',       subtitle: 'Due: December 31, 2025',   daysLeft: 15, urgency: _Urgency.low),
              const SizedBox(height: 24),

              // ── Scholarship Matches ───────────────────────────
              _SectionHeader(title: 'New Scholarship Matches',
                onViewAll: () => Navigator.pushNamed(context, AppRoutes.scholarshipFeedScreen)),
              const SizedBox(height: 12),
              _ScholarshipMatchCard(items: const ['National Merit Scholarships  \$2,500', 'STEM Excellence Award  \$5,000']),
              const SizedBox(height: 24),

              // ── Comparing Schools ─────────────────────────────
              _SectionHeader(title: 'Comparing Schools',
                onViewAll: () => Navigator.pushNamed(context, AppRoutes.schoolSearchScreen)),
              const SizedBox(height: 12),
              _ComparingSchoolsCard(),
              const SizedBox(height: 24),

              // ── Applications in Progress ──────────────────────
              _SectionHeader(title: 'Applications in Progress', onViewAll: () {}),
              const SizedBox(height: 12),
              _ApplicationCard(school: 'Stanford University', stage: 'Essay Review',       progress: 0.75),
              const SizedBox(height: 8),
              _ApplicationCard(school: 'MIT',                 stage: 'Letters of Rec',     progress: 0.50),
              const SizedBox(height: 8),
              _ApplicationCard(school: 'UC Berkeley',         stage: 'Final Review',       progress: 0.90),
              const SizedBox(height: 24),

              // ── Saved Schools ─────────────────────────────────
              _SectionHeader(title: 'Saved Schools',
                onViewAll: () => Navigator.pushNamed(context, AppRoutes.schoolSearchScreen)),
              const SizedBox(height: 12),
              Row(children: [
                _SavedSchoolCard(name: 'Stanford University', location: 'Stanford, CA',   acceptance: '4%'),
                const SizedBox(width: 10),
                _SavedSchoolCard(name: 'MIT',                 location: 'Cambridge, MA',  acceptance: '4%'),
              ]),
              const SizedBox(height: 80),
            ])),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.aiSupportScreen),
        backgroundColor: AppTheme.skyBlue,
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
  final String label, value; final IconData icon; final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color)),
        const SizedBox(height: 10),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted)),
      ]),
    ));
  }
}

enum _Urgency { high, medium, low }

class _DeadlineCard extends StatelessWidget {
  final String title, subtitle; final int daysLeft; final _Urgency urgency;
  const _DeadlineCard({required this.title, required this.subtitle, required this.daysLeft, required this.urgency});

  Color get _color => switch (urgency) { _Urgency.high => AppTheme.errorRed, _Urgency.medium => AppTheme.gold, _Urgency.low => AppTheme.sage };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
      ),
      child: Row(children: [
        Container(width: 4, height: 44, decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: _color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Text('$daysLeft days', style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

class _ScholarshipMatchCard extends StatelessWidget {
  final List<String> items;
  const _ScholarshipMatchCard({required this.items});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: AppTheme.skyBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.auto_awesome, color: AppTheme.skyBlue, size: 14)),
          const SizedBox(width: 10),
          Text('5 new scholarships match your profile',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.skyBlue)),
        ]),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.sage, size: 14),
            const SizedBox(width: 8),
            Text(item, style: Theme.of(context).textTheme.bodySmall),
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
        color: isDark ? AppTheme.cardDark : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('3 Schools', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted)),
          TextButton(onPressed: () {}, child: const Text('View Details', style: TextStyle(fontSize: 12))),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          CircleAvatar(radius: 24, backgroundColor: AppTheme.navy, child: const Text('S', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700))),
          CircleAvatar(radius: 24, backgroundColor: AppTheme.skyBlue, child: const Text('M', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700))),
          CircleAvatar(radius: 24, backgroundColor: AppTheme.sage, child: const Text('L', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('Stanford\n4%',  textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted)),
          Text('MIT\n4%',      textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted)),
          Text('UC Davis\n44%',textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted)),
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
    final pct = (progress * 100).round();
    final color = pct >= 80 ? AppTheme.sage : pct >= 50 ? AppTheme.skyBlue : AppTheme.gold;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(school, style: Theme.of(context).textTheme.titleSmall),
          Text('$pct%', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 2),
        Text(stage, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress, minHeight: 6,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
          ),
        ),
      ]),
    );
  }
}

class _SavedSchoolCard extends StatelessWidget {
  final String name, location, acceptance;
  const _SavedSchoolCard({required this.name, required this.location, required this.acceptance});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 18, backgroundColor: AppTheme.navy,
          child: Text(name[0], style: const TextStyle(color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.w700))),
        const SizedBox(height: 10),
        Text(name, style: Theme.of(context).textTheme.labelMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(location, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted)),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.check_circle, color: AppTheme.sage, size: 12),
          const SizedBox(width: 4),
          Text('$acceptance acceptance', style: const TextStyle(color: AppTheme.sage, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ]),
    ));
  }
}
