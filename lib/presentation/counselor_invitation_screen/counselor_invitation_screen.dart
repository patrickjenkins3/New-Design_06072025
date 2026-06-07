import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/active_counselors_widget.dart';
import './widgets/counselor_invitation_form_widget.dart';
import './widgets/pending_invitations_widget.dart';

class CounselorInvitationScreen extends StatefulWidget {
  const CounselorInvitationScreen({Key? key}) : super(key: key);

  @override
  State<CounselorInvitationScreen> createState() =>
      _CounselorInvitationScreenState();
}

class _CounselorInvitationScreenState extends State<CounselorInvitationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for counselors
  final List<Map<String, dynamic>> _activeCounselors = [
    {
      'id': '1',
      'name': 'Ms. Jennifer Martinez',
      'email': 'j.martinez@lincolnhigh.edu',
      'school': 'Lincoln High School',
      'title': 'College Counselor',
      'profilePhoto':
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face',
      'connectedDate': DateTime.now().subtract(Duration(days: 30)),
      'permissions': ['view_progress', 'add_schools', 'schedule_meetings'],
      'recentActivity': 'Added 3 recommended schools',
    },
  ];

  final List<Map<String, dynamic>> _pendingInvitations = [
    {
      'id': '2',
      'email': 'counselor@springfieldhs.edu',
      'school': 'Springfield High School',
      'invitedDate': DateTime.now().subtract(Duration(days: 2)),
      'message':
          'Hi! I\'d love to help Sarah with her college planning journey.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onInvitationSent(String email, String message, String? school) {
    setState(() {
      _pendingInvitations.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'school': school ?? 'Unknown School',
        'invitedDate': DateTime.now(),
        'message': message,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation sent to $email'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _onInvitationCancelled(String invitationId) {
    setState(() {
      _pendingInvitations
          .removeWhere((invitation) => invitation['id'] == invitationId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation cancelled'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  void _onCounselorRemoved(String counselorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        title: Text(
          'Remove Counselor',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to remove this counselor? They will no longer have access to your family\'s college planning information.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _activeCounselors
                    .removeWhere((counselor) => counselor['id'] == counselorId);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Counselor removed'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('School Counselor Collaboration'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.lightTheme.colorScheme.primary,
          unselectedLabelColor:
              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          indicatorColor: AppTheme.lightTheme.colorScheme.primary,
          tabs: [
            Tab(text: 'Invite'),
            Tab(text: 'Active (${_activeCounselors.length})'),
            Tab(text: 'Pending (${_pendingInvitations.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Invite Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer
                        .withAlpha(77),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          AppTheme.lightTheme.colorScheme.primary.withAlpha(51),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'info_outline',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'About Counselor Collaboration',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Invite your school counselor to join ScholarPath and get personalized guidance on college planning. Counselors can:',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      SizedBox(height: 1.h),
                      Column(
                        children: [
                          _buildBenefitItem(
                              '• View your college application progress'),
                          _buildBenefitItem(
                              '• Recommend schools based on your profile'),
                          _buildBenefitItem('• Schedule virtual meetings'),
                          _buildBenefitItem(
                              '• Share scholarship opportunities'),
                          _buildBenefitItem('• Provide deadline reminders'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                CounselorInvitationFormWidget(
                  onInvitationSent: _onInvitationSent,
                ),
              ],
            ),
          ),

          // Active Counselors Tab
          ActiveCounselorsWidget(
            counselors: _activeCounselors,
            onCounselorRemoved: _onCounselorRemoved,
          ),

          // Pending Invitations Tab
          PendingInvitationsWidget(
            invitations: _pendingInvitations,
            onInvitationCancelled: _onInvitationCancelled,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Text(
        text,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
