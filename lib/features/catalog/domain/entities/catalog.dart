import 'package:equatable/equatable.dart';
import '../../../../core/domain/art.dart';

class Item extends Equatable {
  final String id, kind, title, sub, meta, desc;
  final Art art;
  final bool live;
  final double progress;
  final String? creator;
  final int price;
  final String? on;
  final List<String> cast;
  const Item({
    required this.id,
    required this.kind,
    required this.title,
    required this.sub,
    required this.meta,
    required this.desc,
    required this.art,
    this.live = false,
    this.progress = 0,
    this.creator,
    this.price = 0,
    this.on,
    this.cast = const [],
  });

  bool get isPaid => price > 0;
  @override
  List<Object?> get props => [id];
}

class Reel extends Equatable {
  final String who, caption, tags, likes, comments, ctaLabel, ctaType, ctaId, ctaIcon;
  final Art art;
  const Reel({
    required this.who,
    required this.art,
    required this.caption,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.ctaLabel,
    required this.ctaType,
    required this.ctaId,
    required this.ctaIcon,
  });
  @override
  List<Object?> get props => [who, ctaId];
}

class Offer extends Equatable {
  final String id, brandText, title, sub, cat;
  final String? brand;
  final int? color;
  const Offer({required this.id, required this.brandText, required this.title, required this.sub, required this.cat, this.brand, this.color});
  @override
  List<Object?> get props => [id];
}

class Channel extends Equatable {
  final int number;
  final String name, itemId, time, cat, brand;
  const Channel({required this.number, required this.name, required this.itemId, required this.time, required this.cat, required this.brand});
  @override
  List<Object?> get props => [number];
}

class Catalog extends Equatable {
  final List<Item> items;
  final List<Reel> reels;
  final List<Offer> offers;
  final List<Channel> channels;
  const Catalog({this.items = const [], this.reels = const [], this.offers = const [], this.channels = const []});

  bool get isEmpty => items.isEmpty;
  Item? item(String id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<Item> byIds(List<String> ids) => [for (final id in ids) if (item(id) != null) item(id)!];

  @override
  List<Object?> get props => [items, reels, offers, channels];
}

class Library extends Equatable {
  final Set<String> myList;
  final Set<String> owned;
  final Set<String> watched;
  final Set<String> savedOffers;
  const Library({this.myList = const {}, this.owned = const {}, this.watched = const {}, this.savedOffers = const {}});

  Library copyWith({Set<String>? myList, Set<String>? owned, Set<String>? watched, Set<String>? savedOffers}) => Library(
        myList: myList ?? this.myList,
        owned: owned ?? this.owned,
        watched: watched ?? this.watched,
        savedOffers: savedOffers ?? this.savedOffers,
      );

  @override
  List<Object?> get props => [myList, owned, watched, savedOffers];
}
