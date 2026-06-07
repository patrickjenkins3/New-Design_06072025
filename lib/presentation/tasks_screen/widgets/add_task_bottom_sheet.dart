import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../models/task_model.dart';
import '../../../services/task_service.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(Task) onTaskCreated;

  const AddTaskBottomSheet({super.key, required this.onTaskCreated});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TaskService _taskService = TaskService();

  String _selectedStatus = 'pending';
  String _selectedPriority = 'medium';
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  final List<String> _statusOptions = ['pending', 'in_progress'];
  final List<String> _priorityOptions = ['low', 'medium', 'high', 'urgent'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue[600]!),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final task = await _taskService.createTask(
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );

      widget.onTaskCreated(task);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task created successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating task: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      default:
        return status;
    }
  }

  String _getPriorityDisplayName(String priority) {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double _getResponsiveWidth(double percentage) {
    try {
      return percentage.w;
    } catch (e) {
      return MediaQuery.of(context).size.width * (percentage / 100);
    }
  }

  double _getResponsiveHeight(double percentage) {
    try {
      return percentage.h;
    } catch (e) {
      return MediaQuery.of(context).size.height * (percentage / 100);
    }
  }

  double _getResponsiveFontSize(double size) {
    try {
      return size.sp;
    } catch (e) {
      return size * MediaQuery.of(context).textScaleFactor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(
                    vertical: _getResponsiveHeight(1.0),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getResponsiveWidth(4.0),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Create New Task',
                        style: GoogleFonts.inter(
                          fontSize: _getResponsiveFontSize(20.0),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(_getResponsiveWidth(4.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        Text(
                          'Task Title',
                          style: GoogleFonts.inter(
                            fontSize: _getResponsiveFontSize(16.0),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: _getResponsiveHeight(1.0)),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Enter task title...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue[600]!),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a task title';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: _getResponsiveHeight(3.0)),

                        // Description field
                        Text(
                          'Description (Optional)',
                          style: GoogleFonts.inter(
                            fontSize: _getResponsiveFontSize(16.0),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: _getResponsiveHeight(1.0)),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Enter task description...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue[600]!),
                            ),
                          ),
                        ),

                        SizedBox(height: _getResponsiveHeight(3.0)),

                        // Status and Priority row
                        Row(
                          children: [
                            // Status
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status',
                                    style: GoogleFonts.inter(
                                      fontSize: _getResponsiveFontSize(16.0),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: _getResponsiveHeight(1.0)),
                                  DropdownButtonFormField<String>(
                                    value: _selectedStatus,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.blue[600]!,
                                        ),
                                      ),
                                    ),
                                    items:
                                        _statusOptions.map((status) {
                                          return DropdownMenuItem(
                                            value: status,
                                            child: Text(
                                              _getStatusDisplayName(status),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedStatus = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: _getResponsiveWidth(4.0)),

                            // Priority
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Priority',
                                    style: GoogleFonts.inter(
                                      fontSize: _getResponsiveFontSize(16.0),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: _getResponsiveHeight(1.0)),
                                  DropdownButtonFormField<String>(
                                    value: _selectedPriority,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.blue[600]!,
                                        ),
                                      ),
                                    ),
                                    items:
                                        _priorityOptions.map((priority) {
                                          return DropdownMenuItem(
                                            value: priority,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color: _getPriorityColor(
                                                      priority,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _getPriorityDisplayName(
                                                    priority,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPriority = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: _getResponsiveHeight(3.0)),

                        // Due date
                        Text(
                          'Due Date (Optional)',
                          style: GoogleFonts.inter(
                            fontSize: _getResponsiveFontSize(16.0),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: _getResponsiveHeight(1.0)),
                        InkWell(
                          onTap: _selectDueDate,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(_getResponsiveWidth(4.0)),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: _getResponsiveWidth(3.0)),
                                Text(
                                  _selectedDueDate != null
                                      ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                                      : 'Select due date',
                                  style: GoogleFonts.inter(
                                    fontSize: _getResponsiveFontSize(14.0),
                                    color:
                                        _selectedDueDate != null
                                            ? Colors.black87
                                            : Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                if (_selectedDueDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed:
                                        () => setState(() {
                                          _selectedDueDate = null;
                                        }),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: _getResponsiveHeight(4.0)),
                      ],
                    ),
                  ),
                ),

                // Create button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(_getResponsiveWidth(4.0)),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: _getResponsiveHeight(2.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Create Task',
                              style: GoogleFonts.inter(
                                fontSize: _getResponsiveFontSize(16.0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
