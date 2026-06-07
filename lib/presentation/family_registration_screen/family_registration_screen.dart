import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/family_code_section.dart';
import './widgets/parent_information_section.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/teen_information_section.dart';
import './widgets/terms_and_privacy_section.dart';

class FamilyRegistrationScreen extends StatefulWidget {
  const FamilyRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<FamilyRegistrationScreen> createState() =>
      _FamilyRegistrationScreenState();
}

class _FamilyRegistrationScreenState extends State<FamilyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controllers
  final _parentNameController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _teenNameController = TextEditingController();
  final _teenAgeController = TextEditingController();
  final _teenEmailController = TextEditingController();

  // Focus Nodes
  final _parentNameFocus = FocusNode();
  final _parentEmailFocus = FocusNode();
  final _parentPhoneFocus = FocusNode();
  final _teenNameFocus = FocusNode();
  final _teenAgeFocus = FocusNode();
  final _teenEmailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // State Variables
  bool _parentConsentGiven = false;
  bool _termsAccepted = false;
  bool _isLoading = false;
  String _familyCode = '';
  int _currentStep = 1;

  // Error Messages
  String? _parentNameError;
  String? _parentEmailError;
  String? _parentPhoneError;
  String? _teenNameError;
  String? _teenAgeError;
  String? _teenEmailError;
  String? _passwordError;
  String? _confirmPasswordError;

  final List<String> _stepTitles = ['Information', 'Verification', 'Complete'];

  @override
  void initState() {
    super.initState();
    _generateFamilyCode();
  }

  @override
  void dispose() {
    _parentNameController.dispose();
    _parentEmailController.dispose();
    _parentPhoneController.dispose();
    _teenNameController.dispose();
    _teenAgeController.dispose();
    _teenEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _parentNameFocus.dispose();
    _parentEmailFocus.dispose();
    _parentPhoneFocus.dispose();
    _teenNameFocus.dispose();
    _teenAgeFocus.dispose();
    _teenEmailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _generateFamilyCode() {
    final random = Random();
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    String code = '';
    // Generate 4 letters
    for (int i = 0; i < 4; i++) {
      code += letters[random.nextInt(letters.length)];
    }
    // Add year
    code += '2024';

    setState(() {
      _familyCode = code;
    });
  }

  bool _validateForm() {
    bool isValid = true;

    // Reset errors
    setState(() {
      _parentNameError = null;
      _parentEmailError = null;
      _parentPhoneError = null;
      _teenNameError = null;
      _teenAgeError = null;
      _teenEmailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validate parent name
    if (_parentNameController.text.trim().isEmpty) {
      setState(() {
        _parentNameError = 'Parent name is required';
      });
      isValid = false;
    } else if (_parentNameController.text.trim().length < 2) {
      setState(() {
        _parentNameError = 'Name must be at least 2 characters';
      });
      isValid = false;
    }

    // Validate parent email
    if (_parentEmailController.text.trim().isEmpty) {
      setState(() {
        _parentEmailError = 'Email is required';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_parentEmailController.text.trim())) {
      setState(() {
        _parentEmailError = 'Please enter a valid email address';
      });
      isValid = false;
    }

    // Validate parent phone
    if (_parentPhoneController.text.trim().isEmpty) {
      setState(() {
        _parentPhoneError = 'Phone number is required';
      });
      isValid = false;
    } else if (_parentPhoneController.text.trim().length < 10) {
      setState(() {
        _parentPhoneError = 'Phone number must be at least 10 digits';
      });
      isValid = false;
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      isValid = false;
    } else if (_passwordController.text.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters';
      });
      isValid = false;
    }

    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Please confirm your password';
      });
      isValid = false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      isValid = false;
    }

    // Validate teen name
    if (_teenNameController.text.trim().isEmpty) {
      setState(() {
        _teenNameError = 'Teen name is required';
      });
      isValid = false;
    } else if (_teenNameController.text.trim().length < 2) {
      setState(() {
        _teenNameError = 'Name must be at least 2 characters';
      });
      isValid = false;
    }

    // Validate teen age
    if (_teenAgeController.text.trim().isEmpty) {
      setState(() {
        _teenAgeError = 'Age is required';
      });
      isValid = false;
    } else {
      final age = int.tryParse(_teenAgeController.text.trim());
      if (age == null || age < 14 || age > 18) {
        setState(() {
          _teenAgeError = 'Age must be between 14-18 years';
        });
        isValid = false;
      }
    }

    // Validate teen email if provided
    if (_teenEmailController.text.trim().isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(_teenEmailController.text.trim())) {
        setState(() {
          _teenEmailError = 'Please enter a valid email address';
        });
        isValid = false;
      }
    }

    // Validate consent and terms
    if (!_parentConsentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Parental consent is required'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      isValid = false;
    }

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Please accept the Terms of Service and Privacy Policy'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      isValid = false;
    }

    return isValid;
  }

  Future<void> _createFamilyAccount() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _currentStep = 2;
    });

    try {
      // Create auth account first
      final response = await AuthService.instance.signUp(
        email: _parentEmailController.text.trim(),
        password: _passwordController.text,
        fullName: _parentNameController.text.trim(),
      );

      if (response.user != null) {
        // Update user profile with additional information
        await AuthService.instance.updateUserProfile(
          fullName: _parentNameController.text.trim(),
          role: 'premium', // Family accounts get premium features
        );

        // Send verification email notification
        await _sendVerificationEmail();

        setState(() {
          _currentStep = 3;
        });

        // Show success message
        _showSuccessDialog();
      } else {
        throw Exception('Registration failed. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      setState(() {
        _currentStep = 1;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    // Notification about verification email
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Verification email sent to ${_parentEmailController.text}'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 28,
              ),
              SizedBox(width: 2.w),
              Text(
                'Welcome to CollabFuture!',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your family account has been created successfully!',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Family Code:',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _familyCode,
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Next steps:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '• Check your email for verification\n• Share the family code with your teen\n• Start exploring educational opportunities together',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(
                    context, AppRoutes.dashboardScreen);
              },
              child: const Text('Get Started'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow
                        .withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Family Account',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                        Text(
                          'Plan your family\'s future together',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress Indicator
            Padding(
              padding: EdgeInsets.all(4.w),
              child: ProgressIndicatorWidget(
                currentStep: _currentStep,
                totalSteps: 3,
                stepTitles: _stepTitles,
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Parent Information Section
                      ParentInformationSection(
                        parentNameController: _parentNameController,
                        parentEmailController: _parentEmailController,
                        parentPhoneController: _parentPhoneController,
                        parentNameFocus: _parentNameFocus,
                        parentEmailFocus: _parentEmailFocus,
                        parentPhoneFocus: _parentPhoneFocus,
                        parentNameError: _parentNameError,
                        parentEmailError: _parentEmailError,
                        parentPhoneError: _parentPhoneError,
                      ),
                      SizedBox(height: 2.h),

                      // Password Section
                      _buildPasswordSection(),
                      SizedBox(height: 3.h),

                      // Teen Information Section
                      TeenInformationSection(
                        teenNameController: _teenNameController,
                        teenAgeController: _teenAgeController,
                        teenEmailController: _teenEmailController,
                        teenNameFocus: _teenNameFocus,
                        teenAgeFocus: _teenAgeFocus,
                        teenEmailFocus: _teenEmailFocus,
                        teenNameError: _teenNameError,
                        teenAgeError: _teenAgeError,
                        teenEmailError: _teenEmailError,
                        parentConsentGiven: _parentConsentGiven,
                        onParentConsentChanged: (value) {
                          setState(() {
                            _parentConsentGiven = value ?? false;
                          });
                        },
                      ),
                      SizedBox(height: 3.h),

                      // Family Code Section
                      FamilyCodeSection(
                        familyCode: _familyCode,
                        onGenerateCode: _generateFamilyCode,
                      ),
                      SizedBox(height: 3.h),

                      // Terms and Privacy Section
                      TermsAndPrivacySection(
                        termsAccepted: _termsAccepted,
                        onTermsChanged: (value) {
                          setState(() {
                            _termsAccepted = value ?? false;
                          });
                        },
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Button
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow
                        .withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createFamilyAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme
                            .lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'Creating Account...',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'family_restroom',
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Create Family Account',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.loginScreen),
                    child: Text(
                      'Already have an account? Sign In',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w500,
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

  Widget _buildPasswordSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Security',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Create a secure password for your family account',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          // Password field
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorText: _passwordError,
            ),
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_confirmPasswordFocus);
            },
          ),
          SizedBox(height: 2.h),
          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Confirm your password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorText: _confirmPasswordError,
            ),
          ),
        ],
      ),
    );
  }
}
