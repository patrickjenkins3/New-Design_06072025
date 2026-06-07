import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';
import '../models/user_subscription.dart';

class SubscriptionService {
  static SubscriptionService? _instance;
  static SubscriptionService get instance =>
      _instance ??= SubscriptionService._();
  SubscriptionService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get all subscription plans
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final response = await _client
          .from('subscription_plans')
          .select()
          .eq('is_active', true)
          .order('price');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get subscription plans: $error');
    }
  }

  // Get user's current subscription
  Future<UserSubscription?> getCurrentSubscription() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('subscriptions')
          .select('*, subscription_plans(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;
      return UserSubscription.fromJson(response.first);
    } catch (error) {
      throw Exception('Failed to get current subscription: $error');
    }
  }

  // Create subscription
  Future<Map<String, dynamic>> createSubscription({
    required String planId,
    required String stripeSubscriptionId,
    required String stripeCustomerId,
    String status = 'active',
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('subscriptions')
          .insert({
            'user_id': user.id,
            'plan_id': planId,
            'stripe_subscription_id': stripeSubscriptionId,
            'stripe_customer_id': stripeCustomerId,
            'status': status,
            'current_period_start': currentPeriodStart?.toIso8601String(),
            'current_period_end': currentPeriodEnd?.toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create subscription: $error');
    }
  }

  // Update subscription status
  Future<void> updateSubscriptionStatus({
    required String subscriptionId,
    required String status,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    bool? cancelAtPeriodEnd,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (currentPeriodStart != null) {
        updates['current_period_start'] = currentPeriodStart.toIso8601String();
      }
      if (currentPeriodEnd != null) {
        updates['current_period_end'] = currentPeriodEnd.toIso8601String();
      }
      if (cancelAtPeriodEnd != null) {
        updates['cancel_at_period_end'] = cancelAtPeriodEnd;
      }

      await _client
          .from('subscriptions')
          .update(updates)
          .eq('id', subscriptionId);
    } catch (error) {
      throw Exception('Failed to update subscription status: $error');
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _client.from('subscriptions').update({
        'cancel_at_period_end': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', subscriptionId);
    } catch (error) {
      throw Exception('Failed to cancel subscription: $error');
    }
  }

  // Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('payment_history')
          .select('*, subscriptions(*, subscription_plans(*))')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get payment history: $error');
    }
  }

  // Record payment
  Future<void> recordPayment({
    required String subscriptionId,
    required String stripePaymentIntentId,
    required double amount,
    required String status,
    String currency = 'usd',
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('payment_history').insert({
        'user_id': user.id,
        'subscription_id': subscriptionId,
        'stripe_payment_intent_id': stripePaymentIntentId,
        'amount': amount,
        'currency': currency,
        'status': status,
      });
    } catch (error) {
      throw Exception('Failed to record payment: $error');
    }
  }

  // Check if user has premium access
  Future<bool> hasPremiumAccess() async {
    try {
      final subscription = await getCurrentSubscription();
      if (subscription == null) return false;

      final status = subscription.status;
      return status == 'active' || status == 'trialing';
    } catch (error) {
      return false;
    }
  }
}
