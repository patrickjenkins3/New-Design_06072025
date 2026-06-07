import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  // Public getter for SupabaseClient to be used by other services
  SupabaseClient get client => SupabaseService.instance.client;

  // Current user
  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Enhanced password validation with complexity requirements
  bool _isValidPassword(String password) {
    if (password.length < 12) return false; // Increased minimum length

    // Check for complexity requirements
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    // Require at least 3 of 4 character types
    int complexity = 0;
    if (hasUpperCase) complexity++;
    if (hasLowerCase) complexity++;
    if (hasDigits) complexity++;
    if (hasSpecialCharacters) complexity++;

    if (complexity < 3) return false;

    // Check for common weak patterns
    if (_hasWeakPasswordPattern(password)) return false;

    return true;
  }

  // Check for weak password patterns
  bool _hasWeakPasswordPattern(String password) {
    final lowercasePassword = password.toLowerCase();

    // Common weak passwords and patterns
    const weakPatterns = [
      'password',
      '123456',
      'qwerty',
      'abc123',
      'admin',
      'welcome',
      'letmein',
      'monkey',
      'dragon',
      'master',
      'shadow',
      'password123'
    ];

    for (final pattern in weakPatterns) {
      if (lowercasePassword.contains(pattern)) return true;
    }

    // Check for keyboard patterns
    const keyboardPatterns = [
      'qwertyuiop',
      'asdfghjkl',
      'zxcvbnm',
      '1234567890'
    ];

    for (final pattern in keyboardPatterns) {
      if (lowercasePassword.contains(pattern.substring(0, 4))) return true;
    }

    // Check for repeated characters (3 or more in a row)
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) return true;

    return false;
  }

  // Enhanced sign up with stronger password requirements
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      // Input validation
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address.');
      }
      if (!_isValidPassword(password)) {
        throw Exception(
            'Password must be at least 12 characters with uppercase, lowercase, numbers, and special characters.');
      }

      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? '',
          'role': 'free',
        },
      );
      return response;
    } catch (error) {
      throw Exception(_getAuthErrorMessage(error));
    }
  }

  // Sign in
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Input validation
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address.');
      }
      if (password.isEmpty) {
        throw Exception('Password is required.');
      }

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception(_getAuthErrorMessage(error));
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (error) {
      throw Exception('Unable to sign out. Please try again.');
    }
  }

  // Password reset with environment variable for redirect URL
  Future<void> resetPassword(String email) async {
    try {
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address.');
      }

      const String redirectUrl = String.fromEnvironment('PASSWORD_RESET_URL',
          defaultValue: 'https://collabfuture.com/reset-password');

      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
    } catch (error) {
      throw Exception('Unable to send password reset email. Please try again.');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (error) {
      return null; // Return null instead of throwing for better UX
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    String? role,
  }) async {
    try {
      if (!isAuthenticated) throw Exception('Please sign in to continue.');

      // Input validation
      if (fullName != null && fullName.trim().isEmpty) {
        throw Exception('Name cannot be empty.');
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName.trim();
      if (role != null) updates['role'] = role;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await client
          .from('user_profiles')
          .update(updates)
          .eq('id', currentUser!.id);
    } catch (error) {
      throw Exception('Unable to update profile. Please try again.');
    }
  }

  // Get user sessions
  Future<List<Map<String, dynamic>>> getUserSessions() async {
    try {
      if (!isAuthenticated) return [];

      final response = await client
          .from('user_sessions')
          .select()
          .eq('user_id', currentUser!.id)
          .order('last_activity', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      return [];
    }
  }

  // Log security event
  Future<void> logSecurityEvent({
    required String eventType,
    String? eventDescription,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (!isAuthenticated) return;

      await client.from('security_audit_log').insert({
        'user_id': currentUser!.id,
        'event_type': eventType,
        'event_description': eventDescription,
        'ip_address': ipAddress,
        'user_agent': userAgent,
        'metadata': metadata ?? {},
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      // Log error but don't throw to prevent disrupting user flow
      print('Failed to log security event: ${_sanitizeError(error)}');
    }
  }

  // Get security settings
  Future<Map<String, dynamic>?> getSecuritySettings() async {
    try {
      if (!isAuthenticated) return null;

      final response = await client
          .from('security_settings')
          .select()
          .eq('user_id', currentUser!.id)
          .single();

      return response;
    } catch (error) {
      return null;
    }
  }

  // Update security settings
  Future<void> updateSecuritySettings({
    bool? biometricEnabled,
    bool? pinEnabled,
    bool? twoFactorEnabled,
    int? appLockTimeout,
    bool? backgroundBlurEnabled,
    String? emergencyContactEmail,
  }) async {
    try {
      if (!isAuthenticated) throw Exception('Please sign in to continue.');

      // Input validation for email
      if (emergencyContactEmail != null &&
          emergencyContactEmail.isNotEmpty &&
          !_isValidEmail(emergencyContactEmail)) {
        throw Exception('Please enter a valid emergency contact email.');
      }

      final updates = <String, dynamic>{};
      if (biometricEnabled != null)
        updates['biometric_enabled'] = biometricEnabled;
      if (pinEnabled != null) updates['pin_enabled'] = pinEnabled;
      if (twoFactorEnabled != null)
        updates['two_factor_enabled'] = twoFactorEnabled;
      if (appLockTimeout != null) updates['app_lock_timeout'] = appLockTimeout;
      if (backgroundBlurEnabled != null)
        updates['background_blur_enabled'] = backgroundBlurEnabled;
      if (emergencyContactEmail != null)
        updates['emergency_contact_email'] = emergencyContactEmail;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await client
          .from('security_settings')
          .update(updates)
          .eq('user_id', currentUser!.id);
    } catch (error) {
      throw Exception('Unable to update security settings. Please try again.');
    }
  }

  // Input validation methods
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }

  // Error message sanitization
  String _getAuthErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('invalid_credentials') ||
        errorString.contains('invalid login')) {
      return 'Email or password is incorrect. Please try again.';
    } else if (errorString.contains('email_not_confirmed')) {
      return 'Please check your email and confirm your account.';
    } else if (errorString.contains('too_many_requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Connection issue. Please check your internet and try again.';
    } else if (errorString.contains('user_not_found')) {
      return 'No account found with this email address.';
    } else {
      return 'Unable to complete request. Please try again.';
    }
  }

  String _sanitizeError(dynamic error) {
    final errorString = error.toString();
    // Remove sensitive information from error messages
    return errorString
        .replaceAll(
            RegExp(r'password[^\s]*', caseSensitive: false), '[REDACTED]')
        .replaceAll(RegExp(r'key[^\s]*', caseSensitive: false), '[REDACTED]')
        .replaceAll(RegExp(r'token[^\s]*', caseSensitive: false), '[REDACTED]');
  }

  // Demo credentials from environment variables
  bool isDemoCredentials(String email, String password) {
    const String demoEmail = String.fromEnvironment('DEMO_EMAIL',
        defaultValue: 'demo@collabfuture.com');
    const String demoPassword = String.fromEnvironment('DEMO_PASSWORD',
        defaultValue: 'SecureDemo2024!');

    return email.toLowerCase().trim() == demoEmail.toLowerCase() &&
        password == demoPassword;
  }

  // Auth state stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
