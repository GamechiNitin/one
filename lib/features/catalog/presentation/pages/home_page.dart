import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/state_views.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../assistant/presentation/widgets/assistant_card.dart';
import '../../domain/entities/catalog.dart';
import '../bloc/catalog_bloc.dart';
import '../widgets/catalog_widgets.dart';
import '../../../creators/presentation/bloc/creators_bloc.dart';
import '../../../marketplace/presentation/bloc/market_blocs.dart';
import '../../../marketplace/presentation/widgets/product_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        if (state.catalog.isEmpty) {
          return state.status == LoadStatus.failure
              ? ErrorView(
                  onRetry: () =>
                      context.read<CatalogBloc>().add(const CatalogRequested()))
              : const LoadingView();
        }
        final c = state.catalog;
        final creators = context.watch<CreatorsBloc>().state;
        final market = context.watch<MarketBloc>().state;
        final byId = creators.byId;
        return RefreshIndicator(
          onRefresh: () async =>
              context.read<CatalogBloc>().add(const CatalogRequested()),
          child:
              ListView(padding: const EdgeInsets.only(bottom: 100), children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const OneLogo(size: 26),
                    Row(children: [
                      IconBtn(
                          Icons.notifications_none,
                          () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(context.t('home.caughtUp')))),
                          badge: 2),
                      const SizedBox(width: 10),
                      const Avatar('N', AppColors.blue, size: 40),
                    ]),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Tap(
                onTap: () => context.go(Routes.explore),
                child: AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    Icon(Icons.search, size: 18, color: context.ink2),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(context.t('home.search'),
                            style: TextStyle(color: context.ink2, fontSize: 13),
                            overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Hero(items: c.byIds(const ['dunes', 'neon', 'spirit'])),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Quick(context.t('home.movies'), Icons.movie_outlined,
                        () => context.push(Routes.category('Movies'))),
                    _Quick(context.t('home.liveTv'), Icons.sensors,
                        () => context.push(Routes.live)),
                    _Quick(context.t('home.anime'), Icons.auto_awesome,
                        () => context.push(Routes.category('Anime'))),
                    _Quick(context.t('home.reels'), Icons.play_circle_outline,
                        () => context.push(Routes.reels())),
                    _Quick(context.t('home.events'), Icons.event_outlined,
                        () => context.push(Routes.events)),
                  ]),
            ),
            SectionHeader(context.t('home.services'),
                action: context.t('home.marketplace'), onAction: () {
              context.read<MarketBloc>().add(const MarketBrandChanged(null));
              context.go(Routes.shop);
            }),
            HRow(height: 112, children: [
              for (final k in const [
                'xfinity',
                'peacock',
                'sky',
                'nbc',
                'xumo'
              ])
                SizedBox(
                  width: 84,
                  child: AppCard(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                    onTap: () {
                      context.read<MarketBloc>().add(MarketBrandChanged(k));
                      context.go(Routes.shop);
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BrandBadge(k, size: 50),
                          const SizedBox(height: 8),
                          Text(brandName(k).replaceAll('Universal', ''),
                              style: const TextStyle(
                                  fontSize: 11.5, fontWeight: FontWeight.w600)),
                        ]),
                  ),
                ),
            ]),
            SectionHeader(context.t('home.continue')),
            HRow(height: 168, children: [
              for (final i in c.items.where((i) => i.progress > 0)) WideCard(i)
            ]),
            SectionHeader(context.t('home.trending'),
                action: context.t('common.seeAll'),
                onAction: () => context.push(Routes.category('Movies'))),
            HRow(height: 252, children: [
              for (final i in c
                  .byIds(const ['neon', 'monsoon', 'orbit', 'spirit', 'moons']))
                PosterCard(i)
            ]),
            SectionHeader(context.t('home.reelsForYou'),
                action: context.t('home.watch'),
                onAction: () => context.push(Routes.reels())),
            ReelStrip(
                reels: c.reels, nameOf: (w) => Publisher.of(w, byId).name),
            SectionHeader(context.t('home.liveNow')),
            if (c.item('match') != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Tap(
                  onTap: () => context.push(Routes.live),
                  child: Poster(c.item('match')!.art,
                      aspect: 16 / 8,
                      radius: 16,
                      child: Stack(fit: StackFit.expand, children: [
                        const Shade(),
                        const Positioned(
                            left: 12, top: 12, child: Pill('LIVE', live: true)),
                        const Positioned(
                            right: 12,
                            top: 12,
                            child: BrandBadge('sky', size: 34)),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 12,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(c.item('match')!.title,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800)),
                                Text(c.item('match')!.meta,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ]),
                        ),
                      ])),
                ),
              ),
            SectionHeader(context.t('home.shopForYou'),
                action: context.t('home.marketplace'),
                onAction: () => context.go(Routes.shop)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final id in const ['p2', 'p6'])
                  if (market.product(id) != null) ...[
                    Expanded(child: ProductTile(market.product(id)!)),
                    if (id == 'p2') const SizedBox(width: 12),
                  ],
              ]),
            ),
            const SizedBox(height: 18),
            const AssistantCard(),
            SectionHeader(context.t('home.creators'),
                action: context.t('home.creatorHub'),
                onAction: () => context.go(Routes.creators)),
            HRow(height: 130, children: [
              for (final cr in creators.data.creators) CreatorChip(cr)
            ]),
          ]),
        );
      },
    );
  }
}

class _Quick extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _Quick(this.label, this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => Tap(
        onTap: onTap,
        child: SizedBox(
          width: 58,
          child: Column(children: [
            Container(
              width: 52,
              height: 52,
              decoration:
                  BoxDecoration(color: context.card2, shape: BoxShape.circle),
              child: Icon(icon, color: context.acc, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}

class _Hero extends StatefulWidget {
  final List<Item> items;
  const _Hero({required this.items});
  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  final _pc = PageController();
  int _i = 0;
  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return Column(children: [
      SizedBox(
        height: context.isWide ? 380 : 290,
        child: PageView(
          controller: _pc,
          onPageChanged: (i) => setState(() => _i = i),
          children: [
            for (final it in items)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(fit: StackFit.expand, children: [
                    CustomPaint(painter: ArtPainter(it.art)),
                    const Shade(),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TagChip(context.t('home.featured'),
                                color: AppColors.blue),
                            const SizedBox(height: 8),
                            Text(it.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800)),
                            Text(it.sub,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12.5)),
                            const SizedBox(height: 12),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GBtn(context.t('home.watchNow'),
                                      small: true,
                                      onTap: () =>
                                          context.push(Routes.item(it.id))),
                                  Tap(
                                    radius: 22,
                                    onTap: () =>
                                        context.push(Routes.player(it.id)),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                          color: Colors.white24,
                                          shape: BoxShape.circle),
                                      child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white),
                                    ),
                                  ),
                                ]),
                          ]),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < items.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _i ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
                color: i == _i ? context.acc : context.line,
                borderRadius: BorderRadius.circular(3)),
          ),
      ]),
    ]);
  }
}
