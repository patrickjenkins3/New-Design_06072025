import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationProgressWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const RegistrationProgressWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          // Progress bar
          Row(
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? const Color(0xFF6366F1)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < totalSteps - 1) SizedBox(width: 2.w),
                  ],
                ),
              );
            }),
          ),

          SizedBox(height: 2.h),

          // Step indicators
          Row(
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF6366F1)
                            : isCurrent
                                ? const Color(0xFF6366F1)
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(
                                color: const Color(0xFF6366F1).withAlpha(77),
                                width: 3,
                              )
                            : null,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : _getStepIcon(index),
                        color: isCompleted || isCurrent
                            ? Colors.white
                            : Colors.grey[600],
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _getStepTitle(index),
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isCompleted || isCurrent
                            ? const Color(0xFF6366F1)
                            : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.person;
      case 1:
        return Icons.group;
      case 2:
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Account\nSetup';
      case 1:
        return 'Teen\nInfo';
      case 2:
        return 'Complete\nRegistration';
      default:
        return 'Step ${index + 1}';
    }
  }
}
