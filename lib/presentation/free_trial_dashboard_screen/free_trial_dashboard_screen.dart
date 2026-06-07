import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_error_widget.dart';
import './widgets/social_proof_widget.dart';
import './widgets/trial_feature_card_widget.dart';
import './widgets/trial_limits_widget.dart';
import './widgets/trial_upgrade_prompt_widget.dart';
import './widgets/trial_welcome_banner_widget.dart';

class FreeTrialDashboardScreen extends StatefulWidget {
  const FreeTrialDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FreeTrialDashboardScreen> createState() =>
      _FreeTrialDashboardScreenState();
}

class _FreeTrialDashboardScreenState extends State<FreeTrialDashboardScreen> {
  final SupabaseClient _client = SupabaseService.instance.client;
  bool _isLoading = true;
  String? _error;

  // Trial data
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _subscription;
  List<dynamic> _recentScholarships = [];
  List<dynamic> _userTasks = [];
  int _savedSchoolsCount = 0;

  // Trial limits
  static const int maxSavedSchools = 10;
  static const int maxTrackedDeadlines = 5;

  @override
  void initState() {
    super.initState();
    _loadTrialData();
  }

  Future<void> _loadTrialData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = _client.auth.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        return;
      }

      // Load user profile
      final profileResponse = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      // Load subscription info
      final subscriptionResponse = await _client
          .from('subscriptions')
          .select('*, subscription_plans(*)')
          .eq('user_id', user.id)
          .single();

      // Load recent scholarships (limited for trial)
      final scholarshipsResponse = await _client
          .from('scholarships')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(3);

      // Load user tasks/deadlines
      final tasksResponse = await _client
          .from('tasks')
          .select()
          .eq('user_id', user.id)
          .order('due_date', ascending: true)
          .limit(maxTrackedDeadlines);

      // Count saved schools (simulated - would need separate table)
      _savedSchoolsCount = 3; // Mock count for demo

      setState(() {
        _userProfile = profileResponse;
        _subscription = subscriptionResponse;
        _recentScholarships = scholarshipsResponse;
        _userTasks = tasksResponse;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to load trial data: $error';
        _isLoading = false;
      });
    }
  }

  bool get _isTrialActive {
    if (_subscription == null) return false;
    final status = _subscription!['status'] as String?;
    return status == 'trialing' || status == 'active';
  }

  int get _trialDaysRemaining {
    if (_subscription == null) return 0;
    final endDate = DateTime.parse(_subscription!['current_period_end']);
    final now = DateTime.now();
    return endDate.difference(now).inDays.clamp(0, 30);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? CustomErrorWidget(
                    message: _error!,
                    onRetry: _loadTrialData,
                  )
                : _buildTrialContent(),
      ),
      bottomNavigationBar: _buildTrialBottomNav(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.subscriptionScreen),
        label: Text(
          'Start Full Experience',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.upgrade, color: Colors.white),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }

  Widget _buildTrialContent() {
    return RefreshIndicator(
      onRefresh: _loadTrialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner with trial countdown
            TrialWelcomeBannerWidget(
              userProfile: _userProfile!,
              daysRemaining: _trialDaysRemaining,
              isTrialActive: _isTrialActive,
            ),

            SizedBox(height: 3.h),

            // Core functionality cards
            Text(
              'Explore Key Features',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 2.h),

            // Feature cards grid
            _buildFeatureCards(),

            SizedBox(height: 3.h),

            // Quick wins section
            _buildQuickWinsSection(),

            SizedBox(height: 3.h),

            // Trial limits info
            TrialLimitsWidget(
              savedSchoolsCount: _savedSchoolsCount,
              maxSavedSchools: maxSavedSchools,
              trackedDeadlinesCount: _userTasks.length,
              maxTrackedDeadlines: maxTrackedDeadlines,
            ),

            SizedBox(height: 3.h),

            // Social proof
            const SocialProofWidget(),

            SizedBox(height: 3.h),

            // Upgrade prompt
            const TrialUpgradePromptWidget(),

            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TrialFeatureCardWidget(
                title: 'School Discovery',
                subtitle: 'Limited to 10 saves',
                icon: Icons.school,
                iconColor: const Color(0xFF3B82F6),
                isLimited: true,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.schoolSearchScreen),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: TrialFeatureCardWidget(
                title: 'Scholarships',
                subtitle: 'Basic matching only',
                icon: Icons.monetization_on,
                iconColor: const Color(0xFF10B981),
                isLimited: true,
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.scholarshipFeedScreen),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: TrialFeatureCardWidget(
                title: 'Deadline Tracking',
                subtitle: 'Up to 5 events',
                icon: Icons.event,
                iconColor: const Color(0xFFF59E0B),
                isLimited: true,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.calendarScreen),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: TrialFeatureCardWidget(
                title: 'AI Support',
                subtitle: 'Basic guidance',
                icon: Icons.smart_toy,
                iconColor: const Color(0xFF8B5CF6),
                isLimited: true,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.aiSupportScreen),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickWinsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalized for You',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),

        SizedBox(height: 2.h),

        // Trending scholarships
        _buildScholarshipPreview(),

        SizedBox(height: 2.h),

        // Upcoming deadlines
        _buildUpcomingDeadlines(),
      ],
    );
  }

  Widget _buildScholarshipPreview() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green[600], size: 20.sp),
              SizedBox(width: 2.w),
              Text(
                'Trending Scholarships',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ..._recentScholarships
              .take(2)
              .map((scholarship) => _buildScholarshipItem(scholarship))
              .toList(),
          if (_recentScholarships.length > 2) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.orange[600], size: 16.sp),
                  SizedBox(width: 2.w),
                  Text(
                    'Upgrade to see ${_recentScholarships.length - 2} more',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScholarshipItem(Map<String, dynamic> scholarship) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.monetization_on,
              color: Colors.green[600],
              size: 16.sp,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scholarship['title'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  scholarship['award_display'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${scholarship['match_percentage'] ?? 0}%',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlines() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange[600], size: 20.sp),
              SizedBox(width: 2.w),
              Text(
                'Upcoming Deadlines',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (_userTasks.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.event_available,
                      color: Colors.grey[400], size: 24.sp),
                  SizedBox(height: 1.h),
                  Text(
                    'No deadlines tracked yet',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            ..._userTasks.map((task) => _buildDeadlineItem(task)).toList(),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(Map<String, dynamic> task) {
    final dueDate = DateTime.parse(task['due_date']);
    final daysUntil = dueDate.difference(DateTime.now()).inDays;

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: daysUntil <= 7 ? Colors.red[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.event,
              color: daysUntil <= 7 ? Colors.red[600] : Colors.orange[600],
              size: 16.sp,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  daysUntil > 0 ? '$daysUntil days left' : 'Due today',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: daysUntil <= 7 ? Colors.red[600] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: task['priority'] == 'high'
                  ? Colors.red[50]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              task['priority']?.toString().toUpperCase() ?? 'MEDIUM',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: task['priority'] == 'high'
                    ? Colors.red[700]
                    : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialBottomNav() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(Icons.dashboard, 'Dashboard', true),
          _buildNavItem(Icons.school, 'Schools', false, badge: 'Limited'),
          _buildNavItem(Icons.monetization_on, 'Scholarships', false,
              badge: 'Basic'),
          _buildNavItem(Icons.calendar_today, 'Calendar', false,
              badge: '5 max'),
          _buildNavItem(Icons.person, 'Profile', false, badge: 'Upgrade'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive,
      {String? badge}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isActive) {
            switch (label) {
              case 'Schools':
                Navigator.pushNamed(context, AppRoutes.schoolSearchScreen);
                break;
              case 'Scholarships':
                Navigator.pushNamed(context, AppRoutes.scholarshipFeedScreen);
                break;
              case 'Calendar':
                Navigator.pushNamed(context, AppRoutes.calendarScreen);
                break;
              case 'Profile':
                Navigator.pushNamed(context, AppRoutes.profileSettingsScreen);
                break;
            }
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: isActive ? const Color(0xFF6366F1) : Colors.grey[400],
                  size: 24.sp,
                ),
                if (badge != null)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: EdgeInsets.all(1.sp),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        'U',
                        style: GoogleFonts.inter(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: isActive ? const Color(0xFF6366F1) : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (badge != null) ...[
              Text(
                badge,
                style: GoogleFonts.inter(
                  fontSize: 8.sp,
                  color: Colors.orange[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}