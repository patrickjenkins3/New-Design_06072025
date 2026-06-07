import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FeatureComparisonWidget extends StatelessWidget {
  const FeatureComparisonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compare Plans',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Header row
              _buildHeaderRow(),
              // Feature rows
              ..._getFeatures().map((feature) => _buildFeatureRow(feature)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding: EdgeInsets.all(3.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Features',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Free',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Premium',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(FeatureComparison feature) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      padding: EdgeInsets.all(3.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature.name,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textPrimaryLight,
              ),
            ),
          ),
          Expanded(
            child: _buildFeatureIndicator(feature.freeValue),
          ),
          Expanded(
            child:
                _buildFeatureIndicator(feature.premiumValue, isPremium: true),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIndicator(dynamic value, {bool isPremium = false}) {
    final color = isPremium ? AppTheme.primaryLight : Colors.grey[600];

    if (value is bool) {
      return Icon(
        value ? Icons.check_circle : Icons.cancel,
        color: value
            ? (isPremium ? AppTheme.primaryLight : Colors.green)
            : Colors.red,
        size: 5.w,
      );
    } else if (value is String) {
      return Text(
        value,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: isPremium ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        value.toString(),
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: isPremium ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      );
    }
  }

  List<FeatureComparison> _getFeatures() {
    return [
      FeatureComparison(
        name: 'College Search',
        freeValue: 'Basic',
        premiumValue: 'Advanced',
      ),
      FeatureComparison(
        name: 'Scholarship Recommendations',
        freeValue: '5 per month',
        premiumValue: 'Unlimited',
      ),
      FeatureComparison(
        name: 'AI Essay Assistance',
        freeValue: false,
        premiumValue: true,
      ),
      FeatureComparison(
        name: 'Counselor Support',
        freeValue: 'Email only',
        premiumValue: 'Phone & Video',
      ),
      FeatureComparison(
        name: 'Application Tracking',
        freeValue: 'Basic',
        premiumValue: 'Advanced',
      ),
      FeatureComparison(
        name: 'Document Storage',
        freeValue: '100 MB',
        premiumValue: '10 GB',
      ),
      FeatureComparison(
        name: 'Interview Prep',
        freeValue: false,
        premiumValue: true,
      ),
      FeatureComparison(
        name: 'One-on-One Sessions',
        freeValue: false,
        premiumValue: '1 per month',
      ),
      FeatureComparison(
        name: 'Priority Support',
        freeValue: false,
        premiumValue: true,
      ),
    ];
  }
}

class FeatureComparison {
  final String name;
  final dynamic freeValue;
  final dynamic premiumValue;

  FeatureComparison({
    required this.name,
    required this.freeValue,
    required this.premiumValue,
  });
}