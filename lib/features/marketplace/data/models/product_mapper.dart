import '../../../../core/domain/art.dart';
import '../../domain/entities/product.dart';

class ProductMapper {
  ProductMapper._();
  static List<Product> list(List raw) => raw.map((e) {
        final j = (e as Map).cast<String, dynamic>();
        return Product(
          id: j['id'] as String,
          title: j['title'] as String,
          price: (j['price'] as num).toInt(),
          cat: j['cat'] as String,
          brand: j['brand'] as String,
          desc: j['desc'] as String,
          art: j['art'] == null ? null : Art.fromJson((j['art'] as Map).cast<String, dynamic>()),
          bg: (j['bg'] as num?)?.toInt(),
          member: j['member'] == true,
          tag: j['tag'] as String?,
        );
      }).toList();
}
