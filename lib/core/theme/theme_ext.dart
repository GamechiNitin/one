import 'package:flutter/material.dart';
import 'app_palette.dart';

/// Short accessors so widgets read `context.ink` instead of digging into Theme.
extension ThemeCtx on BuildContext {
  AppPalette get pal => Theme.of(this).extension<AppPalette>()!;
  Color get ink => pal.ink;
  Color get ink2 => pal.ink2;
  Color get card => pal.card;
  Color get card2 => pal.card2;
  Color get line => pal.line;
  Color get acc => pal.accent;
  Color get bgc => pal.bg;
}
