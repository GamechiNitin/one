import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/icon_keys.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/catalog.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/reels_cubit.dart';
import '../widgets/catalog_widgets.dart';
import '../../../creators/presentation/bloc/creators_bloc.dart';
import 'dart:math' as math;

/// Vertical, swipeable reels. Always a 9:16 column, centered on wide screens.
class ReelsPage extends StatelessWidget with FullBleed {
  final int start;
  const ReelsPage({super.key, this.start = 0});

  @override
  Widget build(BuildContext context) {
    final reels = context.watch<CatalogBloc>().state.catalog.reels;
    if (reels.isEmpty) return const Scaffold(backgroundColor: Colors.black);
    return BlocProvider(
      create: (_) => sl<ReelsCubit>()..open(start.clamp(0, reels.length - 1)),
      child: _ReelsView(reels: reels, start: start.clamp(0, reels.length - 1)),
    );
  }
}

class _ReelsView extends StatefulWidget {
  final List<Reel> reels;
  final int start;
  const _ReelsView({required this.reels, required this.start});
  @override
  State<_ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<_ReelsView> {
  late final PageController _pc = PageController(initialPage: widget.start);
  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = context.watch<ReelsCubit>().state;
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (ctx, box) {
        final w = box.maxWidth > 700 ? math.min(box.maxWidth, box.maxHeight * 9 / 16) : box.maxWidth;
        return Center(
          child: SizedBox(
            width: w,
            child: Stack(children: [
              PageView.builder(
                controller: _pc,
                scrollDirection: Axis.vertical,
                itemCount: widget.reels.length,
                onPageChanged: context.read<ReelsCubit>().onPageChanged,
                itemBuilder: (_, i) => _ReelItem(reel: widget.reels[i], active: i == current),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Tap(
                      radius: 20,
                      onTap: () => context.canPop() ? context.pop() : context.go(Routes.home),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                    Expanded(child: Center(child: Text(context.t('home.reels'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)))),
                    const SizedBox(width: 40),
                  ]),
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }
}

class _ReelItem extends StatefulWidget {
  final Reel reel;
  final bool active;
  const _ReelItem({required this.reel, required this.active});
  @override
  State<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<_ReelItem> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 9));
  bool _liked = false;
  bool _heart = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(_ReelItem old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) _c.repeat();
    if (!widget.active) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _doubleTap() {
    setState(() {
      _liked = true;
      _heart = true;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _heart = false);
    });
  }

  void _cta() {
    final r = widget.reel;
    switch (r.ctaType) {
      case 'event':
        context.push(Routes.event(r.ctaId));
      case 'item':
        context.push(Routes.item(r.ctaId));
      default:
        context.push(Routes.product(r.ctaId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reel;
    final creators = context.watch<CreatorsBloc>().state;
    final pub = Publisher.of(r.who, creators.byId);
    final following = creators.prefs.following.contains(r.who);
    final bottom = MediaQuery.of(context).padding.bottom;

    Widget side(IconData i, String label, VoidCallback f, {Color? bg}) => Tap(
          radius: 24,
          onTap: f,
          child: Column(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: bg ?? Colors.white24, shape: BoxShape.circle), child: Icon(i, color: Colors.white, size: 24)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        );

    return GestureDetector(
      onDoubleTap: _doubleTap,
      child: Stack(fit: StackFit.expand, children: [
        ClipRect(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, child) => Transform.scale(scale: 1 + .1 * _c.value, child: child),
            child: CustomPaint(painter: ArtPainter(r.art)),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xE0000000), Color(0x00000000), Color(0x00000000), Color(0x66000000)],
              stops: [0, .5, .8, 1],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => LinearProgressIndicator(value: _c.value, minHeight: 3, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white)),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 92 + bottom,
          child: Column(children: [
            side(Icons.favorite, r.likes, () => setState(() => _liked = !_liked), bg: _liked ? AppColors.live : null),
            const SizedBox(height: 18),
            side(Icons.chat_bubble_outline, r.comments, () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('reels.comments'))))),
            const SizedBox(height: 18),
            side(Icons.ios_share, context.t('reels.share'), () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('reels.linkCopied'))))),
          ]),
        ),
        Positioned(
          left: 16,
          right: 78,
          bottom: 84 + bottom,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              if (pub.brand != null) BrandBadge(pub.brand!, size: 30) else Avatar(pub.name, pub.color, size: 30),
              const SizedBox(width: 8),
              Flexible(child: Text(pub.name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
              if (pub.verified) const Verified(),
              const SizedBox(width: 8),
              Tap(
                radius: 999,
                onTap: () => context.read<CreatorsBloc>().add(FollowToggled(r.who)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(999)),
                  child: Text(following ? context.t('common.following') : context.t('common.follow'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text(r.caption, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(r.tags, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
          ]),
        ),
        Positioned(left: 16, right: 16, bottom: 20 + bottom, child: GBtn(r.ctaLabel, icon: iconFor(r.ctaIcon), expand: true, onTap: _cta)),
        IgnorePointer(
          child: Center(
            child: AnimatedOpacity(
              opacity: _heart ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedScale(scale: _heart ? 1.2 : .4, duration: const Duration(milliseconds: 300), child: const Icon(Icons.favorite, size: 96, color: AppColors.live)),
            ),
          ),
        ),
      ]),
    );
  }
}
