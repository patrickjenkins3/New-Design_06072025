import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class TrialLimitsWidget extends StatelessWidget {
  final int savedSchoolsCount;
  final int maxSavedSchools;
  final int trackedDeadlinesCount;
  final int maxTrackedDeadlines;

  const TrialLimitsWidget({
    Key? key,
    required this.savedSchoolsCount,
    required this.maxSavedSchools,
    required this.trackedDeadlinesCount,
    required this.maxTrackedDeadlines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trial Usage',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'See how you\'re using your free trial',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Saved schools limit
          _buildLimitItem(
            icon: Icons.school,
            iconColor: Colors.blue[600]!,
            title: 'Saved Schools',
            current: savedSchoolsCount,
            max: maxSavedSchools,
            description: 'Schools you can save for later',
          ),

          SizedBox(height: 2.h),

          // Tracked deadlines limit
          _buildLimitItem(
            icon: Icons.event,
            iconColor: Colors.orange[600]!,
            title: 'Tracked Deadlines',
            current: trackedDeadlinesCount,
            max: maxTrackedDeadlines,
            description: 'Important dates you can track',
          ),

          SizedBox(height: 3.h),

          // Upgrade info
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple[50]!,
                  Colors.blue[50]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.upgrade,
                  color: Colors.purple[600],
                  size: 20.sp,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock Full Access',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[800],
                        ),
                      ),
                      Text(
                        'Save unlimited schools, track all deadlines, and access advanced features',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.purple[700],
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
      ),
    );
  }

  Widget _buildLimitItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int current,
    required int max,
    required String description,
  }) {
    final percentage = (current / max).clamp(0.0, 1.0);
    final isNearLimit = percentage >= 0.8;
    final isAtLimit = current >= max;

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$current / $max',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isAtLimit
                              ? Colors.red[600]
                              : isNearLimit
                                  ? Colors.orange[600]
                                  : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 1.h),

        // Progress bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: isAtLimit
                    ? Colors.red[500]
                    : isNearLimit
                        ? Colors.orange[500]
                        : iconColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),

        if (isAtLimit) ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red[600],
                  size: 12.sp,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Limit reached - Upgrade to continue',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
        ] else if (isNearLimit) ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info,
                  color: Colors.orange[600],
                  size: 12.sp,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Approaching limit',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
