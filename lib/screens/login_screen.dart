import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../constants/app_theme.dart';
import '../constants/app_responsive.dart';
import 'donor_dashboard.dart';
import 'ngo_dashboard.dart';
import 'dart:ui';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey  = GlobalKey<FormState>();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _org      = TextEditingController();
  final _addr     = TextEditingController();
  final _phone    = TextEditingController();
  final _authService = AuthService();
  bool  _loading     = false;
  bool   _isLogin = true;
  bool   _obscure = true;
  String _role    = 'Donor';

  late final AnimationController _heroCtrl;
  late final AnimationController _cardCtrl;
  late final Animation<double>   _heroFade;
  late final Animation<Offset>   _heroSlide;
  late final Animation<double>   _cardFade;
  late final Animation<Offset>   _cardSlide;
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseA;
  late final Animation<double>   _pulseB;
  late final AnimationController _glowCtrl;
  late final Animation<double>   _glowAnim;
  late final AnimationController _blinkCtrl;
  late final Animation<double>   _blinkAnim;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _heroFade  = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, .09), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: const Cubic(.16, 1, .3, 1)));

    _cardCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _cardFade  = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(begin: const Offset(0, .07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: const Cubic(.16, 1, .3, 1)));

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _pulseA = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _pulseB = CurvedAnimation(parent: _pulseCtrl,
        curve: const Interval(.15, 1, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    _blinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _blinkAnim = CurvedAnimation(parent: _blinkCtrl, curve: Curves.easeInOut);

    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 150), _cardCtrl.forward);
  }

  @override
  void dispose() {
    for (final c in [_heroCtrl, _cardCtrl, _pulseCtrl, _glowCtrl, _blinkCtrl]) c.dispose();
    for (final c in [_email, _password, _org, _addr, _phone]) c.dispose();
    super.dispose();
  }

  void _switchMode() {
    _cardCtrl.reset();
    // Clear all form fields and reset validation state
    _formKey.currentState?.reset();
    _email.clear();
    _password.clear();
    _org.clear();
    _addr.clear();
    _phone.clear();
    setState(() => _isLogin = !_isLogin);
    _cardCtrl.forward();
  }

  void _submit() async {
    // For Sign Up, check if all required fields are filled
    if (!_isLogin) {
      if (_email.text.trim().isEmpty ||
          _password.text.isEmpty ||
          _org.text.trim().isEmpty ||
          _phone.text.trim().isEmpty ||
          _addr.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All fields need to be filled in'),
            backgroundColor: AppColors.terr,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (_isLogin) {
        // ── Sign In ──────────────────��─────────────────────────
        final data = await _authService.signIn(
          email:    _email.text.trim(),
          password: _password.text,
        );

        if (!mounted) return;

        // Validate that we got user data back
        if (data.isEmpty) {
          throw Exception('Failed to retrieve user profile. Please try again.');
        }

        // Save user to AppState so all screens can access it
        Provider.of<AppState>(context, listen: false)
            .setUser(UserProfile.fromMap(data));

        // Go to the right dashboard based on role
        final role = data['role'] as String? ?? 'Donor';
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, anim, __) => FadeTransition(
              opacity: anim,
              child: role == 'Donor'
                  ? const DonorDashboard()
                  : const NGODashboard(),
            ),
          ),
        );

      } else {
        // ── Sign Up ────────────────────────────────────────────
        await _authService.signUp(
          email:    _email.text.trim(),
          password: _password.text,
          orgName:  _org.text.trim().isEmpty
                        ? 'Organization'
                        : _org.text.trim(),
          address:  _addr.text.trim(),
          role:     _role,             // 'Donor' or 'NGO' from toggle
        );

        if (!mounted) return;

        // Clear form fields after successful signup
        _email.clear();
        _password.clear();
        _org.clear();
        _addr.clear();
        _phone.clear();

        // After signup, ask them to sign in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Account created! Please sign in.'),
            backgroundColor: AppColors.sage,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Switch to login mode automatically
        setState(() => _isLogin = true);
      }

    } catch (e) {
      // Show whatever error message Firebase gives us
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.terr,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // Always stop the loading spinner
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.pageSplit),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Hero bar ─────────────────────────────────────────────
                FadeTransition(
                  opacity: _heroFade,
                  child: SlideTransition(
                    position: _heroSlide,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(AppDimensions.radiusHero)),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(gradient: AppGradients.heroBar),
                        child: Stack(children: [
                          Positioned.fill(child: CustomPaint(painter: _HeroDotPainter())),
                          Positioned(
                            top: -60, right: -60,
                            child: Container(
                              width: 220, height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [AppColors.amber.withOpacity(0.28),
                                    Colors.transparent],
                                  stops: const [0, .65],
                                ),
                              ),
                            ),
                          ),
                          _HeroSection(
                              pulseA: _pulseA, pulseB: _pulseB, blinkAnim: _blinkAnim),
                        ]),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppResponsive.h(20)),

                // ── Form card ────────────────────���───────────────────────
                FadeTransition(
                  opacity: _cardFade,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppResponsive.w(16), 0, 
                        AppResponsive.w(16), 
                        AppResponsive.h(40)
                      ),
                      child: _buildCard(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: AppDecorations.card,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Stack(children: [
          // Three-color left accent stripe
          Positioned(
            left: 0, top: 0, bottom: 0,
            child: Container(
              width: 3,
              decoration: const BoxDecoration(gradient: AppGradients.cardAccentBorder),
            ),
          ),
          Padding(
            padding: AppDimensions.cardPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Pill(label: _isLogin ? 'SIGN IN TO CONTINUE' : 'CREATE ACCOUNT'),
                  const SizedBox(height: 16),

                  Text(_isLogin ? 'Welcome back.' : 'Join us.',
                      style: AppTextStyles.cardHead),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin
                        ? 'Every meal shared is a life touched — sign in and make it count.'
                        : 'Connect your surplus food with communities that need it most.',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 26),

                  _RoleToggle(
                      selected: _role,
                      onChanged: (r) => setState(() => _role = r)),
                  const SizedBox(height: 22),

                  if (!_isLogin) ...[
                    _lf(label: 'ORGANIZATION NAME', ctrl: _org,
                        icon: Icons.business_outlined, hint: 'Your organization',
                        val: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                    const SizedBox(height: 12),
                  ],
                  _lf(label: 'EMAIL ADDRESS', ctrl: _email,
                      icon: Icons.email_outlined, hint: 'you@example.com',
                      keyboard: TextInputType.emailAddress,
                      val: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(v.trim())) return 'Invalid email';
                        return null;
                      }),
                  const SizedBox(height: 12),
                  _lf(label: 'PASSWORD', ctrl: _password,
                      icon: Icons.lock_outline, hint: 'Enter your password',
                      obscure: _obscure,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                          _obscure ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: AppDimensions.iconSm,
                          color: AppColors.ink.withOpacity(0.28),
                        ),
                      ),
                      val: (v) => v == null || v.isEmpty || v.length < 4
                          ? 'Min 4 characters' : null),
                  if (!_isLogin) ...[
                    const SizedBox(height: 12),
                    _lf(label: 'PHONE NUMBER', ctrl: _phone,
                        icon: Icons.phone_outlined, hint: 'Your phone number',
                        keyboard: TextInputType.phone,
                        val: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                    const SizedBox(height: 12),
                    _lf(label: 'FULL ADDRESS', ctrl: _addr,
                        icon: Icons.place_outlined, hint: 'Your full address',
                        val: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                  ],
                  if (_isLogin) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          // Make sure they've typed an email first
                          if (_email.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your email address first.'),
                                backgroundColor: AppColors.terr,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          try {
                            await _authService.sendPasswordResetEmail(_email.text.trim());
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✅ Reset email sent to ${_email.text.trim()}'),
                                backgroundColor: AppColors.sage,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: AppColors.terr,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Text('Forgot password?',
                            style: AppTextStyles.forgotLink),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),

                  _GlowCTAButton(
                    label: _loading
                        ? 'Please wait...'
                        : (_isLogin ? 'SIGN IN' : 'CREATE ACCOUNT'),
                    glowAnim: _glowAnim,
                    onPressed: _loading ? () {} : _submit,
                  ),
                  const SizedBox(height: 20),

                  Row(children: [
                    Expanded(child: Divider(
                        color: AppColors.ink.withOpacity(0.07), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or continue with',
                          style: TextStyle(fontSize: 10.5,
                              fontWeight: FontWeight.w300,
                              color: AppColors.ink.withOpacity(0.28))),
                    ),
                    Expanded(child: Divider(
                        color: AppColors.ink.withOpacity(0.07), thickness: 1)),
                  ]),
                  const SizedBox(height: 14),

                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            final data = await _authService.signInWithGoogle(role: _role);
                            if (data == null || !mounted) return;

                            Provider.of<AppState>(context, listen: false)
                                .setUser(UserProfile.fromMap(data));

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => data['role'] == 'Donor'
                                    ? const DonorDashboard()
                                    : const NGODashboard(),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: AppColors.terr,
                              ),
                            );
                          }
                        },
                        child: _SocialBtn(
                          label: 'Google',
                          icon: Icons.g_mobiledata_rounded,
                          iconColor: const Color(0xFF4285F4),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: _switchMode,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: AppColors.ink.withOpacity(0.42)),
                          children: [
                            TextSpan(text: _isLogin
                                ? "Don't have an account?  "
                                : 'Already have an account?  '),
                            TextSpan(
                              text: _isLogin ? 'Sign up' : 'Sign in',
                              style: AppTextStyles.link,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _lf({
    required String label, required TextEditingController ctrl,
    required IconData icon, required String hint,
    TextInputType? keyboard, bool obscure = false,
    Widget? suffix, String? Function(String?)? val,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 5),
          child: Text(label, style: AppTextStyles.fieldLabel),
        ),
        _FocusField(controller: ctrl, icon: icon, hint: hint,
            keyboard: keyboard, obscure: obscure,
            suffix: suffix, validator: val),
      ],
    );
  }
}

