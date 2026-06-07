import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/subscription_models.dart';
import '../../../theme/app_theme.dart';

class PricingPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isCurrentPlan;
  final VoidCallback onSelectPlan;

  const PricingPlanCard({
    super.key,
    required this.plan,
    required this.isCurrentPlan,
    required this.onSelectPlan,
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = plan.isPremium;
    final cardColor = isPremium ? AppTheme.primaryLight : Colors.white;
    final textColor = isPremium ? Colors.white : AppTheme.textPrimaryLight;
    final borderColor = isPremium ? AppTheme.primaryLight : Colors.grey[300];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? Colors.grey,
          width: isCurrentPlan ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan header
            _buildPlanHeader(textColor, isPremium),
            SizedBox(height: 2.h),

            // Price
            _buildPrice(textColor, isPremium),
            SizedBox(height: 3.h),

            // Features
            _buildFeatures(textColor),
            SizedBox(height: 3.h),

            // Action button
            _buildActionButton(isPremium),

            // Current plan indicator
            if (isCurrentPlan) _buildCurrentPlanIndicator(isPremium),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanHeader(Color textColor, bool isPremium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                plan.name,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            if (isPremium)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 0.5.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          plan.description,
          style: TextStyle(
            fontSize: 14.sp,
            color: isPremium ? Colors.white.withAlpha(230) : Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPrice(Color textColor, bool isPremium) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          plan.isFree ? 'Free' : '\$${plan.price.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        if (!plan.isFree)
          Padding(
            padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
            child: Text(
              '/${plan.billingInterval}',
              style: TextStyle(
                fontSize: 14.sp,
                color:
                    isPremium ? Colors.white.withAlpha(230) : Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatures(Color textColor) {
    final features = _getPlanFeatures();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.take(6).map((feature) {
        return Padding(
          padding: EdgeInsets.only(bottom: 1.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                color: plan.isPremium ? Colors.white : AppTheme.primaryLight,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(bool isPremium) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isCurrentPlan ? null : onSelectPlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPremium ? Colors.white : AppTheme.primaryLight,
          foregroundColor: isPremium ? AppTheme.primaryLight : Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isCurrentPlan
              ? 'Current Plan'
              : plan.isFree
                  ? 'Continue with Free'
                  : 'Upgrade to Premium',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlanIndicator(bool isPremium) {
    return Padding(
      padding: EdgeInsets.only(top: 1.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: isPremium
              ? Colors.white.withAlpha(51)
              : AppTheme.primaryLight.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Currently Active',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: isPremium ? Colors.white : AppTheme.primaryLight,
          ),
        ),
      ),
    );
  }

  List<String> _getPlanFeatures() {
    if (plan.isFree) {
      return [
        'Basic college search',
        'Application deadline tracking',
        'Limited scholarship recommendations',
        'Basic profile management',
        'Email support',
        'Access to basic resources',
      ];
    } else {
      return [
        'Unlimited college search & filters',
        'Advanced scholarship matching',
        'AI-powered application essays',
        'Priority counselor support',
        'Application progress tracking',
        'Document organization tools',
        'Interview preparation resources',
        'One-on-one counseling session',
        '24/7 premium support',
        'Early access to new features',
      ];
    }
  }
}
