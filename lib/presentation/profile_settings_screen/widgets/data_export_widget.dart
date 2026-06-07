import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/app_export.dart';
import '../../../services/data_export_service.dart';
import './settings_tile_widget.dart';

class DataExportWidget extends StatefulWidget {
  const DataExportWidget({Key? key}) : super(key: key);

  @override
  State<DataExportWidget> createState() => _DataExportWidgetState();
}

class _DataExportWidgetState extends State<DataExportWidget> {
  bool _isExporting = false;
  final DataExportService _exportService = DataExportService();

  Future<void> downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);

        if (mounted) {
          _showSuccessMessage('File saved to ${file.path}');
        }
      } catch (e) {
        if (mounted) {
          _showSuccessMessage('Export completed successfully');
        }
      }
    }
  }

  Future<void> _exportScholarshipData() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      // Get real scholarship data from Supabase
      final scholarshipData = await _exportService.getUserScholarshipData();

      if (scholarshipData.isEmpty) {
        _showInfoMessage('No scholarship data found to export');
        return;
      }

      final csvContent = _exportService.generateScholarshipCSV(scholarshipData);
      final filename =
          'scholarships_${DateTime.now().millisecondsSinceEpoch}.csv';

      await downloadFile(csvContent, filename);
      _showSuccessMessage(
          '${scholarshipData.length} scholarships exported successfully');
    } catch (error) {
      _showErrorMessage(
          'Failed to export scholarship data: ${error.toString()}');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportApplicationProgress() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      final progressData = await _exportService.getUserApplicationProgress();
      final jsonContent =
          _exportService.generateApplicationProgressJSON(progressData);
      final filename =
          'application_progress_${DateTime.now().millisecondsSinceEpoch}.json';

      await downloadFile(jsonContent, filename);
      _showSuccessMessage('Application progress exported successfully');
    } catch (error) {
      _showErrorMessage(
          'Failed to export application progress: ${error.toString()}');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _emailScholarshipData() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      // Get user info and scholarship data
      final userInfo = await _exportService.getCurrentUserInfo();
      final email = userInfo['email'];

      if (email == null || email.isEmpty) {
        _showErrorMessage(
            'No email address found. Please update your profile.');
        return;
      }

      final scholarshipData = await _exportService.getUserScholarshipData();

      if (scholarshipData.isEmpty) {
        _showInfoMessage('No scholarship data found to export');
        return;
      }

      final csvContent = _exportService.generateScholarshipCSV(scholarshipData);
      final filename =
          'scholarships_export_${DateTime.now().millisecondsSinceEpoch}.csv';

      // Send via email
      await _exportService.sendDataViaEmail(
        email: email,
        filename: filename,
        csvContent: csvContent,
        userFullName: userInfo['full_name'],
      );

      _showSuccessMessage('Scholarship data has been sent to $email');
    } catch (error) {
      _showErrorMessage(
          'Failed to email scholarship data: ${error.toString()}');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _emailApplicationProgress() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      final userInfo = await _exportService.getCurrentUserInfo();
      final email = userInfo['email'];

      if (email == null || email.isEmpty) {
        _showErrorMessage(
            'No email address found. Please update your profile.');
        return;
      }

      final progressData = await _exportService.getUserApplicationProgress();
      final jsonContent =
          _exportService.generateApplicationProgressJSON(progressData);
      final filename =
          'application_progress_${DateTime.now().millisecondsSinceEpoch}.json';

      // Convert JSON to CSV-like format for email
      final csvContent = _convertProgressToCSV(progressData);

      await _exportService.sendDataViaEmail(
        email: email,
        filename:
            'application_progress_${DateTime.now().millisecondsSinceEpoch}.csv',
        csvContent: csvContent,
        userFullName: userInfo['full_name'],
      );

      _showSuccessMessage('Application progress has been sent to $email');
    } catch (error) {
      _showErrorMessage(
          'Failed to email application progress: ${error.toString()}');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  String _convertProgressToCSV(Map<String, dynamic> progress) {
    final buffer = StringBuffer();
    buffer.writeln('metric,value');
    buffer.writeln('export_date,${progress['export_date']}');
    buffer.writeln('total_applications,${progress['total_applications']}');
    buffer.writeln('total_bookmarks,${progress['total_bookmarks']}');
    buffer.writeln('applied_count,${progress['applied_count']}');
    buffer.writeln('in_review_count,${progress['in_review_count']}');
    buffer.writeln('accepted_count,${progress['accepted_count']}');
    buffer.writeln('rejected_count,${progress['rejected_count']}');
    buffer.writeln('success_rate,${progress['success_rate']}%');

    // Add upcoming deadlines
    if (progress['upcoming_deadlines'] != null) {
      buffer.writeln('\nupcoming_deadlines');
      buffer.writeln('scholarship,deadline,status');
      for (final deadline in progress['upcoming_deadlines']) {
        buffer.writeln(
            '${deadline['scholarship']},${deadline['deadline']},${deadline['status']}');
      }
    }

    return buffer.toString();
  }

  void _showSuccessMessage(String message) {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        textColor: Colors.white,
      );
    }
  }

  void _showErrorMessage(String message) {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
    }
  }

  void _showInfoMessage(String message) {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildLoadingWidget() {
    return SizedBox(
      width: 5.w,
      height: 5.w,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsTileWidget(
          title: 'Export Scholarships',
          subtitle: 'Download your saved scholarships as CSV',
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'school',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          trailing: _isExporting ? _buildLoadingWidget() : null,
          onTap: _isExporting ? null : _exportScholarshipData,
        ),
        SettingsTileWidget(
          title: 'Email Scholarships CSV',
          subtitle: 'Send your scholarship data to your email',
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'email',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 20,
            ),
          ),
          trailing: _isExporting ? _buildLoadingWidget() : null,
          onTap: _isExporting ? null : _emailScholarshipData,
        ),
        SettingsTileWidget(
          title: 'Export Application Progress',
          subtitle: 'Download complete progress report as JSON',
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'assignment',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          trailing: _isExporting ? _buildLoadingWidget() : null,
          onTap: _isExporting ? null : _exportApplicationProgress,
        ),
        SettingsTileWidget(
          title: 'Email Progress Report',
          subtitle: 'Send your application progress to your email',
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'send',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 20,
            ),
          ),
          trailing: _isExporting ? _buildLoadingWidget() : null,
          onTap: _isExporting ? null : _emailApplicationProgress,
        ),
      ],
    );
  }
}
