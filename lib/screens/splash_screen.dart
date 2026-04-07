import 'package:flutter/material.dart';
import 'package:sharemeal/constants/app_theme.dart';
import 'package:sharemeal/screens/auth_wrapper.dart';

// ── Reusable logo widget ───────────────────────────────────────────────────────
class ShareMealLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  const ShareMealLogo({super.key, this.size = 72, this.showShadow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.amberLt, AppColors.amber, AppColors.amberDk],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                    color: AppColors.amber.withAlpha(110),
                    blurRadius: size * 0.5,
                    offset: Offset(0, size * 0.15)),
                BoxShadow(
                    color: AppColors.amberDk.withAlpha(60),
                    blurRadius: size * 0.15,
                    offset: Offset(0, size * 0.05)),
              ]
            : null,
      ),
      child: Stack(alignment: Alignment.center, children: [
        Icon(Icons.favorite,
            size: size * 0.54, color: Colors.white.withAlpha(242)),
        Icon(Icons.handshake,
            size: size * 0.28, color: const Color(0xFF92400E)),
      ]),
    );
  }
}

// ── Static splash background — used both in SplashScreen and transition overlay
class _SplashBg extends StatelessWidget {
  final Widget? child;
  const _SplashBg({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.sageHero, AppColors.sage, Color(0xFF4EA882)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _DotPainter())),
        Positioned(
          top: -80, right: -80,
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.amber.withAlpha(60), Colors.transparent],
                stops: const [0, 0.7],
              ),
            ),
          ),
        ),
        if (child != null) child!,
      ]),
    );
  }
}

// ── Fully static splash content (no animations) — used in transition overlay ──
class _StaticSplashContent extends StatelessWidget {
  const _StaticSplashContent();

  @override
  Widget build(BuildContext context) {
    return _SplashBg(
      child: Stack(children: [
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const ShareMealLogo(size: 100),
            const SizedBox(height: 24),
            const Text(
              'ShareMeal',
              style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.w700,
                color: Colors.white, letterSpacing: -0.5,
                shadows: [Shadow(color: Color(0x40000000), blurRadius: 16)],
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 20, height: 1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                      colors: [Colors.transparent, AppColors.amberLt.withAlpha(160)]),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'REDUCING WASTE · FEEDING HOPE',
                style: TextStyle(
                  fontSize: 9.5, fontWeight: FontWeight.w500,
                  color: AppColors.terrLt.withAlpha(220),
                  letterSpacing: 2.8,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20, height: 1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                      colors: [AppColors.amberLt.withAlpha(160), Colors.transparent]),
                ),
              ),
            ]),
          ]),
        ),
        const Positioned(
          bottom: 40, left: 0, right: 0,
          child: Text(
            'Connecting surplus food with those who need it most',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11, color: Colors.white54,
              fontWeight: FontWeight.w300, letterSpacing: 0.3,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Splash Screen ─────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Entry animations
  late final AnimationController _entryCtrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _tagFade;

  // Exit zoom animation
  late final AnimationController _exitCtrl;
  late final Animation<double> _exitScale;
  late final Animation<double> _exitFade;

  bool _exiting = false;

  @override
  void initState() {
    super.initState();

    // ── Entry ──────────────────────────────────────────────────────
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _logoFade  = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.0, 0.7,
                curve: Cubic(0.34, 1.56, 0.64, 1.0))));
    _tagFade   = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut));

    // ── Exit zoom ──────────────────────────────────────────────────
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    // Zoom the whole splash from 1x → 2x (punches through the screen)
    _exitScale = Tween<double>(begin: 1.0, end: 2.2).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic));
    _exitFade  = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _exitCtrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeIn)));

    _entryCtrl.forward();

    Future.delayed(const Duration(milliseconds: 2000), _startExit);
  }

  Future<void> _startExit() async {
    if (!mounted) return;
    setState(() => _exiting = true);
    await _exitCtrl.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const AuthWrapper(),
      ),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_entryCtrl, _exitCtrl]),
        builder: (_, __) {
          Widget content = _SplashBg(
            child: Stack(children: [
              // ── Animated logo + text ──────────────────────────────
              Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: const ShareMealLogo(size: 100),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _logoFade,
                    child: const Text(
                      'ShareMeal',
                      style: TextStyle(
                        fontSize: 36, fontWeight: FontWeight.w700,
                        color: Colors.white, letterSpacing: -0.5,
                        shadows: [Shadow(color: Color(0x40000000), blurRadius: 16)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _tagFade,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 20, height: 1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(colors: [
                            Colors.transparent,
                            AppColors.amberLt.withAlpha(160)
                          ]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'REDUCING WASTE · FEEDING HOPE',
                        style: TextStyle(
                          fontSize: 9.5, fontWeight: FontWeight.w500,
                          color: AppColors.terrLt.withAlpha(220),
                          letterSpacing: 2.8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20, height: 1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(colors: [
                            AppColors.amberLt.withAlpha(160),
                            Colors.transparent
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),

              // ── Bottom tagline ────────────────────────────────────
              Positioned(
                bottom: 40, left: 0, right: 0,
                child: FadeTransition(
                  opacity: _tagFade,
                  child: const Text(
                    'Connecting surplus food with those who need it most',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11, color: Colors.white54,
                      fontWeight: FontWeight.w300, letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ]),
          );

          // ── Apply exit zoom on top ────────────────────────────────
          if (_exiting) {
            content = FadeTransition(
              opacity: _exitFade,
              child: ScaleTransition(
                scale: _exitScale,
                child: content,
              ),
            );
          }

          return content;
        },
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = Colors.white.withAlpha(12);
    for (double x = 0; x < s.width; x += 24) {
      for (double y = 0; y < s.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1.2, p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
