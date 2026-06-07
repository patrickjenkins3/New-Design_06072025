import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive_utils.dart';
import '../../models/subscription_models.dart';
import '../../models/user_subscription.dart' hide SubscriptionPlan;
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';
import '../../services/subscription_service.dart';
import '../../widgets/custom_error_widget.dart';
import './widgets/family_billing_controls_widget.dart';
import './widgets/payment_form_widget.dart';
import './widgets/payment_header_widget.dart';
import './widgets/subscription_plans_widget.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = true;
  String? _errorMessage;
  UserSubscription? _currentSubscription;
  SubscriptionPlan? _selectedPlan;
  bool _isAnnualBilling = false;
  bool _showPaymentForm = false;
  String? _selectedPaymentMethod;
  bool _isProcessingPayment = false;

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
        _errorMessage = _getUserFriendlyError(error.toString());
        _isLoading = false;
      });
    }
  }

  String _getUserFriendlyError(String error) {
    if (error.contains('network') || error.contains('connection')) {
      return AppStrings.networkError;
    } else if (error.contains('timeout')) {
      return AppStrings.timeoutError;
    } else if (error.contains('auth')) {
      return AppStrings.authenticationError;
    } else {
      return AppStrings.serverError;
    }
  }

  void _onPlanSelected(SubscriptionPlan plan) {
    setState(() {
      _selectedPlan = plan;
      _showPaymentForm = !plan.isFree;
    });

    if (plan.isFree) {
      _processFreeSubscription();
    }
  }

  void _onBillingToggle(bool isAnnual) {
    setState(() {
      _isAnnualBilling = isAnnual;
    });
  }

  void _onPaymentMethodSelected(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  Future<void> _processFreeSubscription() async {
    if (!AuthService.instance.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.loginScreen);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Welcome to ${AppStrings.appName}! Your free plan is active.',
          style: TextStyle(fontSize: context.responsiveFontSize(14)),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Redirect to progressive registration after free plan selection
    Navigator.pushReplacementNamed(
        context, AppRoutes.progressiveRegistrationScreen);
  }

  Future<void> _processPayment() async {
    if (_selectedPlan == null || _selectedPaymentMethod == null) return;

    if (!AuthService.instance.isAuthenticated) {
      Navigator.pushNamed(context, AppRoutes.loginScreen);
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Create checkout session for premium plan
      final checkoutUrl =
          await PaymentService.instance.createSubscriptionCheckout(
        planId: _selectedPlan!.id,
        successUrl:
            '${kIsWeb ? Uri.base.toString() : 'collabfuture://'}payment/success',
        cancelUrl: '${kIsWeb ? Uri.base.toString() : 'collabfuture://'}payment',
      );

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
          arguments: {
            'checkout_url': checkoutUrl,
            'success_redirect': AppRoutes.progressiveRegistrationScreen,
          },
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getUserFriendlyError(error.toString()),
            style: TextStyle(fontSize: context.responsiveFontSize(14)),
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: AppStrings.retry,
            onPressed: _processPayment,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _backToPlans() {
    setState(() {
      _showPaymentForm = false;
      _selectedPlan = null;
      _selectedPaymentMethod = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const CustomLoadingWidget(message: 'Loading payment options...')
            : _errorMessage != null
                ? CustomErrorWidget.general(
                    customMessage: _errorMessage,
                    onRetry: _loadData,
                  )
                : _buildPaymentContent(),
      ),
    );
  }

  Widget _buildPaymentContent() {
    return Column(
      children: [
        PaymentHeaderWidget(
          title: _showPaymentForm ? 'Complete Payment' : 'Choose Your Plan',
          subtitle: _showPaymentForm
              ? 'Secure payment for your ${AppStrings.appName} subscription'
              : 'Select the perfect plan for your educational journey',
          onBackPressed: _showPaymentForm ? _backToPlans : null,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.maxContentWidth,
                minHeight: context.safeAreaHeight - 150,
              ),
              child: Padding(
                padding: context.responsivePadding(),
                child: _showPaymentForm
                    ? _buildPaymentForm()
                    : _buildPlanSelection(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current subscription status
        if (_currentSubscription != null) ...[
          _buildCurrentSubscriptionStatus(),
          SizedBox(height: 2.h),
        ],

        // Subscription plans with billing toggle
        if (_plans.isNotEmpty) ...[
          SubscriptionPlansWidget(
            plans: _plans,
            currentSubscription: _currentSubscription,
            isAnnualBilling: _isAnnualBilling,
            onPlanSelected: _onPlanSelected,
            onBillingToggle: _onBillingToggle,
          ),
          SizedBox(height: 4.h),
        ] else ...[
          CustomEmptyWidget(
            title: 'No Plans Available',
            message:
                'No subscription plans are currently available. Please try again later or contact support.',
            icon: Icons.credit_card_off,
            actionText: AppStrings.contactSupport,
            onAction: () {
              // Add contact support functionality
            },
          ),
          SizedBox(height: 4.h),
        ],

        // Feature highlights
        _buildFeatureHighlights(),
        SizedBox(height: 3.h),

        // Security & Trust indicators
        _buildSecurityIndicators(),
        SizedBox(height: 4.h), // Extra bottom padding
      ],
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected plan summary
        _buildSelectedPlanSummary(),
        SizedBox(height: 3.h),

        // Payment form
        if (_selectedPlan != null)
          PaymentFormWidget(
            selectedPlan: _selectedPlan!,
            isAnnualBilling: _isAnnualBilling,
            onPaymentMethodSelected: _onPaymentMethodSelected,
            selectedPaymentMethod: _selectedPaymentMethod,
          ),

        SizedBox(height: 3.h),

        // Family billing controls (if applicable)
        if (_selectedPlan?.name.toLowerCase().contains('family') == true) ...[
          const FamilyBillingControlsWidget(),
          SizedBox(height: 3.h),
        ],

        // Payment button
        _buildPaymentButton(),
        SizedBox(height: 2.h),

        // Terms and security info
        _buildTermsAndSecurity(),
        SizedBox(height: 4.h), // Extra bottom padding
      ],
    );
  }

  Widget _buildCurrentSubscriptionStatus() {
    final subscription = _currentSubscription!;
    final isActive = subscription.isActive;

    Color statusColor = isActive ? Colors.green : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: context.responsivePadding(),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: statusColor,
            size: context.iconSize(baseSize: 24),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Plan: ${subscription.plan?.name ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(16),
                    fontWeight: FontWeight.bold,
                    color: statusColor.withAlpha(204),
                  ),
                ),
                if (subscription.currentPeriodEnd != null)
                  Text(
                    'Expires: ${DateFormatter.formatDate(subscription.currentPeriodEnd!)}',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(14),
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.subscriptionScreen),
            child: Text(
              'Manage',
              style: TextStyle(fontSize: context.responsiveFontSize(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPlanSummary() {
    if (_selectedPlan == null) return const SizedBox.shrink();

    final plan = _selectedPlan!;
    final price = plan.getPrice(_isAnnualBilling);
    final billingPeriod = _isAnnualBilling ? 'year' : 'month';

    return Container(
      width: double.infinity,
      padding: context.responsivePadding(),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Plan',
            style: TextStyle(
              fontSize: context.responsiveFontSize(16),
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryLight,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        fontSize: context.responsiveFontSize(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (plan.description.isNotEmpty) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        plan.description,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(14),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.isFree ? 'Free' : '\$${price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(20),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                  if (!plan.isFree) ...[
                    Text(
                      '/$billingPeriod',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(14),
                        color: Colors.grey[600],
                      ),
                    ),
                    if (_isAnnualBilling &&
                        plan.annualPrice != null &&
                        plan.monthlyPrice != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        'Save ${plan.annualSavingsPercentage.round()}%',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(12),
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    final isDisabled = _selectedPaymentMethod == null || _isProcessingPayment;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ElevatedButton(
        onPressed: isDisabled ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDisabled ? Colors.grey[400] : AppTheme.primaryLight,
          foregroundColor: Colors.white,
          elevation: isDisabled ? 0 : 2,
          padding:
              EdgeInsets.symmetric(vertical: context.buttonHeight() * 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.borderRadius()),
          ),
        ),
        child: _isProcessingPayment
            ? SizedBox(
                height: context.iconSize(baseSize: 20),
                width: context.iconSize(baseSize: 20),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: context.iconSize(baseSize: 20),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Complete Secure Payment',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose ${AppStrings.appName}?',
          style: TextStyle(
            fontSize: context.responsiveFontSize(20),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        _buildFeatureItem(
          Icons.school,
          'Personalized Learning Path',
          'AI-powered recommendations tailored to your academic goals',
        ),
        _buildFeatureItem(
          Icons.family_restroom,
          'Family Collaboration',
          'Connect parents, students, and counselors in one platform',
        ),
        _buildFeatureItem(
          Icons.trending_up,
          'Progress Tracking',
          'Real-time insights into academic progress and achievements',
        ),
        _buildFeatureItem(
          Icons.support_agent,
          'Expert Support',
          '24/7 support from educational professionals',
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(context.responsiveFontSize(8)),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha(26),
              borderRadius:
                  BorderRadius.circular(context.borderRadius(baseRadius: 8)),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryLight,
              size: context.iconSize(baseSize: 24),
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
                    fontSize: context.responsiveFontSize(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(14),
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityIndicators() {
    return Container(
      padding: context.responsivePadding(),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(context.borderRadius()),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                color: Colors.green[700],
                size: context.iconSize(baseSize: 24),
              ),
              SizedBox(width: 2.w),
              Text(
                'Secure & Trusted',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTrustBadge(Icons.verified_user, 'SSL Secured'),
              _buildTrustBadge(Icons.credit_card, 'Stripe Protected'),
              _buildTrustBadge(Icons.privacy_tip, 'COPPA Compliant'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.green[700],
          size: context.iconSize(baseSize: 20),
        ),
        SizedBox(height: 0.5.h),
        Text(
          text,
          style: TextStyle(
            fontSize: context.responsiveFontSize(12),
            color: Colors.green[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndSecurity() {
    return Column(
      children: [
        Text(
          'By completing this purchase, you agree to our Terms of Service and Privacy Policy. Your payment is processed securely through Stripe.',
          style: TextStyle(
            fontSize: context.responsiveFontSize(12),
            color: Colors.grey[600],
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Add terms of service link
              },
              child: Text(
                AppStrings.termsOfService,
                style: TextStyle(fontSize: context.responsiveFontSize(12)),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: context.responsiveFontSize(12),
              ),
            ),
            TextButton(
              onPressed: () {
                // Add privacy policy link
              },
              child: Text(
                AppStrings.privacyPolicy,
                style: TextStyle(fontSize: context.responsiveFontSize(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
