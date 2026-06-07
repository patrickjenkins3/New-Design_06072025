import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/ai_support_service.dart';
import '../../widgets/cf_bottom_nav.dart';

class AISupportScreen extends StatefulWidget {
  const AISupportScreen({super.key});
  @override
  State<AISupportScreen> createState() => _AISupportScreenState();
}

class _AISupportScreenState extends State<AISupportScreen> {
  final _msgCtrl  = TextEditingController();
  final _scroll   = ScrollController();
  final _service  = AISupportService();
  final List<_ChatMsg> _msgs = [
    _ChatMsg(role: 'assistant', text: "Hi! I'm your AI college admissions assistant. I can help you with college search, scholarships, applications, school visits, and more. How can I help you today?"),
  ];
  bool _typing = false;
  final _quickActions = ['College Search', 'Scholarships', 'Deadlines', 'Financial Aid', 'Requirements'];

  @override
  void dispose() { _msgCtrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _send([String? override]) async {
    final text = override ?? _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    setState(() { _msgs.add(_ChatMsg(role: 'user', text: text)); _typing = true; });
    _scrollDown();

    try {
      final reply = await _service.getQuickGuidance(text);
      if (mounted) setState(() { _msgs.add(_ChatMsg(role: 'assistant', text: reply)); _typing = false; });
    } catch (_) {
      if (mounted) setState(() {
        _msgs.add(const _ChatMsg(role: 'assistant', text: "I apologize, I can't respond right now. Please try again."));
        _typing = false;
      });
    }
    _scrollDown();
  }

  void _scrollDown() => Future.delayed(const Duration(milliseconds: 100), () {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.navy : AppTheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.navyDark : AppTheme.white,
        surfaceTintColor: Colors.transparent,
        title: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.skyBlue, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.smart_toy_outlined, color: AppTheme.white, size: 16)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AI Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text("Here to help you succeed", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted)),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight)),
      ),
      body: Column(children: [
        // Quick actions
        Container(
          height: 44,
          color: isDark ? AppTheme.navyDark : AppTheme.white,
          child: ListView.separated(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _quickActions.length, separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _send(_quickActions[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : AppTheme.dividerLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppTheme.dividerDark : AppTheme.textMuted),
                ),
                alignment: Alignment.center,
                child: Text(_quickActions[i], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _msgs.length + (_typing ? 1 : 0),
            itemBuilder: (_, i) {
              if (_typing && i == _msgs.length) return const _TypingIndicator();
              return _MsgBubble(msg: _msgs[i]);
            },
          ),
        ),

        // Input bar
        Container(
          color: isDark ? AppTheme.navyDark : AppTheme.white,
          padding: EdgeInsets.only(left: 16, right: 8, top: 8, bottom: MediaQuery.of(context).viewInsets.bottom + 8),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true, fillColor: isDark ? AppTheme.cardDark : AppTheme.dividerLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
                maxLines: 3, minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppTheme.navy, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: AppTheme.white, size: 18),
              ),
            ),
          ]),
        ),
      ]),
      bottomNavigationBar: CFBottomNav(currentIndex: 0, onTap: (i) {
        if (i == 0) Navigator.pushReplacementNamed(context, AppRoutes.dashboardScreen);
        else if (i == 2) Navigator.pushReplacementNamed(context, AppRoutes.scholarshipFeedScreen);
        else if (i == 3) Navigator.pushReplacementNamed(context, AppRoutes.profileSettingsScreen);
      }),
    );
  }
}

class _ChatMsg {
  final String role, text;
  const _ChatMsg({required this.role, required this.text});
}

class _MsgBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _MsgBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(width: 28, height: 28, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: AppTheme.skyBlue, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.smart_toy_outlined, color: AppTheme.white, size: 14)),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.navy : (isDark ? AppTheme.cardDark : AppTheme.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4), bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
              ),
              child: Text(msg.text, style: TextStyle(
                color: isUser ? AppTheme.white : (isDark ? AppTheme.white : AppTheme.navy),
                fontSize: 14, height: 1.5,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(width: 28, height: 28, margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: AppTheme.skyBlue, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.smart_toy_outlined, color: AppTheme.white, size: 14)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : AppTheme.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
            border: Border.all(color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
          ),
          child: const SizedBox(width: 40, height: 16, child: _Dots()),
        ),
      ]),
    );
  }
}

class _Dots extends StatefulWidget {
  const _Dots();
  @override
  State<_Dots> createState() => _DotsState();
}

class _DotsState extends State<_Dots> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) {
      final v = (_c.value * 3 - i).clamp(0.0, 1.0);
      return Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 6, height: 6,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.textMuted.withValues(alpha: 0.4 + 0.6 * v)));
    })),
  );
}
