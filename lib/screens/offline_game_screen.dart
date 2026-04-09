import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sharemeal/constants/app_theme.dart';

// ─── Offline Wrapper ──────────────────────────────────────────────────────────
// Wraps any child widget. When offline, shows the Flappy Bird game instead.
class OfflineWrapper extends StatefulWidget {
  final Widget child;
  const OfflineWrapper({super.key, required this.child});

  @override
  State<OfflineWrapper> createState() => _OfflineWrapperState();
}

class _OfflineWrapperState extends State<OfflineWrapper> {
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _sub;

  @override
  void initState() {
    super.initState();
    // Check initial state
    Connectivity().checkConnectivity().then(_handleResult);
    // Listen for changes
    _sub = Connectivity().onConnectivityChanged.listen(_handleResult);
  }

  void _handleResult(List<ConnectivityResult> results) {
    final offline = results.isEmpty || results.every((r) => r == ConnectivityResult.none);
    if (mounted && offline != _isOffline) setState(() => _isOffline = offline);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return widget.child;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FlappyBirdGame(),
    );
  }
}

// ─── Game Constants ───────────────────────────────────────────────────────────
const double _birdX      = 0.25;   // fixed horizontal position (fraction of width)
const double _birdSize   = 38.0;
const double _pipeW      = 62.0;
const double _gapH       = 175.0;  // vertical gap between pipes
const double _gravity    = 0.55;
const double _jumpForce  = -10.5;
const double _pipeSpeed  = 3.2;
const double _groundH    = 60.0;

// ─── Flappy Bird Game ─────────────────────────────────────────────────────────
class FlappyBirdGame extends StatefulWidget {
  const FlappyBirdGame({super.key});

  @override
  State<FlappyBirdGame> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame>
    with SingleTickerProviderStateMixin {
  // Bird state
  double _birdY     = 0.0;   // pixels from center
  double _velocity  = 0.0;
  double _rotation  = 0.0;

  // Game state
  bool   _started   = false;
  bool   _dead      = false;
  int    _score     = 0;
  int    _best      = 0;

  // Pipes: each pipe = {x, gapTop} in pixels
  final List<Map<String, double>> _pipes = [];
  final Random _rng = Random();

  late final AnimationController _ctrl;
  late double _w, _h;

  // Wing flap animation
  int _wingFrame = 0;
  int _wingTick  = 0;

  // Random food character — changes every round
  _FoodType _foodType = _FoodType.values[DateTime.now().millisecondsSinceEpoch % _FoodType.values.length];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_tick)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _tick() {
    if (!_started || _dead) return;
    setState(() {
      // Bird physics
      _velocity += _gravity;
      _birdY    += _velocity;
      _rotation  = (_velocity * 3).clamp(-30.0, 90.0);

      // Wing flap
      _wingTick++;
      if (_wingTick % 6 == 0) _wingFrame = (_wingFrame + 1) % 3;

      // Move pipes
      for (final p in _pipes) {
        p['x'] = p['x']! - _pipeSpeed;
      }

      // Remove off-screen pipes
      _pipes.removeWhere((p) => p['x']! < -_pipeW - 10);

      // Spawn new pipe
      if (_pipes.isEmpty || _pipes.last['x']! < _w - 260) {
        final minGapTop = 80.0;
        final maxGapTop = _h - _groundH - _gapH - 80;
        _pipes.add({
          'x':      _w + _pipeW,
          'gapTop': minGapTop + _rng.nextDouble() * (maxGapTop - minGapTop),
          'scored': 0.0,
        });
      }

      // Score: bird passed a pipe
      final birdPx = _birdX * _w;
      for (final p in _pipes) {
        if (p['scored'] == 0.0 && p['x']! + _pipeW < birdPx) {
          p['scored'] = 1.0;
          _score++;
          if (_score > _best) _best = _score;
          HapticFeedback.lightImpact();
        }
      }

      // Collision detection
      _checkCollision();
    });
  }

