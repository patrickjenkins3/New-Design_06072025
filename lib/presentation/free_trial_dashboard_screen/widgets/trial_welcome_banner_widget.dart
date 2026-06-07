import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class TrialWelcomeBannerWidget extends StatelessWidget {
  final Map<String, dynamic> userProfile;
  final int daysRemaining;
  final bool isTrialActive;

  const TrialWelcomeBannerWidget({
    Key? key,
    required this.userProfile,
    required this.daysRemaining,
    required this.isTrialActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withAlpha(77),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 6.w,
                backgroundColor: Colors.white.withAlpha(51),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${_getFirstName()}!',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isTrialActive
                          ? 'Exploring your free trial'
                          : 'Trial expired - Upgrade now',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withAlpha(128),
                    width: 1,
                  ),
                ),
                child: Text(
                  'FREE TRIAL',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Trial countdown and benefits
          Row(
            children: [
              Expanded(
                child: _buildCountdownCard(),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildBenefitsCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(77),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                isTrialActive ? '$daysRemaining' : '0',
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            isTrialActive
                ? (daysRemaining == 1 ? 'day left' : 'days left')
                : 'trial expired',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: Colors.white.withAlpha(230),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(77),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber[300],
                size: 16.sp,
              ),
              SizedBox(width: 1.w),
              Text(
                'Try Premium',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            '• School discovery\n• Basic scholarships\n• 5 deadlines max',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: Colors.white.withAlpha(204),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  String _getFirstName() {
    final fullName = userProfile['full_name'] as String? ?? 'User';
    return fullName.split(' ').first;
  }
}
