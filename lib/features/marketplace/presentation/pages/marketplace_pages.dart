import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/brands.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../../core/presentation/state_views.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart' show LoadStatus;
import '../../../catalog/presentation/pages/catalog_detail_pages.dart'
    show BackCircle;
import '../../domain/entities/product.dart';
import '../bloc/market_blocs.dart';
import '../widgets/product_tile.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';

final DateTime _dropEnd =
    DateTime.now().add(const Duration(hours: 2, minutes: 14, seconds: 9));

class _Countdown extends StatefulWidget {
  const _Countdown();
  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _t;
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var d = _dropEnd.difference(DateTime.now());
    if (d.isNegative) d = Duration.zero;
    String two(int n) => n.toString().padLeft(2, '0');
    return Text(
        '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}',
        style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()]));
  }
}

// ======================= Marketplace tab =======================
class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketBloc>().state;
    final cartCount = context.select((CartBloc b) => b.state.count);
    final list = market.visible;
    return ListView(padding: const EdgeInsets.only(bottom: 100), children: [
      PageTitle(context.t('market.title'),
          trailing: IconBtn(
              Icons.shopping_bag_outlined, () => context.push(Routes.cart),
              badge: cartCount)),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(context.t('market.subtitle'),
              style: TextStyle(color: context.ink2, fontSize: 12.5))),
      const SizedBox(height: 14),
      SizedBox(
        height: 84,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          children: [
            for (final k in const [
              '',
              'xfinity',
              'peacock',
              'sky',
              'nbc',
              'xumo'
            ])
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Tap(
                  onTap: () => context
                      .read<MarketBloc>()
                      .add(MarketBrandChanged(k.isEmpty ? null : k)),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: (market.brand ?? '') == k
                                  ? context.acc
                                  : Colors.transparent,
                              width: 2)),
                      child: k.isEmpty
                          ? Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: context.card2,
                                  borderRadius: BorderRadius.circular(13)),
                              child: Text(context.t('common.all'),
                                  style: TextStyle(
                                      color: context.acc,
                                      fontWeight: FontWeight.w800)))
                          : BrandBadge(k, size: 48),
                    ),
                    const SizedBox(height: 2),
                    Text(
                        k.isEmpty
                            ? context.t('common.all')
                            : brands[k]!.name.replaceAll('Universal', ''),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
        child: GradCard(
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TagChip(context.t('market.membersDrop')),
                    const SizedBox(height: 8),
                    const Text('Rhea tour hoodie',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800)),
                    Row(children: [
                      Text('${context.t('market.endsIn')} ',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12.5)),
                      const _Countdown()
                    ]),
                  ]),
            ),
            GBtn(context.t('market.add'),
                small: true,
                light: true,
                onTap: () =>
                    context.read<CartBloc>().add(const CartItemAdded('p2'))),
          ]),
        ),
      ),
      const SizedBox(height: 6),
      ChipRow(
        options: const [
          'All',
          'Merch',
          'Collectibles',
          'Devices',
          'Gift cards',
          'Experiences'
        ],
        selected: market.category,
        labelOf: (o) => context.t('market.cat.$o'),
        onSelect: (v) =>
            context.read<MarketBloc>().add(MarketCategoryChanged(v)),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
        child: market.status == LoadStatus.failure && market.products.isEmpty
            ? ErrorView(
                onRetry: () =>
                    context.read<MarketBloc>().add(const MarketRequested()))
            : market.status == LoadStatus.loading && market.products.isEmpty
                ? const LoadingView()
                : list.isEmpty
                    ? AppCard(
                        child: Column(children: [
                        Text(context.t('market.empty'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 10),
                        GBtn(context.t('market.showAll'),
                            small: true,
                            onTap: () => context
                                .read<MarketBloc>()
                                .add(const MarketBrandChanged(null))),
                      ]))
                    : GridView.count(
                        crossAxisCount: context.cols(m: 2, t: 3, d: 4),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                        childAspectRatio: .66,
                        children: [for (final p in list) ProductTile(p)],
                      ),
      ),
    ]);
  }
}

