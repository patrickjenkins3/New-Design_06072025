import 'package:dio/dio.dart';

import './auth_service.dart';
import './supabase_service.dart';

class PaymentService {
  static PaymentService? _instance;
  static PaymentService get instance => _instance ??= PaymentService._();
  PaymentService._();

  final Dio _dio = Dio();
  final String _baseUrl = '${SupabaseService.supabaseUrl}/functions/v1';

  String get _stripePublishableKey =>
      const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  // Create subscription checkout session for Stripe products
  Future<String> createSubscriptionCheckout({
    required String planId,
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final session = AuthService.instance.client.auth.currentSession;
      if (session == null) throw Exception('No active session');

      final response = await _dio.post(
        '$_baseUrl/create-subscription-checkout',
        data: {
          'plan_id': planId,
          'success_url': successUrl,
          'cancel_url': cancelUrl,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['checkout_url'] as String;
      } else {
        throw Exception(
          'Failed to create checkout session: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.response?.data != null) {
        if (e.response?.data['error'] != null) {
          errorMessage = 'Payment error: ${e.response?.data['error']}';
        } else {
          errorMessage =
              'Server error: ${e.response?.statusMessage ?? 'Unknown error'}';
        }
      } else if (e.message?.contains('SocketException') == true) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Unexpected error: $e');
    }
  }

  // Create customer portal session for subscription management
  Future<String> createCustomerPortalSession({
    required String returnUrl,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final session = AuthService.instance.client.auth.currentSession;
      if (session == null) throw Exception('No active session');

      final response = await _dio.post(
        '$_baseUrl/create-customer-portal',
        data: {'return_url': returnUrl},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['portal_url'] as String;
      } else {
        throw Exception(
          'Failed to create customer portal session: ${response.statusMessage}',
        );
      }
    } catch (e) {
      throw Exception('Failed to create customer portal session: $e');
    }
  }

  // Sync Stripe products to Supabase subscription plans
  Future<void> syncStripeProducts() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final session = AuthService.instance.client.auth.currentSession;
      if (session == null) throw Exception('No active session');

      final response = await _dio.post(
        '$_baseUrl/sync-stripe-products',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to sync Stripe products: ${response.statusMessage}',
        );
      }
    } catch (e) {
      throw Exception('Failed to sync Stripe products: $e');
    }
  }

  // Create webhook endpoint handler
  Future<void> handleWebhook({
    required String payload,
    required String signature,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/stripe-webhook',
        data: {'payload': payload, 'signature': signature},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to handle webhook: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to handle webhook: $e');
    }
  }
}
