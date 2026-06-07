import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.5));
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    final isAuth = AuthService.instance.isAuthenticated;
    Navigator.pushReplacementNamed(context, isAuth ? AppRoutes.dashboardScreen : AppRoutes.loginScreen);
  }

  @override
  void dispose() { _logoCtrl.dispose(); _textCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Navy gradient background
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.navy, AppTheme.navyDark],
            ),
          ),
          child: SafeArea(
            child: Column(children: [
              const Spacer(flex: 2),

              // Logo mark
              AnimatedBuilder(
                animation: _logoCtrl,
                builder: (_, __) => Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        color: AppTheme.skyBlue,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: AppTheme.skyBlue.withValues(alpha: 0.4), blurRadius: 32, offset: const Offset(0, 12))],
                      ),
                      child: const Icon(Icons.school, color: AppTheme.white, size: 44),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Text
              AnimatedBuilder(
                animation: _textCtrl,
                builder: (_, __) => FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(children: [
                      Text('CollabFuture',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.white, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      Text("Your Family's Future Planned Together",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.white.withValues(alpha: 0.65))),
                    ]),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Feature row
              AnimatedBuilder(
                animation: _textCtrl,
                builder: (_, __) => Opacity(
                  opacity: _textFade.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      _FeatureChip(icon: Icons.search, label: 'School\nResearch', color: AppTheme.skyBlue),
                      _FeatureChip(icon: Icons.card_giftcard_outlined, label: 'Scholarships', color: AppTheme.sage),
                      _FeatureChip(icon: Icons.group_outlined, label: 'Family\nCollaboration', color: AppTheme.gold),
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 48),
              SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.skyBlue.withValues(alpha: 0.5))),
              const SizedBox(height: 36),
            ]),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _FeatureChip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 52, height: 52,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Icon(icon, color: color, size: 24),
    ),
    const SizedBox(height: 8),
    Text(label, style: TextStyle(color: AppTheme.white.withValues(alpha: 0.75), fontSize: 11, height: 1.3),
      textAlign: TextAlign.center),
  ]);
}
