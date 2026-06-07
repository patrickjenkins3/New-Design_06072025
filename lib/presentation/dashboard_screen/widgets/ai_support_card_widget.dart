import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../routes/app_routes.dart';
import '../../../services/ai_support_service.dart';

class AISupportCardWidget extends StatefulWidget {
  const AISupportCardWidget({super.key});

  @override
  State<AISupportCardWidget> createState() => _AISupportCardWidgetState();
}

class _AISupportCardWidgetState extends State<AISupportCardWidget> {
  final AISupportService _aiService = AISupportService();
  String _dailyTip = 'Loading your daily educational tip...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyTip();
  }

  Future<void> _loadDailyTip() async {
    try {
      final tip = await _aiService.getDailyTip();
      if (mounted) {
        setState(() {
          _dailyTip = tip;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dailyTip =
              'Stay organized with your college planning! Create a timeline for applications, scholarships, and important deadlines.';
          _isLoading = false;
        });
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
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.aiSupportScreen),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: _getResponsiveWidth(4.0),
          vertical: _getResponsiveHeight(1.0),
        ),
        padding: EdgeInsets.all(_getResponsiveWidth(4.0)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withAlpha(77),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: _getResponsiveWidth(3.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Support Assistant',
                        style: GoogleFonts.inter(
                          fontSize: _getResponsiveFontSize(16.0),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Get instant help with college planning',
                        style: GoogleFonts.inter(
                          fontSize: _getResponsiveFontSize(12.0),
                          color: Colors.white.withAlpha(204),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withAlpha(204),
                  size: 16,
                ),
              ],
            ),
            SizedBox(height: _getResponsiveHeight(2.0)),
            Container(
              padding: EdgeInsets.all(_getResponsiveWidth(3.0)),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(38),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: _getResponsiveWidth(1.5)),
                      Text(
                        'Daily Tip',
                        style: GoogleFonts.inter(
                          fontSize: _getResponsiveFontSize(12.0),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _getResponsiveHeight(1.0)),
                  _isLoading
                      ? Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withAlpha(204),
                                ),
                              ),
                            ),
                            SizedBox(width: _getResponsiveWidth(2.0)),
                            Text(
                              'Loading tip...',
                              style: GoogleFonts.inter(
                                fontSize: _getResponsiveFontSize(13.0),
                                color: Colors.white.withAlpha(230),
                                height: 1.4,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _dailyTip,
                          style: GoogleFonts.inter(
                            fontSize: _getResponsiveFontSize(13.0),
                            color: Colors.white.withAlpha(230),
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),
            SizedBox(height: _getResponsiveHeight(1.5)),
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(vertical: _getResponsiveHeight(1.0)),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(51)),
              ),
              child: Text(
                'Tap to chat with AI Assistant',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: _getResponsiveFontSize(12.0),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
