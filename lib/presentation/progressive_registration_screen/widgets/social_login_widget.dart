import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialLoginWidget extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onFacebookPressed;
  final bool isLoading;

  const SocialLoginWidget({
    Key? key,
    this.onGooglePressed,
    this.onApplePressed,
    this.onFacebookPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google Sign-In
        _buildSocialButton(
          onPressed: isLoading ? null : onGooglePressed,
          icon: Icons.g_mobiledata,
          label: 'Continue with Google',
          backgroundColor: Colors.white,
          textColor: Colors.grey[800]!,
          borderColor: Colors.grey[300]!,
          iconColor: Colors.red[600]!,
        ),

        SizedBox(height: 2.h),

        // Apple Sign-In
        _buildSocialButton(
          onPressed: isLoading ? null : onApplePressed,
          icon: Icons.apple,
          label: 'Continue with Apple',
          backgroundColor: Colors.black,
          textColor: Colors.white,
          borderColor: Colors.black,
          iconColor: Colors.white,
        ),

        SizedBox(height: 2.h),

        // Facebook Sign-In
        _buildSocialButton(
          onPressed: isLoading ? null : onFacebookPressed,
          icon: Icons.facebook,
          label: 'Continue with Facebook',
          backgroundColor: const Color(0xFF1877F2),
          textColor: Colors.white,
          borderColor: const Color(0xFF1877F2),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required Color iconColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor),
          ),
          elevation: backgroundColor == Colors.white ? 1 : 2,
          shadowColor: Colors.grey.withAlpha(51),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20.sp,
            ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
