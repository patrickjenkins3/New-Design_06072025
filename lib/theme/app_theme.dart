import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CollabFuture brand palette — sourced from COlor.pdf (November 2025)
///
///  #FFFFFF  White       — backgrounds, cards, text-on-dark
///  #2C2F4C  Navy        — primary dark, headings, nav bar
///  #58C4F4  Sky Blue    — primary action / accent
///  #7FC6A4  Sage Green  — secondary accent / success states
///  #E5B769  Warm Gold   — warnings, highlights, deadlines
class AppTheme {
  AppTheme._();

  // ── Brand tokens ────────────────────────────────────────────────
  static const Color white      = Color(0xFFFFFFFF);
  static const Color navy       = Color(0xFF2C2F4C);
  static const Color navyLight  = Color(0xFF3D4168);
  static const Color navyDark   = Color(0xFF1E2038);
  static const Color skyBlue    = Color(0xFF58C4F4);
  static const Color skyBlueDim = Color(0xFF3AAEDF);
  static const Color sage       = Color(0xFF7FC6A4);
  static const Color sageDark   = Color(0xFF5EAB87);
  static const Color gold       = Color(0xFFE5B769);
  static const Color goldDark   = Color(0xFFCF9D50);

  // ── Surface / neutral tokens ────────────────────────────────────
  static const Color surface       = Color(0xFFF4F5FA);  // very light navy-tinted
  static const Color surfaceCard   = Color(0xFFFFFFFF);
  static const Color surfaceDark   = Color(0xFF1A1D30);  // dark navy bg
  static const Color cardDark      = Color(0xFF252846);  // dark navy card
  static const Color dividerLight  = Color(0xFFE8EAF2);
  static const Color dividerDark   = Color(0xFF343760);
  static const Color textMuted     = Color(0xFF7B7E9A);  // muted navy-grey
  static const Color textMutedDark = Color(0xFF9395B0);
  static const Color errorRed      = Color(0xFFE05555);