  void _checkCollision() {
    final birdPx  = _birdX * _w;
    final birdPy  = _h / 2 + _birdY;
    final birdR   = _birdSize / 2 - 4; // slight forgiveness

    // Floor (account for ground) / ceiling
    if (birdPy + birdR > _h - _groundH || birdPy - birdR < 0) {
      _die();
      return;
    }

    // Pipes
    for (final p in _pipes) {
      final px = p['x']!;
      final gt = p['gapTop']!;

      final inXRange = birdPx + birdR > px && birdPx - birdR < px + _pipeW;
      if (!inXRange) continue;

      final inTopPipe    = birdPy - birdR < gt;
      final inBottomPipe = birdPy + birdR > gt + _gapH;
      if (inTopPipe || inBottomPipe) {
        _die();
        return;
      }
    }
  }

  void _die() {
    _dead = true;
    HapticFeedback.heavyImpact();
  }

  void _jump() {
    if (_dead) {
      _reset();
      return;
    }
    if (!_started) _started = true;
    setState(() {
      _velocity = _jumpForce;
      _wingFrame = 0;
    });
    HapticFeedback.selectionClick();
  }

  void _reset() {
    // Pick a different food than the current one
    final types = _FoodType.values.where((t) => t != _foodType).toList();
    setState(() {
      _foodType = types[Random().nextInt(types.length)];
      _birdY    = 0;
      _velocity = 0;
      _rotation = 0;
      _started  = false;
      _dead     = false;
      _score    = 0;
      _pipes.clear();
      _wingFrame = 0;
    });
  }

