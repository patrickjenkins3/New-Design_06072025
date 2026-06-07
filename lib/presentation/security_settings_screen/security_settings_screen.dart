import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import '../../services/security_service.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_tile_widget.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final SecurityService _securityService = SecurityService.instance;
  final AuthService _authService = AuthService.instance;

  bool _isLoading = true;
  Map<String, dynamic>? _securitySettings;
  int _securityScore = 50;
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  bool _twoFactorEnabled = false;
  bool _backgroundBlurEnabled = true;

  final List<int> _timeoutOptions = [
    0,
    60,
    300,
    900,
    1800
  ]; // immediate, 1min, 5min, 15min, 30min
  final List<String> _timeoutLabels = [
    'Immediate',
    '1 minute',
    '5 minutes',
    '15 minutes',
    '30 minutes'
  ];

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    try {
      setState(() => _isLoading = true);

      final settings = await _securityService.getSecuritySettings();
      final score = await _securityService.getSecurityScore();
      final biometric = await _securityService.isBiometricEnabled();
      final pin = await _securityService.isPinEnabled();
      final blur = await _securityService.isBackgroundBlurEnabled();

      setState(() {
        _securitySettings = settings;
        _securityScore = score;
        _biometricEnabled = biometric;
        _pinEnabled = pin;
        _twoFactorEnabled = settings?['two_factor_enabled'] ?? false;
        _backgroundBlurEnabled = blur;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading security settings: $error')),
        );
      }
    }
  }

  Future<void> _updateBiometric(bool enabled) async {
    try {
      await _securityService.updateSecuritySettings(biometricEnabled: enabled);
      setState(() => _biometricEnabled = enabled);
      await _updateSecurityScore();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Biometric authentication ${enabled ? 'enabled' : 'disabled'}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating biometric setting: $error')),
        );
      }
    }
  }

  Future<void> _setupPIN() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _PINSetupDialog(),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _securityService.setPIN(result);
        setState(() => _pinEnabled = true);
        await _updateSecurityScore();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN setup successfully')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error setting up PIN: $error')),
          );
        }
      }
    }
  }

  Future<void> _removePIN() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove PIN'),
        content: const Text(
            'Are you sure you want to remove your PIN? This will reduce your security score.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _securityService.removePIN();
        setState(() => _pinEnabled = false);
        await _updateSecurityScore();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN removed successfully')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error removing PIN: $error')),
          );
        }
      }
    }
  }

  Future<void> _updateTwoFactor(bool enabled) async {
    try {
      await _securityService.updateSecuritySettings(twoFactorEnabled: enabled);
      setState(() => _twoFactorEnabled = enabled);
      await _updateSecurityScore();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Two-factor authentication ${enabled ? 'enabled' : 'disabled'}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating two-factor setting: $error')),
        );
      }
    }
  }

  Future<void> _updateBackgroundBlur(bool enabled) async {
    try {
      await _securityService.updateSecuritySettings(
          backgroundBlurEnabled: enabled);
      setState(() => _backgroundBlurEnabled = enabled);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Background blur ${enabled ? 'enabled' : 'disabled'}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating background blur: $error')),
        );
      }
    }
  }

  Future<void> _updateAppLockTimeout(int timeout) async {
    try {
      await _securityService.updateSecuritySettings();
      // Remove the setState line for _appLockTimeout
      
      if (mounted) {
        final label = _timeoutLabels[_timeoutOptions.indexOf(timeout)];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('App lock timeout set to $label')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating app lock timeout: $error')),
        );
      }
    }
  }

  Future<void> _updateSecurityScore() async {
    try {
      final score = await _securityService.getSecurityScore();
      setState(() => _securityScore = score);
    } catch (error) {
      // Silently fail score update
    }
  }

  Future<void> _viewAuditLog() async {
    Navigator.pushNamed(context, '/security-audit-log');
  }

  Future<void> _manageSessions() async {
    Navigator.pushNamed(context, '/session-management');
  }

  Color _getSecurityScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getSecurityScoreText(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Security Settings',
          style: GoogleFonts.inter(
            fontSize: 20.h,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Security Help'),
                  content: const Text(
                    'Enable multiple security features to improve your overall security score. '
                    'Biometric authentication and two-factor authentication provide the highest security.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSecuritySettings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security Score Widget
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.h),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 10.h,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.h),
                                decoration: BoxDecoration(
                                  color: _getSecurityScoreColor(_securityScore)
                                      .withAlpha(26),
                                  borderRadius: BorderRadius.circular(12.h),
                                ),
                                child: Icon(
                                  Icons.security,
                                  color: _getSecurityScoreColor(_securityScore),
                                  size: 24.h,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Security Score',
                                      style: GoogleFonts.inter(
                                        fontSize: 16.h,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '${_securityScore}/100 - ${_getSecurityScoreText(_securityScore)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14.h,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '$_securityScore',
                                style: GoogleFonts.inter(
                                  fontSize: 24.h,
                                  fontWeight: FontWeight.bold,
                                  color: _getSecurityScoreColor(_securityScore),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          LinearProgressIndicator(
                            value: _securityScore / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getSecurityScoreColor(_securityScore),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Authentication Methods Section
                    SettingsSectionWidget(
                      title: 'Authentication Methods',
                      icon: Icons.fingerprint,
                      children: [
                        SettingsTileWidget(
                          title: 'Biometric Authentication',
                          subtitle: 'Use Face ID, Touch ID, or Fingerprint',
                          trailing: Switch(
                            value: _biometricEnabled,
                            onChanged: _updateBiometric,
                          ),
                        ),
                        SettingsTileWidget(
                          title: 'PIN Code',
                          subtitle: _pinEnabled
                              ? 'PIN is set up'
                              : 'Set up a backup PIN',
                          trailing: _pinEnabled
                              ? TextButton(
                                  onPressed: _removePIN,
                                  child: const Text('Remove'),
                                )
                              : TextButton(
                                  onPressed: _setupPIN,
                                  child: const Text('Setup'),
                                ),
                        ),
                        SettingsTileWidget(
                          title: 'Two-Factor Authentication',
                          subtitle: 'Add an extra layer of security',
                          trailing: Switch(
                            value: _twoFactorEnabled,
                            onChanged: _updateTwoFactor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Privacy Settings Section
                    SettingsSectionWidget(
                      title: 'Privacy Settings',
                      icon: Icons.privacy_tip,
                      children: [
                        SettingsTileWidget(
                          title: 'Background Privacy',
                          subtitle: 'Blur app when switching between apps',
                          trailing: Switch(
                            value: _backgroundBlurEnabled,
                            onChanged: _updateBackgroundBlur,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Session Management Section
                    SettingsSectionWidget(
                      title: 'Session Management',
                      icon: Icons.devices,
                      children: [
                        SettingsTileWidget(
                          title: 'Active Sessions',
                          subtitle: 'View and manage your login sessions',
                          onTap: _manageSessions,
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Security Audit Section
                    SettingsSectionWidget(
                      title: 'Security Monitoring',
                      icon: Icons.security,
                      children: [
                        SettingsTileWidget(
                          title: 'Security Audit Log',
                          subtitle: 'View recent security events',
                          onTap: _viewAuditLog,
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    // Security Recommendations
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.h),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16.h),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb,
                                  color: Colors.blue[600], size: 20.h),
                              SizedBox(width: 8.w),
                              Text(
                                'Security Recommendations',
                                style: GoogleFonts.inter(
                                  fontSize: 16.h,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          ..._getSecurityRecommendations().map(
                            (recommendation) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.arrow_right,
                                    color: Colors.blue[600],
                                    size: 16.h,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      recommendation,
                                      style: GoogleFonts.inter(
                                        fontSize: 14.h,
                                        color: Colors.blue[700],
                                      ),
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
            ),
    );
  }

  List<String> _getSecurityRecommendations() {
    final recommendations = <String>[];

    if (!_biometricEnabled) {
      recommendations
          .add('Enable biometric authentication for quick and secure access');
    }
    if (!_pinEnabled) {
      recommendations.add('Set up a PIN as a backup authentication method');
    }
    if (!_twoFactorEnabled) {
      recommendations
          .add('Enable two-factor authentication for maximum security');
    }

    if (recommendations.isEmpty) {
      recommendations
          .add('Great job! Your security settings are well configured');
    }

    return recommendations;
  }
}

class _PINSetupDialog extends StatefulWidget {
  @override
  State<_PINSetupDialog> createState() => _PINSetupDialogState();
}

class _PINSetupDialogState extends State<_PINSetupDialog> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePin = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Setup PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            obscureText: _obscurePin,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Enter PIN',
              hintText: '6-digit PIN',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
                icon:
                    Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Confirm PIN',
              hintText: 'Enter PIN again',
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                    _obscureConfirm ? Icons.visibility : Icons.visibility_off),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final pin = _pinController.text.trim();
            final confirm = _confirmController.text.trim();

            if (pin.length != 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN must be 6 digits')),
              );
              return;
            }

            if (pin != confirm) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PINs do not match')),
              );
              return;
            }

            Navigator.of(context).pop(pin);
          },
          child: const Text('Setup'),
        ),
      ],
    );
  }
}