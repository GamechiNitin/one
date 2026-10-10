import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../domain/art.dart';
import 'brands.dart';
import 'responsive.dart';
import '../theme/app_colors.dart';
import '../theme/theme_ext.dart';

// ---------- Generated poster art ----------
class ArtPainter extends CustomPainter {
  final Art art;
  ArtPainter(this.art);

  Paint f(Color c, [double o = 1]) => Paint()..color = c.withValues(alpha: o);
  Paint s(Color c, double w, [double o = 1]) => Paint()
    ..color = c.withValues(alpha: o)
    ..style = PaintingStyle.stroke
    ..strokeWidth = w;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final sc = math.max(size.width / 200, size.height / 300);
    canvas.translate((size.width - 200 * sc) / 2, (size.height - 300 * sc) / 2);
    canvas.scale(sc);
    const rect = Rect.fromLTWH(0, 0, 200, 300);
    final c = art.colors.map(Color.new).toList();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c[0], c[1]]).createShader(rect),
    );
    switch (art.type) {
      case 'harbour':
        canvas.drawCircle(const Offset(100, 150), 46, f(c[2], .92));
        final dark = f(const Color(0xFF06101F), .94);
        for (final r in const [
          [0.0, 192.0, 30.0, 110.0],
          [26.0, 166.0, 22.0, 136.0],
          [52.0, 202.0, 34.0, 100.0],
          [92.0, 180.0, 26.0, 122.0],
          [122.0, 206.0, 30.0, 96.0],
          [150.0, 172.0, 24.0, 130.0],
          [172.0, 196.0, 28.0, 106.0],
        ]) {
          canvas.drawRect(Rect.fromLTWH(r[0], r[1], r[2], r[3]), dark);
        }
        for (final y in const [252.0, 266.0, 280.0]) {
          canvas.drawLine(Offset(0, y), Offset(200, y), s(c[1], 1.5, .55));
        }
        break;
      case 'monsoon':
        for (var i = 0; i < 26; i++) {
          final x = ((i * 17) % 210).toDouble();
          final y = ((i * 37) % 120).toDouble();
          canvas.drawLine(
              Offset(x, y), Offset(x - 12, y + 46), s(c[1], 1.6, .55));
        }
        final p = Path()
          ..moveTo(40, 190)
          ..arcToPoint(const Offset(160, 190),
              radius: const Radius.circular(60))
          ..close();
        canvas.drawPath(p, f(c[2]));
        canvas.drawLine(
            const Offset(100, 190), const Offset(100, 242), s(c[2], 3));
        canvas.drawRect(
            const Rect.fromLTWH(0, 262, 200, 40), f(Colors.black, .35));
        break;
      case 'moons':
        canvas.drawCircle(const Offset(62, 96), 52, f(c[1], .9));
        canvas.drawCircle(const Offset(142, 170), 38, f(c[2], .95));
        canvas.drawCircle(const Offset(70, 238), 26, f(Colors.white, .85));
        canvas.drawCircle(const Offset(168, 60), 8, f(Colors.white, .8));
        break;
      case 'train':
        for (var i = 0; i < 8; i++) {
          final y = 165 + i * i * 2.4 + i * 6;
          final half = (y - 150) * .33;
          canvas.drawLine(Offset(100 - half, y), Offset(100 + half, y),
              s(Colors.black, 2, .5));
        }
        canvas.drawLine(
            const Offset(60, 300), const Offset(98, 150), s(c[1], 3));
        canvas.drawLine(
            const Offset(140, 300), const Offset(102, 150), s(c[1], 3));
        canvas.drawCircle(const Offset(100, 148), 26, f(c[2], .3));
        canvas.drawCircle(const Offset(100, 148), 10, f(c[2]));
        break;
      case 'concert':
        final beam = f(c[2], .4);
        for (final x in const [20.0, 80.0, 140.0]) {
          canvas.drawPath(
              Path()
                ..moveTo(100, 300)
                ..lineTo(x, 0)
                ..lineTo(x + 40, 0)
                ..close(),
              beam);
        }
        final side = f(c[1], .35);
        canvas.drawPath(
            Path()
              ..moveTo(100, 300)
              ..lineTo(-10, 80)
              ..lineTo(-10, 30)
              ..close(),
            side);
        canvas.drawPath(
            Path()
              ..moveTo(100, 300)
              ..lineTo(210, 80)
              ..lineTo(210, 30)
              ..close(),
            side);
        canvas.drawOval(
            const Rect.fromLTWH(10, 248, 180, 28), f(Colors.black, .5));
        canvas.drawCircle(const Offset(100, 200), 14, f(Colors.white));
        canvas.drawLine(
            const Offset(100, 214), const Offset(100, 252), s(Colors.white, 5));
        break;
      case 'comedy':
        canvas.drawPath(
            Path()
              ..moveTo(100, 0)
              ..lineTo(40, 300)
              ..lineTo(160, 300)
              ..close(),
            f(Colors.white, .22));
        canvas.drawOval(const Rect.fromLTWH(40, 282, 120, 20), f(c[2], .8));
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(94, 170, 12, 100),
                const Radius.circular(6)),
            f(Colors.white));
        canvas.drawCircle(const Offset(100, 160), 16, f(c[2]));
        break;
      case 'football':
        final w = s(Colors.white, 2, .55);
        canvas.drawRect(const Rect.fromLTWH(20, 40, 160, 230), w);
        canvas.drawLine(const Offset(20, 155), const Offset(180, 155), w);
        canvas.drawCircle(const Offset(100, 155), 30, w);
        canvas.drawRect(const Rect.fromLTWH(60, 40, 80, 34), w);
        canvas.drawRect(const Rect.fromLTWH(60, 236, 80, 34), w);
        canvas.drawCircle(const Offset(100, 155), 9, f(c[2]));
        break;
      case 'dunes':
        canvas.drawCircle(const Offset(62, 86), 20, f(c[2], .95));
        canvas.drawCircle(const Offset(128, 112), 11, f(c[2], .7));
        canvas.drawPath(
            Path()
              ..moveTo(0, 220)
              ..quadraticBezierTo(50, 180, 110, 215)
              ..quadraticBezierTo(160, 240, 200, 195)
              ..lineTo(200, 300)
              ..lineTo(0, 300)
              ..close(),
            f(Colors.black, .4));
        canvas.drawPath(
            Path()
              ..moveTo(0, 258)
              ..quadraticBezierTo(70, 226, 140, 256)
              ..quadraticBezierTo(175, 268, 200, 240)
              ..lineTo(200, 300)
              ..lineTo(0, 300)
              ..close(),
            f(Colors.black, .55));
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTWH(95, 190, 7, 30), const Radius.circular(3)),
            f(Colors.black));
        canvas.drawCircle(const Offset(98.5, 186), 5, f(Colors.black));
        break;
      case 'space':
        for (var i = 0; i < 22; i++) {
          canvas.drawCircle(
              Offset(((i * 47) % 200).toDouble(), ((i * 83) % 300).toDouble()),
              i % 3 == 0 ? 1.8 : 1,
              f(Colors.white, .7));
        }
        canvas.drawCircle(const Offset(100, 140), 54, f(c[2]));
        canvas.save();
        canvas.translate(100, 140);
        canvas.rotate(-18 * math.pi / 180);
        canvas.drawOval(
            const Rect.fromLTRB(-88, -14, 88, 14), s(Colors.white, 3, .6));
        canvas.restore();
        canvas.drawPath(
            Path()
              ..moveTo(0, 270)
              ..quadraticBezierTo(100, 240, 200, 272)
              ..lineTo(200, 300)
              ..lineTo(0, 300)
              ..close(),
            f(Colors.black, .5));
        break;
      case 'forest':
        canvas.drawCircle(const Offset(140, 80), 22, f(c[2], .9));
        for (var i = 0; i < 9; i++) {
          final x = i * 26 - 4.0;
          final hh = 70.0 + (i * 37) % 60;
          canvas.drawPath(
              Path()
                ..moveTo(x, 300)
                ..lineTo(x + 14, 300 - hh)
                ..lineTo(x + 28, 300)
                ..close(),
              f(const Color(0xFF04120D), .9));
        }
        canvas.drawRect(const Rect.fromLTWH(0, 190, 200, 40), f(c[2], .12));
        break;
      case 'burst':
        for (var i = 0; i < 18; i++) {
          final a = i * 20 * math.pi / 180;
          canvas.drawLine(
              const Offset(100, 120),
              Offset(100 + math.cos(a) * 260, 120 + math.sin(a) * 260),
              s(c[2], 5, .28));
        }
        final sil = f(const Color(0xFF07101F));
        canvas.drawCircle(const Offset(100, 118), 17, sil);
        canvas.drawPath(
            Path()
              ..moveTo(62, 300)
              ..cubicTo(62, 240, 76, 152, 100, 152)
              ..cubicTo(124, 152, 138, 240, 138, 300)
              ..close(),
            sil);
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(ArtPainter old) => old.art != art;
}

