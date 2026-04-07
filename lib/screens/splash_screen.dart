import 'package:flutter/material.dart';
import 'package:sharemeal/constants/app_theme.dart';
import 'package:sharemeal/screens/auth_wrapper.dart';

// ── Reusable logo widget used across the app ──────────────────────────────────
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
        boxShadow: showShadow ? [
          BoxShadow(color: AppColors.amber.withAlpha(110), blurRadius: size * 0.5, offset: Offset(0, size * 0.15)),
          BoxShadow(color: AppColors.amberDk.withAlpha(60), blurRadius: size * 0.15, offset: Offset(0, size * 0.05)),
        ] : null,
      ),
      child: Stack(alignment: Alignment.center, children: [
        Icon(Icons.favorite, size: size * 0.54, color: Colors.white.withAlpha(242)),
        Icon(Icons.handshake, size: size * 0.28, color: const Color(0xFF92400E)),
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _tagFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Cubic(0.34, 1.56, 0.64, 1.0))));
    _tagFade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut));

    _ctrl.forward();

    // Navigate after 2.2 seconds
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, anim, __) => const AuthWrapper(),
          transitionsBuilder: (_, anim, __, child) {
            // Zoom-in: splash zooms toward you while login fades in
            final zoomOut = Tween<double>(begin: 1.0, end: 1.18).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeIn),
            );
            final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(parent: anim, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
            );
            final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
            );
            return Stack(children: [
              // Login page fades in underneath
              FadeTransition(opacity: fadeIn, child: child),
              // Splash zooms out and fades
              FadeTransition(
                opacity: fadeOut,
                child: ScaleTransition(
                  scale: zoomOut,
                  child: _buildSplashContent(),
                ),
              ),
            ]);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSplashContent(),
    );
  }

  Widget _buildSplashContent() {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.sageHero, AppColors.sage, Color(0xFF4EA882)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(children: [
          // Subtle dot pattern background
          Positioned.fill(child: CustomPaint(painter: _DotPainter())),

          // Ambient glow top-right
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

          // Center content
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo with scale + fade
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: const ShareMealLogo(size: 100),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Brand name
                  FadeTransition(
                    opacity: _fade,
                    child: const Text(
                      'ShareMeal',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [Shadow(color: Color(0x40000000), blurRadius: 16)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  FadeTransition(
                    opacity: _tagFade,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 20, height: 1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(colors: [Colors.transparent, AppColors.amberLt.withAlpha(160)]),
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
                          gradient: LinearGradient(colors: [AppColors.amberLt.withAlpha(160), Colors.transparent]),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          // Bottom version tag
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
