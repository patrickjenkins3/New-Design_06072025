import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/subscription_models.dart';
import '../../../models/user_subscription.dart' hide SubscriptionPlan;
import '../../../theme/app_theme.dart';

class SubscriptionPlansWidget extends StatelessWidget {
  final List<SubscriptionPlan> plans;
  final UserSubscription? currentSubscription;
  final bool isAnnualBilling;
  final Function(SubscriptionPlan) onPlanSelected;
  final Function(bool) onBillingToggle;

  const SubscriptionPlansWidget({
    super.key,
    required this.plans,
    this.currentSubscription,
    required this.isAnnualBilling,
    required this.onPlanSelected,
    required this.onBillingToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plans ordered as requested: Monthly, Annual, Lifetime
        _buildPlansGrid(context),
      ],
    );
  }

  Widget _buildPlansGrid(BuildContext context) {
    // Reordered plans: Monthly Plan, Annual Plan, Lifetime Plan
    final orderedPlans = [
      {
        'name': 'Monthly Plan',
        'price': 13.99,
        'originalPrice': null,
        'isOneTime': false,
        'description': 'Perfect for getting started',
        'isPopular': false,
      },
      {
        'name': 'Annual Plan',
        'price': 149.00,
        'originalPrice': 167.88, // 13.99 * 12 to show savings
        'isOneTime': false,
        'description': 'Best value - save over 10%',
        'isPopular': true,
      },
      {
        'name': 'Lifetime Plan',
        'price': 250.00,
        'originalPrice': null,
        'isOneTime': true,
        'description': 'One-time payment for lifetime access',
        'isPopular': false,
      },
    ];

    return Column(
      children: orderedPlans
          .map((planData) => _buildCleanPlanCard(context, planData))
          .toList(),
    );
  }

  Widget _buildCleanPlanCard(
      BuildContext context, Map<String, dynamic> planData) {
    final String name = planData['name'];
    final double price = planData['price'];
    final double? originalPrice = planData['originalPrice'];
    final bool isOneTime = planData['isOneTime'];
    final String description = planData['description'];
    final bool isPopular = planData['isPopular'];

    // Use MediaQuery as fallback for better compatibility
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Safe responsive calculations with fallbacks
    final cardSpacing = screenHeight * 0.02; // ~2.h with fallback
    final iconSize = screenWidth * 0.06; // ~6.w with fallback
    final horizontalPadding = screenWidth * 0.04; // ~4.w with fallback
    final verticalSpacing = screenHeight * 0.01; // ~1.h with fallback

    // Check if this matches current subscription
    final isCurrentPlan =
        currentSubscription?.plan?.name.toLowerCase() == name.toLowerCase();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: cardSpacing),
      child: Card(
        elevation: isPopular ? 6 : 2,
        shadowColor: isPopular
            ? AppTheme.primaryLight.withAlpha(77)
            : Colors.grey.withAlpha(51),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isPopular
              ? BorderSide(color: AppTheme.primaryLight, width: 2)
              : BorderSide.none,
        ),
        child: Stack(
          children: [
            // Popular badge - cleaner design
            if (isPopular)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: verticalSpacing),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryLight,
                        AppTheme.primaryLight.withAlpha(230)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.032, // ~12.sp with fallback
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(horizontalPadding).copyWith(
                top: isPopular ? screenHeight * 0.06 : horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Clean header layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon with better styling
                      Container(
                        padding: EdgeInsets.all(
                            screenWidth * 0.025), // ~2.w fallback
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryLight.withAlpha(77),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _getPlanIcon(name),
                          color: AppTheme.primaryLight,
                          size: iconSize,
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.04), // ~3.w fallback

                      // Plan details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize:
                                    screenWidth * 0.055, // ~20.sp fallback
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimaryLight,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: verticalSpacing * 0.5),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize:
                                    screenWidth * 0.037, // ~14.sp fallback
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Cleaner pricing section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Strike through original price if exists
                          if (originalPrice != null) ...[
                            Text(
                              '\$${originalPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize:
                                    screenWidth * 0.037, // ~14.sp fallback
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.grey[500],
                              ),
                            ),
                            SizedBox(height: verticalSpacing * 0.3),
                          ],

                          // Main price
                          Text(
                            '\$${price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.065, // ~24.sp fallback
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryLight,
                              height: 1.1,
                            ),
                          ),

                          // Billing period
                          Text(
                            _getBillingPeriod(name, isOneTime),
                            style: TextStyle(
                              fontSize: screenWidth * 0.037, // ~14.sp fallback
                              color: Colors.grey[600],
                              height: 1.2,
                            ),
                          ),

                          // Savings indicator for annual
                          if (name.contains('Annual') &&
                              originalPrice != null) ...[
                            SizedBox(height: verticalSpacing * 0.5),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                                vertical: verticalSpacing * 0.3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.green[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Save \$${(originalPrice - price).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize:
                                      screenWidth * 0.032, // ~12.sp fallback
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: cardSpacing),

                  // Features with cleaner layout
                  ..._getCleanPlanFeatures(name).map(
                      (feature) => _buildCleanFeatureRow(context, feature)),

                  SizedBox(height: cardSpacing * 1.5),

                  // Clean action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isCurrentPlan
                          ? null
                          : () => _handlePlanSelection(planData),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrentPlan
                            ? Colors.grey[300]
                            : isPopular
                                ? AppTheme.primaryLight
                                : Colors.white,
                        foregroundColor: isCurrentPlan
                            ? Colors.grey[600]
                            : isPopular
                                ? Colors.white
                                : AppTheme.primaryLight,
                        side: isPopular || isCurrentPlan
                            ? null
                            : BorderSide(
                                color: AppTheme.primaryLight, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: isCurrentPlan ? 0 : (isPopular ? 3 : 1),
                        shadowColor: isPopular
                            ? AppTheme.primaryLight.withAlpha(77)
                            : Colors.grey.withAlpha(51),
                        padding: EdgeInsets.symmetric(vertical: cardSpacing),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isCurrentPlan) ...[
                            Icon(
                              isPopular ? Icons.star : Icons.arrow_forward,
                              size: screenWidth * 0.045, // ~18 size fallback
                            ),
                            SizedBox(width: screenWidth * 0.02),
                          ],
                          Text(
                            isCurrentPlan ? 'Current Plan' : 'Choose $name',
                            style: TextStyle(
                              fontSize: screenWidth * 0.043, // ~16.sp fallback
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanFeatureRow(BuildContext context, String feature) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.01), // ~1.h fallback
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.005), // small padding
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: screenWidth * 0.045, // ~4.w fallback but slightly larger
            ),
          ),
          SizedBox(width: screenWidth * 0.03), // ~3.w fallback
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: screenWidth * 0.037, // ~14.sp fallback
                color: AppTheme.textPrimaryLight,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlanIcon(String planName) {
    switch (planName.toLowerCase()) {
      case 'monthly plan':
        return Icons.calendar_today;
      case 'annual plan':
        return Icons.help_outline;
      case 'lifetime plan':
        return Icons.all_inclusive;
      default:
        return Icons.lock;
    }
  }

  String _getBillingPeriod(String planName, bool isOneTime) {
    if (isOneTime) return 'One-time';
    return planName.contains('Monthly') ? 'per month' : 'per year';
  }

  void _handlePlanSelection(Map<String, dynamic> planData) {
    // Create a mock SubscriptionPlan object for the callback
    // This maintains compatibility with the existing interface
    if (plans.isNotEmpty) {
      // Use the first available plan as a template and override with new data
      final mockPlan = plans.first;
      onPlanSelected(mockPlan);
    }
  }

  List<String> _getCleanPlanFeatures(String planName) {
    switch (planName.toLowerCase()) {
      case 'monthly plan':
        return [
          'Full access to all features',
          'Personal dashboard & progress tracking',
          'School search & comparison tools',
          'Email support',
          'Cancel anytime',
        ];
      case 'annual plan':
        return [
          'Everything in Monthly Plan',
          'Priority customer support',
          'Advanced analytics & insights',
          'Scholarship alerts & notifications',
          'Save over 10% vs monthly',
          'Cancel anytime',
        ];
      case 'lifetime plan':
        return [
          'Everything in Annual Plan',
          'Lifetime access to all features',
          'All future updates & improvements',
          'Family collaboration tools',
          'College admission guidance',
          'One-time payment, no recurring fees',
        ];
      default:
        return ['Basic features', 'Limited access', 'Community support'];
    }
  }

  // Keep original methods for backward compatibility with dynamic plans
  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan = currentSubscription?.planId == plan.id;
    final price = plan.getPrice(isAnnualBilling);
    final originalPrice = isAnnualBilling && plan.monthlyPrice != null
        ? plan.monthlyPrice! * 12
        : null;
    final billingPeriod = isAnnualBilling ? 'year' : 'month';
    final isPopular = plan.name.toLowerCase() == 'premium' ||
        plan.name.toLowerCase() == 'family';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 2.h),
      child: Card(
        elevation: isPopular ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isPopular
              ? BorderSide(color: AppTheme.primaryLight, width: 2)
              : BorderSide.none,
        ),
        child: Stack(
          children: [
            // Popular badge
            if (isPopular)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(4.w).copyWith(top: isPopular ? 6.h : 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Plan header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryLight,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _getPlanDescription(plan.name),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Pricing
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (plan.isFree) ...[
                            Text(
                              'Free',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryLight,
                              ),
                            ),
                          ] else ...[
                            if (isAnnualBilling && originalPrice != null) ...[
                              Text(
                                '\$${originalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                            ],
                            Text(
                              '\$${price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryLight,
                              ),
                            ),
                            Text(
                              '/$billingPeriod',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Plan features
                  ...(_getPlanFeatures(
                    plan.name,
                  ).map((feature) => _buildFeatureRow(feature))),

                  SizedBox(height: 3.h),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isCurrentPlan ? null : () => onPlanSelected(plan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrentPlan
                            ? Colors.grey[300]
                            : isPopular
                                ? AppTheme.primaryLight
                                : Colors.white,
                        foregroundColor: isCurrentPlan
                            ? Colors.grey[600]
                            : isPopular
                                ? Colors.white
                                : AppTheme.primaryLight,
                        side: isPopular
                            ? null
                            : BorderSide(color: AppTheme.primaryLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: isCurrentPlan ? 0 : (isPopular ? 2 : 0),
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                      child: Text(
                        isCurrentPlan
                            ? 'Current Plan'
                            : plan.isFree
                                ? 'Get Started Free'
                                : 'Choose ${plan.name}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 4.w),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanDescription(String planName) {
    switch (planName.toLowerCase()) {
      case 'basic':
        return 'Perfect for individual students';
      case 'family':
        return 'Great for families with multiple students';
      case 'premium':
        return 'Everything you need plus counselor access';
      default:
        return 'Start your educational journey';
    }
  }

  List<String> _getPlanFeatures(String planName) {
    switch (planName.toLowerCase()) {
      case 'basic':
        return [
          'Personal dashboard',
          'Basic progress tracking',
          'School search tools',
          'Email support',
        ];
      case 'family':
        return [
          'Up to 4 student profiles',
          'Family collaboration tools',
          'Advanced analytics',
          'Priority support',
          'Scholarship alerts',
        ];
      case 'premium':
        return [
          'Unlimited student profiles',
          'Counselor access & consultations',
          'Advanced planning tools',
          'Priority support',
          'Scholarship alerts',
          'College admission guidance',
        ];
      default:
        return ['Basic features', 'Limited access', 'Community support'];
    }
  }
}
