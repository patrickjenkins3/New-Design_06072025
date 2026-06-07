import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/subscription_models.dart';
import '../../models/user_subscription.dart' hide SubscriptionPlan;
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';
import '../../services/subscription_service.dart';
import './widgets/feature_comparison_widget.dart';
import './widgets/pricing_plan_card.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = true;
  String? _errorMessage;
  UserSubscription? _currentSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load subscription plans
      final plansData =
          await SubscriptionService.instance.getSubscriptionPlans();
      final plans =
          plansData.map((plan) => SubscriptionPlan.fromJson(plan)).toList();

      // Load current subscription if user is authenticated
      UserSubscription? currentSubscription;
      if (AuthService.instance.isAuthenticated) {
        try {
          currentSubscription =
              await SubscriptionService.instance.getCurrentSubscription();
        } catch (e) {
          // Continue without subscription data if there's an error
          debugPrint('Error loading subscription: $e');
        }
      }

      setState(() {
        _plans = plans;
        _currentSubscription = currentSubscription;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _selectPlan(SubscriptionPlan plan) async {
    if (!AuthService.instance.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.loginScreen);
      return;
    }

    if (plan.isFree) {
      // Handle free plan selection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are already on the free plan!'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Create checkout session for premium plan
      final checkoutUrl =
          await PaymentService.instance.createSubscriptionCheckout(
        planId: plan.id,
        successUrl:
            '${kIsWeb ? Uri.base.toString() : 'collabfuture://'}subscription/success',
        cancelUrl: '${kIsWeb ? Uri.base.toString() : 'collabfuture://'}pricing',
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (kIsWeb) {
        // For web, open checkout URL in same tab
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } else {
          throw Exception('Could not launch checkout URL');
        }
      } else {
        // For mobile, navigate to subscription screen with checkout URL
        Navigator.pushNamed(
          context,
          AppRoutes.subscriptionScreen,
          arguments: {'checkout_url': checkoutUrl},
        );
      }
    } catch (error) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to start checkout: ${error.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _selectPlan(plan),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.paymentScreen),
            child: const Text(
              'Payment',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildPricingContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 15.w, color: Colors.red),
            SizedBox(height: 2.h),
            Text(
              'Failed to load pricing plans',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            _buildHeader(),
            SizedBox(height: 4.h),

            // Current subscription status
            if (_currentSubscription != null) _buildCurrentSubscriptionStatus(),

            // Pricing plans
            _buildPricingPlans(),
            SizedBox(height: 4.h),

            // Feature comparison
            const FeatureComparisonWidget(),
            SizedBox(height: 4.h),

            // FAQ or additional info
            _buildAdditionalInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Unlock Your Academic Potential',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          'Choose the plan that fits your college preparation needs. Start your journey to academic success with CollabFuture.',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCurrentSubscriptionStatus() {
    final subscription = _currentSubscription!;
    final isActive = subscription.isActive;
    final isPastDue = subscription.isPastDue;

    Color statusColor = isActive
        ? Colors.green
        : isPastDue
            ? Colors.orange
            : Colors.red;

    String statusText = isActive
        ? 'Active'
        : isPastDue
            ? 'Past Due'
            : 'Inactive';

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.info,
            color: statusColor,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Plan: ${subscription.plan?.name ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor.withAlpha(204),
                  ),
                ),
                if (subscription.currentPeriodEnd != null)
                  Text(
                    'Expires: ${DateFormatter.formatDate(subscription.currentPeriodEnd!)}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                if (subscription.cancelAtPeriodEnd)
                  Text(
                    'Scheduled for cancellation',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                Text(
                  'Status: $statusText',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.subscriptionScreen),
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingPlans() {
    if (_plans.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        child: Center(
          child: Text(
            'No pricing plans available',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        SizedBox(height: 2.h),
        if (_plans.length <= 2)
          Row(
            children: _plans.map<Widget>((plan) {
              final isCurrentPlan = _currentSubscription?.planId == plan.id;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: PricingPlanCard(
                    plan: plan,
                    isCurrentPlan: isCurrentPlan,
                    onSelectPlan: () => _selectPlan(plan),
                  ),
                ),
              );
            }).toList(),
          )
        else
          Column(
            children: _plans.map<Widget>((plan) {
              final isCurrentPlan = _currentSubscription?.planId == plan.id;
              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: PricingPlanCard(
                  plan: plan,
                  isCurrentPlan: isCurrentPlan,
                  onSelectPlan: () => _selectPlan(plan),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        SizedBox(height: 2.h),
        _buildFAQItem(
          'Can I change my plan anytime?',
          'Yes! You can upgrade or downgrade your plan at any time. Changes will be reflected in your next billing cycle.',
        ),
        _buildFAQItem(
          'What happens if I cancel?',
          'You can cancel anytime and continue using premium features until your current period ends.',
        ),
        _buildFAQItem(
          'Is there a free trial?',
          'Yes! New users get a 7-day free trial with full access to premium features.',
        ),
        _buildFAQItem(
          'Are there any setup fees?',
          'No setup fees! You only pay for your chosen subscription plan.',
        ),
        SizedBox(height: 2.h),
        Center(
          child: TextButton(
            onPressed: () {
              // You can add support contact functionality here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact support at support@collabfuture.com'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Have more questions? Contact Support'),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            answer,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
