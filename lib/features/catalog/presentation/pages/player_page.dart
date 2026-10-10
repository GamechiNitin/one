import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/catalog.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/player_cubit.dart';
import 'catalog_detail_pages.dart' show BackCircle;

/// Full-screen player. Phone: stacked. Wide screens and TV: video left, chat right.
class PlayerPage extends StatelessWidget with FullBleed {
  final String itemId;
  const PlayerPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final item = context.watch<CatalogBloc>().state.catalog.item(itemId);
    if (item == null) return const Scaffold(backgroundColor: Colors.black);
    return BlocProvider(
      create: (_) => sl<PlayerCubit>()..start(item),
      child: _PlayerView(item: item),
    );
  }
}

class _Float {
  final String emoji;
  final double right;
  final int key;
  _Float(this.emoji, this.right, this.key);
}

class _PlayerView extends StatefulWidget {
  final Item item;
  const _PlayerView({required this.item});
  @override
  State<_PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<_PlayerView> {
  final List<_Float> _floats = [];
  int _fk = 0;
  final _rnd = math.Random();

  void _react(String e) {
    final f = _Float(e, 16 + _rnd.nextDouble() * 60, _fk++);
    setState(() => _floats.add(f));
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _floats.remove(f));
    });
  }

  Widget _video() => Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: ArtPainter(widget.item.art)),
        const BackCircle(),
        if (widget.item.live) const Positioned(right: 14, top: 18, child: Pill('LIVE', live: true)),
        for (final f in _floats)
          Positioned(
            key: ValueKey(f.key),
            right: f.right,
            bottom: 10,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1500),
              builder: (_, v, __) => Transform.translate(offset: Offset(0, -120 * v), child: Opacity(opacity: 1 - v, child: Text(f.emoji, style: const TextStyle(fontSize: 26)))),
            ),
          ),
      ]);

  Widget _controls(PlayerState s) {
    final mm = (s.seconds ~/ 60).toString();
    final ss = (s.seconds.floor() % 60).toString().padLeft(2, '0');
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Tap(
            onTap: () => context.read<PlayerCubit>().togglePause(),
            child: Padding(padding: const EdgeInsets.all(4), child: Icon(s.paused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white, size: 30)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: s.progress, minHeight: 5, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Color(0xFF5C8BFF))),
            ),
          ),
          const SizedBox(width: 14),
          Text('$mm:$ss', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.item.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(widget.item.meta, style: const TextStyle(color: Colors.white60, fontSize: 12.5)),
          ]),
        ),
      ),
    ]);
  }

  Widget _side(PlayerState s) {
    if (!widget.item.live) return Padding(padding: const EdgeInsets.all(18), child: Text(widget.item.desc, style: const TextStyle(color: Colors.white70)));
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final m in s.chat)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '${m.split('|')[0]}  ', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.spectrum[m.length % 6])),
              TextSpan(text: m.split('|')[1], style: const TextStyle(color: Colors.white)),
            ])),
          ),
      ]),
    );
  }

  Widget _reacts() => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: Row(children: [
            for (final e in const ['\u{1F525}', '\u{1F602}', '\u2764\uFE0F', '\u{1F44F}'])
              Expanded(
                child: Tap(
                  onTap: () => _react(e),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(14)),
                    child: Text(e, style: const TextStyle(fontSize: 22)),
                  ),
                ),
              ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return BlocBuilder<PlayerCubit, PlayerState>(builder: (context, s) {
      if (!wide) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Column(children: [
            AspectRatio(aspectRatio: 16 / 10, child: _video()),
            _controls(s),
            Expanded(child: _side(s)),
            _reacts(),
          ]),
        );
      }
      return Scaffold(
        backgroundColor: Colors.black,
        body: Row(children: [
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Flexible(child: AspectRatio(aspectRatio: 16 / 9, child: _video())),
              _controls(s),
            ]),
          ),
          Container(width: 360, color: const Color(0xFF0B0F1E), child: Column(children: [Expanded(child: _side(s)), _reacts()])),
        ]),
      );
    });
  }
}
