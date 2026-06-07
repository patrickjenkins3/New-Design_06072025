import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';


class TaskStatsWidget extends StatelessWidget {
  final Map<String, int> statistics;

  const TaskStatsWidget({super.key, required this.statistics});

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

  double get completionRate {
    final total = statistics['total'] ?? 0;
    final completed = statistics['completed'] ?? 0;
    return total > 0 ? (completed / total) * 100 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(_getResponsiveWidth(4.0, context)),
      padding: EdgeInsets.all(_getResponsiveWidth(4.0, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue[600], size: 20),
              SizedBox(width: _getResponsiveWidth(2.0, context)),
              Text(
                'Task Overview',
                style: GoogleFonts.inter(
                  fontSize: _getResponsiveFontSize(16.0),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (statistics['total'] != null && statistics['total']! > 0)
                Text(
                  '${completionRate.toInt()}% Complete',
                  style: GoogleFonts.inter(
                    fontSize: _getResponsiveFontSize(14.0),
                    fontWeight: FontWeight.w600,
                    color: Colors.green[600],
                  ),
                ),
            ],
          ),

          SizedBox(height: _getResponsiveHeight(2.0, context)),

          // Statistics Grid
          Row(
            children: [
              // Total Tasks
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Total',
                  value: statistics['total'] ?? 0,
                  color: Colors.blue,
                  icon: Icons.task_alt,
                ),
              ),
              SizedBox(width: _getResponsiveWidth(3.0, context)),

              // Completed Tasks
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Completed',
                  value: statistics['completed'] ?? 0,
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
              SizedBox(width: _getResponsiveWidth(3.0, context)),

              // Pending Tasks
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Pending',
                  value: statistics['pending'] ?? 0,
                  color: Colors.orange,
                  icon: Icons.schedule,
                ),
              ),
              SizedBox(width: _getResponsiveWidth(3.0, context)),

              // In Progress
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'In Progress',
                  value: statistics['in_progress'] ?? 0,
                  color: Colors.purple,
                  icon: Icons.play_circle_filled,
                ),
              ),
            ],
          ),

          // Priority Stats (if any high priority or urgent tasks)
          if ((statistics['high_priority'] ?? 0) > 0 ||
              (statistics['urgent'] ?? 0) > 0) ...[
            SizedBox(height: _getResponsiveHeight(2.0, context)),
            Container(
              padding: EdgeInsets.all(_getResponsiveWidth(3.0, context)),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withAlpha(26)),
              ),
              child: Row(
                children: [
                  Icon(Icons.priority_high, color: Colors.red[600], size: 16),
                  SizedBox(width: _getResponsiveWidth(2.0, context)),
                  Text(
                    'High Priority: ${statistics['high_priority'] ?? 0}',
                    style: GoogleFonts.inter(
                      fontSize: _getResponsiveFontSize(12.0),
                      fontWeight: FontWeight.w500,
                      color: Colors.red[700],
                    ),
                  ),
                  if ((statistics['urgent'] ?? 0) > 0) ...[
                    SizedBox(width: _getResponsiveWidth(4.0, context)),
                    Text(
                      'Urgent: ${statistics['urgent'] ?? 0}',
                      style: GoogleFonts.inter(
                        fontSize: _getResponsiveFontSize(12.0),
                        fontWeight: FontWeight.w600,
                        color: Colors.red[800],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Progress bar
          if (statistics['total'] != null && statistics['total']! > 0) ...[
            SizedBox(height: _getResponsiveHeight(2.0, context)),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completionRate / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  completionRate >= 100 ? Colors.green : Colors.blue[600]!,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(_getResponsiveWidth(3.0, context)),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: _getResponsiveHeight(1.0, context)),
          Text(
            value.toString(),
            style: GoogleFonts.inter(
              fontSize: _getResponsiveFontSize(18.0),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: _getResponsiveFontSize(10.0),
              fontWeight: FontWeight.w500,
              color: color.withAlpha(204),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
