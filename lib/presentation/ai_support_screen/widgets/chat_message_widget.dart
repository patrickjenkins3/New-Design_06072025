import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../ai_support_screen.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({
    super.key,
    required this.message,
  });

  double _getResponsiveWidth(BuildContext context, double percentage) {
    try {
      return percentage.w;
    } catch (e) {
      return MediaQuery.of(context).size.width * (percentage / 100);
    }
  }

  double _getResponsiveHeight(BuildContext context, double percentage) {
    try {
      return percentage.h;
    } catch (e) {
      return MediaQuery.of(context).size.height * (percentage / 100);
    }
  }

  double _getResponsiveFontSize(BuildContext context, double size) {
    try {
      return size.sp;
    } catch (e) {
      return size * MediaQuery.of(context).textScaleFactor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (message.isTyping) {
      return _buildTypingIndicator(context);
    }

    return Container(
      margin: EdgeInsets.only(
        bottom: _getResponsiveHeight(context, 2.0),
        left: message.isUser ? _getResponsiveWidth(context, 12.0) : 0,
        right: message.isUser ? 0 : _getResponsiveWidth(context, 12.0),
      ),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            SizedBox(width: _getResponsiveWidth(context, 2.0)),
          ],
          Expanded(
            child: Container(
              padding: EdgeInsets.all(_getResponsiveWidth(context, 4.0)),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF6366F1)
                    : (message.isError ? Colors.red[50] : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                border: message.isUser
                    ? null
                    : Border.all(
                        color: message.isError
                            ? Colors.red[200]!
                            : Colors.grey[200]!,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.text.isNotEmpty)
                    SelectableText(
                      message.text,
                      style: GoogleFonts.inter(
                        fontSize: _getResponsiveFontSize(context, 15.0),
                        color: message.isUser
                            ? Colors.white
                            : (message.isError
                                ? Colors.red[800]
                                : Colors.black87),
                        height: 1.4,
                      ),
                    ),
                  if (message.text.isNotEmpty)
                    SizedBox(height: _getResponsiveHeight(context, 1.0)),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: _getResponsiveFontSize(context, 12.0),
                      color: message.isUser
                          ? Colors.white.withAlpha(179)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: _getResponsiveWidth(context, 2.0)),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: _getResponsiveHeight(context, 2.0),
        right: _getResponsiveWidth(context, 12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          SizedBox(width: _getResponsiveWidth(context, 2.0)),
          Container(
            padding: EdgeInsets.all(_getResponsiveWidth(context, 4.0)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: _getResponsiveWidth(context, 1.0)),
                _buildDot(1),
                SizedBox(width: _getResponsiveWidth(context, 1.0)),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.4, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[400]!.withOpacity(value),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
