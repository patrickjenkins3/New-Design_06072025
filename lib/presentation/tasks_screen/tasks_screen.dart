import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';
import './widgets/task_card_widget.dart';
import './widgets/task_stats_widget.dart';
import './widgets/add_task_bottom_sheet.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  late TabController _tabController;

  List<Task> _allTasks = [];
  Map<String, int> _statistics = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final tasks = await _taskService.getAllTasks();
      final stats = await _taskService.getTaskStatistics();

      setState(() {
        _allTasks = tasks;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  List<Task> _getFilteredTasks() {
    switch (_tabController.index) {
      case 0: // All
        return _allTasks;
      case 1: // Pending
        return _allTasks.where((task) => task.status == 'pending').toList();
      case 2: // In Progress
        return _allTasks.where((task) => task.status == 'in_progress').toList();
      case 3: // Completed
        return _allTasks.where((task) => task.status == 'completed').toList();
      default:
        return _allTasks;
    }
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddTaskBottomSheet(
            onTaskCreated: (task) {
              _loadTasks(); // Refresh tasks
            },
          ),
    );
  }

  Future<void> _toggleTaskStatus(Task task) async {
    try {
      await _taskService.toggleTaskStatus(task.id, task.status);
      _loadTasks(); // Refresh tasks

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            task.isCompleted ? 'Task marked as pending' : 'Task completed!',
          ),
          backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTask(Task task) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Task',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _taskService.deleteTask(task.id);
        _loadTasks(); // Refresh tasks

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted successfully'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tasks',
          style: GoogleFonts.inter(
            fontSize: _getResponsiveFontSize(20.0),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadTasks,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(height: 1.0, color: Colors.grey[200]),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    SizedBox(height: _getResponsiveHeight(2.0)),
                    Text(
                      'Error loading tasks',
                      style: GoogleFonts.inter(
                        fontSize: _getResponsiveFontSize(18.0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: _getResponsiveHeight(1.0)),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: _getResponsiveFontSize(14.0),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: _getResponsiveHeight(2.0)),
                    ElevatedButton(
                      onPressed: _loadTasks,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Statistics Card
                  TaskStatsWidget(statistics: _statistics),

                  // Tab Bar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue[600],
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: Colors.blue[600],
                      labelStyle: GoogleFonts.inter(
                        fontSize: _getResponsiveFontSize(14.0),
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.inter(
                        fontSize: _getResponsiveFontSize(14.0),
                        fontWeight: FontWeight.w500,
                      ),
                      onTap: (index) => setState(() {}),
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Pending'),
                        Tab(text: 'In Progress'),
                        Tab(text: 'Completed'),
                      ],
                    ),
                  ),

                  // Task List
                  Expanded(child: _buildTaskList()),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskBottomSheet,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskList() {
    final filteredTasks = _getFilteredTasks();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            SizedBox(height: _getResponsiveHeight(2.0)),
            Text(
              _getEmptyStateMessage(),
              style: GoogleFonts.inter(
                fontSize: _getResponsiveFontSize(16.0),
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: _getResponsiveHeight(1.0)),
            Text(
              _getEmptyStateSubtitle(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: _getResponsiveFontSize(14.0),
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: _getResponsiveWidth(4.0),
          vertical: _getResponsiveHeight(1.0),
        ),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];

          return Padding(
            padding: EdgeInsets.only(bottom: _getResponsiveHeight(1.0)),
            child: TaskCardWidget(
              task: task,
              onToggleStatus: () => _toggleTaskStatus(task),
              onDelete: () => _deleteTask(task),
            ),
          );
        },
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (_tabController.index) {
      case 1:
        return 'No pending tasks';
      case 2:
        return 'No tasks in progress';
      case 3:
        return 'No completed tasks';
      default:
        return 'No tasks yet';
    }
  }

  String _getEmptyStateSubtitle() {
    switch (_tabController.index) {
      case 1:
        return 'All tasks are either completed or in progress';
      case 2:
        return 'Start working on some tasks to see them here';
      case 3:
        return 'Complete some tasks to see your achievements';
      default:
        return 'Create your first task to get started';
    }
  }
}