class Poster extends StatelessWidget {
  final Art art;
  final double aspect;
  final double radius;
  final Widget? child;
  const Poster(this.art,
      {super.key, this.aspect = 2 / 3, this.radius = 12, this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: aspect,
        child: Stack(fit: StackFit.expand, children: [
          CustomPaint(painter: ArtPainter(art)),
          if (child != null) child!,
        ]),
      ),
    );
  }
}

class Shade extends StatelessWidget {
  final double strength;
  const Shade({super.key, this.strength = .88});
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [
              Colors.black.withValues(alpha: strength),
              Colors.transparent
            ],
          ),
        ),
      );
}

// ---------- Brand / logo ----------
class BrandBadge extends StatelessWidget {
  final String brand;
  final double size;
  const BrandBadge(this.brand, {super.key, this.size = 44});
  @override
  Widget build(BuildContext context) {
    final b = brands[brand]!;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.symmetric(horizontal: size * .06),
      decoration: BoxDecoration(
        color: b.bg,
        borderRadius: BorderRadius.circular(size * .26),
        border: Border.all(color: context.line),
      ),
      alignment: Alignment.center,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (b.dots) ...[
          Row(mainAxisSize: MainAxisSize.min, children: [
            for (final c in AppColors.spectrum)
              Container(
                width: size * .075,
                height: size * .075,
                margin: EdgeInsets.symmetric(horizontal: size * .015),
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
          ]),
          SizedBox(height: size * .05),
        ],
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(b.mark,
              style: TextStyle(
                  color: b.fg,
                  fontWeight: FontWeight.w800,
                  fontSize: size * b.fs,
                  letterSpacing: -.4)),
        ),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromCircle(
        center: size.center(Offset.zero), radius: size.width * .36);
    canvas.drawCircle(
      r.center,
      r.width / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .18
        ..shader = const LinearGradient(
          colors: [Color(0xFF1E90FF), Color(0xFF4B2BE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class OneLogo extends StatelessWidget {
  final double size;
  const OneLogo({super.key, this.size = 26});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
          width: size * .95,
          height: size * .95,
          child: CustomPaint(painter: _RingPainter())),
      Text('NE',
          style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w800,
              color: context.ink,
              height: 1,
              letterSpacing: -.5)),
    ]);
  }
}

// ---------- Small building blocks ----------
class GBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool outline, small, light, expand;
  const GBtn(this.label,
      {super.key,
      this.onTap,
      this.icon,
      this.outline = false,
      this.small = false,
      this.light = false,
      this.expand = false});
  @override
  Widget build(BuildContext context) {
    final fg = outline
        ? context.acc
        : (light ? const Color(0xFF1F3FD8) : Colors.white);
    final r = BorderRadius.circular(small ? 10 : 12);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: r,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: (outline || light) ? null : AppColors.gradient,
            color: light ? Colors.white : (outline ? context.card : null),
            border: outline ? Border.all(color: context.acc, width: 1.5) : null,
            borderRadius: r,
          ),
          padding: EdgeInsets.symmetric(
              horizontal: small ? 14 : 20, vertical: small ? 8 : 12),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: small ? 16 : 18, color: fg),
                const SizedBox(width: 6)
              ],
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        fontSize: small ? 12.5 : 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(14),
      this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.line),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const GradCard({super.key, required this.child, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(20)),
        child: child,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        if (action != null)
          Tap(
            onTap: onAction,
            child: Text(action!,
                style: TextStyle(
                    color: context.acc,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5)),
          ),
      ]),
    );
  }
}

