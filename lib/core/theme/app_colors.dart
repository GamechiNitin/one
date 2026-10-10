import 'package:flutter/material.dart';

/// Brand colors and gradients. No widgets, no ThemeData.
class AppColors {
  AppColors._();

  static const blue = Color(0xFF1F5BFF);
  static const blueSoft = Color(0xFF6B93FF);
  static const live = Color(0xFFE5373D);
  static const ok = Color(0xFF12A672);
  static const okDark = Color(0xFF3BD08F);

  static const gradient = LinearGradient(
    colors: [Color(0xFF1E6BFF), Color(0xFF3B3BF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// The six-dot spectrum used by partner badges.
  static const spectrum = [
    Color(0xFFFF5A5F),
    Color(0xFFFFA400),
    Color(0xFFFFD400),
    Color(0xFF2BC48A),
    Color(0xFF2D8CFF),
    Color(0xFF8B5CF6),
  ];

  // Light surface tokens
  static const lightBg = Color(0xFFF3F6FD);
  static const lightCard = Colors.white;
  static const lightCard2 = Color(0xFFEAF0FF);
  static const lightInk = Color(0xFF0B1633);
  static const lightInk2 = Color(0xFF5A6785);
  static const lightLine = Color(0xFFE1E8F8);

  // Dark surface tokens
  static const darkBg = Color(0xFF060A18);
  static const darkCard = Color(0xFF0F1630);
  static const darkCard2 = Color(0xFF1A2450);
  static const darkInk = Color(0xFFEEF2FF);
  static const darkInk2 = Color(0xFF97A3C4);
  static const darkLine = Color(0xFF1D2750);
}