// ======================= Product detail =======================
class ProductPage extends StatelessWidget {
  final String productId;
  const ProductPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MarketBloc>().state.product(productId);
    if (p == null) return Scaffold(appBar: AppBar(), body: const LoadingView());
    final paid = context.select((WalletBloc b) => b.state.wallet.isPaid);
    final price = p.unitPrice(planIsPaid: paid);
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: ListView(padding: EdgeInsets.zero, children: [
            SizedBox(
                height: 320,
                child: Stack(
                    fit: StackFit.expand,
                    children: [productArt(p), const BackCircle()])),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      BrandBadge(p.brand, size: 34),
                      const SizedBox(width: 10),
                      Text(
                          context.t('product.soldBy', [
                            brands[p.brand]!.name +
                                (p.brand == 'one' ? ' Originals' : '')
                          ]),
                          style: TextStyle(color: context.ink2, fontSize: 12.5))
                    ]),
                    const SizedBox(height: 10),
                    Text(p.title,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(rs(price),
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 10),
                      if (p.member && paid) ...[
                        Text(rs(p.price),
                            style: TextStyle(
                                color: context.ink2,
                                decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 8),
                        Pill(context.t('product.memberPrice'))
                      ] else if (p.member)
                        Pill(context.t('product.plusOff')),
                    ]),
                    const SizedBox(height: 14),
                    Text(p.desc,
                        style: TextStyle(color: context.ink2, fontSize: 14)),
                    const SizedBox(height: 16),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Divided([
                        ListRow(
                            leading: Icon(Icons.local_shipping_outlined,
                                color: context.ink2),
                            title: p.cat == 'Gift cards'
                                ? context.t('product.instant')
                                : context.t('product.delivery')),
                        ListRow(
                            leading:
                                Icon(Icons.star_outline, color: context.ink2),
                            title: context
                                .t('product.earn', [(price / 20).round()])),
                        ListRow(
                            leading: Icon(Icons.verified_user_outlined,
                                color: context.ink2),
                            title: context.t(
                                'product.fulfilled', [brands[p.brand]!.name])),
                      ]),
                    ),
                  ]),
            ),
          ]),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
              18, 12, 18, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
              color: context.card,
              border: Border(top: BorderSide(color: context.line))),
          child: Row(children: [
            Expanded(
                child: GBtn(context.t('product.addToCart'),
                    outline: true,
                    expand: true,
                    onTap: () =>
                        context.read<CartBloc>().add(CartItemAdded(p.id)))),
            const SizedBox(width: 12),
            Expanded(
              child: GBtn(context.t('product.buyNow'), expand: true, onTap: () {
                context.read<CartBloc>().add(CartItemAdded(p.id, silent: true));
                context.pushReplacement(Routes.cart);
              }),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ======================= Cart =======================
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartBloc>().state;
    final market = context.watch<MarketBloc>().state;
    final wallet = context.watch<WalletBloc>().state.wallet;
    final summary = CartSummary.compute(cart.lines, market.products,
        planIsPaid: wallet.isPaid);
    return BlocListener<CartBloc, CartState>(
      listenWhen: (a, b) => a.checkout != b.checkout,
      listener: (context, s) {
        if (s.checkout == CheckoutStatus.success && context.canPop()) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.t('cart.title'))),
        body: summary.lines.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(18),
                child: AppCard(
                    child: Column(children: [
                  Text(context.t('cart.empty'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(context.t('cart.emptyBody'),
                      style: TextStyle(color: context.ink2)),
                  const SizedBox(height: 12),
                  GBtn(context.t('cart.browse'),
                      small: true,
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go(Routes.shop)),
                ])),
              )
            : ListView(padding: const EdgeInsets.all(18), children: [
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Divided([
                    for (final l in summary.lines)
                      ListRow(
                        leading: SizedBox(
                            width: 54,
                            height: 54,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: productArt(l.product, badgeSize: 40))),
                        title: l.product.title,
                        sub: '${rs(l.unit)} · ${brands[l.product.brand]!.name}',
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          _StepBtn(
                              Icons.remove,
                              () => context
                                  .read<CartBloc>()
                                  .add(CartItemRemoved(l.product.id))),
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('${l.qty}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800))),
                          _StepBtn(
                              Icons.add,
                              () => context.read<CartBloc>().add(
                                  CartItemAdded(l.product.id, silent: true))),
                        ]),
                      ),
                  ]),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.t('cart.subtotal')),
                          Text(rs(summary.full),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700))
                        ]),
                    if (summary.savings > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.t('cart.savings', [wallet.plan])),
                              Text('\u2212${rs(summary.savings)}',
                                  style: const TextStyle(
                                      color: AppColors.ok,
                                      fontWeight: FontWeight.w700))
                            ]),
                      ),
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.t('cart.delivery')),
                              Text(context.t('cart.free'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700))
                            ])),
                    Divider(height: 24, color: context.line),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.t('events.total'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                          Text(rs(summary.total),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 18))
                        ]),
                    const SizedBox(height: 8),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            context.t('cart.paidFrom', [summary.points]),
                            style:
                                TextStyle(fontSize: 12, color: context.ink2))),
                    const SizedBox(height: 12),
                    GBtn(context.t('checkout.pay', [rs(summary.total)]),
                        expand: true,
                        onTap: () => context
                            .read<CartBloc>()
                            .add(const CartCheckoutRequested())),
                    if (wallet.balance < summary.total)
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(context.t('msg.lowBalance'),
                              style: const TextStyle(
                                  color: AppColors.live, fontSize: 12.5))),
                  ]),
                ),
              ]),
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => Tap(
        radius: 16,
        onTap: onTap,
        child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: context.card,
                shape: BoxShape.circle,
                border: Border.all(color: context.line)),
            child: Icon(icon, size: 16)),
      );
}
