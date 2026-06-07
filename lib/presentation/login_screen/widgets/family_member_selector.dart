import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FamilyMemberSelector extends StatelessWidget {
  final List<Map<String, dynamic>> familyMembers;
  final Function(Map<String, dynamic>) onMemberSelected;
  final String? selectedMemberName;

  const FamilyMemberSelector({
    Key? key,
    required this.familyMembers,
    required this.onMemberSelected,
    this.selectedMemberName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      constraints: BoxConstraints(maxHeight: 40.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              'Select Family Member',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(
            color: AppTheme.lightTheme.colorScheme.outline,
            height: 1,
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              itemCount: familyMembers.length,
              separatorBuilder: (context, index) => Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                height: 1,
                indent: 4.w,
                endIndent: 4.w,
              ),
              itemBuilder: (context, index) {
                final member = familyMembers[index];
                final isSelected = selectedMemberName == member['name'];

                return Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: AppTheme.lightTheme.primaryColor,
                            width: 2,
                          )
                        : null,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 6.w,
                      backgroundColor: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                      child: CustomIconWidget(
                        iconName: (member['type'] as String) == 'Parent'
                            ? 'person'
                            : 'school',
                        color: isSelected
                            ? Colors.white
                            : AppTheme.lightTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      member['name'] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      member['type'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.8)
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppTheme.lightTheme.primaryColor,
                            size: 6.w,
                          )
                        : null,
                    onTap: () => onMemberSelected(member),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
