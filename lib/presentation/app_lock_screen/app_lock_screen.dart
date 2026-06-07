import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'dart:math'; // Add this import for sin function

import '../../services/auth_service.dart';
import '../../services/security_service.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({Key? key}) : super(key: key);

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen>
    with TickerProviderStateMixin {
  final SecurityService _securityService = SecurityService.instance;
  final AuthService _authService = AuthService.instance;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _enteredPin = '';
  bool _isLoading = false;
  bool _biometricAvailable = false;
  bool _pinEnabled = false;
  int _failedAttempts = 0;
  bool _isAccountLocked = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkSecuritySettings();
    _loadFailedAttempts();
    _checkAccountLocked();
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_fadeController);

    _fadeController.forward();
  }

  Future<void> _checkSecuritySettings() async {
    try {
      final biometric = await _securityService.isBiometricEnabled();
      final pin = await _securityService.isPinEnabled();

      setState(() {
        _biometricAvailable = biometric;
        _pinEnabled = pin;
      });
    } catch (error) {
      // Handle error silently
    }
  }

  Future<void> _loadFailedAttempts() async {
    try {
      final attempts = await _securityService.getFailedAttempts();
      setState(() => _failedAttempts = attempts);
    } catch (error) {
      // Handle error silently
    }
  }

  Future<void> _checkAccountLocked() async {
    try {
      final locked = await _securityService.isAccountLocked();
      setState(() => _isAccountLocked = locked);
    } catch (error) {
      // Handle error silently
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (_isAccountLocked || !_biometricAvailable) return;

    setState(() => _isLoading = true);

    try {
      // Note: In a real implementation, you would use local_auth package here
      // For now, we'll simulate biometric authentication
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate successful biometric authentication
      await _securityService.resetFailedAttempts();
      await _securityService.recordActivity();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard-screen');
      }
    } catch (error) {
      await _handleFailedAuthentication();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _authenticateWithPIN(String pin) async {
    if (_isAccountLocked || !_pinEnabled) return;

    setState(() => _isLoading = true);

    try {
      final isValid = await _securityService.verifyPIN(pin);

      if (isValid) {
        await _securityService.resetFailedAttempts();
        await _securityService.recordActivity();

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard-screen');
        }
      } else {
        await _handleFailedAuthentication();
        _triggerShakeAnimation();
        setState(() => _enteredPin = '');
      }
    } catch (error) {
      await _handleFailedAuthentication();
      _triggerShakeAnimation();
      setState(() => _enteredPin = '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFailedAuthentication() async {
    await _securityService.incrementFailedAttempts();
    final attempts = await _securityService.getFailedAttempts();
    setState(() => _failedAttempts = attempts);

    if (attempts >= 5) {
      setState(() => _isAccountLocked = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Account locked due to too many failed attempts. Please try again in 30 minutes.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  void _addPinDigit(String digit) {
    if (_enteredPin.length < 6 && !_isLoading && !_isAccountLocked) {
      setState(() {
        _enteredPin += digit;
      });

      // Haptic feedback
      HapticFeedback.lightImpact();

      // Auto-authenticate when PIN is complete
      if (_enteredPin.length == 6) {
        _authenticateWithPIN(_enteredPin);
      }
    }
  }

  void _removePinDigit() {
    if (_enteredPin.isNotEmpty && !_isLoading) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      await _securityService.clearAllSecurityData();
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login-screen', (route) => false);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(204),
                Colors.black.withAlpha(242),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header Section
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo/Icon
                      Container(
                        padding: EdgeInsets.all(20.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(26),
                          borderRadius: BorderRadius.circular(20.h),
                        ),
                        child: Icon(
                          Icons.security,
                          size: 60.h,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      Text(
                        'App Locked',
                        style: GoogleFonts.inter(
                          fontSize: 28.h,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        _isAccountLocked
                            ? 'Account is temporarily locked'
                            : 'Enter your PIN or use biometric authentication',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16.h,
                          color: Colors.white70,
                        ),
                      ),

                      if (_failedAttempts > 0) ...[
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(51),
                            borderRadius: BorderRadius.circular(8.h),
                            border:
                                Border.all(color: Colors.red.withAlpha(128)),
                          ),
                          child: Text(
                            'Failed attempts: $_failedAttempts/5',
                            style: GoogleFonts.inter(
                              fontSize: 14.h,
                              color: Colors.red[300],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // PIN Input Section
                if (_pinEnabled && !_isAccountLocked) ...[
                  Expanded(
                    flex: 1,
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                              sin(_shakeAnimation.value * 2 * 3.14159) * 10, 0),
                          child: Column(
                            children: [
                              // PIN Dots
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(6, (index) {
                                  return Container(
                                    width: 16.h,
                                    height: 16.h,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: index < _enteredPin.length
                                          ? Colors.white
                                          : Colors.white.withAlpha(77),
                                      border: Border.all(
                                        color: Colors.white.withAlpha(128),
                                        width: 1,
                                      ),
                                    ),
                                  );
                                }),
                              ),

                              SizedBox(height: 32.h),

                              // PIN Keypad
                              Expanded(
                                child: GridView.count(
                                  crossAxisCount: 3,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 1.2,
                                  crossAxisSpacing: 20.w,
                                  mainAxisSpacing: 16.h,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 40.w),
                                  children: [
                                    // Numbers 1-9
                                    ...List.generate(9, (index) {
                                      return _buildKeypadButton(
                                        (index + 1).toString(),
                                        () => _addPinDigit(
                                            (index + 1).toString()),
                                      );
                                    }),

                                    // Biometric button
                                    if (_biometricAvailable)
                                      _buildKeypadButton(
                                        '',
                                        _authenticateWithBiometric,
                                        icon: Icons.fingerprint,
                                      )
                                    else
                                      Container(),

                                    // Zero
                                    _buildKeypadButton(
                                        '0', () => _addPinDigit('0')),

                                    // Delete button
                                    _buildKeypadButton(
                                      '',
                                      _removePinDigit,
                                      icon: Icons.backspace_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Biometric Only Section
                if (_biometricAvailable &&
                    !_pinEnabled &&
                    !_isAccountLocked) ...[
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _authenticateWithBiometric,
                          child: Container(
                            width: 80.h,
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(26),
                              borderRadius: BorderRadius.circular(40.h),
                              border: Border.all(
                                color: Colors.white.withAlpha(77),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.fingerprint,
                              size: 40.h,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Touch to authenticate',
                          style: GoogleFonts.inter(
                            fontSize: 16.h,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Loading Indicator
                if (_isLoading)
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),

                // Bottom Actions
                Padding(
                  padding: EdgeInsets.all(20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _signOut,
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.inter(
                            fontSize: 16.h,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(
    String text,
    VoidCallback onPressed, {
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(35.h),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(26),
            border: Border.all(
              color: Colors.white.withAlpha(77),
              width: 1,
            ),
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: Colors.white,
                    size: 24.h,
                  )
                : Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 24.h,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}