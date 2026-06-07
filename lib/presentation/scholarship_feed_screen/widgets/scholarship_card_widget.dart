import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';
import '../../../core/utils/date_formatter.dart';

class ScholarshipCardWidget extends StatelessWidget {
  final Map<String, dynamic> scholarship;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onReminder;
  final VoidCallback? onViewDetails;
  final VoidCallback? onAddToCalendar;
  final VoidCallback? onMarkApplied;
  final VoidCallback? onApplicationLinkTap;

  const ScholarshipCardWidget({
    super.key,
    required this.scholarship,
    this.onTap,
    this.onSave,
    this.onShare,
    this.onReminder,
    this.onViewDetails,
    this.onAddToCalendar,
    this.onMarkApplied,
    this.onApplicationLinkTap,
  });

  Color _getDeadlineColor(DateTime deadline) {
    final now = DateTime.now();
    final daysLeft = deadline.difference(now).inDays;

    if (daysLeft <= 7) return AppTheme.warningLight;
    if (daysLeft <= 30) return AppTheme.accentLight;
    return AppTheme.successLight;
  }

  String _formatDeadline(DateTime deadline) {
    return DateFormatter.formatDeadlineWithDate(deadline);
  }

  Widget _buildMatchBadge(int matchPercentage) {
    if (matchPercentage < 70) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.successLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        matchPercentage >= 90 ? 'High Match' : 'Good Match',
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDifficultyRating(String difficulty) {
    Color difficultyColor;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        difficultyColor = AppTheme.successLight;
        break;
      case 'medium':
        difficultyColor = AppTheme.accentLight;
        break;
      case 'hard':
        difficultyColor = AppTheme.warningLight;
        break;
      default:
        difficultyColor = AppTheme.lightTheme.colorScheme.outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: difficultyColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: difficultyColor, width: 1),
      ),
      child: Text(
        difficulty,
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: difficultyColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildApplicationStatus(String status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'applied':
        statusColor = AppTheme.successLight;
        statusText = 'Applied';
        statusIcon = Icons.check_circle;
        break;
      case 'in_review':
        statusColor = AppTheme.accentLight;
        statusText = 'In Review';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'accepted':
        statusColor = AppTheme.successLight;
        statusText = 'Accepted';
        statusIcon = Icons.celebration;
        break;
      case 'rejected':
        statusColor = AppTheme.warningLight;
        statusText = 'Rejected';
        statusIcon = Icons.cancel;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          SizedBox(width: 1.w),
          Text(
            statusText,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently or show a message
    }
  }

  @override
  Widget build(BuildContext context) {
    final deadline = DateTime.parse(scholarship['deadline'] as String);
    final matchPercentage = scholarship['match_percentage'] as int? ?? 0;
    final isBookmarked = scholarship['isBookmarked'] as bool? ?? false;
    final applicationStatus =
        scholarship['application_status'] as String? ?? 'not_applied';
    final applicationUrl = scholarship['application_url'] as String? ?? '';

    return Slidable(
      key: ValueKey(scholarship['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onSave?.call(),
            backgroundColor: AppTheme.successLight,
            foregroundColor: Colors.white,
            icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            label: isBookmarked ? 'Saved' : 'Save',
          ),
          SlidableAction(
            onPressed: (_) => onShare?.call(),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
          SlidableAction(
            onPressed: (_) => onReminder?.call(),
            backgroundColor: AppTheme.accentLight,
            foregroundColor: Colors.white,
            icon: Icons.notifications,
            label: 'Remind',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow.withValues(
                  alpha: 0.1,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with deadline and match badge
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: _getDeadlineColor(deadline).withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: _getDeadlineColor(deadline),
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _formatDeadline(deadline),
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                                color: _getDeadlineColor(deadline),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildApplicationStatus(applicationStatus),
                        if (applicationStatus != 'not_applied')
                          SizedBox(width: 2.w),
                        _buildMatchBadge(matchPercentage),
                      ],
                    ),
                  ],
                ),
              ),

              // Main content
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and bookmark
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            scholarship['title'] as String,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        GestureDetector(
                          onTap: onSave,
                          child: CustomIconWidget(
                            iconName:
                                isBookmarked ? 'bookmark' : 'bookmark_border',
                            color:
                                isBookmarked
                                    ? AppTheme.accentLight
                                    : AppTheme.lightTheme.colorScheme.outline,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.h),

                    // Sponsor
                    Text(
                      'by ${scholarship['sponsor'] as String}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Award amount and difficulty
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Award Amount',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                    color:
                                        AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              scholarship['award_display'] as String,
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        _buildDifficultyRating(
                          scholarship['difficulty'] as String,
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Description
                    Text(
                      scholarship['description'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 2.h),

                    // Requirements tags
                    if (scholarship['requirements'] != null)
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children:
                            (scholarship['requirements'] as List)
                                .take(3)
                                .map(
                                  (req) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      req as String,
                                      style: AppTheme
                                          .lightTheme
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color:
                                                AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                          ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),

                    SizedBox(height: 2.h),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchUrl(applicationUrl),
                            icon: CustomIconWidget(
                              iconName: 'link',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 16,
                            ),
                            label: const Text('Apply Now'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                              side: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        if (applicationStatus == 'not_applied')
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: onMarkApplied,
                              icon: CustomIconWidget(
                                iconName: 'check_circle',
                                color: Colors.white,
                                size: 16,
                              ),
                              label: const Text('Mark Applied'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.successLight,
                              ),
                            ),
                          ),
                        if (applicationStatus != 'not_applied')
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: null, // Disabled
                              icon: CustomIconWidget(
                                iconName: 'check_circle',
                                color: Colors.white,
                                size: 16,
                              ),
                              label: Text(_getStatusText(applicationStatus)),
                              style: FilledButton.styleFrom(
                                backgroundColor: _getStatusColor(
                                  applicationStatus,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'applied':
        return 'Applied';
      case 'in_review':
        return 'In Review';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Applied';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'applied':
        return AppTheme.successLight;
      case 'in_review':
        return AppTheme.accentLight;
      case 'accepted':
        return AppTheme.successLight;
      case 'rejected':
        return AppTheme.warningLight;
      default:
        return AppTheme.successLight;
    }
  }

  void _showContextMenu(BuildContext context) {
    final applicationStatus =
        scholarship['application_status'] as String? ?? 'not_applied';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 2.h),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'link',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  title: const Text('Apply Now'),
                  onTap: () {
                    Navigator.pop(context);
                    _launchUrl(scholarship['application_url'] as String);
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'visibility',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  title: const Text('View Details'),
                  onTap: () {
                    Navigator.pop(context);
                    onViewDetails?.call();
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.accentLight,
                    size: 24,
                  ),
                  title: const Text('Add to Calendar'),
                  onTap: () {
                    Navigator.pop(context);
                    onAddToCalendar?.call();
                  },
                ),
                if (applicationStatus == 'not_applied')
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.successLight,
                      size: 24,
                    ),
                    title: const Text('Mark as Applied'),
                    onTap: () {
                      Navigator.pop(context);
                      onMarkApplied?.call();
                    },
                  ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
    );
  }
}
