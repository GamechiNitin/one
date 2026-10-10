import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Custom semantic colors exposed through the theme (ThemeExtension).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color bg, card, card2, ink, ink2, line, accent, success;
  const AppPalette({
    required this.bg,
    required this.card,
    required this.card2,
    required this.ink,
    required this.ink2,
    required this.line,
    required this.accent,
    required this.success,
  });

  static const light = AppPalette(
    bg: AppColors.lightBg,
    card: AppColors.lightCard,
    card2: AppColors.lightCard2,
    ink: AppColors.lightInk,
    ink2: AppColors.lightInk2,
    line: AppColors.lightLine,
    accent: AppColors.blue,
    success: AppColors.ok,
  );

  static const dark = AppPalette(
    bg: AppColors.darkBg,
    card: AppColors.darkCard,
    card2: AppColors.darkCard2,
    ink: AppColors.darkInk,
    ink2: AppColors.darkInk2,
    line: AppColors.darkLine,
    accent: AppColors.blueSoft,
    success: AppColors.okDark,
  );

  @override
  AppPalette copyWith({Color? bg, Color? card, Color? card2, Color? ink, Color? ink2, Color? line, Color? accent, Color? success}) => AppPalette(
        bg: bg ?? this.bg,
        card: card ?? this.card,
        card2: card2 ?? this.card2,
        ink: ink ?? this.ink,
        ink2: ink2 ?? this.ink2,
        line: line ?? this.line,
        accent: accent ?? this.accent,
        success: success ?? this.success,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      card2: Color.lerp(card2, other.card2, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      line: Color.lerp(line, other.line, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}
