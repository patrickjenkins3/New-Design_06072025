import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class FamilyBillingControlsWidget extends StatefulWidget {
  const FamilyBillingControlsWidget({super.key});

  @override
  State<FamilyBillingControlsWidget> createState() =>
      _FamilyBillingControlsWidgetState();
}

class _FamilyBillingControlsWidgetState
    extends State<FamilyBillingControlsWidget> {
  bool _parentOnlyPayments = true;
  bool _requireApproval = true;
  bool _spendingNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.family_restroom,
                color: AppTheme.primaryLight,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Family Billing Controls',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          Text(
            'Manage payment permissions and controls for family members',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 3.h),

          // Parent-only payments
          _buildControlTile(
            'Parent-Only Payments',
            'Only parents/guardians can make purchases',
            _parentOnlyPayments,
            (value) => setState(() => _parentOnlyPayments = value),
            Icons.security,
          ),

          // Require approval
          _buildControlTile(
            'Require Payment Approval',
            'Teen account purchases need parent approval',
            _requireApproval,
            (value) => setState(() => _requireApproval = value),
            Icons.approval,
          ),

          // Spending notifications
          _buildControlTile(
            'Spending Notifications',
            'Get notified of all family account charges',
            _spendingNotifications,
            (value) => setState(() => _spendingNotifications = value),
            Icons.notifications,
          ),

          SizedBox(height: 2.h),

          // Info card
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber.shade700,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'These controls help ensure safe and responsible use of family billing features.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryLight,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryLight,
          ),
        ],
      ),
    );
  }
}
