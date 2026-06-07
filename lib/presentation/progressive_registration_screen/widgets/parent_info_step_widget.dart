import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentInfoStepWidget extends StatefulWidget {
  final Map<String, TextEditingController> controllers;
  final String? error;

  const ParentInfoStepWidget({
    Key? key,
    required this.controllers,
    this.error,
  }) : super(key: key);

  @override
  State<ParentInfoStepWidget> createState() => _ParentInfoStepWidgetState();
}

class _ParentInfoStepWidgetState extends State<ParentInfoStepWidget> {
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name
        _buildInputField(
          controller: widget.controllers['parentName']!,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
        ),

        SizedBox(height: 3.h),

        // Email
        _buildInputField(
          controller: widget.controllers['parentEmail']!,
          label: 'Email Address',
          hint: 'Enter your email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        SizedBox(height: 3.h),

        // Password
        _buildInputField(
          controller: widget.controllers['parentPassword']!,
          label: 'Password',
          hint: 'Create a strong password',
          icon: Icons.lock_outline,
          obscureText: !_showPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        ),

        SizedBox(height: 1.h),

        // Password requirements
        _buildPasswordRequirements(),

        SizedBox(height: 3.h),

        // Confirm Password
        _buildInputField(
          controller: widget.controllers['confirmPassword']!,
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          icon: Icons.lock_outline,
          obscureText: !_showConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: () =>
                setState(() => _showConfirmPassword = !_showConfirmPassword),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          obscureText: obscureText,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey[800],
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.grey[600],
              size: 20.sp,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF6366F1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[400]!),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final password = widget.controllers['parentPassword']!.text;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password must contain:',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 1.h),
          _buildRequirement(
            'At least 8 characters',
            password.length >= 8,
          ),
          _buildRequirement(
            'One uppercase letter',
            password.contains(RegExp(r'[A-Z]')),
          ),
          _buildRequirement(
            'One lowercase letter',
            password.contains(RegExp(r'[a-z]')),
          ),
          _buildRequirement(
            'One number',
            password.contains(RegExp(r'[0-9]')),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green[600] : Colors.grey[400],
            size: 16.sp,
          ),
          SizedBox(width: 2.w),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: isMet ? Colors.green[700] : Colors.grey[600],
              fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
