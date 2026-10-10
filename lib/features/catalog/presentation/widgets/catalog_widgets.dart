import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/brands.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../domain/entities/catalog.dart';
import '../bloc/library_cubit.dart';
import '../../../creators/domain/entities/creator.dart';

class PosterCard extends StatelessWidget {
  final Item item;
  const PosterCard(this.item, {super.key});
  @override
  Widget build(BuildContext context) => Tap(
        onTap: () => context.push(Routes.item(item.id)),
        child: SizedBox(
          width: 118,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Poster(item.art, child: item.progress > 0 ? ProgressOverlay(item.progress) : null),
            const SizedBox(height: 8),
            Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(item.sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: context.ink2)),
          ]),
        ),
      );
}

class WideCard extends StatelessWidget {
  final Item item;
  const WideCard(this.item, {super.key});
  @override
  Widget build(BuildContext context) => Tap(
        onTap: () => context.push(Routes.item(item.id)),
        child: SizedBox(
          width: 168,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Poster(item.art, aspect: 16 / 10, child: item.progress > 0 ? ProgressOverlay(item.progress) : null),
            const SizedBox(height: 8),
            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(item.sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: context.ink2)),
          ]),
        ),
      );
}

class ReelStrip extends StatelessWidget {
  final List<Reel> reels;
  final String Function(String who) nameOf;
  const ReelStrip({super.key, required this.reels, required this.nameOf});
  @override
  Widget build(BuildContext context) => HRow(height: 200, children: [
        for (var i = 0; i < reels.length; i++)
          Tap(
            onTap: () => context.push(Routes.reels(start: i)),
            child: SizedBox(
              width: 112,
              child: Poster(reels[i].art, aspect: 9 / 16, radius: 14, child: Stack(fit: StackFit.expand, children: [
                const Shade(strength: .8),
                Positioned(left: 8, top: 8, child: TagChip('\u25B6 ${reels[i].likes}', color: Colors.black54)),
                Positioned(left: 8, right: 8, bottom: 8, child: Text(nameOf(reels[i].who), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
              ])),
            ),
          ),
      ]);
}

class OfferRow extends StatelessWidget {
  final Offer offer;
  const OfferRow(this.offer, {super.key});
  @override
  Widget build(BuildContext context) {
    final saved = context.select((LibraryCubit c) => c.state.savedOffers.contains(offer.id));
    return ListRow(
      leading: offer.brand != null
          ? BrandBadge(offer.brand!, size: 44)
          : Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Color(offer.color ?? 0xFF1A2B6B), borderRadius: BorderRadius.circular(12)),
              child: Text(offer.brandText[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ),
      title: offer.title,
      sub: '${offer.brandText} · ${offer.sub}',
      trailing: GBtn(saved ? context.t('offers.added') : context.t('offers.get'), small: true, outline: saved, onTap: () => context.read<LibraryCubit>().saveOffer(offer.id)),
    );
  }
}

class CreatorChip extends StatelessWidget {
  final Creator creator;
  const CreatorChip(this.creator, {super.key});
  @override
  Widget build(BuildContext context) => Tap(
        onTap: () => context.push(Routes.creator(creator.id)),
        child: SizedBox(
          width: 92,
          child: Column(children: [
            Avatar(creator.name, Color(creator.color), size: 76),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Flexible(child: Text(creator.name.split(' ').first, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
              const Verified(),
            ]),
            Text(creator.followers, style: TextStyle(fontSize: 11.5, color: context.ink2)),
          ]),
        ),
      );
}

/// Name and brand for a reel publisher: creators come from the creators feature,
/// partner accounts (sky, peacock) and ONE Originals are built in.
class Publisher {
  final String name;
  final Color color;
  final String? brand;
  final bool verified;
  const Publisher(this.name, this.color, {this.brand, this.verified = true});

  static Publisher of(String who, Map<String, Creator> creators) {
    switch (who) {
      case 'one':
        return const Publisher('ONE Originals', AppColors.blue);
      case 'sky':
        return const Publisher('Sky Sports', Color(0xFF1F3FD8), brand: 'sky', verified: false);
      case 'peacock':
        return const Publisher('Peacock', Color(0xFF111111), brand: 'peacock', verified: false);
    }
    final c = creators[who];
    return c == null ? Publisher(who, AppColors.blue) : Publisher(c.name, Color(c.color));
  }
}

String brandName(String key) => brands[key]?.name ?? key;
