import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AddToListBottomSheet extends StatefulWidget {
  final String schoolName;
  final Function(String) onAddToExistingList;
  final Function(String) onCreateNewList;

  const AddToListBottomSheet({
    Key? key,
    required this.schoolName,
    required this.onAddToExistingList,
    required this.onCreateNewList,
  }) : super(key: key);

  @override
  State<AddToListBottomSheet> createState() => _AddToListBottomSheetState();
}

class _AddToListBottomSheetState extends State<AddToListBottomSheet> {
  final TextEditingController _newListController = TextEditingController();
  String? _selectedList;
  bool _isCreatingNew = false;

  final List<Map<String, dynamic>> _existingLists = [
    {
      "id": "1",
      "name": "Top Choices",
      "count": 5,
      "icon": "star",
      "color": Colors.amber,
    },
    {
      "id": "2",
      "name": "Safety Schools",
      "count": 8,
      "icon": "security",
      "color": Colors.green,
    },
    {
      "id": "3",
      "name": "Reach Schools",
      "count": 3,
      "icon": "trending_up",
      "color": Colors.blue,
    },
    {
      "id": "4",
      "name": "Engineering Programs",
      "count": 12,
      "icon": "engineering",
      "color": Colors.orange,
    },
    {
      "id": "5",
      "name": "In-State Options",
      "count": 7,
      "icon": "location_on",
      "color": Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'playlist_add',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  "Add ${widget.schoolName} to List",
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              _buildToggleButton("Existing List", !_isCreatingNew),
              SizedBox(width: 2.w),
              _buildToggleButton("New List", _isCreatingNew),
            ],
          ),
          SizedBox(height: 3.h),
          _isCreatingNew
              ? _buildCreateNewSection()
              : _buildExistingListsSection(),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canAddToList() ? _handleAddToList : null,
              child: Text(
                  _isCreatingNew ? "Create List & Add School" : "Add to List"),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isCreatingNew = text == "New List"),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          child: Text(
            text,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: isSelected
                  ? Colors.white
                  : AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildExistingListsSection() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 40.h),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _existingLists.length,
        itemBuilder: (context, index) {
          final list = _existingLists[index];
          final isSelected = _selectedList == list["id"];

          return GestureDetector(
            onTap: () => setState(() => _selectedList = list["id"] as String),
            child: Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: (list["color"] as Color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: list["icon"] as String,
                      color: list["color"] as Color,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list["name"] as String,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : null,
                          ),
                        ),
                        Text(
                          "${list["count"]} schools",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateNewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "List Name",
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _newListController,
          decoration: InputDecoration(
            hintText: "Enter list name (e.g., 'Dream Schools')",
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'create',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  "Tip: Create lists like 'Safety Schools', 'Reach Schools', or organize by major or location.",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _canAddToList() {
    if (_isCreatingNew) {
      return _newListController.text.trim().isNotEmpty;
    } else {
      return _selectedList != null;
    }
  }

  void _handleAddToList() {
    if (_isCreatingNew) {
      widget.onCreateNewList(_newListController.text.trim());
    } else if (_selectedList != null) {
      final selectedListName = _existingLists
          .firstWhere((list) => list["id"] == _selectedList)["name"] as String;
      widget.onAddToExistingList(selectedListName);
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _newListController.dispose();
    super.dispose();
  }
}
