import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdmissionsTabWidget extends StatelessWidget {
  final Map<String, dynamic> schoolData;

  const AdmissionsTabWidget({
    Key? key,
    required this.schoolData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final admissions = schoolData["admissions"] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeadlineCountdown(admissions),
          SizedBox(height: 3.h),
          Text(
            "Requirements Checklist",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          _buildRequirementsChecklist(admissions),
          SizedBox(height: 3.h),
          Text(
            "Test Score Ranges",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          _buildTestScoreRanges(admissions),
          SizedBox(height: 3.h),
          Text(
            "Important Dates",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          _buildImportantDates(admissions),
        ],
      ),
    );
  }

  Widget _buildDeadlineCountdown(Map<String, dynamic> admissions) {
    final deadline =
        DateTime.parse(admissions["applicationDeadline"] as String);
    final now = DateTime.now();
    final daysLeft = deadline.difference(now).inDays;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            "Application Deadline",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "$daysLeft",
            style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "days left",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "${deadline.month}/${deadline.day}/${deadline.year}",
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsChecklist(Map<String, dynamic> admissions) {
    final requirements = admissions["requirements"] as List;

    return Column(
      children: (requirements).map<Widget>((dynamic requirement) {
        final reqMap = requirement as Map<String, dynamic>;
        final isCompleted = reqMap["completed"] as bool;

        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3)
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.lightTheme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reqMap["title"] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (reqMap["description"] != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        reqMap["description"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTestScoreRanges(Map<String, dynamic> admissions) {
    final testScores = admissions["testScores"] as Map<String, dynamic>;

    return Column(
      children: testScores.entries.map<Widget>((entry) {
        final testName = entry.key;
        final scores = entry.value as Map<String, dynamic>;

        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                testName.toUpperCase(),
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScoreRange(
                      "25th Percentile", scores["percentile25"].toString()),
                  _buildScoreRange(
                      "75th Percentile", scores["percentile75"].toString()),
                  _buildScoreRange("Average", scores["average"].toString()),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScoreRange(String label, String score) {
    return Column(
      children: [
        Text(
          score,
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImportantDates(Map<String, dynamic> admissions) {
    final dates = admissions["importantDates"] as List;

    return Column(
      children: (dates).map<Widget>((dynamic date) {
        final dateMap = date as Map<String, dynamic>;
        final dateTime = DateTime.parse(dateMap["date"] as String);

        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateMap["title"] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "${dateTime.month}/${dateTime.day}/${dateTime.year}",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
