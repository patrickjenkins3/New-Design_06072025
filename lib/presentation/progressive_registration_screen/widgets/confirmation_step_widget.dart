import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationStepWidget extends StatelessWidget {
  final Map<String, dynamic> registrationData;
  final bool agreedToTerms;
  final bool agreedToPrivacy;
  final ValueChanged<bool?> onTermsChanged;
  final ValueChanged<bool?> onPrivacyChanged;
  final String? error;

  const ConfirmationStepWidget({
    Key? key,
    required this.registrationData,
    required this.agreedToTerms,
    required this.agreedToPrivacy,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Registration summary
        _buildRegistrationSummary(),

        SizedBox(height: 4.h),

        // Free trial info
        _buildTrialInfo(),

        SizedBox(height: 4.h),

        // Terms and privacy
        _buildTermsAndPrivacy(),

        SizedBox(height: 4.h),

        // What happens next
        _buildNextStepsInfo(),
      ],
    );
  }

  Widget _buildRegistrationSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: const Color(0xFF6366F1),
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Account Summary',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Parent info
          _buildSummaryItem(
            'Parent Name',
            registrationData['parentName'] ?? '',
            Icons.person,
          ),

          _buildSummaryItem(
            'Email Address',
            registrationData['parentEmail'] ?? '',
            Icons.email,
          ),

          // Teen info (if provided)
          if (registrationData['teenName']?.isNotEmpty == true) ...[
            Divider(color: Colors.grey[200], height: 3.h),
            _buildSummaryItem(
              'Teen Name',
              registrationData['teenName'] ?? '',
              Icons.school,
            ),
            if (registrationData['teenEmail']?.isNotEmpty == true)
              _buildSummaryItem(
                'Teen Email',
                registrationData['teenEmail'] ?? '',
                Icons.email_outlined,
              ),
          ] else ...[
            Divider(color: Colors.grey[200], height: 3.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey[600],
                    size: 16.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Teen information can be added later',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 16.sp,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialInfo() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withAlpha(26),
            const Color(0xFF8B5CF6).withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                '30-Day Free Trial',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Your free trial includes:',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 1.h),
          ..._buildTrialFeatures(),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(179),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF6366F1),
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'No payment required. Cancel anytime during trial.',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTrialFeatures() {
    final features = [
      'Save up to 10 schools',
      'Track up to 5 deadlines',
      'Basic scholarship matching',
      'AI guidance and support',
    ];

    return features
        .map(
          (feature) => Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  feature,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildTermsAndPrivacy() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms & Privacy',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 3.h),

          // Terms of Service
          _buildCheckboxItem(
            value: agreedToTerms,
            onChanged: onTermsChanged,
            text: 'I agree to the ',
            linkText: 'Terms of Service',
            onLinkTap: () {
              // Open terms of service
            },
          ),

          SizedBox(height: 2.h),

          // Privacy Policy
          _buildCheckboxItem(
            value: agreedToPrivacy,
            onChanged: onPrivacyChanged,
            text: 'I agree to the ',
            linkText: 'Privacy Policy',
            onLinkTap: () {
              // Open privacy policy
            },
          ),

          SizedBox(height: 2.h),

          // Additional privacy note
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.security,
                  color: Colors.green[600],
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Your data is encrypted and secure. We never share personal information with third parties.',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.green[700],
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Padding(
              padding: EdgeInsets.only(top: 1.5.h),
              child: RichText(
                text: TextSpan(
                  text: text,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                  children: [
                    TextSpan(
                      text: linkText,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepsInfo() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rocket_launch,
                color: Colors.blue[600],
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'What happens next?',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ..._buildNextSteps(),
        ],
      ),
    );
  }

  List<Widget> _buildNextSteps() {
    final steps = [
      {
        'number': '1',
        'title': 'Email Confirmation',
        'description': 'Check your email and click the confirmation link',
      },
      {
        'number': '2',
        'title': 'Free Trial Dashboard',
        'description':
            'Explore features and start your college planning journey',
      },
      {
        'number': '3',
        'title': 'Personalized Experience',
        'description': 'Get tailored recommendations and guidance',
      },
    ];

    return steps
        .map(
          (step) => Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      step['number'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      Text(
                        step['description'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.blue[700],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
