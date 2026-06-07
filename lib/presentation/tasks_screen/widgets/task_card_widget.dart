import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../models/task_model.dart';

class TaskCardWidget extends StatelessWidget {
  final Task task;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.onToggleStatus,
    this.onDelete,
    this.onEdit,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
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

  Color _getStatusColor() {
    switch (task.status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle_filled;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }

  double _getResponsiveWidth(double percentage, BuildContext context) {
    try {
      return percentage.w;
    } catch (e) {
      return MediaQuery.of(context).size.width * (percentage / 100);
    }
  }

  double _getResponsiveHeight(double percentage, BuildContext context) {
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
      return size;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: task.isOverdue && !task.isCompleted
            ? Border.all(color: Colors.red.withAlpha(77), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with priority indicator and actions
          Container(
            padding: EdgeInsets.all(_getResponsiveWidth(4.0, context)),
            decoration: BoxDecoration(
              color: _getPriorityColor().withAlpha(26),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Priority indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: _getResponsiveWidth(2.0, context)),
                Text(
                  task.priorityDisplayName.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: _getResponsiveFontSize(12.0),
                    fontWeight: FontWeight.w600,
                    color: _getPriorityColor(),
                  ),
                ),
                const Spacer(),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onToggleStatus != null)
                      IconButton(
                        icon: Icon(
                          _getStatusIcon(),
                          color: _getStatusColor(),
                          size: 20,
                        ),
                        onPressed: onToggleStatus,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: onDelete,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Task content
          Padding(
            padding: EdgeInsets.all(_getResponsiveWidth(4.0, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  task.title,
                  style: GoogleFonts.inter(
                    fontSize: _getResponsiveFontSize(16.0),
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted ? Colors.grey[600] : Colors.black87,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Description (if available)
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  SizedBox(height: _getResponsiveHeight(1.0, context)),
                  Text(
                    task.description!,
                    style: GoogleFonts.inter(
                      fontSize: _getResponsiveFontSize(14.0),
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                SizedBox(height: _getResponsiveHeight(2.0, context)),

                // Bottom row with status and due date
                Row(
                  children: [
                    // Status chip
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _getResponsiveWidth(2.5, context),
                        vertical: _getResponsiveHeight(0.5, context),
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor().withAlpha(77),
                        ),
                      ),
                      child: Text(
                        task.statusDisplayName,
                        style: GoogleFonts.inter(
                          fontSize: _getResponsiveFontSize(12.0),
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Due date
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: task.isOverdue && !task.isCompleted
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                      SizedBox(width: _getResponsiveWidth(1.0, context)),
                      Text(
                        _formatDate(task.dueDate),
                        style: GoogleFonts.inter(
                          fontSize: _getResponsiveFontSize(12.0),
                          color: task.isOverdue && !task.isCompleted
                              ? Colors.red
                              : Colors.grey[600],
                          fontWeight: task.isOverdue && !task.isCompleted
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),

                // Overdue indicator
                if (task.isOverdue && !task.isCompleted) ...[
                  SizedBox(height: _getResponsiveHeight(1.0, context)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: _getResponsiveHeight(0.5, context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withAlpha(77)),
                    ),
                    child: Text(
                      'OVERDUE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: _getResponsiveFontSize(12.0),
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
