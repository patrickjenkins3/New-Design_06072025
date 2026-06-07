import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  RangeValues _awardRange = const RangeValues(500, 50000);
  RangeValues _deadlineRange = const RangeValues(0, 365);
  List<String> _selectedEligibility = [];
  List<String> _selectedRequirements = [];

  final List<String> _eligibilityOptions = [
    'High School Senior',
    'College Freshman',
    'College Sophomore',
    'College Junior',
    'College Senior',
    'Graduate Student',
    'Community College',
    'Trade School',
    'Military Family',
    'First Generation',
    'Minority Student',
    'STEM Field',
    'Arts & Humanities',
    'Business',
    'Healthcare',
  ];

  final List<String> _requirementOptions = [
    'Essay Required',
    'Transcript Required',
    'Letters of Recommendation',
    'Portfolio Required',
    'Interview Required',
    'Community Service',
    'Financial Need',
    'Academic Merit',
    'Leadership Experience',
    'Extracurricular Activities',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _initializeFilters();
  }

  void _initializeFilters() {
    _awardRange = RangeValues(
      (_filters['minAward'] as double? ?? 500).clamp(500, 50000),
      (_filters['maxAward'] as double? ?? 50000).clamp(500, 50000),
    );

    _deadlineRange = RangeValues(
      (_filters['minDeadlineDays'] as double? ?? 0).clamp(0, 365),
      (_filters['maxDeadlineDays'] as double? ?? 365).clamp(0, 365),
    );

    _selectedEligibility = List<String>.from(_filters['eligibility'] ?? []);
    _selectedRequirements = List<String>.from(_filters['requirements'] ?? []);
  }

  void _applyFilters() {
    final updatedFilters = {
      'minAward': _awardRange.start,
      'maxAward': _awardRange.end,
      'minDeadlineDays': _deadlineRange.start,
      'maxDeadlineDays': _deadlineRange.end,
      'eligibility': _selectedEligibility,
      'requirements': _selectedRequirements,
    };

    widget.onFiltersChanged(updatedFilters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _awardRange = const RangeValues(500, 50000);
      _deadlineRange = const RangeValues(0, 365);
      _selectedEligibility.clear();
      _selectedRequirements.clear();
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRangeSlider({
    required String title,
    required String subtitle,
    required RangeValues values,
    required double min,
    required double max,
    required Function(RangeValues) onChanged,
    required String Function(double) formatter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            Text(
              '${formatter(values.start)} - ${formatter(values.end)}',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          subtitle,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: title.contains('Award') ? 20 : 12,
          activeColor: AppTheme.lightTheme.colorScheme.primary,
          inactiveColor: AppTheme.lightTheme.colorScheme.outline,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String) onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return FilterChip(
              label: Text(
                option,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onToggle(option),
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Scholarships',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Award Amount Section
                  _buildSectionHeader('Award Amount'),
                  _buildRangeSlider(
                    title: 'Award Range',
                    subtitle: 'Filter scholarships by award amount',
                    values: _awardRange,
                    min: 500,
                    max: 50000,
                    onChanged: (values) => setState(() => _awardRange = values),
                    formatter: (value) =>
                        '\$${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  ),

                  SizedBox(height: 3.h),

                  // Deadline Range Section
                  _buildSectionHeader('Application Deadline'),
                  _buildRangeSlider(
                    title: 'Deadline Range',
                    subtitle: 'Filter by days until deadline',
                    values: _deadlineRange,
                    min: 0,
                    max: 365,
                    onChanged: (values) =>
                        setState(() => _deadlineRange = values),
                    formatter: (value) => value == 0
                        ? 'Today'
                        : value == 365
                            ? '1 Year'
                            : '${value.toInt()} days',
                  ),

                  SizedBox(height: 3.h),

                  // Eligibility Criteria Section
                  _buildSectionHeader('Eligibility Criteria'),
                  _buildChipSection(
                    title: 'Student Status & Field',
                    options: _eligibilityOptions,
                    selectedOptions: _selectedEligibility,
                    onToggle: (option) {
                      setState(() {
                        _selectedEligibility.contains(option)
                            ? _selectedEligibility.remove(option)
                            : _selectedEligibility.add(option);
                      });
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Application Requirements Section
                  _buildSectionHeader('Application Requirements'),
                  _buildChipSection(
                    title: 'Required Documents & Criteria',
                    options: _requirementOptions,
                    selectedOptions: _selectedRequirements,
                    onToggle: (option) {
                      setState(() {
                        _selectedRequirements.contains(option)
                            ? _selectedRequirements.remove(option)
                            : _selectedRequirements.add(option);
                      });
                    },
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
