import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/catalog.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/library_cubit.dart';
import '../widgets/catalog_widgets.dart';
import '../../../creators/presentation/bloc/creators_bloc.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';

class BackCircle extends StatelessWidget {
  const BackCircle({super.key});
  @override
  Widget build(BuildContext context) => Positioned(
        left: 14,
        top: 14,
        child: Tap(
          radius: 20,
          onTap: () =>
              context.canPop() ? context.pop() : context.go(Routes.home),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: Colors.black45, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
      );
}

// ======================= Category grid =======================
class CategoryPage extends StatelessWidget {
  final String category;
  const CategoryPage({super.key, required this.category});

  bool _match(Item i) {
    switch (category) {
      case 'Movies':
        return i.kind == 'Movie' || i.kind == 'Short film';
      case 'TV Shows':
        return i.kind == 'Show';
      case 'Anime':
        return i.kind == 'Anime';
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items =
        context.watch<CatalogBloc>().state.catalog.items.where(_match).toList();
    return Scaffold(
      appBar: AppBar(
          title: Text(category == 'Movies'
              ? context.t('home.movies')
              : (category == 'Anime'
                  ? context.t('home.anime')
                  : context.t('explore.tvShows')))),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Wrap(
            spacing: 12,
            runSpacing: 16,
            children: [for (final i in items) PosterCard(i)])
      ]),
    );
  }
}

// ======================= Item detail =======================
class ItemPage extends StatefulWidget {
  final String itemId;
  const ItemPage({super.key, required this.itemId});
  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  String _tab = 'about';
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogBloc>().state.catalog;
    final item = catalog.item(widget.itemId);
    if (item == null) return Scaffold(appBar: AppBar(), body: const SizedBox());
    final lib = context.watch<LibraryCubit>().state;
    final plan = context.select((WalletBloc b) => b.state.wallet);
    final creator = item.creator == null
        ? null
        : context.watch<CreatorsBloc>().state.byId[item.creator];
    final owned = lib.owned.contains(item.id);
    final inList = lib.myList.contains(item.id);
    return Scaffold(
      body: ListView(padding: EdgeInsets.zero, children: [
        SizedBox(
          height: 360,
          child: Stack(fit: StackFit.expand, children: [
            CustomPaint(painter: ArtPainter(item.art)),
            const Shade(),
            const BackCircle(),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    item.live
                        ? const Pill('LIVE', live: true)
                        : TagChip(item.kind),
                    const SizedBox(height: 8),
                    Text(item.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                    Text(item.meta,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12.5)),
                    const SizedBox(height: 12),
                    Row(children: [
                      GBtn(
                          item.isPaid && !owned
                              ? context.t('item.trailer')
                              : context.t('home.watchNow'),
                          icon: Icons.play_arrow_rounded,
                          onTap: () => context.push(Routes.player(item.id))),
                      const SizedBox(width: 10),
                      if (item.isPaid && !owned)
                        GBtn(context.t('item.unlock', [rs(item.price)]),
                            outline: true,
                            onTap: () =>
                                context.read<LibraryCubit>().unlock(item))
                      else
                        GBtn(
                            inList
                                ? context.t('item.inList')
                                : context.t('item.myList'),
                            outline: true,
                            icon: inList ? Icons.check : Icons.add,
                            onTap: () => context
                                .read<LibraryCubit>()
                                .toggleMyList(item.id)),
                    ]),
                  ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(children: [
            for (final t in const ['about', 'cast', 'similar'])
              Expanded(
                child: Tap(
                  onTap: () => setState(() => _tab = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: _tab == t ? context.acc : context.line,
                                width: 2.5))),
                    child: Text(context.t('item.$t'),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _tab == t ? context.acc : context.ink2)),
                  ),
                ),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          child: switch (_tab) {
            'about' =>
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.desc,
                    style: TextStyle(color: context.ink2, fontSize: 14)),
                if (item.on != null) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    child: Row(children: [
                      BrandBadge(item.on!, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  context.t('item.availableOn',
                                      [brandName(item.on!)]),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(
                                  plan.isPaid
                                      ? context.t('item.included', [plan.plan])
                                      : context.t('item.upgradeAds'),
                                  style: TextStyle(
                                      fontSize: 12, color: context.ink2)),
                            ]),
                      ),
                    ]),
                  ),
                ],
                if (creator != null) ...[
                  const SizedBox(height: 12),
                  AppCard(
                    onTap: () => context.push(Routes.creator(creator.id)),
                    child: Row(children: [
                      Avatar(creator.name, Color(creator.color)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(creator.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                const Verified()
                              ]),
                              Text('${creator.role} · ${creator.followers}',
                                  style: TextStyle(
                                      fontSize: 12, color: context.ink2)),
                            ]),
                      ),
                      const Icon(Icons.chevron_right),
                    ]),
                  ),
                ],
              ]),
            'cast' => AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Divided([
                  for (var k = 0; k < item.cast.length; k++)
                    ListRow(
                        leading: Avatar(
                            item.cast[k], AppColors.spectrum[(k * 2 + 1) % 6]),
                        title: item.cast[k])
                ]),
              ),
            _ => Wrap(spacing: 12, runSpacing: 16, children: [
                for (final o in catalog.items
                    .where((x) => x.id != item.id && x.kind == item.kind)
                    .take(4))
                  PosterCard(o),
              ]),
          },
        ),
        SectionHeader(context.t('home.trending')),
        HRow(height: 252, children: [
          for (final i
              in catalog.byIds(const ['neon', 'monsoon', 'orbit', 'moons']))
            if (i.id != item.id) PosterCard(i)
        ]),
        const SizedBox(height: 30),
      ]),
    );
  }
}

