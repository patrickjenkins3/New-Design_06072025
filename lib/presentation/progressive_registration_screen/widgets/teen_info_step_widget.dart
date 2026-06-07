import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class TeenInfoStepWidget extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final bool isSkipped;
  final String? error;

  const TeenInfoStepWidget({
    Key? key,
    required this.controllers,
    required this.isSkipped,
    this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isSkipped ? 0.3 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSkipped) ...[
            _buildSkippedMessage(),
            SizedBox(height: 4.h),
          ],

          // Benefits of adding teen info
          if (!isSkipped) ...[
            _buildBenefitsSection(),
            SizedBox(height: 4.h),
          ],

          // Teen information form
          _buildTeenForm(),
        ],
      ),
    );
  }

  Widget _buildSkippedMessage() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey[600],
            size: 32.sp,
          ),
          SizedBox(height: 2.h),
          Text(
            'Teen Information Skipped',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'You can add this information anytime in your profile settings to get personalized recommendations.',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[50]!,
            Colors.blue[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Colors.green[700],
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Why add teen information?',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ..._buildBenefitsList(),
        ],
      ),
    );
  }

  List<Widget> _buildBenefitsList() {
    final benefits = [
      {
        'icon': Icons.school,
        'title': 'Personalized college matches',
        'description': 'Get recommendations based on grade level and interests',
      },
      {
        'icon': Icons.monetization_on,
        'title': 'Targeted scholarships',
        'description':
            'Find scholarships that match teen\'s profile and achievements',
      },
      {
        'icon': Icons.timeline,
        'title': 'Custom timeline',
        'description': 'Receive grade-appropriate deadlines and milestones',
      },
    ];

    return benefits
        .map(
          (benefit) => Padding(
            padding: EdgeInsets.only(bottom: 1.5.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    benefit['icon'] as IconData,
                    color: Colors.green[600],
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit['title'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                      Text(
                        benefit['description'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.green[700],
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

  Widget _buildTeenForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Teen Name
        _buildInputField(
          controller: controllers['teenName']!,
          label: 'Teen\'s Name',
          hint: 'Enter teen\'s full name',
          icon: Icons.person_outline,
          enabled: !isSkipped,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
        ),

        SizedBox(height: 3.h),

        // Teen Email (optional)
        _buildInputField(
          controller: controllers['teenEmail']!,
          label: 'Teen\'s Email (Optional)',
          hint: 'Enter teen\'s email if available',
          icon: Icons.email_outlined,
          enabled: !isSkipped,
          keyboardType: TextInputType.emailAddress,
        ),

        SizedBox(height: 3.h),

        // Grade level
        _buildInputField(
          controller: controllers['teenGrade']!,
          label: 'Current Grade Level',
          hint: 'e.g., 9th, 10th, 11th, 12th',
          icon: Icons.school_outlined,
          enabled: !isSkipped,
          textCapitalization: TextCapitalization.words,
        ),

        SizedBox(height: 3.h),

        // School name
        _buildInputField(
          controller: controllers['teenSchool']!,
          label: 'Current School (Optional)',
          hint: 'Enter current school name',
          icon: Icons.location_city_outlined,
          enabled: !isSkipped,
          textCapitalization: TextCapitalization.words,
        ),

        if (!isSkipped) ...[
          SizedBox(height: 2.h),

          // Privacy note
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.security,
                  color: Colors.blue[600],
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy & Safety',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      Text(
                        'Teen information is kept secure and private. Only you as the parent can access and modify this data.',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
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
        ],
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.grey[800] : Colors.grey[500],
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: enabled ? Colors.grey[800] : Colors.grey[500],
          ),
          decoration: InputDecoration(
            hintText: enabled ? hint : 'Skipped - can add later',
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(
              icon,
              color: enabled ? Colors.grey[600] : Colors.grey[400],
              size: 20.sp,
            ),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: enabled ? Colors.grey[300]! : Colors.grey[200]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF6366F1), width: 2),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          ),
        ),
      ],
    );
  }
}
