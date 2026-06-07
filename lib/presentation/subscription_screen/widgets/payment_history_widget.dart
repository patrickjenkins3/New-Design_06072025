import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PaymentHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> paymentHistory;
  final VoidCallback onRefresh;

  const PaymentHistoryWidget({
    super.key,
    required this.paymentHistory,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (paymentHistory.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment History',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              SizedBox(height: 2.h),
              ...paymentHistory.map((payment) => _buildPaymentItem(payment)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 15.w,
              color: Colors.grey,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Payment History',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your payment history will appear here once you make your first payment.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    final amount = (payment['amount'] as num).toDouble();
    final currency = payment['currency'] as String? ?? 'USD';
    final status = payment['status'] as String;
    final createdAt = DateTime.parse(payment['created_at'] as String);
    final subscription = payment['subscriptions'] as Map<String, dynamic>?;
    final plan = subscription?['subscription_plans'] as Map<String, dynamic>?;

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with amount and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currency.toUpperCase()} \$${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _formatPaymentStatus(status),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            // Plan name if available
            if (plan != null)
              Text(
                plan['name'] as String,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryLight,
                ),
              ),

            SizedBox(height: 2.h),

            // Payment details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (payment['stripe_payment_intent_id'] != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment ID',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _truncateId(
                              payment['stripe_payment_intent_id'] as String),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Additional actions
            if (status == 'failed' || status == 'requires_action')
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Handle retry payment or required action
                    },
                    icon: Icon(
                      status == 'failed' ? Icons.refresh : Icons.warning,
                      size: 4.w,
                    ),
                    label: Text(
                      status == 'failed' ? 'Retry Payment' : 'Action Required',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _getStatusColor(status),
                      side: BorderSide(color: _getStatusColor(status)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'requires_action':
        return Colors.blue;
      case 'canceled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'pending':
        return 'Pending';
      case 'requires_action':
        return 'Action Required';
      case 'canceled':
        return 'Canceled';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _truncateId(String id) {
    if (id.length <= 20) return id;
    return '${id.substring(0, 10)}...${id.substring(id.length - 6)}';
  }
}