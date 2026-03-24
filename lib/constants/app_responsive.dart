import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppResponsive
//
// Usage — call AppResponsive.init(context) once at the top of any build():
//
//   @override
//   Widget build(BuildContext context) {
//     AppResponsive.init(context);
//     ...
//   }
//
// Then use anywhere in the same widget tree:
//   AppResponsive.sp(14)    → scaled font size
//   AppResponsive.w(16)     → scaled width / horizontal padding
//   AppResponsive.h(52)     → scaled height
//   AppResponsive.r(13)     → scaled border radius
//   AppResponsive.isSmall   → true on phones < 360px wide
//   AppResponsive.isMedium  → true on phones 360–480px
//   AppResponsive.isLarge   → true on tablets / wide screens > 480px
//
// Design reference: 390×844 (iPhone 14 / most Android flagships)
// ─────────────────────────────────────────────────────────────────────────────

class AppResponsive {
  AppResponsive._();

  // ── Design reference dimensions ──────────────────────────────────────────
  static const double _baseW = 390.0;
  static const double _baseH = 844.0;

  static late double _screenW;
  static late double _screenH;
  static late double _scaleW;   // horizontal scale factor
  static late double _scaleH;   // vertical scale factor
  static late double _scaleSp;  // font scale (blend of W+H)
  static late double _textScale; // system font scale
  static bool _initialized = false;

  /// Call once at the top of every build() that uses responsive values.
  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    _screenW    = mq.size.width;
    _screenH    = mq.size.height;
    _scaleW     = _screenW / _baseW;
    _scaleH     = _screenH / _baseH;
    _textScale  = mq.textScaler.scale(1.0).clamp(0.85, 1.30);
    // Font scale blends width + height, capped so text never gets huge
    _scaleSp    = ((_scaleW + _scaleH) / 2).clamp(0.75, 1.40);
    _initialized = true;
  }

  // ── Breakpoints ──────────────────────────────────────────────────────────
  /// Small phones: width < 360 (Galaxy A03, Moto E, iPhone SE)
  static bool get isSmall  => _screenW < 360;

  /// Medium phones: 360 ≤ width < 480 (most Androids, iPhone 14)
  static bool get isMedium => _screenW >= 360 && _screenW < 480;

  /// Large: tablets, foldables, web (width ≥ 480)
  static bool get isLarge  => _screenW >= 480;

  /// Web / desktop: width ≥ 800
  static bool get isWeb    => _screenW >= 800;

  // ── Scaling helpers ──────────────────────────────────────────────────────
  /// Scale a font size — respects system accessibility text scale too.
  /// Use for all TextStyle fontSize values.
  static double sp(double size) {
    _assertInit();
    return (size * _scaleSp / _textScale).roundToDouble();
  }

  /// Scale a horizontal dimension (padding, width, gap).
  static double w(double px) {
    _assertInit();
    return (px * _scaleW).roundToDouble();
  }

  /// Scale a vertical dimension (height, vertical padding).
  static double h(double px) {
    _assertInit();
    return (px * _scaleH).roundToDouble();
  }

  /// Scale a border radius or icon size (uses width scale).
  static double r(double px) {
    _assertInit();
    return (px * _scaleW).roundToDouble();
  }

  /// Raw screen width.
  static double get screenWidth  => _screenW;

  /// Raw screen height.
  static double get screenHeight => _screenH;

  // ── Responsive value picker ───────────────────────────────────────────────
  /// Returns [small] on small phones, [medium] on medium phones,
  /// [large] on tablets/web. Falls back to [medium] if not provided.
  static T pick<T>({
    required T small,
    required T medium,
    T? large,
  }) {
    _assertInit();
    if (isLarge)  return large  ?? medium;
    if (isSmall)  return small;
    return medium;
  }

  static void _assertInit() {
    assert(_initialized,
        'AppResponsive.init(context) must be called before using responsive values.');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ResponsiveLayout
//
// Declarative widget version of AppResponsive.pick().
// Renders different widget trees based on screen size.
//
// Example:
//   ResponsiveLayout(
//     small:  _compactCard(),
//     medium: _standardCard(),
//     large:  _wideCard(),
//   )
// ─────────────────────────────────────────────────────────────────────────────

class ResponsiveLayout extends StatelessWidget {
  final Widget small;
  final Widget medium;
  final Widget? large;

  const ResponsiveLayout({
    super.key,
    required this.small,
    required this.medium,
    this.large,
  });

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return AppResponsive.pick<Widget>(
      small:  small,
      medium: medium,
      large:  large,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppResponsivePadding
//
// Pre-built padding values that auto-scale.
// Reference values match AppDimensions at 390px width.
// ─────────────────────────────────────────────────────────────────────────────

class AppResponsivePadding {
  AppResponsivePadding._();

  /// Horizontal page padding — 16px at reference, scales with screen width.
  static EdgeInsets get page => EdgeInsets.symmetric(
        horizontal: AppResponsive.w(16));

  /// Card internal padding.
  static EdgeInsets get card => EdgeInsets.fromLTRB(
        AppResponsive.w(24),
        AppResponsive.h(30),
        AppResponsive.w(24),
        AppResponsive.h(26),
      );

  /// Field content padding.
  static EdgeInsets get field => EdgeInsets.symmetric(
        horizontal: AppResponsive.w(16),
        vertical:   AppResponsive.h(14),
      );

  /// Bottom sheet padding (above keyboard).
  static EdgeInsets bottomSheet(BuildContext context) => EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
                AppResponsive.h(24),
        left:   AppResponsive.w(24),
        right:  AppResponsive.w(24),
        top:    AppResponsive.h(8),
      );
}