class HRow extends StatelessWidget {
  final double height;
  final List<Widget> children;
  const HRow({super.key, required this.height, required this.children});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }
}

class ChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final String Function(String option)? labelOf;
  const ChipRow(
      {super.key,
      required this.options,
      required this.selected,
      required this.onSelect,
      this.labelOf});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final o = options[i];
          final on = o == selected;
          return Tap(
            onTap: () => onSelect(o),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: on ? AppColors.gradient : null,
                color: on ? null : context.card,
                borderRadius: BorderRadius.circular(999),
                border:
                    Border.all(color: on ? Colors.transparent : context.line),
              ),
              child: Text(labelOf == null ? o : labelOf!(o),
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: on ? Colors.white : context.ink2)),
            ),
          );
        },
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final bool live;
  const Pill(this.text, {super.key, this.live = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: live ? AppColors.live : context.card2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: live ? Colors.white : context.acc)),
      );
}

class TagChip extends StatelessWidget {
  final String text;
  final Color? color;
  const TagChip(this.text, {super.key, this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color ?? Colors.white.withValues(alpha: .2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      );
}

class Avatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  const Avatar(this.name, this.color, {super.key, this.size = 36});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Text(name.isEmpty ? '?' : name[0],
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * .4)),
      );
}

class Verified extends StatelessWidget {
  const Verified({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.only(left: 4),
      child: Icon(Icons.verified, size: 15, color: AppColors.blue));
}

class IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badge;
  const IconBtn(this.icon, this.onTap, {super.key, this.badge = 0});
  @override
  Widget build(BuildContext context) => Tap(
        onTap: onTap,
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: context.card,
                shape: BoxShape.circle,
                border: Border.all(color: context.line)),
            child: Icon(icon, size: 20, color: context.ink),
          ),
          if (badge > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                    color: AppColors.live,
                    borderRadius: BorderRadius.circular(9)),
                child: Text('$badge',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ]),
      );
}

class ListRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? sub;
  final Widget? trailing;
  final VoidCallback? onTap;
  const ListRow(
      {super.key,
      required this.leading,
      required this.title,
      this.sub,
      this.trailing,
      this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    if (sub != null)
                      Text(sub!,
                          style: TextStyle(fontSize: 12, color: context.ink2)),
                  ]),
            ),
            if (trailing != null) trailing!,
          ]),
        ),
      );
}

class IconTile extends StatelessWidget {
  final IconData icon;
  final double size;
  const IconTile(this.icon, {super.key, this.size = 42});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: context.card2, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: size * .5, color: context.acc),
      );
}

class Divided extends StatelessWidget {
  final List<Widget> children;
  const Divided(this.children, {super.key});
  @override
  Widget build(BuildContext context) {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i < children.length - 1) {
        out.add(Divider(height: 1, color: context.line));
      }
    }
    return Column(children: out);
  }
}

class PageTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const PageTitle(this.title, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          trailing == null ? const SizedBox.shrink() : trailing!,
        ]),
      );
}

class _Progress extends StatelessWidget {
  final double v;
  const _Progress(this.v);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
                value: v,
                minHeight: 3.5,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation(Colors.white)),
          ),
        ),
      );
}

/// Poster with an optional "continue watching" progress bar.
class ProgressOverlay extends StatelessWidget {
  final double value;
  const ProgressOverlay(this.value, {super.key});
  @override
  Widget build(BuildContext context) => _Progress(value);
}