  String get _foodName {
    switch (_foodType) {
      case _FoodType.burger:   return 'Burger';
      case _FoodType.pizza:    return 'Pizza';
      case _FoodType.donut:    return 'Donut';
      case _FoodType.icecream: return 'Ice Cream';
      case _FoodType.taco:     return 'Taco';
      case _FoodType.sushi:    return 'Sushi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _w = constraints.maxWidth;
      _h = constraints.maxHeight;

      return GestureDetector(
        onTapDown: (_) => _jump(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          body: Stack(children: [
            // Sky gradient background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0F3460), Color(0xFF16213E), Color(0xFF1A1A2E)],
                  ),
                ),
              ),
            ),

            // Scrolling stars (static for simplicity)
            ..._buildStars(),

            // Ground
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2D5A27), Color(0xFF1A3A15)],
                  ),
                ),
                child: CustomPaint(painter: _GrassPainter()),
              ),
            ),

            // Pipes
            ..._pipes.map((p) => _buildPipe(p)),

            // Bird
            _buildBird(_foodType),

            // HUD
            _buildHUD(),

            // Overlay: start or game over
            if (!_started || _dead) _buildOverlay(),
          ]),
        ),
      );
    });
  }

  List<Widget> _buildStars() {
    // Deterministic star positions using fixed seeds
    final stars = <Widget>[];
    final r = Random(42);
    for (int i = 0; i < 60; i++) {
      final x = r.nextDouble() * (_w > 0 ? _w : 400);
      final y = r.nextDouble() * (_h > 0 ? _h * 0.7 : 300);
      final size = r.nextDouble() * 2 + 0.5;
      stars.add(Positioned(
        left: x, top: y,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha((r.nextDouble() * 180 + 60).round()),
          ),
        ),
      ));
    }
    return stars;
  }

  Widget _buildPipe(Map<String, double> p) {
    final x      = p['x']!;
    final gapTop = p['gapTop']!;

    return Stack(children: [
      // Top pipe
      Positioned(
        left: x, top: 0,
        child: _Pipe(width: _pipeW, height: gapTop, isTop: true),
      ),
      // Bottom pipe
      Positioned(
        left: x, top: gapTop + _gapH,
        child: _Pipe(width: _pipeW, height: _h - _groundH - gapTop - _gapH, isTop: false),
      ),
    ]);
  }

  Widget _buildBird(_FoodType foodType) {
    final birdPx = _birdX * _w - _birdSize / 2;
    final birdPy = _h / 2 + _birdY - _birdSize / 2;
    return Positioned(
      left: birdPx, top: birdPy,
      child: Transform.rotate(
        angle: _rotation * pi / 180,
        child: _FoodBird(foodType: foodType, frame: _wingFrame, dead: _dead),
      ),
    );
  }

  Widget _buildHUD() {
    return Positioned(
      top: 52, left: 0, right: 0,
      child: Column(children: [
        // Score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Text(
            '$_score',
            style: const TextStyle(
              fontSize: 48, fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(2, 2)),
              ],
            ),
          ),
        ),
        // Best
        if (_best > 0) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Best: $_best',
              style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(_dead ? 140 : 80),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Offline badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFE53935).withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFE53935).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('YOU\'RE OFFLINE', style: TextStyle(
                  color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.w800, letterSpacing: 1.8,
                )),
              ]),
            ),
            const SizedBox(height: 24),

            if (_dead) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE53935), width: 2),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935), size: 32),
                    SizedBox(width: 10),
                    Text('FOOD WASTED', style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w900,
                      color: Color(0xFFE53935),
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(2, 2)),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFF2ECC40).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2ECC40), width: 1.5),
                    ),
                    child: Text('$_foodName Saved: $_score', style: const TextStyle(
                      fontSize: 20, color: Color(0xFF2ECC40), fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    )),
                  ),
                  if (_score == _best && _score > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('🏆 NEW BEST!', style: TextStyle(
                        fontSize: 16, color: Colors.white, fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      )),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Don\'t let food go to waste!',
                    style: TextStyle(
                      fontSize: 13, 
                      color: Colors.white70, 
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 28),
            ] else ...[
              // Food drawing big on start screen
              SizedBox(
                width: 90, height: 90,
                child: CustomPaint(
                  painter: _FoodPainter(foodType: _foodType, dead: false),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2ECC40), Color(0xFF27AE60)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2ECC40).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Save the $_foodName!',
                  style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Help rescue food while offline',
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.white.withOpacity(0.85), 
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 28),
            ],

            // Tap to play button
            GestureDetector(
              onTap: _jump,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2ECC40), Color(0xFF27AE60), Color(0xFF1E8449)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2ECC40).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      _dead ? 'PLAY AGAIN' : 'TAP TO PLAY',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.w900, letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '💡',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap anywhere to flap',
                    style: TextStyle(
                      fontSize: 13, 
                      color: Colors.white.withOpacity(0.9), 
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Food Type Enum ───────────────────────────────────────────────────────────
enum _FoodType { burger, pizza, donut, icecream, taco, sushi }

// ─── Food Bird Widget ─────────────────────────────────────────────────────────
class _FoodBird extends StatelessWidget {
  final _FoodType foodType;
  final int frame;
  final bool dead;
  const _FoodBird({required this.foodType, required this.frame, required this.dead});

  @override
  Widget build(BuildContext context) {
    const scales = [0.88, 1.0, 1.1];
    final scale  = dead ? 0.85 : scales[frame];

    return SizedBox(
      width: _birdSize + 10,
      height: _birdSize + 10,
      child: Stack(alignment: Alignment.center, children: [
        // Glow
        Container(
          width: _birdSize + 6, height: _birdSize + 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
              color: dead ? Colors.red.withAlpha(120) : Colors.white.withAlpha(50),
              blurRadius: 14, spreadRadius: 2,
            )],
          ),
        ),
        // Food drawing
        Transform.scale(
          scale: scale,
          child: SizedBox(
            width: _birdSize, height: _birdSize,
            child: CustomPaint(
              painter: _FoodPainter(foodType: foodType, dead: dead),
            ),
          ),
        ),
        // Speed lines
        if (!dead)
          Positioned(
            left: 0,
            child: CustomPaint(
              size: Size(14, _birdSize),
              painter: _SpeedLinePainter(frame: frame),
            ),
          ),
      ]),
    );
  }
}

// ─── Food Painter ─────────────────────────────────────────────────────────────
class _FoodPainter extends CustomPainter {
  final _FoodType foodType;
  final bool dead;
  const _FoodPainter({required this.foodType, required this.dead});

