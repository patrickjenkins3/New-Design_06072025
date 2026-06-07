import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterModalWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterModalWidget({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late Map<String, dynamic> _filters;
  RangeValues _tuitionRange = const RangeValues(0, 100000);
  RangeValues _acceptanceRange = const RangeValues(0, 100);

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _tuitionRange = RangeValues(
      (_filters['tuitionMin'] ?? 0).toDouble(),
      (_filters['tuitionMax'] ?? 100000).toDouble(),
    );
    _acceptanceRange = RangeValues(
      (_filters['acceptanceMin'] ?? 0).toDouble(),
      (_filters['acceptanceMax'] ?? 100).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSchoolTypeSection(),
                  SizedBox(height: 3.h),
                  _buildLocationSection(),
                  SizedBox(height: 3.h),
                  _buildEnrollmentSection(),
                  SizedBox(height: 3.h),
                  _buildTuitionSection(),
                  SizedBox(height: 3.h),
                  _buildAcceptanceRateSection(),
                  SizedBox(height: 3.h),
                  _buildAdvancedFiltersSection(),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              'Filter Schools',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Clear All',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolTypeSection() {
    return _buildFilterSection(
      'School Type',
      Column(
        children: [
          _buildCheckboxTile('College', 'college'),
          _buildCheckboxTile('Trade School', 'tradeSchool'),
          _buildCheckboxTile('Military', 'military'),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return _buildFilterSection(
      'Location',
      Column(
        children: [
          _buildCheckboxTile('Within 50 miles', 'within50'),
          _buildCheckboxTile('Within 100 miles', 'within100'),
          _buildCheckboxTile('Within 200 miles', 'within200'),
          _buildCheckboxTile('Anywhere', 'anywhere'),
        ],
      ),
    );
  }

  Widget _buildEnrollmentSection() {
    return _buildFilterSection(
      'Enrollment Size',
      Column(
        children: [
          _buildCheckboxTile('Small (< 5,000)', 'small'),
          _buildCheckboxTile('Medium (5,000 - 15,000)', 'medium'),
          _buildCheckboxTile('Large (> 15,000)', 'large'),
        ],
      ),
    );
  }

  Widget _buildTuitionSection() {
    return _buildFilterSection(
      'Tuition Range',
      Column(
        children: [
          RangeSlider(
            values: _tuitionRange,
            min: 0,
            max: 100000,
            divisions: 100,
            labels: RangeLabels(
              '\$${_tuitionRange.start.round()}',
              '\$${_tuitionRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _tuitionRange = values;
                _filters['tuitionMin'] = values.start.round();
                _filters['tuitionMax'] = values.end.round();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_tuitionRange.start.round()}',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                '\$${_tuitionRange.end.round()}',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceRateSection() {
    return _buildFilterSection(
      'Acceptance Rate',
      Column(
        children: [
          RangeSlider(
            values: _acceptanceRange,
            min: 0,
            max: 100,
            divisions: 100,
            labels: RangeLabels(
              '${_acceptanceRange.start.round()}%',
              '${_acceptanceRange.end.round()}%',
            ),
            onChanged: (values) {
              setState(() {
                _acceptanceRange = values;
                _filters['acceptanceMin'] = values.start.round();
                _filters['acceptanceMax'] = values.end.round();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_acceptanceRange.start.round()}%',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                '${_acceptanceRange.end.round()}%',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFiltersSection() {
    return _buildFilterSection(
      'Advanced Filters',
      Column(
        children: [
          _buildCheckboxTile('Has Online Programs', 'hasOnline'),
          _buildCheckboxTile('Offers Financial Aid', 'hasFinancialAid'),
          _buildCheckboxTile('NCAA Division I', 'ncaaD1'),
          _buildCheckboxTile('STEM Programs', 'hasStem'),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        content,
      ],
    );
  }

  Widget _buildCheckboxTile(String title, String key) {
    return CheckboxListTile(
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium,
      ),
      value: _filters[key] ?? false,
      onChanged: (value) {
        setState(() {
          _filters[key] = value ?? false;
        });
      },
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearAllFilters,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: Text('Reset'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onApplyFilters(_filters);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: Text(
                'Apply Filters',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _tuitionRange = const RangeValues(0, 100000);
      _acceptanceRange = const RangeValues(0, 100);
    });
  }
}
