import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/subscription_service.dart';
import '../../../models/user_subscription.dart';

class SubscriptionManagementWidget extends StatelessWidget {
  final UserSubscription? subscription;
  final VoidCallback onRefresh;

  const SubscriptionManagementWidget({
    super.key,
    this.subscription,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Management',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 2.h),
            _buildManagementOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOptions(BuildContext context) {
    if (subscription == null) {
      return _buildFreeUserOptions(context);
    }

    return Column(
      children: [
        // Subscription info
        _buildInfoTile(
          icon: Icons.info_outline,
          title: 'Plan Details',
          subtitle: '${subscription!.plan?.name} - ${_getStatusDescription()}',
          onTap: () => _showSubscriptionDetails(context),
        ),

        // Usage and limits
        _buildInfoTile(
          icon: Icons.analytics_outlined,
          title: 'Usage & Limits',
          subtitle: 'View your current usage and plan limits',
          onTap: () => _showUsageDetails(context),
        ),

        // Billing preferences
        if (subscription!.stripeCustomerId != null)
          _buildInfoTile(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage your payment methods and billing',
            onTap: () => _managePaymentMethods(context),
          ),

        // Download invoice
        if (subscription!.isActive)
          _buildInfoTile(
            icon: Icons.receipt_outlined,
            title: 'Download Invoices',
            subtitle: 'Access your billing history and invoices',
            onTap: () => _downloadInvoices(context),
          ),

        // Cancel subscription
        if (subscription!.isActive && !subscription!.cancelAtPeriodEnd)
          _buildInfoTile(
            icon: Icons.cancel_outlined,
            title: 'Cancel Subscription',
            subtitle: 'Cancel your subscription at any time',
            onTap: () => _showCancelDialog(context),
            textColor: Colors.red,
          ),

        // Reactivate if canceled
        if (subscription!.cancelAtPeriodEnd)
          _buildInfoTile(
            icon: Icons.refresh_outlined,
            title: 'Reactivate Subscription',
            subtitle: 'Continue your subscription beyond current period',
            onTap: () => _reactivateSubscription(context),
            textColor: Colors.green,
          ),
      ],
    );
  }

  Widget _buildFreeUserOptions(BuildContext context) {
    return Column(
      children: [
        _buildInfoTile(
          icon: Icons.upgrade_outlined,
          title: 'Upgrade to Premium',
          subtitle: 'Unlock advanced features and unlimited access',
          onTap: () => Navigator.pushNamed(context, AppRoutes.subscriptionScreen),
          textColor: AppTheme.primaryLight,
        ),
        _buildInfoTile(
          icon: Icons.help_outline,
          title: 'Free Plan Features',
          subtitle: 'See what\'s included in your current plan',
          onTap: () => _showFreeFeatures(context),
        ),
        _buildInfoTile(
          icon: Icons.support_agent_outlined,
          title: 'Get Help',
          subtitle: 'Contact support or browse help articles',
          onTap: () => _contactSupport(context),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: (textColor ?? AppTheme.primaryLight).withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: textColor ?? AppTheme.primaryLight,
          size: 6.w,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppTheme.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 4.w,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  String _getStatusDescription() {
    if (subscription == null) return '';

    switch (subscription!.status) {
      case 'active':
        return 'Active subscription';
      case 'trialing':
        return 'Free trial period';
      case 'canceled':
        return 'Canceled, expires ${_formatDate(subscription!.currentPeriodEnd!)}';
      case 'past_due':
        return 'Payment overdue';
      case 'unpaid':
        return 'Payment required';
      default:
        return subscription!.status;
    }
  }

  void _showSubscriptionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Plan', subscription!.plan?.name ?? 'Unknown'),
            _buildDetailRow('Status', subscription!.status),
            if (subscription!.plan?.price != null)
              _buildDetailRow('Price',
                  '\$${subscription!.plan!.price}/${subscription!.plan!.billingInterval}'),
            if (subscription!.currentPeriodEnd != null)
              _buildDetailRow(
                  'Next billing', _formatDate(subscription!.currentPeriodEnd!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUsageDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usage & Limits'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Feature usage tracking is not implemented in this demo.',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              'In a production app, this would show:\n• API usage\n• Storage usage\n• Feature limits\n• Usage graphs',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _managePaymentMethods(BuildContext context) async {
    // In production, this would open Stripe customer portal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening payment method management...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _downloadInvoices(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice download feature not implemented in demo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to cancel your subscription?',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              'You will continue to have access to premium features until ${_formatDate(subscription!.currentPeriodEnd!)}.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelSubscription(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelSubscription(BuildContext context) async {
    try {
      await SubscriptionService.instance.cancelSubscription(subscription!.id);
      onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription canceled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel subscription: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reactivateSubscription(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Reactivation feature requires Stripe Customer Portal integration'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showFreeFeatures(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Free Plan Features'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your free plan includes:',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            ...[
              'Basic college search',
              'Application deadline tracking',
              'Limited scholarship recommendations',
              'Basic profile management',
              'Email support',
            ].map((feature) => Padding(
                  padding: EdgeInsets.only(bottom: 0.5.h),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 4.w),
                      SizedBox(width: 2.w),
                      Expanded(
                          child:
                              Text(feature, style: TextStyle(fontSize: 14.sp))),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.subscriptionScreen);
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Need help? Reach out to our support team:',
                style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 2.h),
            Text('Email: support@nextmatric.com\nPhone: 1-800-NEXTMAT',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}