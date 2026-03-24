import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppColors — static raw palette. Never reference these directly in widgets;
// use AppThemeColors.of(context) instead so dark mode is respected.
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const sage     = Color(0xFF3D8B6F);
  static const sageMid  = Color(0xFF52B08A);
  static const sageDk   = Color(0xFF2A6B52);
  static const sageHero = Color(0xFF2D5C45);
  static const sageLt   = Color(0xFF86B898);
  static const sageBg   = Color(0xFFF2F7F4);

  static const amber   = Color(0xFFF59E0B);
  static const amberLt = Color(0xFFFDE68A);
  static const amberDk = Color(0xFFB45309);

  static const terr   = Color(0xFFD4603A);
  static const terrLt = Color(0xFFF08060);

  static const ink  = Color(0xFF1C2B22);
  static const ink2 = Color(0xFF3D5248);
  static const ink3 = Color(0xFF7A9186);

  static const white       = Color(0xFFFFFFFF);
  static const offWhite    = Color(0xFFF9FAF8);
  static const fieldBg     = Color(0xFFF9FAF8);
  static const fieldBorder = Color(0x17314B3F);
  static const cardSurface = Color(0xFFFFFFFF);

  // Dark-mode surfaces
  static const darkBg       = Color(0xFF0F1419);
  static const darkSurface  = Color(0xFF1A1F26);
  static const darkSurface2 = Color(0xFF252B33);
}

// ─────────────────────────────────────────────────────────────────────────────
// AppThemeColors — theme-aware colour helper.
//
// Usage in any widget:
//   final tc = AppThemeColors.of(context);
//   Container(color: tc.cardBg)
//   Text('…', style: TextStyle(color: tc.textPrimary))
// ─────────────────────────────────────────────────────────────────────────────
class AppThemeColors {
  final bool isDark;
  const AppThemeColors._(this.isDark);

  factory AppThemeColors.of(BuildContext context) =>
      AppThemeColors._(Theme.of(context).brightness == Brightness.dark);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  Color get scaffoldBg    => isDark ? AppColors.darkBg       : AppColors.offWhite;
  Color get cardBg        => isDark ? AppColors.darkSurface  : AppColors.white;
  Color get sheetBg       => isDark ? AppColors.darkBg       : AppColors.white;
  Color get dialogBg      => isDark ? AppColors.darkSurface  : AppColors.white;
  Color get fieldFill     => isDark ? AppColors.darkSurface2 : AppColors.fieldBg;
  Color get searchDropBg  => isDark ? AppColors.darkSurface  : AppColors.white;
  Color get mapCardBg     => isDark ? AppColors.darkSurface  : AppColors.white;

  /// Sage-tinted bg for location chips / address cards
  Color get sageTintBg =>
      isDark ? const Color(0xFF1A2E25) : AppColors.sageBg;

  // ── Borders ───────────────────────────────────────────────────────────────
  Color get fieldBorderColor =>
      isDark ? const Color(0xFF3A4E42) : AppColors.fieldBorder;
  Color get dividerColor =>
      isDark ? const Color(0xFF2A3530) : AppColors.fieldBorder;
  Color get dragHandleColor =>
      isDark ? const Color(0xFF3A4E42) : const Color(0xFFCDD9D4);

  // ── Text ──────────────────────────────────────────────────────────────────
  Color get textPrimary   => isDark ? const Color(0xFFE8EFF0) : AppColors.ink;
  Color get textSecondary => isDark ? const Color(0xFFD0D8DC) : AppColors.ink2;
  Color get textMuted     => isDark ? const Color(0xFF8A9A96) : AppColors.ink3;
  Color get textHint      =>
      isDark ? const Color(0xFF6A7A76) : AppColors.ink.withAlpha(71);

  // ── Misc ──────────────────────────────────────────────────────────────────
  Color get shadowColor => isDark ? Colors.black : AppColors.ink;

