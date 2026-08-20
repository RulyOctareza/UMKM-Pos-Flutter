import 'package:flutter/material.dart';

/// Single source of truth untuk color tokens sesuai DESIGN_SYSTEM.md
class AppColors {
  AppColors._();

  /// Seed color utama: Teal (kepercayaan, uang, modern tanpa klise)
  static const Color seed = Color(0xFF0D9488);

  /// Semantic tokens
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  /// Light theme specific accents
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  /// Dark theme specific accents
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
}
