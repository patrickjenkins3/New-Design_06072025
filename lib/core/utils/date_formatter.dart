import 'package:intl/intl.dart';

class DateFormatter {
  // Standard MM/dd/yyyy format
  static final DateFormat _standardFormat = DateFormat('MM/dd/yyyy');

  // Alternative formats for parsing
  static final DateFormat _parseFormat1 = DateFormat('yyyy-MM-dd');
  static final DateFormat _parseFormat2 = DateFormat('dd/MM/yyyy');
  static final DateFormat _parseFormat3 = DateFormat('M/d/yyyy');

  /// Formats a DateTime to MM/dd/yyyy string format
  static String formatDate(DateTime date) {
    return _standardFormat.format(date);
  }

  /// Formats a DateTime to MM/dd/yyyy with time if needed
  static String formatDateWithTime(DateTime date, {bool includeTime = false}) {
    if (includeTime) {
      final timeFormat = DateFormat('MM/dd/yyyy hh:mm a');
      return timeFormat.format(date);
    }
    return formatDate(date);
  }

  /// Parses various date string formats to DateTime
  static DateTime? parseDate(String dateString) {
    if (dateString.isEmpty) return null;

    final formats = [
      _standardFormat,
      _parseFormat1,
      _parseFormat2,
      _parseFormat3,
    ];

    for (final format in formats) {
      try {
        return format.parse(dateString);
      } catch (e) {
        continue;
      }
    }

    // Try parsing ISO 8601 format
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Formats date range for display
  static String formatDateRange(DateTime startDate, DateTime endDate) {
    return '${formatDate(startDate)} - ${formatDate(endDate)}';
  }

  /// Gets relative date description with fallback to standard format
  static String getRelativeOrStandardDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Today (${formatDate(date)})';
    if (difference == 1) return 'Tomorrow (${formatDate(date)})';
    if (difference == -1) return 'Yesterday (${formatDate(date)})';
    if (difference > 1 && difference <= 7) {
      return 'In $difference days (${formatDate(date)})';
    }
    if (difference < -1 && difference >= -7) {
      return '${difference.abs()} days ago (${formatDate(date)})';
    }

    return formatDate(date);
  }

  /// Formats deadline with urgency and standard date
  static String formatDeadlineWithDate(DateTime deadline) {
    final now = DateTime.now();
    final daysLeft = deadline.difference(now).inDays;
    final standardDate = formatDate(deadline);

    if (daysLeft < 0) return 'Expired ($standardDate)';
    if (daysLeft == 0) return 'Due Today ($standardDate)';
    if (daysLeft == 1) return '1 day left ($standardDate)';
    if (daysLeft <= 30) return '$daysLeft days left ($standardDate)';

    final monthsLeft = (daysLeft / 30).floor();
    final monthText = monthsLeft == 1 ? '1 month' : '$monthsLeft months';
    return '$monthText left ($standardDate)';
  }

  /// Validates if a string is in MM/dd/yyyy format
  static bool isValidDateFormat(String dateString) {
    try {
      _standardFormat.parseStrict(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }
}