// ======================= Live TV =======================
class LiveTvPage extends StatefulWidget {
  const LiveTvPage({super.key});
  @override
  State<LiveTvPage> createState() => _LiveTvPageState();
}

class _LiveTvPageState extends State<LiveTvPage> {
  String _filter = 'All';
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogBloc>().state.catalog;
    final hero = catalog.item('match');
    final list = catalog.channels
        .where((c) => _filter == 'All' || c.cat == _filter)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.t('home.liveTv'))),
      body: ListView(children: [
        ChipRow(
            options: const ['All', 'Sports', 'News', 'Movies', 'Kids'],
            selected: _filter,
            labelOf: (o) => context.t('live.$o'),
            onSelect: (v) => setState(() => _filter = v)),
        if (hero != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Poster(hero.art,
                aspect: 16 / 9,
                radius: 18,
                child: Stack(fit: StackFit.expand, children: [
                  const Shade(),
                  const Positioned(
                      left: 12, top: 12, child: Pill('LIVE', live: true)),
                  const Positioned(
                      right: 12, top: 12, child: BrandBadge('sky', size: 36)),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 12,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(hero.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          Text(hero.meta,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 8),
                          GBtn(context.t('live.watchLive'),
                              small: true,
                              onTap: () =>
                                  context.push(Routes.player(hero.id))),
                        ]),
                  ),
                ])),
          ),
        SectionHeader(context.t('live.guide')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Divided([
              for (final c in list)
                ListRow(
                  leading: BrandBadge(c.brand, size: 46),
                  title: catalog.item(c.itemId)?.title ?? c.name,
                  sub: '${c.number} · ${c.name}\n${c.time}',
                  trailing: c.cat == 'Sports'
                      ? const Pill('LIVE', live: true)
                      : const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.player(c.itemId)),
                ),
            ]),
          ),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }
}

// ======================= Offers =======================
class OffersPage extends StatefulWidget {
  const OffersPage({super.key});
  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  String _filter = 'All';
  @override
  Widget build(BuildContext context) {
    final offers = context
        .watch<CatalogBloc>()
        .state
        .catalog
        .offers
        .where((o) => _filter == 'All' || o.cat == _filter)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.t('offers.title'))),
      body: ListView(children: [
        ChipRow(
            options: const ['All', 'Movies', 'Sports', 'Shopping', 'Food'],
            selected: _filter,
            labelOf: (o) => context.t('offers.cat.$o'),
            onSelect: (v) => setState(() => _filter = v)),
        Padding(
          padding: const EdgeInsets.all(18),
          child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Divided([for (final o in offers) OfferRow(o)])),
        ),
      ]),
    );
  }
}
