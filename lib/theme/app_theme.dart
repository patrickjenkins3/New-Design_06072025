import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Brand palette ──────────────────────────────────────────────
  static const Color primaryBlack   = Color(0xFF0A0A0A);
  static const Color surfaceBlack   = Color(0xFF111111);
  static const Color cardBlack      = Color(0xFF1A1A1A);
  static const Color dividerBlack   = Color(0xFF2A2A2A);
  static const Color teal           = Color(0xFF00BFA5);
  static const Color tealLight      = Color(0xFF4DD0C4);
  static const Color tealDark       = Color(0xFF008F7A);
  static const Color white          = Color(0xFFFFFFFF);
  static const Color offWhite       = Color(0xFFF5F5F5);
  static const Color grey50         = Color(0xFFFAFAFA);
  static const Color grey100        = Color(0xFFF0F0F0);
  static const Color grey300        = Color(0xFFB0B0B0);
  static const Color grey500        = Color(0xFF757575);
  static const Color grey700        = Color(0xFF424242);
  static const Color errorRed       = Color(0xFFE53935);
  static const Color successGreen   = Color(0xFF43A047);
  static const Color warningAmber   = Color(0xFFFFA000);
  static const Color infoBlue       = Color(0xFF1E88E5);

  // ── Text styles ────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color base) {
    return TextTheme(
      displayLarge:  GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: base, letterSpacing: -1.0),
      displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: base, letterSpacing: -0.5),
      displaySmall:  GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: base),
      headlineLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: base),
      headlineMedium:GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: base),
      headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: base),
      titleLarge:    GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: base),
      titleMedium:   GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: base),
      titleSmall:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: base),
      bodyLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: base),
      bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: base),
      bodySmall:     GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: base),
      labelLarge:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: base),
      labelMedium:   GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: base),
      labelSmall:    GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: base),
    );
  }

  // ── Light theme ────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary:          teal,
        onPrimary:        white,
        primaryContainer: tealLight.withValues(alpha: 0.15),
        secondary:        primaryBlack,
        onSecondary:      white,
        surface:          white,
        onSurface:        primaryBlack,
        surfaceContainerHighest: grey100,
        outline:          grey300,
        error:            errorRed,
      ),
      scaffoldBackgroundColor: offWhite,
      textTheme: _buildTextTheme(primaryBlack),
      appBarTheme: AppBarTheme(
        backgroundColor:  white,
        foregroundColor:  primaryBlack,
        elevation:        0,
        centerTitle:      false,
        titleTextStyle:   GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: primaryBlack),
        iconTheme:        const IconThemeData(color: primaryBlack),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color:         white,
        elevation:     0,
        shape:         RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: grey100)),
        margin:        const EdgeInsets.all(0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  teal,
          foregroundColor:  white,
          elevation:        0,
          minimumSize:      const Size(double.infinity, 52),
          shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:        GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlack,
          side:            const BorderSide(color: grey300),
          minimumSize:     const Size(double.infinity, 52),
          shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:       GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: teal,
          textStyle:       GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:           true,
        fillColor:        white,
        border:           OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: grey300)),
        enabledBorder:    OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: grey300)),
        focusedBorder:    OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: teal, width: 1.5)),
        errorBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: errorRed)),
        contentPadding:   const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:        GoogleFonts.inter(fontSize: 14, color: grey500),
        labelStyle:       GoogleFonts.inter(fontSize: 14, color: grey700),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:      white,
        selectedItemColor:    teal,
        unselectedItemColor:  grey500,
        type:                 BottomNavigationBarType.fixed,
        elevation:            8,
        selectedLabelStyle:   TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:      grey100,
        selectedColor:        teal.withValues(alpha: 0.15),
        labelStyle:           GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        shape:                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side:                 const BorderSide(color: grey300),
        padding:              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      dividerTheme: const DividerThemeData(color: grey100, thickness: 1, space: 0),
      switchTheme: SwitchThemeData(
        thumbColor:  WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? teal : grey300),
        trackColor:  WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? teal.withValues(alpha: 0.3) : grey100),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? teal : Colors.transparent),
        side: const BorderSide(color: grey300, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary:          teal,
        onPrimary:        white,
        primaryContainer: teal.withValues(alpha: 0.2),
        secondary:        tealLight,
        onSecondary:      primaryBlack,
        surface:          cardBlack,
        onSurface:        white,
        surfaceContainerHighest: dividerBlack,
        outline:          grey700,
        error:            errorRed,
      ),
      scaffoldBackgroundColor: primaryBlack,
      textTheme: _buildTextTheme(white),
      appBarTheme: AppBarTheme(
        backgroundColor:  surfaceBlack,
        foregroundColor:  white,
        elevation:        0,
        centerTitle:      false,
        titleTextStyle:   GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: white),
        iconTheme:        const IconThemeData(color: white),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color:     cardBlack,
        elevation: 0,
        shape:     RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: dividerBlack)),
        margin:    const EdgeInsets.all(0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: white,
          elevation:       0,
          minimumSize:     const Size(double.infinity, 52),
          shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:       GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: white,
          side:            const BorderSide(color: dividerBlack),
          minimumSize:     const Size(double.infinity, 52),
          shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:       GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:        true,
        fillColor:     surfaceBlack,
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: dividerBlack)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: dividerBlack)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: teal, width: 1.5)),
        errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: errorRed)),
        contentPadding:const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:     GoogleFonts.inter(fontSize: 14, color: grey500),
        labelStyle:    GoogleFonts.inter(fontSize: 14, color: grey300),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:      surfaceBlack,
        selectedItemColor:    teal,
        unselectedItemColor:  grey500,
        type:                 BottomNavigationBarType.fixed,
        elevation:            8,
      ),
      dividerTheme: const DividerThemeData(color: dividerBlack, thickness: 1, space: 0),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? teal : grey500),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? teal.withValues(alpha: 0.3) : dividerBlack),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? teal : Colors.transparent),
        side: const BorderSide(color: grey700, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
