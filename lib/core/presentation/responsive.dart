import 'package:flutter/material.dart';
import '../theme/theme_ext.dart';

/// Build with `--dart-define=TV=true` for Android TV / Fire TV / Google TV.
const bool kTv = bool.fromEnvironment('TV');

enum FormFactor { mobile, tablet, desktop, tv }

FormFactor formFactorOf(double width) {
  if (kTv) return FormFactor.tv;
  if (width < 700) return FormFactor.mobile;
  if (width < 1100) return FormFactor.tablet;
  return FormFactor.desktop;
}

extension Responsive on BuildContext {
  FormFactor get ff => formFactorOf(MediaQuery.sizeOf(this).width);
  bool get isWide => ff != FormFactor.mobile;
  int cols({int m = 2, int t = 3, int d = 4}) {
    switch (ff) {
      case FormFactor.mobile:
        return m;
      case FormFactor.tablet:
        return t;
      default:
        return d;
    }
  }
}

/// Marks full-screen routes (video player, reels) that manage their own width.
mixin FullBleed {}

/// Centers a page in a column on wide screens (web, tablet, TV).
class Wide extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const Wide({super.key, required this.child, this.maxWidth = 720});
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 700 || child is FullBleed) return child;
    return ColoredBox(
      color: context.bgc,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: context.line))),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Focusable, tappable wrapper: works with touch, mouse, keyboard and TV D-pad.
class Tap extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double radius;
  const Tap({super.key, this.onTap, required this.child, this.radius = 14});
  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      enabled: widget.onTap != null,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
          widget.onTap?.call();
          return null;
        }),
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: _focused ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 3),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
