import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';


class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? backgroundColor;

  const SettingsSectionWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.all(20.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(10.h),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 20.h,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18.h,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),

          // Section Content
          Column(children: children),
        ],
      ),
    );
  }
}