  // Compatibility helpers (legacy naming)
  static Color surface(BuildContext context) => AppThemeColors.of(context).cardBg;
  static Color surfaceHigh(BuildContext context) => AppThemeColors.of(context).scaffoldBg;
  static Color onSurface(BuildContext context) => AppThemeColors.of(context).textPrimary;
  static Color onSurface2(BuildContext context) => AppThemeColors.of(context).textSecondary;
  static Color onSurfaceMuted(BuildContext context) => AppThemeColors.of(context).textMuted;
  static Color divider(BuildContext context) => AppThemeColors.of(context).dividerColor;
  static Color fieldBg(BuildContext context) => AppThemeColors.of(context).fieldFill;
  static Color fieldBorder(BuildContext context) => AppThemeColors.of(context).fieldBorderColor;
}

class ThemeHelper {
  ThemeHelper._();

  static Color onSurface(BuildContext context) => AppThemeColors.onSurface(context);
  static Color onSurfaceMuted(BuildContext context) => AppThemeColors.onSurfaceMuted(context);
  static Color fieldFill(BuildContext context) => AppThemeColors.of(context).fieldFill;
  static Color sageBg(BuildContext context) => AppThemeColors.of(context).sageTintBg;
  static Color cardColor(BuildContext context) => AppThemeColors.of(context).cardBg;
  static Color sheetColor(BuildContext context) => AppThemeColors.of(context).sheetBg;
  static Color dividerColor(BuildContext context) => AppThemeColors.of(context).dividerColor;

  static BoxDecoration cardDecoration(BuildContext context, {Color? accentLeft}) => BoxDecoration(
        color: cardColor(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: accentLeft ?? AppColors.sage.withAlpha(90), width: 1),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppThemeDecorations — context-aware BoxDecorations.
//
// Usage:
//   final td = AppThemeDecorations.of(context);
//   Container(decoration: td.field())
// ─────────────────────────────────────────────────────────────────────────────
class AppThemeDecorations {
  final AppThemeColors tc;
  const AppThemeDecorations._(this.tc);

  factory AppThemeDecorations.of(BuildContext context) =>
      AppThemeDecorations._(AppThemeColors.of(context));

  BoxDecoration field() => BoxDecoration(
        color: tc.fieldFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: tc.fieldBorderColor, width: 1.5),
      );

  BoxDecoration fieldFocused() => BoxDecoration(
        color: tc.fieldFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.sage.withAlpha(115), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.sage.withAlpha(23), spreadRadius: 3, blurRadius: 0)
        ],
      );

  BoxDecoration fieldError() => BoxDecoration(
        color: tc.fieldFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.terr, width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.terr.withAlpha(38), spreadRadius: 3, blurRadius: 0)
        ],
      );

  BoxDecoration card() => BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(color: tc.shadowColor.withAlpha(38), blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: tc.shadowColor.withAlpha(20), blurRadius: 6,  offset: const Offset(0, 1)),
        ],
      );

  BoxDecoration sageTintChip() => BoxDecoration(
        color: tc.sageTintBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.sage.withAlpha(51)),
      );

  BoxDecoration socialBtn() => BoxDecoration(
        color: tc.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tc.fieldBorderColor, width: 1.5),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextStyles — base styles. Colors baked in only for hero/CTA text.
