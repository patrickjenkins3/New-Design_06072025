import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import './widgets/confirmation_step_widget.dart';
import './widgets/parent_info_step_widget.dart';
import './widgets/registration_progress_widget.dart';
import './widgets/social_login_widget.dart';
import './widgets/teen_info_step_widget.dart';

class ProgressiveRegistrationScreen extends StatefulWidget {
  const ProgressiveRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<ProgressiveRegistrationScreen> createState() =>
      _ProgressiveRegistrationScreenState();
}

class _ProgressiveRegistrationScreenState
    extends State<ProgressiveRegistrationScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final SupabaseClient _client = SupabaseService.instance.client;
  final AuthService _authService = AuthService.instance;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final Map<String, TextEditingController> _controllers = {
    'parentName': TextEditingController(),
    'parentEmail': TextEditingController(),
    'parentPassword': TextEditingController(),
    'confirmPassword': TextEditingController(),
    'teenName': TextEditingController(),
    'teenEmail': TextEditingController(),
    'teenGrade': TextEditingController(),
    'teenSchool': TextEditingController(),
  };

  // State variables
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _skipTeenInfo = false;
  Map<String, dynamic> _registrationData = {};

  // Add validation methods from AuthService
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep < 2) {
      if (await _validateCurrentStep()) {
        await _animateToStep(_currentStep + 1);
      }
    } else {
      await _completeRegistration();
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep > 0) {
      await _animateToStep(_currentStep - 1);
    }
  }

  Future<void> _animateToStep(int step) async {
    await _slideController.reverse();

    setState(() {
      _currentStep = step;
      _error = null;
    });

    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    await _slideController.forward();
  }

  Future<bool> _validateCurrentStep() async {
    setState(() => _error = null);

    switch (_currentStep) {
      case 0:
        return _validateParentInfo();
      case 1:
        return _validateTeenInfo();
      case 2:
        return _validateTermsAndConfirmation();
      default:
        return false;
    }
  }

  bool _validateParentInfo() {
    final name = _controllers['parentName']!.text.trim();
    final email = _controllers['parentEmail']!.text.trim();
    final password = _controllers['parentPassword']!.text;
    final confirmPassword = _controllers['confirmPassword']!.text;

    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return false;
    }

    if (!_isValidEmail(email)) {
      setState(() => _error = 'Please enter a valid email address');
      return false;
    }

    if (!_isValidPassword(password)) {
      setState(() => _error =
          'Password must be at least 8 characters with uppercase, lowercase, and number');
      return false;
    }

    if (password != confirmPassword) {
      setState(() => _error = 'Passwords do not match');
      return false;
    }

    // Store parent data
    _registrationData['parentName'] = name;
    _registrationData['parentEmail'] = email;
    _registrationData['parentPassword'] = password;

    return true;
  }

  bool _validateTeenInfo() {
    if (_skipTeenInfo) {
      _registrationData['skipTeenInfo'] = true;
      return true;
    }

    final name = _controllers['teenName']!.text.trim();
    final email = _controllers['teenEmail']!.text.trim();

    if (name.isNotEmpty &&
        email.isNotEmpty &&
        !_isValidEmail(email)) {
      setState(() => _error = 'Please enter a valid teen email address');
      return false;
    }

    // Store teen data (optional)
    _registrationData['teenName'] = name;
    _registrationData['teenEmail'] = email;
    _registrationData['teenGrade'] = _controllers['teenGrade']!.text.trim();
    _registrationData['teenSchool'] = _controllers['teenSchool']!.text.trim();

    return true;
  }

  bool _validateTermsAndConfirmation() {
    if (!_agreedToTerms) {
      setState(() => _error = 'Please agree to the Terms of Service');
      return false;
    }

    if (!_agreedToPrivacy) {
      setState(() => _error = 'Please agree to the Privacy Policy');
      return false;
    }

    return true;
  }

  Future<void> _completeRegistration() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Register with Supabase Auth
      final authResponse = await _client.auth.signUp(
        email: _registrationData['parentEmail'],
        password: _registrationData['parentPassword'],
        data: {
          'full_name': _registrationData['parentName'],
          'user_type': 'parent',
        },
      );

      if (authResponse.user == null) {
        throw Exception('Registration failed. Please try again.');
      }

      // Create user profile
      await _client.from('user_profiles').insert({
        'id': authResponse.user!.id,
        'email': _registrationData['parentEmail'],
        'full_name': _registrationData['parentName'],
        'role': 'free',
      });

      // Create free trial subscription
      final freePlan = await _client
          .from('subscription_plans')
          .select()
          .eq('name', 'Free Plan')
          .single();

      await _client.from('subscriptions').insert({
        'user_id': authResponse.user!.id,
        'plan_id': freePlan['id'],
        'status': 'trialing',
        'current_period_start': DateTime.now().toIso8601String(),
        'current_period_end':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });

      // Show success and navigate
      _showRegistrationSuccess();

      // Navigate to free trial dashboard after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacementNamed(
            context, AppRoutes.freeTrialDashboardScreen);
      }
    } catch (error) {
      setState(() {
        _error = 'Registration failed: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showRegistrationSuccess() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 2.w),
            Text(
              'Welcome to your free trial!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      bool success = false;

      switch (provider) {
        case 'google':
          setState(() => _error = 'Google Sign-In coming soon');
          return;
        case 'apple':
          // Apple sign-in would be implemented here
          setState(() => _error = 'Apple Sign-In coming soon');
          return;
        case 'facebook':
          success = await _client.auth.signInWithOAuth(OAuthProvider.facebook);
          break;
      }

      if (success) {
        Navigator.pushReplacementNamed(
            context, AppRoutes.freeTrialDashboardScreen);
      } else {
        setState(() => _error = 'Social login failed. Please try again.');
      }
    } catch (error) {
      setState(() => _error = 'Social login failed: ${error.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            RegistrationProgressWidget(
              currentStep: _currentStep,
              totalSteps: 3,
            ),

            // Content
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1ParentInfo(),
                      _buildStep2TeenInfo(),
                      _buildStep3Confirmation(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1ParentInfo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Create Your Account',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 1.h),

          Text(
            'Let\'s start with your basic information',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 4.h),

          // Social login options
          SocialLoginWidget(
            onGooglePressed: () => _handleSocialLogin('google'),
            onApplePressed: () => _handleSocialLogin('apple'),
            onFacebookPressed: () => _handleSocialLogin('facebook'),
            isLoading: _isLoading,
          ),

          SizedBox(height: 4.h),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'or continue with email',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),

          SizedBox(height: 4.h),

          // Parent information form
          ParentInfoStepWidget(
            controllers: _controllers,
            error: _error,
          ),

          SizedBox(height: 4.h),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStep2TeenInfo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Teen Information',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 1.h),

          Text(
            'Add your teen\'s information for personalized recommendations (optional)',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 4.h),

          // Skip option
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 20.sp),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skip for Now',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      Text(
                        'You can add teen information later in your profile settings',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _skipTeenInfo,
                  onChanged: (value) => setState(() => _skipTeenInfo = value),
                  activeColor: Colors.blue[600],
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Teen information form
          TeenInfoStepWidget(
            controllers: _controllers,
            isSkipped: _skipTeenInfo,
            error: _error,
          ),

          SizedBox(height: 4.h),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStep3Confirmation() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Almost Done!',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 1.h),

          Text(
            'Review your information and complete your registration',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 4.h),

          // Confirmation step
          ConfirmationStepWidget(
            registrationData: _registrationData,
            agreedToTerms: _agreedToTerms,
            agreedToPrivacy: _agreedToPrivacy,
            onTermsChanged: (value) =>
                setState(() => _agreedToTerms = value ?? false),
            onPrivacyChanged: (value) =>
                setState(() => _agreedToPrivacy = value ?? false),
            error: _error,
          ),

          SizedBox(height: 4.h),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        if (_error != null) ...[
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 20.sp),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    _error!,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
        ],

        // Next/Complete button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20.sp,
                    width: 20.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _currentStep == 2 ? 'Complete Registration' : 'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        if (_currentStep > 0) ...[
          SizedBox(height: 2.h),

          // Back button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _previousStep,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Text(
                'Back',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],

        SizedBox(height: 2.h),

        // Login link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(
                  context, AppRoutes.loginScreen),
              child: Text(
                'Sign In',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}