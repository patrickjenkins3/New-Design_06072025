import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AddEventDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Function(Map<String, dynamic>) onEventAdded;

  const AddEventDialog({
    Key? key,
    required this.selectedDate,
    required this.onEventAdded,
  }) : super(key: key);

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _schoolController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedEventType = 'deadline';
  String _selectedPriority = 'medium';
  String _selectedAssignedTo = 'teen';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isAllDay = true;
  bool _isLoading = false;

  final List<Map<String, String>> _eventTypes = [
    {'value': 'application', 'label': 'Application', 'icon': 'assignment'},
    {'value': 'scholarship', 'label': 'Scholarship', 'icon': 'monetization_on'},
    {'value': 'test', 'label': 'Test', 'icon': 'quiz'},
    {'value': 'visit', 'label': 'Campus Visit', 'icon': 'location_on'},
    {'value': 'deadline', 'label': 'Deadline', 'icon': 'schedule'},
    {'value': 'meeting', 'label': 'Meeting', 'icon': 'group'},
  ];

  final List<Map<String, String>> _priorities = [
    {'value': 'low', 'label': 'Low', 'color': '#4CAF50'},
    {'value': 'medium', 'label': 'Medium', 'color': '#2196F3'},
    {'value': 'high', 'label': 'High', 'color': '#FF9800'},
    {'value': 'urgent', 'label': 'Urgent', 'color': '#FF5252'},
  ];

  final List<Map<String, String>> _assignments = [
    {'value': 'teen', 'label': 'Student'},
    {'value': 'parent', 'label': 'Parent'},
    {'value': 'both', 'label': 'Family'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _schoolController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'date': _selectedDate,
        'type': _selectedEventType,
        'school': _schoolController.text.trim().isEmpty
            ? null
            : _schoolController.text.trim(),
        'assignedTo': _selectedAssignedTo,
        'priority': _selectedPriority,
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'isAllDay': _isAllDay,
        'startTime': _isAllDay ? null : _selectedTime,
      };

      widget.onEventAdded(eventData);
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create event: $error'),
          backgroundColor: AppTheme.warningLight,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(4.w),
      child: Container(
        constraints: BoxConstraints(maxHeight: 80.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'add_circle',
                    size: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Add New Event',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Event Title *',
                          hintText: 'Enter event title',
                          prefixIcon: CustomIconWidget(
                            iconName: 'title',
                            size: 20,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an event title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 3.h),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter event description',
                          prefixIcon: CustomIconWidget(
                            iconName: 'description',
                            size: 20,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Event Type',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: _eventTypes.map((type) {
                          final isSelected =
                              _selectedEventType == type['value'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedEventType = type['value']!;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryLight
                                    : AppTheme.lightTheme.colorScheme.surface,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryLight
                                      : AppTheme.borderLight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: type['icon']!,
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textSecondaryLight,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    type['label']!,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textSecondaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 3.h),
                      TextFormField(
                        controller: _schoolController,
                        decoration: InputDecoration(
                          labelText: 'School/Organization',
                          hintText: 'Enter school or organization name',
                          prefixIcon: CustomIconWidget(
                            iconName: 'school',
                            size: 20,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Priority Level',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: _priorities.map((priority) {
                          final isSelected =
                              _selectedPriority == priority['value'];
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 2.w),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedPriority = priority['value']!;
                                  });
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 1.5.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Color(int.parse(
                                            '0xFF${priority['color']!.substring(1)}'))
                                        : AppTheme
                                            .lightTheme.colorScheme.surface,
                                    border: Border.all(
                                      color: Color(int.parse(
                                          '0xFF${priority['color']!.substring(1)}')),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    priority['label']!,
                                    textAlign: TextAlign.center,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : Color(int.parse(
                                              '0xFF${priority['color']!.substring(1)}')),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Assigned To',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: _assignments.map((assignment) {
                          final isSelected =
                              _selectedAssignedTo == assignment['value'];
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 2.w),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedAssignedTo = assignment['value']!;
                                  });
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 1.5.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryLight
                                        : AppTheme
                                            .lightTheme.colorScheme.surface,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryLight
                                          : AppTheme.borderLight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    assignment['label']!,
                                    textAlign: TextAlign.center,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textSecondaryLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppTheme.borderLight),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'calendar_today',
                                      size: 20,
                                      color: AppTheme.primaryLight,
                                    ),
                                    SizedBox(width: 3.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date',
                                          style: AppTheme
                                              .lightTheme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: AppTheme.textSecondaryLight,
                                          ),
                                        ),
                                        Text(
                                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          if (!_isAllDay)
                            Expanded(
                              child: InkWell(
                                onTap: _selectTime,
                                child: Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppTheme.borderLight),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'access_time',
                                        size: 20,
                                        color: AppTheme.primaryLight,
                                      ),
                                      SizedBox(width: 3.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Time',
                                            style: AppTheme
                                                .lightTheme.textTheme.labelSmall
                                                ?.copyWith(
                                              color:
                                                  AppTheme.textSecondaryLight,
                                            ),
                                          ),
                                          Text(
                                            _selectedTime.format(context),
                                            style: AppTheme
                                                .lightTheme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      CheckboxListTile(
                        title: Text(
                          'All-day event',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        value: _isAllDay,
                        onChanged: (value) {
                          setState(() {
                            _isAllDay = value ?? true;
                          });
                        },
                        activeColor: AppTheme.primaryLight,
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          hintText: 'Enter event location',
                          prefixIcon: CustomIconWidget(
                            iconName: 'location_on',
                            size: 20,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Additional Notes',
                          hintText: 'Enter any additional notes',
                          prefixIcon: CustomIconWidget(
                            iconName: 'note',
                            size: 20,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitEvent,
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text('Create Event'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
