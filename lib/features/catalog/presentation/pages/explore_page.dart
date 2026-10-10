import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/theme_ext.dart';
import '../bloc/catalog_bloc.dart';
import '../widgets/catalog_widgets.dart';
import '../../../creators/presentation/bloc/creators_bloc.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _ctl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogBloc>().state.catalog;
    final creators = context.watch<CreatorsBloc>().state;
    final q = _q.toLowerCase();
    final matches = catalog.items.where((i) => '${i.title} ${i.kind} ${i.desc}'.toLowerCase().contains(q)).toList();
    final people = creators.data.creators.where((c) => '${c.name} ${c.role}'.toLowerCase().contains(q)).toList();
    return ListView(padding: const EdgeInsets.only(bottom: 100), children: [
      PageTitle(context.t('explore.title'), trailing: IconBtn(Icons.auto_awesome, () => context.push(Routes.assistant()))),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
        child: TextField(
          controller: _ctl,
          onChanged: (v) => setState(() => _q = v),
          decoration: InputDecoration(
            hintText: context.t('explore.hint'),
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: context.card,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.line)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.line)),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: context.card2, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.explore, size: 16, color: context.acc),
                  const SizedBox(width: 6),
                  Text(context.t('explore.browse'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.acc)),
                ]),
              ),
            ),
            Expanded(
              child: Tap(
                onTap: () => context.push(Routes.reels()),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.transparent,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.play_arrow_rounded, size: 18, color: context.ink2),
                    const SizedBox(width: 6),
                    Text(context.t('home.reels'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.ink2)),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
      if (_q.isNotEmpty) ...[
        SectionHeader(context.t('explore.results')),
        if (people.isNotEmpty) HRow(height: 130, children: [for (final c in people) CreatorChip(c)]),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: matches.isEmpty && people.isEmpty
              ? AppCard(child: Column(children: [
                  Text(context.t('explore.noMatches'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(context.t('explore.noMatchesBody'), style: TextStyle(color: context.ink2)),
                ]))
              : Wrap(spacing: 12, runSpacing: 16, children: [for (final i in matches) PosterCard(i)]),
        ),
      ] else ...[
        SectionHeader(context.t('home.reels'), action: context.t('explore.watchAll'), onAction: () => context.push(Routes.reels())),
        ReelStrip(reels: catalog.reels, nameOf: (w) => Publisher.of(w, creators.byId).name),
        SectionHeader(context.t('explore.categories')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: GridView.count(
            crossAxisCount: context.cols(m: 3, t: 4, d: 6),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _Tile(context.t('home.movies'), Icons.movie_outlined, const Color(0xFF6D4AFF), const Color(0xFF9A7BFF), () => context.push(Routes.category('Movies'))),
              _Tile(context.t('explore.tvShows'), Icons.tv, const Color(0xFF2D8CFF), const Color(0xFF5AB0FF), () => context.push(Routes.category('TV Shows'))),
              _Tile(context.t('home.anime'), Icons.auto_awesome, const Color(0xFF7C93FF), const Color(0xFFAFC0FF), () => context.push(Routes.category('Anime'))),
              _Tile(context.t('home.liveTv'), Icons.sensors, const Color(0xFF3B5BFF), const Color(0xFF6C86FF), () => context.push(Routes.live)),
              _Tile(context.t('explore.sports'), Icons.sports_soccer, const Color(0xFF13B887), const Color(0xFF4AD8AA), () => context.push(Routes.eventsFiltered('Sports'))),
              _Tile(context.t('explore.music'), Icons.music_note, const Color(0xFFA55CF6), const Color(0xFFCB8CFF), () => context.push(Routes.eventsFiltered('Concerts'))),
            ],
          ),
        ),
        SectionHeader(context.t('explore.trending')),
        HRow(height: 252, children: [for (final i in catalog.byIds(const ['dunes', 'neon', 'spirit', 'orbit', 'signal'])) PosterCard(i)]),
        SectionHeader(context.t('explore.offers'), action: context.t('common.seeAll'), onAction: () => context.push(Routes.offers)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: AppCard(padding: const EdgeInsets.symmetric(horizontal: 14), child: Divided([for (final o in catalog.offers.take(3)) OfferRow(o)])),
        ),
      ],
    ]);
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color a, b;
  final VoidCallback onTap;
  const _Tile(this.label, this.icon, this.a, this.b, this.onTap);
  @override
  Widget build(BuildContext context) => Tap(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [a, b], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
          ]),
        ),
      );
}
