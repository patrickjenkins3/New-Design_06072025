import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../models/user_subscription.dart';

class SubscriptionStatusCard extends StatelessWidget {
  final UserSubscription? subscription;
  final VoidCallback onUpgrade;
  final VoidCallback? onManage;

  const SubscriptionStatusCard({
    super.key,
    this.subscription,
    required this.onUpgrade,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    if (subscription == null) {
      return _buildNoSubscriptionCard(context);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _getStatusGradient(subscription!.status),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 2.h),
              _buildSubscriptionDetails(),
              SizedBox(height: 3.h),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSubscriptionCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: 12.w,
              color: AppTheme.primaryLight,
            ),
            SizedBox(height: 2.h),
            Text(
              'Free Plan',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'You are currently on the free plan with basic features.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription!.plan?.name ?? 'Unknown Plan',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 0.5.h),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 0.5.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatStatus(subscription!.status),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Icon(
          _getStatusIcon(subscription!.status),
          size: 10.w,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSubscriptionDetails() {
    final plan = subscription!.plan;
    final price = plan?.price ?? 0.0;
    final billingInterval = plan?.billingInterval ?? 'month';
    final currentPeriodEnd = subscription!.currentPeriodEnd;
    final cancelAtPeriodEnd = subscription!.cancelAtPeriodEnd;

    return Column(
      children: [
        if (price > 0)
          _buildDetailRow(
            'Amount',
            '\$${price.toStringAsFixed(2)}/$billingInterval',
          ),
        if (currentPeriodEnd != null)
          _buildDetailRow(
            cancelAtPeriodEnd ? 'Expires' : 'Next Billing',
            _formatDate(currentPeriodEnd),
          ),
        if (cancelAtPeriodEnd)
          _buildDetailRow(
            'Status',
            'Will cancel at period end',
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withAlpha(230),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final price = subscription!.plan?.price ?? 0;
    final isCanceled = subscription!.status == 'canceled';
    final isActive = subscription!.status == 'active';

    return Row(
      children: [
        if (price == 0 || isCanceled)
          Expanded(
            child: ElevatedButton(
              onPressed: onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryLight,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isCanceled ? 'Reactivate' : 'Upgrade',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (isActive && onManage != null) ...[
          if (price == 0 || isCanceled) SizedBox(width: 3.w),
          Expanded(
            child: ElevatedButton(
              onPressed: onManage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withAlpha(51),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white, width: 1),
                ),
              ),
              child: Text(
                'Manage',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  LinearGradient _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
        );
      case 'trialing':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        );
      case 'canceled':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF757575), Color(0xFF616161)],
        );
      case 'past_due':
      case 'unpaid':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
        );
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'trialing':
        return Icons.star;
      case 'canceled':
        return Icons.cancel;
      case 'past_due':
      case 'unpaid':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'ACTIVE';
      case 'canceled':
        return 'CANCELED';
      case 'past_due':
        return 'PAST DUE';
      case 'unpaid':
        return 'UNPAID';
      case 'trialing':
        return 'FREE TRIAL';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