  @override
  void paint(Canvas canvas, Size s) {
    if (dead) { _drawExplosion(canvas, s); return; }
    switch (foodType) {
      case _FoodType.burger:   _drawBurger(canvas, s);  break;
      case _FoodType.pizza:    _drawPizza(canvas, s);   break;
      case _FoodType.donut:    _drawDonut(canvas, s);   break;
      case _FoodType.icecream: _drawIceCream(canvas, s);break;
      case _FoodType.taco:     _drawTaco(canvas, s);    break;
      case _FoodType.sushi:    _drawSushi(canvas, s);   break;
    }
  }

  void _drawBurger(Canvas c, Size s) {
    final cx = s.width / 2; final cy = s.height / 2;
    // bottom bun
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy + 10), width: s.width * 0.9, height: s.height * 0.28),
        Paint()..color = const Color(0xFFC8860A));
    // patty
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy + 3), width: s.width * 0.85, height: s.height * 0.22),
        Paint()..color = const Color(0xFF7B3F00));
    // cheese
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy - 2), width: s.width * 0.88, height: s.height * 0.18),
        Paint()..color = const Color(0xFFFFC107));
    // lettuce
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy - 7), width: s.width * 0.9, height: s.height * 0.16),
        Paint()..color = const Color(0xFF4CAF50));
    // top bun
    final bunPath = Path()
      ..addArc(Rect.fromCenter(center: Offset(cx, cy - 10), width: s.width * 0.9, height: s.height * 0.7), pi, pi);
    c.drawPath(bunPath, Paint()..color = const Color(0xFFE8A020));
    // sesame seeds
    final seed = Paint()..color = Colors.white.withAlpha(200);
    c.drawCircle(Offset(cx - 6, cy - 16), 2, seed);
    c.drawCircle(Offset(cx + 4, cy - 18), 2, seed);
    c.drawCircle(Offset(cx + 10, cy - 14), 1.5, seed);
  }

  void _drawPizza(Canvas c, Size s) {
    final cx = s.width / 2; final cy = s.height / 2;
    final r = s.width * 0.46;
    // crust
    c.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFFD4A017));
    // sauce
    c.drawCircle(Offset(cx, cy), r * 0.82, Paint()..color = const Color(0xFFCC3300));
    // cheese
    c.drawCircle(Offset(cx, cy), r * 0.70, Paint()..color = const Color(0xFFFFF176));
    // pepperoni
    final pep = Paint()..color = const Color(0xFFB71C1C);
    c.drawCircle(Offset(cx - 6, cy - 5), 5, pep);
    c.drawCircle(Offset(cx + 7, cy + 4), 4, pep);
    c.drawCircle(Offset(cx, cy + 8), 4, pep);
    // slice lines
    final line = Paint()..color = const Color(0xFFD4A017)..strokeWidth = 1.5;
    c.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), line);
    c.drawLine(Offset(cx - r * 0.87, cy - r * 0.5), Offset(cx + r * 0.87, cy + r * 0.5), line);
    c.drawLine(Offset(cx + r * 0.87, cy - r * 0.5), Offset(cx - r * 0.87, cy + r * 0.5), line);
  }

  void _drawDonut(Canvas c, Size s) {
    final cx = s.width / 2; final cy = s.height / 2;
    final r = s.width * 0.44;
    // donut body
    c.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFFD4A017));
    // icing
    final icingPath = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.95));
    c.drawPath(icingPath, Paint()..color = const Color(0xFFFF69B4)..style = PaintingStyle.stroke..strokeWidth = r * 0.45);
    // hole
    c.drawCircle(Offset(cx, cy), r * 0.32, Paint()..color = const Color(0xFF1A1A2E));
    // sprinkles
    final colors = [Colors.red, Colors.blue, Colors.yellow, Colors.green, Colors.purple];
    final rng = Random(7);
    for (int i = 0; i < 8; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final dist  = r * (0.5 + rng.nextDouble() * 0.35);
      final sx = cx + cos(angle) * dist;
      final sy = cy + sin(angle) * dist;
      c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(sx, sy), width: 6, height: 2.5), const Radius.circular(2)),
        Paint()..color = colors[i % colors.length],
      );
    }
  }

  void _drawIceCream(Canvas c, Size s) {
    final cx = s.width / 2;
    // cone
    final conePath = Path()
      ..moveTo(cx - s.width * 0.28, s.height * 0.52)
      ..lineTo(cx + s.width * 0.28, s.height * 0.52)
      ..lineTo(cx, s.height * 0.96)
      ..close();
    c.drawPath(conePath, Paint()..color = const Color(0xFFD4A017));
    // cone lines
    final cl = Paint()..color = const Color(0xFFB8860B)..strokeWidth = 1;
    c.drawLine(Offset(cx, s.height * 0.96), Offset(cx - s.width * 0.1, s.height * 0.52), cl);
    c.drawLine(Offset(cx, s.height * 0.96), Offset(cx + s.width * 0.1, s.height * 0.52), cl);
    // scoop 1 (bottom)
    c.drawCircle(Offset(cx, s.height * 0.42), s.width * 0.28,
        Paint()..color = const Color(0xFFFFB6C1));
    // scoop 2 (top)
    c.drawCircle(Offset(cx, s.height * 0.22), s.width * 0.24,
        Paint()..color = const Color(0xFFA5D6A7));
    // cherry
    c.drawCircle(Offset(cx, s.height * 0.06), s.width * 0.1,
        Paint()..color = const Color(0xFFE53935));
    // cherry stem
    c.drawLine(Offset(cx, s.height * 0.06), Offset(cx + 4, s.height * 0.0),
        Paint()..color = const Color(0xFF4CAF50)..strokeWidth = 1.5);
  }

  void _drawTaco(Canvas c, Size s) {
    final cx = s.width / 2; final cy = s.height / 2;
    // shell
    final shell = Path()
      ..moveTo(cx - s.width * 0.46, cy + s.height * 0.2)
      ..quadraticBezierTo(cx, cy - s.height * 0.5, cx + s.width * 0.46, cy + s.height * 0.2)
      ..quadraticBezierTo(cx, cy + s.height * 0.35, cx - s.width * 0.46, cy + s.height * 0.2)
      ..close();
    c.drawPath(shell, Paint()..color = const Color(0xFFD4A017));
    // lettuce
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy + 4), width: s.width * 0.7, height: s.height * 0.22),
        Paint()..color = const Color(0xFF66BB6A));
    // meat
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2), width: s.width * 0.55, height: s.height * 0.16),
        Paint()..color = const Color(0xFF7B3F00));
    // cheese shreds
    final ch = Paint()..color = const Color(0xFFFFC107)..strokeWidth = 2;
    for (int i = -2; i <= 2; i++) {
      c.drawLine(Offset(cx + i * 6.0, cy - 4), Offset(cx + i * 6.0 + 3, cy + 4), ch);
    }
    // tomato
    c.drawCircle(Offset(cx - 8, cy - 2), 4, Paint()..color = const Color(0xFFEF5350));
    c.drawCircle(Offset(cx + 8, cy - 2), 4, Paint()..color = const Color(0xFFEF5350));
  }

  void _drawSushi(Canvas c, Size s) {
    final cx = s.width / 2; final cy = s.height / 2;
    // rice base
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy + 4), width: s.width * 0.82, height: s.height * 0.52),
        Paint()..color = Colors.white);
    // nori band
    c.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: s.width * 0.82, height: s.height * 0.18),
      Paint()..color = const Color(0xFF1B2A1B),
    );
    // salmon topping
    final salmonPath = Path()
      ..addOval(Rect.fromCenter(center: Offset(cx, cy - 4), width: s.width * 0.7, height: s.height * 0.36));
    c.drawPath(salmonPath, Paint()..color = const Color(0xFFFF8A65));
    // salmon detail lines
    final sl = Paint()..color = const Color(0xFFFF7043)..strokeWidth = 1.2;
    c.drawLine(Offset(cx - 10, cy - 8), Offset(cx + 10, cy), sl);
    c.drawLine(Offset(cx - 8, cy - 2), Offset(cx + 8, cy + 4), sl);
    // wasabi dot
    c.drawCircle(Offset(cx + 12, cy - 8), 4, Paint()..color = const Color(0xFF66BB6A));
  }

  void _drawExplosion(Canvas c, Size s) {
    final cx = s.width / 2; final cy = s.height / 2;
    final rng = Random(3);
    // burst rays
    final ray = Paint()..color = const Color(0xFFFFD600)..strokeWidth = 3..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      c.drawLine(
        Offset(cx + cos(angle) * 6, cy + sin(angle) * 6),
        Offset(cx + cos(angle) * (14 + rng.nextDouble() * 6), cy + sin(angle) * (14 + rng.nextDouble() * 6)),
        ray,
      );
    }
    // center circle
    c.drawCircle(Offset(cx, cy), 10, Paint()..color = const Color(0xFFFF6D00));
    c.drawCircle(Offset(cx, cy), 6,  Paint()..color = const Color(0xFFFFD600));
    c.drawCircle(Offset(cx, cy), 3,  Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_FoodPainter old) => old.dead != dead || old.foodType != foodType;
}

