import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/user_subscription.dart';
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';
import '../../services/subscription_service.dart';
import './widgets/payment_history_widget.dart';
import './widgets/subscription_management_widget.dart';
import './widgets/subscription_status_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserSubscription? _currentSubscription;
  List<Map<String, dynamic>> _paymentHistory = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSubscriptionData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptionData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Don't redirect to login immediately - allow viewing subscription plans
      // if (!AuthService.instance.isAuthenticated) {
      //   Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      //   return;
      // }

      // Load current subscription only if authenticated
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

      // Load payment history only if authenticated
      List<Map<String, dynamic>> paymentHistory = [];
      if (AuthService.instance.isAuthenticated) {
        try {
          paymentHistory =
              await SubscriptionService.instance.getPaymentHistory();
        } catch (e) {
          // Continue without payment history if there's an error
          debugPrint('Error loading payment history: $e');
        }
      }

      setState(() {
        _currentSubscription = currentSubscription;
        _paymentHistory = paymentHistory;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _manageSubscription() async {
    try {
      if (_currentSubscription?.stripeCustomerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active subscription found'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final portalUrl =
          await PaymentService.instance.createCustomerPortalSession(
        returnUrl: kIsWeb ? Uri.base.toString() : 'nextmatric://subscription',
      );

      if (kIsWeb) {
        // For web, show message with URL
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening customer portal: $portalUrl'),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // For mobile, you'd open the URL with url_launcher
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening customer portal: $portalUrl'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open customer portal: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle checkout URL from navigation arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final checkoutUrl = arguments?['checkout_url'] as String?;

    if (checkoutUrl != null) {
      // Show checkout handling UI
      return _buildCheckoutScreen(checkoutUrl);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'My Subscription',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(179),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Billing'),
            Tab(text: 'History'),
          ],
        ),
        actions: [
          if (_currentSubscription != null &&
              _currentSubscription?.stripeCustomerId != null)
            IconButton(
              onPressed: _manageSubscription,
              icon: const Icon(Icons.settings),
              tooltip: 'Manage Subscription',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildSubscriptionContent(),
    );
  }

  Widget _buildCheckoutScreen(String checkoutUrl) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Complete Your Subscription'),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payment,
                size: 20.w,
                color: AppTheme.primaryLight,
              ),
              SizedBox(height: 3.h),
              Text(
                'Complete Your Subscription',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                'You will be redirected to Stripe to complete your payment securely.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // In production, you'd use url_launcher to open the checkout URL
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening checkout: $checkoutUrl'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Complete Payment',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 15.w,
              color: Colors.red,
            ),
            SizedBox(height: 2.h),
            Text(
              'Failed to load subscription data',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadSubscriptionData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Overview tab
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                SubscriptionStatusCard(
                  subscription: _currentSubscription,
                  onUpgrade: () =>
                      Navigator.pushNamed(context, AppRoutes.paymentScreen),
                  onManage: _currentSubscription?.stripeCustomerId != null
                      ? _manageSubscription
                      : null,
                ),
                SizedBox(height: 3.h),
                SubscriptionManagementWidget(
                  subscription: _currentSubscription,
                  onRefresh: _loadSubscriptionData,
                ),
              ],
            ),
          ),
        ),
        // Billing tab
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                if (AuthService.instance.isAuthenticated)
                  _currentSubscription != null
                      ? _buildBillingInfo()
                      : _buildNoBillingInfo()
                else
                  _buildUnauthenticatedBillingInfo(),
              ],
            ),
          ),
        ),
        // History tab
        AuthService.instance.isAuthenticated
            ? PaymentHistoryWidget(
                paymentHistory: _paymentHistory,
                onRefresh: _loadSubscriptionData,
              )
            : _buildUnauthenticatedHistoryInfo(),
      ],
    );
  }

  Widget _buildUnauthenticatedBillingInfo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 15.w,
            color: AppTheme.primaryLight,
          ),
          SizedBox(height: 2.h),
          Text(
            'Sign In Required',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Please sign in to view your billing information and manage your subscription.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.loginScreen),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign In'),
              ),
              SizedBox(width: 3.w),
              OutlinedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.paymentScreen),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryLight,
                ),
                child: const Text('View Plans'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedHistoryInfo() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 15.w,
              color: Colors.grey,
            ),
            SizedBox(height: 2.h),
            Text(
              'Payment History Unavailable',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Sign in to view your payment history and transaction details.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.loginScreen),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Information',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        SizedBox(height: 2.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBillingRow(
                    'Plan', _currentSubscription?.plan?.name ?? 'Unknown'),
                _buildBillingRow('Status',
                    _formatStatus(_currentSubscription?.status ?? '')),
                if (_currentSubscription?.plan?.price != null)
                  _buildBillingRow(
                    'Amount',
                    '\$${_currentSubscription!.plan!.price.toStringAsFixed(2)}/${_currentSubscription!.plan!.billingInterval}',
                  ),
                if (_currentSubscription?.currentPeriodEnd != null)
                  _buildBillingRow(
                    'Next Billing Date',
                    _formatDate(_currentSubscription!.currentPeriodEnd!),
                  ),
                if (_currentSubscription?.cancelAtPeriodEnd == true)
                  _buildBillingRow('Cancellation', 'Will cancel at period end'),
              ],
            ),
          ),
        ),
        SizedBox(height: 3.h),
        if (_currentSubscription?.stripeCustomerId != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _manageSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Manage Billing',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoBillingInfo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 15.w,
            color: Colors.grey,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Active Subscription',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Upgrade to access premium features and billing information.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.paymentScreen),
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return '✅ Active';
      case 'canceled':
        return '❌ Canceled';
      case 'past_due':
        return '⚠️ Past Due';
      case 'unpaid':
        return '💳 Unpaid';
      case 'trialing':
        return '🆓 Trial';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
