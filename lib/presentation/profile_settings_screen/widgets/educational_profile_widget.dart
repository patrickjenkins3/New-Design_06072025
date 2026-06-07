import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './settings_tile_widget.dart';

class EducationalProfileWidget extends StatelessWidget {
  final Map<String, dynamic> educationalData;
  final Function(String, dynamic) onDataChanged;

  const EducationalProfileWidget({
    Key? key,
    required this.educationalData,
    required this.onDataChanged,
  }) : super(key: key);

  void _showGraduationYearPicker(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(8, (index) => currentYear + index);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: 40.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Select Graduation Year',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView.builder(
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isSelected = educationalData['graduationYear'] == year;

                  return ListTile(
                    title: Text(
                      year.toString(),
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      onDataChanged('graduationYear', year);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGPARangePicker(BuildContext context) {
    final gpaRanges = [
      '4.0+',
      '3.5 - 3.9',
      '3.0 - 3.4',
      '2.5 - 2.9',
      '2.0 - 2.4',
      'Below 2.0',
      'Not Available'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: 50.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Select GPA Range',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView.builder(
                itemCount: gpaRanges.length,
                itemBuilder: (context, index) {
                  final range = gpaRanges[index];
                  final isSelected = educationalData['gpaRange'] == range;

                  return ListTile(
                    title: Text(
                      range,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      onDataChanged('gpaRange', range);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMajorSelector(BuildContext context) {
    final majors = [
      'Business Administration',
      'Computer Science',
      'Engineering',
      'Pre-Medicine',
      'Psychology',
      'Education',
      'Liberal Arts',
      'Nursing',
      'Criminal Justice',
      'Communications',
      'Art & Design',
      'Music',
      'Undecided',
      'Other'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: 60.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Select Intended Major',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView.builder(
                itemCount: majors.length,
                itemBuilder: (context, index) {
                  final major = majors[index];
                  final isSelected = educationalData['intendedMajor'] == major;

                  return ListTile(
                    title: Text(
                      major,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      onDataChanged('intendedMajor', major);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsTileWidget(
          title: 'Graduation Year',
          subtitle: educationalData['graduationYear']?.toString() ?? 'Not set',
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          onTap: () => _showGraduationYearPicker(context),
        ),
        SettingsTileWidget(
          title: 'GPA Range',
          subtitle: educationalData['gpaRange'] ?? 'Not set',
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'grade',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          onTap: () => _showGPARangePicker(context),
        ),
        SettingsTileWidget(
          title: 'Test Scores',
          subtitle: 'SAT/ACT scores for matching',
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'quiz',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          onTap: () {
            // Navigate to test scores screen
          },
        ),
        SettingsTileWidget(
          title: 'Intended Major',
          subtitle: educationalData['intendedMajor'] ?? 'Not set',
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'school',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          onTap: () => _showMajorSelector(context),
        ),
        SettingsTileWidget(
          title: 'Extracurricular Interests',
          subtitle: 'Activities and interests for matching',
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'sports',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          onTap: () {
            // Navigate to extracurricular interests screen
          },
        ),
      ],
    );
  }
}
