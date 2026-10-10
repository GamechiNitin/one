import '../../../../core/domain/art.dart';
import '../../domain/entities/catalog.dart';

class CatalogMapper {
  CatalogMapper._();

  static Item item(Map<String, dynamic> j) => Item(
        id: j['id'] as String,
        kind: j['kind'] as String,
        title: j['title'] as String,
        sub: j['sub'] as String,
        meta: j['meta'] as String,
        desc: j['desc'] as String,
        art: Art.fromJson((j['art'] as Map).cast<String, dynamic>()),
        live: j['live'] == true,
        progress: (j['progress'] as num?)?.toDouble() ?? 0,
        creator: j['creator'] as String?,
        price: (j['price'] as num?)?.toInt() ?? 0,
        on: j['on'] as String?,
        cast: ((j['cast'] as List?) ?? const []).map((e) => e as String).toList(),
      );

  static Reel reel(Map<String, dynamic> j) => Reel(
        who: j['who'] as String,
        art: Art.fromJson((j['art'] as Map).cast<String, dynamic>()),
        caption: j['caption'] as String,
        tags: j['tags'] as String,
        likes: j['likes'] as String,
        comments: j['comments'] as String,
        ctaLabel: j['ctaLabel'] as String,
        ctaType: j['ctaType'] as String,
        ctaId: j['ctaId'] as String,
        ctaIcon: j['ctaIcon'] as String,
      );

  static Offer offer(Map<String, dynamic> j) => Offer(
        id: j['id'] as String,
        brandText: j['brandText'] as String,
        title: j['title'] as String,
        sub: j['sub'] as String,
        cat: j['cat'] as String,
        brand: j['brand'] as String?,
        color: (j['color'] as num?)?.toInt(),
      );

  static Channel channel(Map<String, dynamic> j) => Channel(
        number: (j['number'] as num).toInt(),
        name: j['name'] as String,
        itemId: j['itemId'] as String,
        time: j['time'] as String,
        cat: j['cat'] as String,
        brand: j['brand'] as String,
      );

  static List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) f) =>
      ((raw as List?) ?? const []).map((e) => f((e as Map).cast<String, dynamic>())).toList();

  static Catalog catalog(Map<String, dynamic> j) => Catalog(
        items: _list(j['items'], item),
        reels: _list(j['reels'], reel),
        offers: _list(j['offers'], offer),
        channels: _list(j['channels'], channel),
      );
}
