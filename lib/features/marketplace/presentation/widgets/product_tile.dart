import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';
import '../bloc/market_blocs.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';

/// Product artwork: generated poster art, or a brand tile for partner products.
Widget productArt(Product p, {double badgeSize = 86}) {
  if (p.art != null) return CustomPaint(painter: ArtPainter(p.art!));
  return Container(
      color: Color(p.bg ?? 0xFFFFFFFF),
      alignment: Alignment.center,
      child: BrandBadge(p.brand, size: badgeSize));
}

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    final paid = context.select((WalletBloc b) => b.state.wallet.isPaid);
    final qty = context.select((CartBloc b) => b.state.lines[product.id] ?? 0);
    final p = product;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Tap(
        onTap: () => context.push(Routes.product(p.id)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(fit: StackFit.expand, children: [
              productArt(p),
              if (p.tag != null)
                Positioned(
                    left: 8,
                    top: 8,
                    child: TagChip(p.tag!, color: Colors.black54)),
              if (p.art != null)
                Positioned(
                    left: 8, bottom: 8, child: BrandBadge(p.brand, size: 28)),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Row(children: [
              Text(rs(p.unitPrice(planIsPaid: paid)),
                  style: TextStyle(fontSize: 12, color: context.ink2)),
              if (p.member && paid) ...[
                const SizedBox(width: 6),
                Text(rs(p.price),
                    style: TextStyle(
                        fontSize: 11,
                        color: context.ink2,
                        decoration: TextDecoration.lineThrough)),
              ],
            ]),
          ]),
        ),
        Tap(
          radius: 17,
          onTap: () => context.read<CartBloc>().add(CartItemAdded(p.id)),
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
                gradient: AppColors.gradient, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: qty > 0
                ? Text('$qty',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12))
                : const Icon(Icons.add, color: Colors.white, size: 18),
          ),
        ),
      ]),
    ]);
  }
}
