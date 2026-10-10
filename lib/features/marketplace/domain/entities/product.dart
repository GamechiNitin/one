import 'package:equatable/equatable.dart';
import '../../../../core/domain/art.dart';

class Product extends Equatable {
  final String id, title, cat, brand, desc;
  final int price;
  final Art? art;
  final int? bg;
  final bool member;
  final String? tag;
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.cat,
    required this.brand,
    required this.desc,
    this.art,
    this.bg,
    this.member = false,
    this.tag,
  });

  /// Member items are 10% off for paid ONE plans.
  int unitPrice({required bool planIsPaid}) => (member && planIsPaid) ? (price * .9).round() : price;

  @override
  List<Object?> get props => [id];
}

class CartLine extends Equatable {
  final Product product;
  final int qty;
  final int unit;
  const CartLine(this.product, this.qty, this.unit);
  @override
  List<Object?> get props => [product, qty, unit];
}

class CartSummary extends Equatable {
  final List<CartLine> lines;
  final int full, total;
  const CartSummary(this.lines, this.full, this.total);

  int get savings => full - total;
  int get points => (total / 20).round();
  int get count => lines.fold(0, (a, l) => a + l.qty);

  factory CartSummary.compute(Map<String, int> cart, List<Product> products, {required bool planIsPaid}) {
    final byId = {for (final p in products) p.id: p};
    final lines = <CartLine>[];
    var full = 0, total = 0;
    cart.forEach((id, qty) {
      final p = byId[id];
      if (p == null || qty <= 0) return;
      final unit = p.unitPrice(planIsPaid: planIsPaid);
      lines.add(CartLine(p, qty, unit));
      full += p.price * qty;
      total += unit * qty;
    });
    return CartSummary(lines, full, total);
  }

  @override
  List<Object?> get props => [lines, full, total];
}
