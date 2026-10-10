import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const title = TextStyle(fontSize: 22, fontWeight: FontWeight.w800);
  static const section = TextStyle(fontSize: 18, fontWeight: FontWeight.w800);
  static const heading = TextStyle(fontSize: 16, fontWeight: FontWeight.w800);
  static const cardTitle = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);
  static const caption = TextStyle(fontSize: 11.5);
  static const button = TextStyle(fontWeight: FontWeight.w700, fontSize: 14);
  static const big = TextStyle(fontSize: 38, fontWeight: FontWeight.w800, height: 1);

  static TextTheme textTheme(Color ink) => TextTheme(
        bodyLarge: TextStyle(color: ink),
        bodyMedium: TextStyle(color: ink),
        bodySmall: TextStyle(color: ink),
        titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w700),
        labelLarge: TextStyle(color: ink, fontWeight: FontWeight.w700),
      );
}
