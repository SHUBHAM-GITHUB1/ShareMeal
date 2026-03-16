import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppColors — every color used across the app
// Usage: AppColors.sage, AppColors.amber, etc.
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._(); // prevent instantiation

  // Sage Green — primary action color (buttons, toggle, focus rings, CTA)
  static const sage          = Color(0xFF3D8B6F);
  static const sageMid       = Color(0xFF52B08A);
  static const sageDk        = Color(0xFF2A6B52);
  static const sageHero      = Color(0xFF2D5C45); // darkest — hero bar top
  static const sageLt        = Color(0xFF86B898);
  static const sageBg        = Color(0xFFF2F7F4); // light tint for toggle bg

  // Amber — logo badge + accent touches (complement to sage)
  static const amber         = Color(0xFFF59E0B);
  static const amberLt       = Color(0xFFFDE68A);
  static const amberDk       = Color(0xFFB45309);

  // Terracotta — forgot link, pills, error states
  static const terr          = Color(0xFFD4603A);
  static const terrLt        = Color(0xFFF08060);

  // Ink / Neutrals — text and borders
  static const ink           = Color(0xFF1C2B22); // primary text
  static const ink2          = Color(0xFF3D5248); // secondary text
  static const ink3          = Color(0xFF7A9186); // hint / muted text

  // Surfaces
  static const white         = Color(0xFFFFFFFF);
  static const offWhite      = Color(0xFFF9FAF8); // scaffold background
  static const cream         = Color(0xFFFFFBF3); // warm page tint
  static const fieldBg       = Color(0xFFF9FAF8); // input field fill
  static const fieldBorder   = Color(0x17314B3F); // ink @ ~9% opacity
  static const cardSurface   = Color(0xFFFFFFFF);

  // Dark theme surfaces
  static const darkBg        = Color(0xFF0D1510);
  static const darkSurface   = Color(0xFF121A14);
  static const darkSurface2  = Color(0xFF1E2E22);
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextStyles — reusable text styles
// Usage: AppTextStyles.heading, AppTextStyles.bodyMuted, etc.
// ─────────────────────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  // Display / hero
  static const heroTitle = TextStyle(
    fontFamily:  'Georgia',
    fontSize:    34,
    fontWeight:  FontWeight.w700,
    color:       Colors.white,
    letterSpacing: -0.2,
  );

  static const brandName = TextStyle(
    fontFamily:  'Georgia',
    fontSize:    32,
    fontWeight:  FontWeight.w700,
    color:       Colors.white,
    letterSpacing: -0.2,
    shadows: [Shadow(color: Color(0x33000000), blurRadius: 12)],
  );

  // Card headings
  static const cardHead = TextStyle(
    fontFamily:  'Georgia',
    fontSize:    26,
    fontWeight:  FontWeight.w700,
    fontStyle:   FontStyle.italic,
    color:       AppColors.ink,
    height:      1.15,
  );

  static const sectionHead = TextStyle(
    fontFamily:  'Georgia',
    fontSize:    22,
    fontWeight:  FontWeight.w700,
    color:       AppColors.ink,
  );

  // Body
  static const body = TextStyle(
    fontSize:    13.5,
    fontWeight:  FontWeight.w400,
    color:       AppColors.ink,
    height:      1.6,
  );

  static const bodyMuted = TextStyle(
    fontSize:    12.5,
    fontWeight:  FontWeight.w300,
    color:       AppColors.ink3,
    height:      1.7,
  );

  static const bodySmall = TextStyle(
    fontSize:    11.5,
    fontWeight:  FontWeight.w300,
    color:       AppColors.ink3,
  );

  // Labels
  static const fieldLabel = TextStyle(
    fontSize:    10,
    fontWeight:  FontWeight.w600,
    color:       AppColors.ink3,
    letterSpacing: 0.7,
  );

  static const pillLabel = TextStyle(
    fontSize:    9.5,
    fontWeight:  FontWeight.w600,
    color:       AppColors.terr,
    letterSpacing: 1.0,
  );

  static const tagline = TextStyle(
    fontSize:    9.5,
    fontWeight:  FontWeight.w500,
    color:       AppColors.terrLt,
    letterSpacing: 2.6,
  );

  static const liveLabel = TextStyle(
    fontSize:    9,
    fontWeight:  FontWeight.w700,
    color:       AppColors.amberLt,
    letterSpacing: 1.0,
  );

  static const statNumber = TextStyle(
    fontFamily:  'Georgia',
    fontSize:    17,
    fontWeight:  FontWeight.w700,
    color:       AppColors.sage,
  );

  static const statLabel = TextStyle(
    fontSize:    9,
    fontWeight:  FontWeight.w500,
    color:       AppColors.ink3,
    height:      1.4,
    letterSpacing: 0.2,
  );

  // CTA button
  static const ctaButton = TextStyle(
    color:       Colors.white,
    fontSize:    13,
    fontWeight:  FontWeight.w700,
    letterSpacing: 1.5,
  );

  // Links
  static const link = TextStyle(
    fontSize:    12,
    fontWeight:  FontWeight.w600,
    color:       AppColors.amberDk,
  );

  static const forgotLink = TextStyle(
    fontSize:    11,
    fontWeight:  FontWeight.w500,
    color:       AppColors.terr,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppDimensions — spacing, radius, sizes
// ─────────────────────────────────────────────────────────────────────────────
class AppDimensions {
  AppDimensions._();

  // Border radii
  static const radiusSm   = 10.0;
  static const radiusMd   = 13.0;
  static const radiusLg   = 20.0;
  static const radiusXl   = 24.0;
  static const radiusHero = 40.0; // hero bar bottom curve

  // Common paddings
  static const pagePadding       = EdgeInsets.symmetric(horizontal: 16);
  static const cardPadding       = EdgeInsets.fromLTRB(24, 30, 24, 26);
  static const heroPadding       = EdgeInsets.fromLTRB(24, 20, 24, 28);
  static const fieldContentPad   = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  // Icon sizes
  static const iconSm   = 17.0;
  static const iconMd   = 20.0;
  static const iconLg   = 24.0;

  // Image heights
  static const imageHeight   = 170.0;
  static const imageHeightSm = 120.0;

  // Button heights
  static const btnHeight = 52.0;
  static const fieldHeight = 50.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// AppDecorations — reusable BoxDecoration / InputDecoration snippets
// ─────────────────────────────────────────────────────────────────────────────
class AppDecorations {
  AppDecorations._();

  // White floating card
  static BoxDecoration card = BoxDecoration(
    color:         AppColors.cardSurface,
    borderRadius:  BorderRadius.circular(AppDimensions.radiusXl),
    boxShadow: [
      BoxShadow(color: AppColors.ink.withOpacity(0.04),
          blurRadius: 4, offset: const Offset(0, 2)),
      BoxShadow(color: AppColors.ink.withOpacity(0.10),
          blurRadius: 48, offset: const Offset(0, 16)),
    ],
  );

  // Floating stats bridge card
  static BoxDecoration statsCard = BoxDecoration(
    color:        AppColors.white,
    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
    boxShadow: [
      BoxShadow(color: AppColors.ink.withOpacity(0.12),
          blurRadius: 32, offset: const Offset(0, 8)),
      BoxShadow(color: AppColors.ink.withOpacity(0.06),
          blurRadius: 8,  offset: const Offset(0, 2)),
    ],
  );

  // Input field (unfocused)
  static BoxDecoration field = BoxDecoration(
    color:         AppColors.fieldBg,
    borderRadius:  BorderRadius.circular(AppDimensions.radiusMd),
    border:        Border.all(color: AppColors.fieldBorder, width: 1.5),
  );

  // Input field (focused)
  static BoxDecoration fieldFocused = BoxDecoration(
    color:         AppColors.fieldBg,
    borderRadius:  BorderRadius.circular(AppDimensions.radiusMd),
    border: Border.all(
        color: AppColors.sage.withOpacity(0.45), width: 1.5),
    boxShadow: [
      BoxShadow(color: AppColors.sage.withOpacity(0.09),
          spreadRadius: 3, blurRadius: 0),
    ],
  );

  // Sage pill (sign in / create account)
  static BoxDecoration sagePill = BoxDecoration(
    color:         AppColors.sage.withOpacity(0.09),
    border:        Border.all(color: AppColors.sage.withOpacity(0.22)),
    borderRadius:  BorderRadius.circular(30),
  );

  // Terracotta pill
  static BoxDecoration terrPill = BoxDecoration(
    color:         AppColors.terr.withOpacity(0.09),
    border:        Border.all(color: AppColors.terr.withOpacity(0.20)),
    borderRadius:  BorderRadius.circular(30),
  );

  // Amber live badge
  static BoxDecoration liveBadge = BoxDecoration(
    color:         AppColors.amberLt.withOpacity(0.20),
    border:        Border.all(color: AppColors.amberLt.withOpacity(0.35)),
    borderRadius:  BorderRadius.circular(20),
  );

  // Role toggle container
  static BoxDecoration toggleBg = BoxDecoration(
    color:  AppColors.sageBg,
    border: Border.all(color: AppColors.sage.withOpacity(0.15)),
    borderRadius: BorderRadius.circular(14),
  );

  // Active toggle tab
  static BoxDecoration toggleActive = BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.sageMid, AppColors.sage, AppColors.sageDk],
    ),
    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
    boxShadow: [
      BoxShadow(color: AppColors.sage.withOpacity(0.30),
          blurRadius: 14, offset: const Offset(0, 4)),
    ],
  );

  // Social button
  static BoxDecoration socialBtn = BoxDecoration(
    color:         AppColors.fieldBg,
    borderRadius:  BorderRadius.circular(12),
    border:        Border.all(color: AppColors.fieldBorder, width: 1.5),
  );

  // Hero gradient bar
  static const BoxDecoration heroBar = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end:   Alignment.bottomRight,
      colors: [AppColors.sageHero, AppColors.sage, Color(0xFF4EA882)],
    ),
  );

  // Amber logo circle
  static const BoxDecoration logoBadge = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end:   Alignment.bottomRight,
      colors: [AppColors.amberLt, AppColors.amber, AppColors.amberDk],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppGradients — reusable gradients
