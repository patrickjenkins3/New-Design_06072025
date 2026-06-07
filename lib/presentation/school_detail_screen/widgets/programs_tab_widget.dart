import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProgramsTabWidget extends StatefulWidget {
  final Map<String, dynamic> schoolData;

  const ProgramsTabWidget({
    Key? key,
    required this.schoolData,
  }) : super(key: key);

  @override
  State<ProgramsTabWidget> createState() => _ProgramsTabWidgetState();
}

class _ProgramsTabWidgetState extends State<ProgramsTabWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredPrograms = [];
  List<Map<String, dynamic>> _allPrograms = [];

  @override
  void initState() {
    super.initState();
    _allPrograms = List<Map<String, dynamic>>.from(
        (widget.schoolData["programs"] as List).cast<Map<String, dynamic>>());
    _filteredPrograms = List.from(_allPrograms);
  }

  void _filterPrograms(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPrograms = List.from(_allPrograms);
      } else {
        _filteredPrograms = _allPrograms.where((program) {
          final name = (program["name"] as String).toLowerCase();
          final category = (program["category"] as String).toLowerCase();
          return name.contains(query.toLowerCase()) ||
              category.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          color: AppTheme.lightTheme.colorScheme.surface,
          child: TextField(
            controller: _searchController,
            onChanged: _filterPrograms,
            decoration: InputDecoration(
              hintText: "Search programs and majors...",
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _filterPrograms('');
                      },
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: _filteredPrograms.length,
            itemBuilder: (context, index) {
              final program = _filteredPrograms[index];
              return _buildProgramCard(program);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: _getCategoryColor(program["category"] as String)
                  .withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(program["category"] as String),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: _getCategoryIcon(program["category"] as String),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program["name"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color:
                              _getCategoryColor(program["category"] as String)
                                  .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          program["category"] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: _getCategoryColor(
                                program["category"] as String),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program["description"] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  "Career Paths",
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: (program["careerPaths"] as List)
                      .map<Widget>((dynamic career) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        career as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildProgramStat(
                        "Duration",
                        program["duration"] as String,
                        'schedule',
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildProgramStat(
                        "Degree Type",
                        program["degreeType"] as String,
                        'school',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramStat(String label, String value, String iconName) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'engineering':
        return Colors.blue;
      case 'business':
        return Colors.green;
      case 'arts':
        return Colors.purple;
      case 'science':
        return Colors.orange;
      case 'medicine':
        return Colors.red;
      case 'law':
        return Colors.indigo;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'engineering':
        return 'engineering';
      case 'business':
        return 'business';
      case 'arts':
        return 'palette';
      case 'science':
        return 'science';
      case 'medicine':
        return 'local_hospital';
      case 'law':
        return 'gavel';
      default:
        return 'school';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