// ─── Hero Dot Painter ─────────────────────────────────────────────────────────
class _HeroDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = Colors.white.withOpacity(0.06);
    for (double x = 0; x < s.width; x += 22) {
      for (double y = 0; y < s.height; y += 22) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
  }
  @override bool shouldRepaint(_) => false;
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final Animation<double> pulseA, pulseB, blinkAnim;
  const _HeroSection({
    required this.pulseA, required this.pulseB, required this.blinkAnim});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.heroPadding,
      child: Column(children: [
        // LIVE badge
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedBuilder(
            animation: blinkAnim,
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: AppDecorations.liveBadge,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 5, height: 5,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: AppColors.amberLt,
                        boxShadow: [BoxShadow(
                            color: AppColors.amber, blurRadius: 6)])),
                const SizedBox(width: 5),
                Text('LIVE', style: AppTextStyles.liveLabel),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Logo badge with pulse rings
        SizedBox(
          width: 116, height: 116,
          child: Stack(alignment: Alignment.center, children: [
            AnimatedBuilder(animation: pulseB, builder: (_, __) => Container(
              width: 112 + pulseB.value * 8,
              height: 112 + pulseB.value * 8,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.amberLt.withOpacity(
                          (0.15 - pulseB.value * 0.06).clamp(0.0, 1.0)),
                      width: 1)),
            )),
            AnimatedBuilder(animation: pulseA, builder: (_, __) => Container(
              width: 100 + pulseA.value * 6,
              height: 100 + pulseA.value * 6,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.amberLt.withOpacity(
                          (0.35 - pulseA.value * 0.12).clamp(0.0, 1.0)),
                      width: 1.5)),
            )),
            Container(
              width: 86, height: 86,
              decoration: AppDecorations.logoBadge.copyWith(boxShadow: [
                BoxShadow(color: AppColors.amber.withOpacity(0.40),
                    blurRadius: 40, offset: const Offset(0, 14)),
                BoxShadow(color: AppColors.amberDk.withOpacity(0.22),
                    blurRadius: 12, offset: const Offset(0, 4)),
              ]),
              child: Stack(alignment: Alignment.center, children: [
                Icon(Icons.favorite, size: 46,
                    color: Colors.white.withOpacity(0.95)),
                const Icon(Icons.handshake, size: 24,
                    color: Color(0xFF92400E)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        Text('ShareMeal', style: AppTextStyles.brandName),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 24, height: 1,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(colors: [Colors.transparent,
                      AppColors.amberLt.withOpacity(0.55)]))),
            const SizedBox(width: 8),
            Text('REDUCING WASTE · FEEDING HOPE', style: AppTextStyles.tagline),
            const SizedBox(width: 8),
            Container(width: 24, height: 1,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(colors: [
                      AppColors.amberLt.withOpacity(0.55), Colors.transparent]))),
          ]),
        ),
        const SizedBox(height: 20),

        // Stats bridge card
        Container(
          decoration: AppDecorations.statsCard,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: const Row(children: [
            Expanded(child: _StatItem(number: '1.3B', label: 'tonnes food\nwasted/year')),
            _StatDivider(),
            Expanded(child: _StatItem(number: '828M', label: 'people hungry\nevery day')),
            _StatDivider(),
            Expanded(child: _StatItem(number: '2hr',  label: 'food rescue\ntime window')),
          ]),
        ),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number, label;
  const _StatItem({required this.number, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(number, style: AppTextStyles.statNumber),
    const SizedBox(height: 4),
    Text(label, textAlign: TextAlign.center, style: AppTextStyles.statLabel),
  ]);
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36,
          color: AppColors.ink.withOpacity(0.08));
}

