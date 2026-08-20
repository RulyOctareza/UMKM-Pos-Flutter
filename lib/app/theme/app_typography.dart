import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography configuration sesuai DESIGN_SYSTEM.md §3
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color textColor) {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: textColor.withAlpha(180),
        fontWeight: FontWeight.normal,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: textColor.withAlpha(180),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Style khusus angka harga/nominal kasir dengan tabular figures (digit sejajar rapi)
  static TextStyle priceStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
