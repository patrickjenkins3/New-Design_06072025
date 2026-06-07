import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool enabled;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _sendMessage() {
    if (_hasText && widget.enabled) {
      final text = widget.controller.text.trim();
      if (text.isNotEmpty) {
        widget.onSend(text);
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
    return Container(
      padding: EdgeInsets.all(_getResponsiveWidth(4.0)),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: widget.controller,
                  enabled: widget.enabled,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.inter(
                    fontSize: _getResponsiveFontSize(16.0),
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask me anything about college planning...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: _getResponsiveFontSize(16.0),
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: _getResponsiveWidth(5.0),
                      vertical: _getResponsiveHeight(1.5),
                    ),
                  ),
                  onSubmitted: (text) => _sendMessage(),
                ),
              ),
            ),
            SizedBox(width: _getResponsiveWidth(3.0)),
            GestureDetector(
              onTap: widget.enabled && _hasText ? _sendMessage : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.enabled && _hasText
                      ? const Color(0xFF6366F1)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.send,
                  color: widget.enabled && _hasText
                      ? Colors.white
                      : Colors.grey[500],
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