// ─── Pill ─────────────────────────────────────────────────────────────────────
class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: AppDecorations.sagePill,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColors.sage,
                boxShadow: [BoxShadow(
                    color: AppColors.sage.withOpacity(0.5), blurRadius: 6)])),
        const SizedBox(width: 7),
        Text(label,
            style: AppTextStyles.pillLabel.copyWith(color: AppColors.sage)),
      ]),
    );
  }
}

// ─── Role Toggle ──────────────────────────────────────────────────────────────
class _RoleToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _RoleToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, padding: const EdgeInsets.all(4),
      decoration: AppDecorations.toggleBg,
      child: Row(children: [
        _tab(Icons.volunteer_activism_outlined, 'Donor', 'Donor'),
        _tab(Icons.groups_outlined,             'NGO',   'NGO'),
      ]),
    );
  }

  // ── 3 params: icon, display label, key ────────────────────────────────
  Widget _tab(IconData icon, String label, String key) {
    final active = selected == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(key),
        child: Container(
          color: Colors.transparent, // Make entire area tappable
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: active ? AppDecorations.toggleActive : null,
            alignment: Alignment.center,
            child: AnimatedScale(
              scale: active ? 1.02 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: active ? Colors.white : AppColors.ink.withOpacity(0.38),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active
                          ? Colors.white
                          : AppColors.ink.withOpacity(0.38),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Focus-aware field ────────────────────────────────────────────────────────
class _FocusField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboard;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;
  const _FocusField({
    required this.controller, required this.icon, required this.hint,
    this.keyboard, this.obscure = false, this.suffix, this.validator,
  });
  @override State<_FocusField> createState() => _FocusFieldState();
}

class _FocusFieldState extends State<_FocusField> {
  final _f = FocusNode();
  bool _focused = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _f.addListener(() => setState(() => _focused = _f.hasFocus));
    widget.controller.addListener(_clearError);
  }

  void _clearError() {
    if (mounted && _hasError && widget.controller.text.isEmpty) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    }
  }

  @override void dispose() { 
    _f.dispose();
    widget.controller.removeListener(_clearError);
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: _hasError
              ? AppDecorations.fieldError
              : (_focused ? AppDecorations.fieldFocused : AppDecorations.field),
          child: TextFormField(
            controller: widget.controller, focusNode: _f,
            keyboardType: widget.keyboard, obscureText: widget.obscure,
            validator: (value) {
              final result = widget.validator?.call(value);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _hasError = result != null;
                    _errorMessage = result;
                  });
                }
              });
              return null; // Return null to hide default error below
            },
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: AppColors.ink.withOpacity(0.25),
                  fontSize: 13.5, fontWeight: FontWeight.w300),
              prefixIcon: AnimatedOpacity(
                opacity: _focused ? 0.65 : 0.30,
                duration: const Duration(milliseconds: 200),
                child: Icon(widget.icon, size: AppDimensions.iconSm,
                    color: _hasError ? AppColors.terr : AppColors.ink),
              ),
              suffixIcon: widget.suffix != null
                  ? Padding(padding: const EdgeInsets.only(right: 12),
                      child: widget.suffix)
                  : null,
              border: InputBorder.none,
              contentPadding: _hasError
                  ? EdgeInsets.fromLTRB(16, 12, 16, 12) // Reduced padding for error text
                  : AppDimensions.fieldContentPad,
            ),
          ),
        ),
        if (_hasError && _errorMessage != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.terr,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Glow CTA Button ─────────────────────────────────────────────────────────
class _GlowCTAButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Animation<double> glowAnim;
  const _GlowCTAButton({
    required this.label, required this.onPressed, required this.glowAnim});
  @override State<_GlowCTAButton> createState() => _GlowCTAState();
}

class _GlowCTAState extends State<_GlowCTAButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onPressed(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: double.infinity, height: AppDimensions.btnHeight,
          child: Stack(children: [
            AnimatedBuilder(
              animation: widget.glowAnim,
              builder: (_, __) => Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    boxShadow: [BoxShadow(
                      color: AppColors.sage.withOpacity(
                          (0.32 + widget.glowAnim.value * 0.18).clamp(0.0, 1.0)),
                      blurRadius: 18, spreadRadius: 2,
                    )],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppGradients.sageButton,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                boxShadow: [BoxShadow(color: AppColors.sage.withOpacity(0.30),
                    blurRadius: 20, offset: const Offset(0, 8))],
              ),
              alignment: Alignment.center,
              child: Text(widget.label, style: AppTextStyles.ctaButton),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Social Button ────────────────────────────────────────────────────────────
class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  const _SocialBtn({required this.label, required this.icon,
      required this.iconColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: AppDecorations.socialBtn,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500, color: AppColors.ink2)),
      ]),
    );
  }
}
