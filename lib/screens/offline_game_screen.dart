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
  Widget build(BuildContext context) =>
      _isOffline ? const FlappyBirdGame() : widget.child;
}

// ─── Game Constants ───────────────────────────────────────────────────────────
const double _birdX      = 0.25;   // fixed horizontal position (fraction of width)
const double _birdSize   = 38.0;
const double _pipeW      = 62.0;
const double _gapH       = 175.0;  // vertical gap between pipes
const double _gravity    = 0.55;
const double _jumpForce  = -10.5;
const double _pipeSpeed  = 3.2;

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
        final maxGapTop = _h - _gapH - 80;
        _pipes.add({
          'x':      _w + _pipeW,
          'gapTop': minGapTop + _rng.nextDouble() * (maxGapTop - minGapTop),
          'scored': 0,
        });
      }

      // Score: bird passed a pipe
      final birdPx = _birdX * _w;
      for (final p in _pipes) {
        if (p['scored'] == 0 && p['x']! + _pipeW < birdPx) {
          p['scored'] = 1;
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

    // Floor / ceiling
    if (birdPy + birdR > _h || birdPy - birdR < 0) {
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
    setState(() {
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
            _buildBird(),

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
        child: _Pipe(width: _pipeW, height: _h - gapTop - _gapH, isTop: false),
      ),
    ]);
  }

  Widget _buildBird() {
    final birdPx = _birdX * _w - _birdSize / 2;
    final birdPy = _h / 2 + _birdY - _birdSize / 2;

    return Positioned(
      left: birdPx,
      top:  birdPy,
      child: Transform.rotate(
        angle: _rotation * pi / 180,
        child: _BirdWidget(frame: _wingFrame, dead: _dead),
      ),
    );
  }

  Widget _buildHUD() {
    return Positioned(
      top: 52, left: 0, right: 0,
      child: Column(children: [
        // Score
        Text(
          '$_score',
          style: const TextStyle(
            fontSize: 52, fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(2, 2))],
          ),
        ),
        // Best
        if (_best > 0)
          Text(
            'Best: $_best',
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(180),
            ),
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.terr.withAlpha(200),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text('YOU\'RE OFFLINE', style: TextStyle(
                  color: Colors.white, fontSize: 11,
                  fontWeight: FontWeight.w700, letterSpacing: 1.5,
                )),
              ]),
            ),
            const SizedBox(height: 20),

            if (_dead) ...[
              // Game over
              const Text('GAME OVER', style: TextStyle(
                fontSize: 38, fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
              )),
              const SizedBox(height: 8),
              Text('Score: $_score', style: const TextStyle(
                fontSize: 22, color: Colors.white70, fontWeight: FontWeight.w600,
              )),
              if (_score == _best && _score > 0) ...[
                const SizedBox(height: 4),
                const Text('🏆 New Best!', style: TextStyle(
                  fontSize: 16, color: AppColors.amber, fontWeight: FontWeight.w700,
                )),
              ],
              const SizedBox(height: 28),
            ] else ...[
              // Title
              const Text('Flappy\nShareMeal', textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40, fontWeight: FontWeight.w900,
                  color: Colors.white, height: 1.1,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 12),
              Text('While you wait for connection...', style: TextStyle(
                fontSize: 14, color: Colors.white.withAlpha(180),
              )),
              const SizedBox(height: 32),
            ],

            // Tap to play button
            GestureDetector(
              onTap: _jump,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.sageMid, AppColors.sage, AppColors.sageDk],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(color: AppColors.sage.withAlpha(100), blurRadius: 20, offset: const Offset(0, 6)),
                  ],
                ),
                child: Text(
                  _dead ? '▶  PLAY AGAIN' : '▶  TAP TO PLAY',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w800, letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Tap anywhere or press the button to flap',
              style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(120)),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Bird Widget ──────────────────────────────────────────────────────────────
class _BirdWidget extends StatelessWidget {
  final int frame;
  final bool dead;
  const _BirdWidget({required this.frame, required this.dead});

  @override
  Widget build(BuildContext context) {
    // Wing offsets per frame: down, mid, up
    const wingOffsets = [-6.0, 0.0, 6.0];
    final wingY = dead ? 4.0 : wingOffsets[frame];

    return SizedBox(
      width: _birdSize, height: _birdSize,
      child: CustomPaint(painter: _BirdPainter(wingY: wingY, dead: dead)),
    );
  }
}

class _BirdPainter extends CustomPainter {
  final double wingY;
  final bool dead;
  const _BirdPainter({required this.wingY, required this.dead});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Body
    final bodyPaint = Paint()..color = dead ? const Color(0xFFE07856) : const Color(0xFFFBD000);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.42, bodyPaint);

    // Wing
    final wingPaint = Paint()..color = dead ? const Color(0xFFB85A3A) : const Color(0xFFF5A623);
    final wingPath = Path()
      ..moveTo(cx - 4, cy + wingY)
      ..quadraticBezierTo(cx - 18, cy + wingY + 8, cx - 14, cy + wingY + 16)
      ..quadraticBezierTo(cx - 4, cy + wingY + 10, cx + 2, cy + wingY + 4)
      ..close();
    canvas.drawPath(wingPath, wingPaint);

    // Eye white
    canvas.drawCircle(Offset(cx + 8, cy - 4), 7, Paint()..color = Colors.white);
    // Pupil
    canvas.drawCircle(
      Offset(cx + 10, cy - 3),
      3.5,
      Paint()..color = dead ? Colors.red.shade900 : Colors.black87,
    );
    // Eye shine
    canvas.drawCircle(Offset(cx + 11, cy - 5), 1.2, Paint()..color = Colors.white);

    // Beak
    final beakPaint = Paint()..color = const Color(0xFFFF8C00);
    final beakPath = Path()
      ..moveTo(cx + 14, cy + 1)
      ..lineTo(cx + 22, cy - 2)
      ..lineTo(cx + 22, cy + 5)
      ..close();
    canvas.drawPath(beakPath, beakPaint);

    // X eyes when dead
    if (dead) {
      final xPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx + 5, cy - 7), Offset(cx + 11, cy - 1), xPaint);
      canvas.drawLine(Offset(cx + 11, cy - 7), Offset(cx + 5, cy - 1), xPaint);
    }
  }

  @override
  bool shouldRepaint(_BirdPainter old) =>
      old.wingY != wingY || old.dead != dead;
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
