import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  bool _isParent = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.instance.signIn(email: _emailCtrl.text.trim(), password: _passCtrl.text);
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.dashboardScreen);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 48),

              // ── Logo ─────────────────────────────────────────
              Center(child: Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.navy,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppTheme.navy.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: const Icon(Icons.school, color: AppTheme.white, size: 30),
                ),
                const SizedBox(height: 12),
                Text('CollabFuture', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.navy, fontWeight: FontWeight.w800)),
              ])),
              const SizedBox(height: 36),

              // ── Heading ───────────────────────────────────────
              Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text("Plan your family's future together",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted)),
              const SizedBox(height: 24),

              // ── Parent / Teen toggle ──────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : AppTheme.dividerLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(children: [
                  _TypeTab(label: 'Parent', selected: _isParent,  onTap: () => setState(() => _isParent = true)),
                  _TypeTab(label: 'Teen',   selected: !_isParent, onTap: () => setState(() => _isParent = false)),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Email ─────────────────────────────────────────
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Address', hintText: 'Enter your email address'),
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 14),

              // ── Password ──────────────────────────────────────
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textMuted, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
              ),
              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ),

              // ── Error banner ──────────────────────────────────
              if (_error != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13))),
                  ]),
                ),
              ],
              const SizedBox(height: 20),

              // ── Sign In ───────────────────────────────────────
              ElevatedButton(
                onPressed: _loading ? null : _signIn,
                child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white))
                  : const Text('Sign In'),
              ),
              const SizedBox(height: 20),

              // ── Social divider ────────────────────────────────
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Or continue with', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),

              // ── Social buttons ────────────────────────────────
              Row(children: [
                Expanded(child: _SocialBtn(icon: Icons.g_mobiledata, label: 'Google', onTap: () {})),
                const SizedBox(width: 12),
                Expanded(child: _SocialBtn(icon: Icons.apple, label: 'Apple', onTap: () {})),
              ]),
              const SizedBox(height: 28),

              // ── Sign up link ──────────────────────────────────
              Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("Don't have an account? ", style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.progressiveRegistrationScreen),
                  child: const Text('Sign Up', style: TextStyle(color: AppTheme.skyBlue, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ])),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reset Password', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text("We'll send a reset link to your email.", style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
          const SizedBox(height: 16),
          TextField(controller: ctrl, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email Address')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isNotEmpty) {
                try { await AuthService.instance.resetPassword(ctrl.text.trim()); } catch (_) {}
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset email sent! Check your inbox.')));
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _TypeTab({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(
          color: selected ? AppTheme.white : AppTheme.textMuted,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          fontSize: 14,
        )),
      ),
    ),
  );
}

class _SocialBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _SocialBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 20),
    label: Text(label),
    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
  );
}