// For body/card text always call .copyWith(color: tc.textPrimary).
// ─────────────────────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const heroTitle = TextStyle(
    fontFamily: 'Georgia', fontSize: 34, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: -0.2,
  );
  static const brandName = TextStyle(
    fontFamily: 'Georgia', fontSize: 32, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: -0.2,
    shadows: [Shadow(color: Color(0x33000000), blurRadius: 12)],
  );
  static const cardHead = TextStyle(
    fontFamily: 'Georgia', fontSize: 26, fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic, color: AppColors.ink, height: 1.15,
  );
  static const sectionHead = TextStyle(
    fontFamily: 'Georgia', fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const body = TextStyle(
    fontSize: 13.5, fontWeight: FontWeight.w400,
    color: AppColors.ink, height: 1.6,
  );
  static const bodyMuted = TextStyle(
    fontSize: 12.5, fontWeight: FontWeight.w300,
    color: AppColors.ink3, height: 1.7,
  );
  static const bodySmall = TextStyle(
    fontSize: 11.5, fontWeight: FontWeight.w300, color: AppColors.ink3,
  );
  static const fieldLabel = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w600,
    color: AppColors.ink3, letterSpacing: 0.7,
  );
  static const pillLabel = TextStyle(
    fontSize: 9.5, fontWeight: FontWeight.w600,
    color: AppColors.terr, letterSpacing: 1.0,
  );
  static const tagline = TextStyle(
    fontSize: 9.5, fontWeight: FontWeight.w500,
    color: AppColors.terrLt, letterSpacing: 2.6,
  );
  static const liveLabel = TextStyle(
    fontSize: 9, fontWeight: FontWeight.w700,
    color: AppColors.amberLt, letterSpacing: 1.0,
  );
  static const statNumber = TextStyle(
    fontFamily: 'Georgia', fontSize: 17, fontWeight: FontWeight.w700,
    color: AppColors.sage,
  );
  static const statLabel = TextStyle(
    fontSize: 9, fontWeight: FontWeight.w500,
    color: AppColors.ink3, height: 1.4, letterSpacing: 0.2,
  );
  static const ctaButton = TextStyle(
    color: Colors.white, fontSize: 13,
    fontWeight: FontWeight.w700, letterSpacing: 1.5,
  );
  static const link = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.amberDk,
  );
  static const forgotLink = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.terr,
  );

  static TextStyle bodyThemed(BuildContext context) => body.copyWith(color: AppThemeColors.of(context).textPrimary);
  static TextStyle bodySmallThemed(BuildContext context) => bodySmall.copyWith(color: AppThemeColors.of(context).textSecondary);
  static TextStyle sectionHeadThemed(BuildContext context) => sectionHead.copyWith(color: AppThemeColors.of(context).textPrimary);
  static TextStyle bodyMutedThemed(BuildContext context) => bodyMuted.copyWith(color: AppThemeColors.of(context).textMuted);
  static TextStyle cardHeadThemed(BuildContext context) => cardHead.copyWith(color: AppThemeColors.of(context).textPrimary);
}

// ─────────────────────────────────────────────────────────────────────────────
// AppDimensions
// ─────────────────────────────────────────────────────────────────────────────
class AppDimensions {
  AppDimensions._();

  static const radiusSm   = 10.0;
  static const radiusMd   = 13.0;
  static const radiusLg   = 20.0;
  static const radiusXl   = 24.0;
  static const radiusHero = 40.0;

  static const pagePadding     = EdgeInsets.symmetric(horizontal: 16);
  static const cardPadding     = EdgeInsets.fromLTRB(24, 30, 24, 26);
  static const heroPadding     = EdgeInsets.fromLTRB(24, 20, 24, 28);
  static const fieldContentPad = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  static const iconSm = 17.0;
  static const iconMd = 20.0;
  static const iconLg = 24.0;

  static const imageHeight   = 170.0;
  static const imageHeightSm = 120.0;

  static const btnHeight   = 52.0;
  static const fieldHeight = 50.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// AppDecorations — context-free (light-only) decorations kept for login screen
// and other permanently-light widgets. Prefer AppThemeDecorations elsewhere.
// ─────────────────────────────────────────────────────────────────────────────
class AppDecorations {
  AppDecorations._();

  static BoxDecoration card = BoxDecoration(
    color: AppColors.cardSurface,
    borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
    boxShadow: [
      BoxShadow(color: AppColors.ink.withAlpha(10), blurRadius: 4,  offset: const Offset(0, 2)),
      BoxShadow(color: AppColors.ink.withAlpha(26), blurRadius: 48, offset: const Offset(0, 16)),
    ],
  );