  // ── Typography ──────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color base) => TextTheme(
    displayLarge:   GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: base, letterSpacing: -1.0),
    displayMedium:  GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: base, letterSpacing: -0.5),
    displaySmall:   GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: base),
    headlineLarge:  GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: base),
    headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: base),
    headlineSmall:  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: base),
    titleLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: base),
    titleMedium:    GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: base),
    titleSmall:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: base),
    bodyLarge:      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: base),
    bodyMedium:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: base),
    bodySmall:      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: base),
    labelLarge:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: base),
    labelMedium:    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: base),
    labelSmall:     GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: base),
  );

  // ── Light theme ─────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary:              skyBlue,
      onPrimary:            white,
      primaryContainer:     skyBlue.withValues(alpha: 0.12),
      secondary:            sage,
      onSecondary:          white,
      secondaryContainer:   sage.withValues(alpha: 0.12),
      tertiary:             gold,
      onTertiary:           navy,
      tertiaryContainer:    gold.withValues(alpha: 0.15),
      surface:              surfaceCard,
      onSurface:            navy,
      surfaceContainerHighest: dividerLight,
      outline:              dividerLight,
      outlineVariant:       dividerLight,
      error:                errorRed,
      onError:              white,
    ),
    scaffoldBackgroundColor: surface,
    textTheme: _buildTextTheme(navy),
    appBarTheme: AppBarTheme(
      backgroundColor:  white,
      foregroundColor:  navy,
      elevation:        0,
      centerTitle:      false,
      titleTextStyle:   GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: navy),
      iconTheme:        const IconThemeData(color: navy),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      color:     surfaceCard,
      elevation: 0,
      shape:     RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: dividerLight),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: navy,
        foregroundColor: white,
        elevation:       0,
        minimumSize:     const Size(double.infinity, 52),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:       GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: navy,
        side:            const BorderSide(color: dividerLight),
        minimumSize:     const Size(double.infinity, 52),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:       GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: skyBlue,
        textStyle:       GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:        true,
      fillColor:     white,
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: dividerLight)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: dividerLight)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: skyBlue, width: 1.5)),
      errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: errorRed)),
      contentPadding:const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle:     GoogleFonts.inter(fontSize: 14, color: textMuted),
      labelStyle:    GoogleFonts.inter(fontSize: 14, color: textMuted),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      white,
      selectedItemColor:    navy,
      unselectedItemColor:  textMuted,
      type:                 BottomNavigationBarType.fixed,
      elevation:            0,
      selectedLabelStyle:   TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor:  dividerLight,
      selectedColor:    skyBlue.withValues(alpha: 0.15),
      labelStyle:       GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: navy),
      shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side:             const BorderSide(color: dividerLight),
      padding:          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    dividerTheme: const DividerThemeData(color: dividerLight, thickness: 1, space: 0),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? skyBlue : Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? skyBlue.withValues(alpha: 0.35) : dividerLight),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? skyBlue : Colors.transparent),
      side: const BorderSide(color: dividerLight, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: skyBlue, linearTrackColor: dividerLight),
    sliderTheme: SliderThemeData(activeTrackColor: skyBlue, thumbColor: skyBlue, inactiveTrackColor: dividerLight),
  );

  // ── Dark theme ──────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary:              skyBlue,
      onPrimary:            navy,
      primaryContainer:     skyBlue.withValues(alpha: 0.18),
      secondary:            sage,
      onSecondary:          navyDark,
      secondaryContainer:   sage.withValues(alpha: 0.18),
      tertiary:             gold,
      onTertiary:           navyDark,
      tertiaryContainer:    gold.withValues(alpha: 0.18),
      surface:              cardDark,
      onSurface:            white,
      surfaceContainerHighest: dividerDark,
      outline:              dividerDark,
      outlineVariant:       dividerDark,
      error:                errorRed,
      onError:              white,
    ),
    scaffoldBackgroundColor: surfaceDark,
    textTheme: _buildTextTheme(white),
    appBarTheme: AppBarTheme(
      backgroundColor:  navyDark,
      foregroundColor:  white,
      elevation:        0,
      centerTitle:      false,
      titleTextStyle:   GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: white),
      iconTheme:        const IconThemeData(color: white),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      color:     cardDark,
      elevation: 0,
      shape:     RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: dividerDark),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: skyBlue,
        foregroundColor: navy,
        elevation:       0,
        minimumSize:     const Size(double.infinity, 52),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:       GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: white,
        side:            const BorderSide(color: dividerDark),
        minimumSize:     const Size(double.infinity, 52),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:       GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: skyBlue,
        textStyle:       GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:        true,
      fillColor:     navyDark,
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: dividerDark)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: dividerDark)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: skyBlue, width: 1.5)),
      errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: errorRed)),
      contentPadding:const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle:     GoogleFonts.inter(fontSize: 14, color: textMutedDark),
      labelStyle:    GoogleFonts.inter(fontSize: 14, color: textMutedDark),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      navyDark,
      selectedItemColor:    skyBlue,
      unselectedItemColor:  textMutedDark,
      type:                 BottomNavigationBarType.fixed,
      elevation:            0,
      selectedLabelStyle:   TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor:  dividerDark,
      selectedColor:    skyBlue.withValues(alpha: 0.22),
      labelStyle:       GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: white),
      shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side:             const BorderSide(color: dividerDark),
      padding:          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    dividerTheme: const DividerThemeData(color: dividerDark, thickness: 1, space: 0),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? skyBlue : textMutedDark),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? skyBlue.withValues(alpha: 0.3) : dividerDark),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? skyBlue : Colors.transparent),
      side: const BorderSide(color: dividerDark, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: skyBlue, linearTrackColor: dividerDark),
    sliderTheme: SliderThemeData(activeTrackColor: skyBlue, thumbColor: skyBlue, inactiveTrackColor: dividerDark),
  );
}
