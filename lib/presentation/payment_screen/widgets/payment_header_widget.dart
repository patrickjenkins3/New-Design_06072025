import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class PaymentHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackPressed;

  const PaymentHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              // Header row with back button and security indicator
              Row(
                children: [
                  if (onBackPressed != null)
                    IconButton(
                      onPressed: onBackPressed,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      padding: EdgeInsets.zero,
                    )
                  else
                    SizedBox(width: 10.w),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock,
                          color: Colors.green[300],
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Secure Payment',
                          style: TextStyle(
                            color: Colors.green[300],
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showHelpDialog(context);
                    },
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Title and subtitle
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 1.h),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withAlpha(230),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              // SSL and security indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSecurityBadge(Icons.verified, '256-bit SSL'),
                  SizedBox(width: 4.w),
                  _buildSecurityBadge(Icons.credit_card, 'Stripe Secure'),
                  SizedBox(width: 4.w),
                  _buildSecurityBadge(Icons.shield, 'PCI Compliant'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.green[300],
          size: 4.w,
        ),
        SizedBox(width: 1.w),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withAlpha(204),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help with your payment?'),
            SizedBox(height: 16),
            Text('• All payments are processed securely through Stripe'),
            Text('• Your card information is never stored on our servers'),
            Text('• You can cancel anytime from your account settings'),
            Text('• Contact support: support@collabfuture.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