  static BoxDecoration statsCard = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
    boxShadow: [
      BoxShadow(color: AppColors.ink.withAlpha(31), blurRadius: 32, offset: const Offset(0, 8)),
      BoxShadow(color: AppColors.ink.withAlpha(15), blurRadius: 8,  offset: const Offset(0, 2)),
    ],
  );

  static BoxDecoration field = BoxDecoration(
    color: AppColors.fieldBg,
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    border: Border.all(color: AppColors.fieldBorder, width: 1.5),
  );

  static BoxDecoration fieldFocused = BoxDecoration(
    color: AppColors.fieldBg,
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    border: Border.all(color: AppColors.sage.withAlpha(115), width: 1.5),
    boxShadow: [BoxShadow(color: AppColors.sage.withAlpha(23), spreadRadius: 3, blurRadius: 0)],
  );

  static BoxDecoration fieldError = BoxDecoration(
    color: AppColors.fieldBg,
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    border: Border.all(color: AppColors.terr, width: 1.5),
    boxShadow: [BoxShadow(color: AppColors.terr.withAlpha(38), spreadRadius: 3, blurRadius: 0)],
  );

  static BoxDecoration bottomSheet(BuildContext context) => BoxDecoration(
        color: AppThemeColors.of(context).sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      );

  static BoxDecoration draggableSheet(BuildContext context) => BoxDecoration(
        color: AppThemeColors.of(context).sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      );

  static BoxDecoration cardAccentThemed(BuildContext context, Color accentColor) => BoxDecoration(
        color: AppThemeColors.of(context).cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: accentColor.withAlpha(90)),
      );

  static BoxDecoration sageBgThemed(BuildContext context) => BoxDecoration(
        color: AppThemeColors.of(context).sageTintBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      );

  static BoxDecoration fieldThemed(BuildContext context) => AppThemeDecorations.of(context).field();

  static BoxDecoration sagePill = BoxDecoration(
    color: AppColors.sage.withAlpha(23),
    border: Border.all(color: AppColors.sage.withAlpha(56)),
    borderRadius: BorderRadius.circular(30),
  );

  static BoxDecoration terrPill = BoxDecoration(
    color: AppColors.terr.withAlpha(23),
    border: Border.all(color: AppColors.terr.withAlpha(51)),
    borderRadius: BorderRadius.circular(30),
  );

  static BoxDecoration liveBadge = BoxDecoration(
    color: AppColors.amberLt.withAlpha(51),
    border: Border.all(color: AppColors.amberLt.withAlpha(89)),
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration toggleBg = BoxDecoration(
    color: AppColors.sageBg,
    border: Border.all(color: AppColors.sage.withAlpha(38)),
    borderRadius: BorderRadius.circular(14),
  );

  static BoxDecoration toggleActive = BoxDecoration(
    gradient: const LinearGradient(
        colors: [AppColors.sageMid, AppColors.sage, AppColors.sageDk]),
    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
    boxShadow: [
      BoxShadow(color: AppColors.sage.withAlpha(77), blurRadius: 14, offset: const Offset(0, 4))
    ],
  );

  static BoxDecoration socialBtn = BoxDecoration(
    color: AppColors.fieldBg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.fieldBorder, width: 1.5),
  );

  static const BoxDecoration heroBar = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.sageHero, AppColors.sage, Color(0xFF4EA882)],
    ),
  );

  static const BoxDecoration logoBadge = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.amberLt, AppColors.amber, AppColors.amberDk],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppGradients
// ─────────────────────────────────────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  static const sageButton = LinearGradient(
    colors: [AppColors.sageMid, AppColors.sage, AppColors.sageDk],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const amberBadge = LinearGradient(
    colors: [AppColors.amberLt, AppColors.amber, AppColors.amberDk],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroBar = LinearGradient(
    colors: [AppColors.sageHero, AppColors.sage, Color(0xFF4EA882)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const pageSplit = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, .52, .52, 1],
    colors: [
      Color(0xFFFEFCF7), Color(0xFFFEFCF7),
      Color(0xFFEEF7F2), Color(0xFFEAF5EE),
    ],
  );

  static const cardAccentBorder = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.amber, AppColors.sage, AppColors.terr],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — MaterialApp themes
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.offWhite,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.sage,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEAF5EE),
      onPrimaryContainer: AppColors.sageDk,
      secondary: AppColors.amber,
      onSecondary: AppColors.ink,
      secondaryContainer: Color(0xFFFEF3C7),
      onSecondaryContainer: AppColors.amberDk,
      tertiary: AppColors.terr,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFDE8DF),
      onTertiaryContainer: Color(0xFF7A2810),
      surface: AppColors.offWhite,
      onSurface: AppColors.ink,
      surfaceContainerHighest: Color(0xFFEEF7F2),
      error: AppColors.terr,
      onError: Colors.white,
      outline: AppColors.ink3,
      outlineVariant: Color(0xFFCDD9D4),
      shadow: AppColors.ink,
      scrim: AppColors.ink,
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.offWhite,
      inversePrimary: AppColors.sageLt,
    ),
    fontFamily: 'Georgia',
    textTheme: const TextTheme(
      displayLarge:   TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 36, letterSpacing: -0.5, color: AppColors.ink),
      displayMedium:  TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 30, letterSpacing: -0.3, color: AppColors.ink),
      displaySmall:   TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600, fontSize: 24, color: AppColors.ink),
      headlineLarge:  TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 22, color: AppColors.ink),
      headlineMedium: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.ink),
      headlineSmall:  TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.ink),
      titleLarge:     TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.ink),
      titleMedium:    TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.ink),
      titleSmall:     TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.ink),
      bodyLarge:      TextStyle(fontWeight: FontWeight.w400, fontSize: 14, height: 1.6, color: AppColors.ink),
      bodyMedium:     TextStyle(fontWeight: FontWeight.w300, fontSize: 13, height: 1.6, color: AppColors.ink),
      bodySmall:      TextStyle(fontWeight: FontWeight.w300, fontSize: 11.5, color: AppColors.ink3),
      labelLarge:     TextStyle(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5),
      labelMedium:    TextStyle(fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: 0.6),
      labelSmall:     TextStyle(fontWeight: FontWeight.w600, fontSize: 9.5, letterSpacing: 1.2),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.sage, foregroundColor: Colors.white,
        shadowColor: AppColors.sage, elevation: 4,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
        textStyle: AppTextStyles.ctaButton,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.sage,
        side: const BorderSide(color: AppColors.sage, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.terr,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.fieldBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: AppColors.sage.withAlpha(115), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.terr, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.terr, width: 1.5),
      ),
      hintStyle: TextStyle(color: AppColors.ink.withAlpha(71), fontWeight: FontWeight.w300, fontSize: 13.5),
      errorStyle: const TextStyle(color: AppColors.terr, fontSize: 11),
      contentPadding: AppDimensions.fieldContentPad,
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.sageDk,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Georgia', fontSize: 20, fontWeight: FontWeight.w700,
        color: Colors.white, letterSpacing: -0.2,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.sage,
      unselectedItemColor: AppColors.ink3,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.sageBg,
      selectedColor: AppColors.sage,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      side: BorderSide(color: AppColors.sageLt.withAlpha(128)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.amber,
      foregroundColor: AppColors.ink,
      elevation: 6,
      shape: CircleBorder(),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.ink.withAlpha(20), thickness: 1, space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.sage : Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.sage.withAlpha(102)
              : const Color(0xFFCDD9D4)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.sage : Colors.transparent),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColors.ink3, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
      actionTextColor: AppColors.sageLt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.sage,
      linearTrackColor: Color(0xFFEAF5EE),
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.sageLt,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1F4D3A),
      onPrimaryContainer: Color(0xFFA8E6D0),
      secondary: AppColors.amber,
      onSecondary: AppColors.ink,
      secondaryContainer: Color(0xFF4D3A00),
      onSecondaryContainer: Color(0xFFFFE8A8),
      tertiary: AppColors.terrLt,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF5A2A15),
      onTertiaryContainer: Color(0xFFFFD9C8),
      surface: Color(0xFF1A1F26),
      onSurface: Color(0xFFE8EFF0),
      surfaceContainerHighest: Color(0xFF252B33),
      error: AppColors.terrLt,
      onError: Colors.white,
      outline: Color(0xFF5A7A68),
      outlineVariant: Color(0xFF3A4E42),
      shadow: Colors.black87,
      scrim: Colors.black87,
      inverseSurface: Color(0xFFE8EFF0),
      onInverseSurface: Color(0xFF0F1419),
      inversePrimary: AppColors.sage,
    ),
    fontFamily: 'Georgia',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.sageHero,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge:   TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 36, letterSpacing: -0.5, color: Color(0xFFE8EFF0)),
      displayMedium:  TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 30, letterSpacing: -0.3, color: Color(0xFFE8EFF0)),
      displaySmall:   TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600, fontSize: 24, color: Color(0xFFE8EFF0)),
      headlineLarge:  TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 22, color: Color(0xFFE8EFF0)),
      headlineMedium: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFFE8EFF0)),
      headlineSmall:  TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFFE8EFF0)),
      titleLarge:     TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFFE8EFF0)),
      titleMedium:    TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFFE8EFF0)),
      titleSmall:     TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Color(0xFFE8EFF0)),
      bodyLarge:      TextStyle(fontWeight: FontWeight.w400, fontSize: 14, height: 1.6, color: Color(0xFFE8EFF0)),
      bodyMedium:     TextStyle(fontWeight: FontWeight.w300, fontSize: 13, height: 1.6, color: Color(0xFFD0D8DC)),
      bodySmall:      TextStyle(fontWeight: FontWeight.w300, fontSize: 11.5, color: Color(0xFFB0B8BC)),
      labelLarge:     TextStyle(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5, color: Color(0xFFE8EFF0)),
      labelMedium:    TextStyle(fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: 0.6, color: Color(0xFFD0D8DC)),
      labelSmall:     TextStyle(fontWeight: FontWeight.w600, fontSize: 9.5, letterSpacing: 1.2, color: Color(0xFFB0B8BC)),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: Color(0xFF3A4E42), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: Color(0xFF3A4E42), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: AppColors.sageLt.withAlpha(153), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.terrLt, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.terrLt, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF7A8288), fontWeight: FontWeight.w300, fontSize: 13.5),
      errorStyle: const TextStyle(color: AppColors.terrLt, fontSize: 11),
      contentPadding: AppDimensions.fieldContentPad,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.sageLt,
      unselectedItemColor: Color(0xFF7A8288),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface2,
      selectedColor: AppColors.sageLt,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFE8EFF0)),
      side: BorderSide(color: AppColors.sageLt.withAlpha(77)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.amber,
      foregroundColor: AppColors.ink,
      elevation: 6,
      shape: CircleBorder(),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3A4E42), thickness: 1, space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.sageLt : const Color(0xFF7A8288)),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.sageLt.withAlpha(128)
              : const Color(0xFF3A4E42)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.sageLt : Colors.transparent),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: Color(0xFF7A8288), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurface,
      contentTextStyle: const TextStyle(color: Color(0xFFE8EFF0), fontSize: 13),
      actionTextColor: AppColors.sageLt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.sageLt,
      linearTrackColor: AppColors.darkSurface2,
    ),
  );
}