// ─── Speed Line Painter ───────────────────────────────────────────────────────
class _SpeedLinePainter extends CustomPainter {
  final int frame;
  const _SpeedLinePainter({required this.frame});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(frame == 0 ? 80 : 40)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final offsets = [size.height * 0.3, size.height * 0.5, size.height * 0.7];
    final lengths = [10.0, 14.0, 8.0];
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(Offset(lengths[i], offsets[i]), Offset(0, offsets[i]), paint);
    }
  }

  @override
  bool shouldRepaint(_SpeedLinePainter old) => old.frame != frame;
}

// ─── Pipe Widget ──────────────────────────────────────────────────────────────
class _Pipe extends StatelessWidget {
  final double width, height;
  final bool isTop;
  const _Pipe({required this.width, required this.height, required this.isTop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, height: height,
      child: CustomPaint(painter: _PipePainter(isTop: isTop)),
    );
  }
}

class _PipePainter extends CustomPainter {
  final bool isTop;
  const _PipePainter({required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    const capH = 22.0;
    const capExtra = 6.0; // cap is wider than pipe body

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF2ECC40), const Color(0xFF27AE60), const Color(0xFF1E8449)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final capPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF58D68D), const Color(0xFF27AE60), const Color(0xFF1A7A3C)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width + capExtra * 2, capH));

    final borderPaint = Paint()
      ..color = const Color(0xFF1A5C2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (isTop) {
      // Body (top pipe body goes from top to near bottom)
      final bodyRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height - capH),
        const Radius.circular(2),
      );
      canvas.drawRRect(bodyRect, bodyPaint);
      canvas.drawRRect(bodyRect, borderPaint);

      // Cap at bottom of top pipe
      final capRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-capExtra, size.height - capH, size.width + capExtra * 2, capH),
        const Radius.circular(4),
      );
      canvas.drawRRect(capRect, capPaint);
      canvas.drawRRect(capRect, borderPaint);
    } else {
      // Cap at top of bottom pipe
      final capRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-capExtra, 0, size.width + capExtra * 2, capH),
        const Radius.circular(4),
      );
      canvas.drawRRect(capRect, capPaint);
      canvas.drawRRect(capRect, borderPaint);

      // Body
      final bodyRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, capH, size.width, size.height - capH),
        const Radius.circular(2),
      );
      canvas.drawRRect(bodyRect, bodyPaint);
      canvas.drawRRect(bodyRect, borderPaint);
    }

    // Highlight stripe
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..strokeWidth = 4;
    if (isTop) {
      canvas.drawLine(
        Offset(size.width * 0.25, 0),
        Offset(size.width * 0.25, size.height - capH),
        highlightPaint,
      );
    } else {
      canvas.drawLine(
        Offset(size.width * 0.25, capH),
        Offset(size.width * 0.25, size.height),
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Grass Painter ────────────────────────────────────────────────────────────
class _GrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF4CAF50);
    for (double x = 0; x < size.width; x += 12) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + 6, -10)
        ..lineTo(x + 12, 0)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