// ─────────────────────────────────────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  static const sageButton = LinearGradient(
    colors: [AppColors.sageMid, AppColors.sage, AppColors.sageDk],
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
  );

  static const amberBadge = LinearGradient(
    colors: [AppColors.amberLt, AppColors.amber, AppColors.amberDk],
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
  );

  static const heroBar = LinearGradient(
    colors: [AppColors.sageHero, AppColors.sage, Color(0xFF4EA882)],
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
  );

  static const pageSplit = LinearGradient(
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
    stops:  [0, .52, .52, 1],
    colors: [
      Color(0xFFFEFCF7), Color(0xFFFEFCF7),
      Color(0xFFEEF7F2), Color(0xFFEAF5EE),
    ],
  );

  // Three-color left border stripe on cards
  static const cardAccentBorder = LinearGradient(
    begin:  Alignment.topCenter,
    end:    Alignment.bottomCenter,
    colors: [AppColors.amber, AppColors.sage, AppColors.terr],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — the full MaterialApp theme
// Usage: MaterialApp(theme: AppTheme.light, darkTheme: AppTheme.dark)
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.offWhite,

    colorScheme: ColorScheme(
      brightness:             Brightness.light,
      primary:                AppColors.sage,
      onPrimary:              Colors.white,
      primaryContainer:       const Color(0xFFEAF5EE),
      onPrimaryContainer:     AppColors.sageDk,
      secondary:              AppColors.amber,
      onSecondary:            AppColors.ink,
      secondaryContainer:     const Color(0xFFFEF3C7),
      onSecondaryContainer:   AppColors.amberDk,
      tertiary:               AppColors.terr,
      onTertiary:             Colors.white,
      tertiaryContainer:      const Color(0xFFFDE8DF),
      onTertiaryContainer:    const Color(0xFF7A2810),
      surface:                AppColors.offWhite,
      onSurface:              AppColors.ink,
      surfaceContainerHighest: const Color(0xFFEEF7F2),
      error:                  AppColors.terr,
      onError:                Colors.white,
      outline:                AppColors.ink3,
      outlineVariant:         const Color(0xFFCDD9D4),
      shadow:                 AppColors.ink,
      scrim:                  AppColors.ink,
      inverseSurface:         AppColors.ink,
      onInverseSurface:       AppColors.offWhite,
      inversePrimary:         AppColors.sageLt,
    ),

    fontFamily: 'Georgia',

    textTheme: const TextTheme(
      displayLarge:   TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700,
          fontSize: 36, letterSpacing: -0.5, color: AppColors.ink),
      displayMedium:  TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700,
          fontSize: 30, letterSpacing: -0.3, color: AppColors.ink),
      displaySmall:   TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600,
          fontSize: 24, color: AppColors.ink),
      headlineLarge:  TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700,
          fontSize: 22, color: AppColors.ink),
      headlineMedium: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600,
          fontSize: 18, color: AppColors.ink),
      headlineSmall:  TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600,
          fontSize: 16, color: AppColors.ink),
      titleLarge:     TextStyle(fontWeight: FontWeight.w600,
          fontSize: 16, color: AppColors.ink),
      titleMedium:    TextStyle(fontWeight: FontWeight.w500,
          fontSize: 14, color: AppColors.ink),
      titleSmall:     TextStyle(fontWeight: FontWeight.w500,
          fontSize: 12, color: AppColors.ink),
      bodyLarge:      TextStyle(fontWeight: FontWeight.w400,
          fontSize: 14, height: 1.6, color: AppColors.ink),
      bodyMedium:     TextStyle(fontWeight: FontWeight.w300,
          fontSize: 13, height: 1.6, color: AppColors.ink),
      bodySmall:      TextStyle(fontWeight: FontWeight.w300,
          fontSize: 11.5, color: AppColors.ink3),
      labelLarge:     TextStyle(fontWeight: FontWeight.w600,
          fontSize: 13, letterSpacing: 0.5),
      labelMedium:    TextStyle(fontWeight: FontWeight.w500,
          fontSize: 11, letterSpacing: 0.6),
      labelSmall:     TextStyle(fontWeight: FontWeight.w600,
          fontSize: 9.5, letterSpacing: 1.2),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:   AppColors.sage,
        foregroundColor:   Colors.white,
        shadowColor:       AppColors.sage,
        elevation:         4,
        padding:    const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
        textStyle: AppTextStyles.ctaButton,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.sage,
        side: const BorderSide(color: AppColors.sage, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.terr,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled:      true,
      fillColor:   AppColors.fieldBg,
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
        borderSide: BorderSide(
            color: AppColors.sage.withOpacity(0.45), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.terr, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.terr, width: 1.5),
      ),
      hintStyle: TextStyle(color: AppColors.ink.withOpacity(0.28),
          fontWeight: FontWeight.w300, fontSize: 13.5),
      errorStyle: const TextStyle(color: AppColors.terr, fontSize: 11),
      contentPadding: AppDimensions.fieldContentPad,
    ),

    cardTheme: CardThemeData(
      color:           AppColors.white,
      elevation:       0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
      surfaceTintColor: Colors.transparent,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor:  AppColors.sageDk,
      foregroundColor:  Colors.white,
      elevation:        0,
      centerTitle:      true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontFamily:    'Georgia',
        fontSize:      20,
        fontWeight:    FontWeight.w700,
        color:         Colors.white,
        letterSpacing: -0.2,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      AppColors.white,
      selectedItemColor:    AppColors.sage,
      unselectedItemColor:  AppColors.ink3,
      elevation:            8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle:   TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
    ),

    chipTheme: ChipThemeData(
      backgroundColor:  AppColors.sageBg,
      selectedColor:    AppColors.sage,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      side: BorderSide(color: AppColors.sageLt.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor:  AppColors.amber,
      foregroundColor:  AppColors.ink,
      elevation:        6,
      shape: CircleBorder(),
    ),

    dividerTheme: DividerThemeData(
      color:     AppColors.ink.withOpacity(0.08),
      thickness: 1,
      space:     1,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.sage : Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.sage.withOpacity(0.40)
              : const Color(0xFFCDD9D4)),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.sage : Colors.transparent),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColors.ink3, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor:  AppColors.ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
      actionTextColor:  AppColors.sageLt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color:            AppColors.sage,
      linearTrackColor: Color(0xFFEAF5EE),
    ),
  );

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static final dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: ColorScheme(
      brightness:             Brightness.dark,
      primary:                AppColors.sageLt,
      onPrimary:              AppColors.sageDk,
      primaryContainer:       const Color(0xFF1A3D2E),
      onPrimaryContainer:     AppColors.sageLt,
      secondary:              AppColors.amber,
      onSecondary:            AppColors.ink,
      secondaryContainer:     const Color(0xFF3D2A00),
      onSecondaryContainer:   const Color(0xFFFDE68A),
      tertiary:               AppColors.terrLt,
      onTertiary:             Colors.white,
      tertiaryContainer:      const Color(0xFF4A1C0A),
      onTertiaryContainer:    const Color(0xFFFDC8B4),
      surface:                AppColors.darkSurface,
      onSurface:              const Color(0xFFE0EDE5),
      surfaceContainerHighest: AppColors.darkSurface2,
      error:                  AppColors.terrLt,
      onError:                Colors.white,
      outline:                const Color(0xFF4A6B58),
      outlineVariant:         const Color(0xFF2A3E30),
      shadow:                 Colors.black,
      scrim:                  Colors.black,
      inverseSurface:         const Color(0xFFE0EDE5),
      onInverseSurface:       AppColors.darkSurface,
      inversePrimary:         AppColors.sage,
    ),
    fontFamily: 'Georgia',
    appBarTheme: const AppBarTheme(
      backgroundColor:  AppColors.darkBg,
      foregroundColor:  Color(0xFFE0EDE5),
      elevation:        0,
      centerTitle:      true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
  );
}