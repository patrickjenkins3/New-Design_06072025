import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class QuickActionsWidget extends StatelessWidget {
  final Function(String) onActionTap;

  const QuickActionsWidget({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Help Topics',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildActionChip(
                icon: Icons.school_outlined,
                label: 'College Search',
                action: 'college_search',
                color: Colors.blue,
              ),
              _buildActionChip(
                icon: Icons.monetization_on_outlined,
                label: 'Scholarships',
                action: 'scholarships',
                color: Colors.green,
              ),
              _buildActionChip(
                icon: Icons.assignment_outlined,
                label: 'Applications',
                action: 'applications',
                color: Colors.orange,
              ),
              _buildActionChip(
                icon: Icons.calendar_today_outlined,
                label: 'Planning',
                action: 'planning',
                color: Colors.purple,
              ),
              _buildActionChip(
                icon: Icons.payment_outlined,
                label: 'Payments',
                action: 'payments',
                color: Colors.teal,
              ),
              _buildActionChip(
                icon: Icons.help_outline,
                label: 'Technical',
                action: 'technical',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required String action,
    required MaterialColor color,
  }) {
    return InkWell(
      onTap: () => onActionTap(action),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color[600]),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: color[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
