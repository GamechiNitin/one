import 'package:flutter/material.dart';
import '../../../../core/presentation/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/icon_keys.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../bloc/wallet_bloc.dart';

// ======================= Rewards tab =======================
class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});
  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  String _tab = 'earn';
  @override
  Widget build(BuildContext context) {
    final state = context.watch<WalletBloc>().state;
    final w = state.wallet;
    final bloc = context.read<WalletBloc>();
    return ListView(padding: const EdgeInsets.only(bottom: 100), children: [
      PageTitle(context.t('rewards.title')),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
        child: GradCard(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.t('rewards.totalPoints'), style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
              const SizedBox(height: 6),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(nf(w.points), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800, height: 1)),
                const SizedBox(width: 6),
                const Text('PTS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 6),
              Text(context.t('rewards.level', [w.level]), style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
            ]),
            GBtn(context.t('rewards.redeem'), small: true, light: true, onTap: () => setState(() => _tab = 'redeem')),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
        child: AppCard(
          child: Row(children: [
            const IconTile(Icons.account_balance_wallet_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(context.t('wallet.title'), style: TextStyle(fontSize: 12, color: context.ink2)),
                Text(rs(w.balance), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ]),
            ),
            GBtn(context.t('rewards.addMoney', [rs(1000)]), small: true, outline: true, onTap: () => bloc.add(const WalletTopUpRequested())),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
        child: Row(children: [
          for (final t in const ['earn', 'redeem'])
            Expanded(
              child: Tap(
                onTap: () => setState(() => _tab = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _tab == t ? context.acc : context.line, width: 2.5))),
                  child: Text(context.t('rewards.$t'), style: TextStyle(fontWeight: FontWeight.w700, color: _tab == t ? context.acc : context.ink2)),
                ),
              ),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: _tab == 'earn'
              ? Divided([
                  ListRow(leading: const IconTile(Icons.movie_outlined), title: context.t('rewards.watchSeries'), sub: context.t('rewards.watchSeriesSub'), trailing: GBtn(context.t('home.watch'), small: true, onTap: () => context.push(Routes.player('signal')))),
                  ListRow(leading: const IconTile(Icons.sensors), title: context.t('home.liveTv'), sub: context.t('rewards.liveSub'), trailing: GBtn(context.t('home.watch'), small: true, onTap: () => context.push(Routes.player('match')))),
                  ListRow(leading: const IconTile(Icons.emoji_events_outlined), title: context.t('rewards.mission'), sub: '50 pts', trailing: GBtn(w.missionDone ? context.t('common.done') : context.t('rewards.view'), small: true, outline: w.missionDone, onTap: () => bloc.add(const WalletMissionClaimed()))),
                  ListRow(leading: const IconTile(Icons.groups_outlined), title: context.t('rewards.party'), sub: '30 pts', trailing: GBtn(w.joinedParty ? context.t('rewards.joined') : context.t('rewards.join'), small: true, outline: w.joinedParty, onTap: () => bloc.add(const WalletPartyJoined()))),
                ])
              : Divided([
                  for (final r in state.catalog.rewards)
                    ListRow(
                      leading: IconTile(iconFor(r.icon)),
                      title: r.title,
                      sub: '${r.sub} · ${nf(r.cost)} pts',
                      trailing: GBtn(context.t('rewards.redeem'), small: true, outline: w.points < r.cost, onTap: () => bloc.add(WalletRedeemRequested(r))),
                    ),
                ]),
        ),
      ),
      SectionHeader(context.t('rewards.activity')),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Divided([for (final t in w.tx.reversed.take(5)) ListRow(leading: const SizedBox.shrink(), title: t.title, trailing: Pill(t.amount))]),
        ),
      ),
    ]);
  }
}

// ======================= ONE Pass =======================
class PassPage extends StatelessWidget {
  const PassPage({super.key});

  static const _included = [
    ['xfinity', 'Xfinity Internet', '1 Gbps', 2],
    ['peacock', 'Peacock Premium', 'Included', 1],
    ['xumo', 'Xumo Play', 'Free streaming', 1],
    ['nbc', 'NBC News and more', 'Included', 1],
    ['sky', 'Sky Sports', 'Included', 2],
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WalletBloc>().state;
    final plans = state.catalog.plans;
    final current = plans.indexWhere((p) => p.name == state.wallet.plan);
    return Scaffold(
      appBar: AppBar(title: Text(context.t('pass.title'))),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        GradCard(
          child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_awesome, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.t('pass.title'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)), Text(context.t('pass.tagline'), style: const TextStyle(color: Colors.white70, fontSize: 12.5))])),
          ]),
        ),
        const SizedBox(height: 14),
        for (final p in plans)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.popular ? context.acc : context.line, width: p.popular ? 2 : 1)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (p.popular) Padding(padding: const EdgeInsets.only(bottom: 8), child: Pill(context.t('pass.popular'))),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ONE ${p.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), Text(p.desc, style: TextStyle(fontSize: 12, color: context.ink2))])),
                  Text(p.price > 0 ? '${rs(p.price)}${context.t('pass.perMonth')}' : context.t('pass.free'), style: const TextStyle(fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 12),
                GBtn(state.wallet.plan == p.name ? context.t('pass.current') : (p.price > 0 ? context.t('pass.subscribe') : context.t('pass.switchFree')), expand: true, small: true, outline: state.wallet.plan == p.name, onTap: () => context.read<WalletBloc>().add(WalletPlanSelected(p))),
              ]),
            ),
          ),
        SectionHeader(context.t('pass.included')),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Divided([
            for (final x in _included)
              ListRow(
                leading: BrandBadge(x[0] as String, size: 40),
                title: x[1] as String,
                sub: '${x[2]}${current >= (x[3] as int) || plans.length <= (x[3] as int) ? '' : ' · ONE ${plans[x[3] as int].name}'}',
                trailing: current >= (x[3] as int) ? const Icon(Icons.check_circle, color: AppColors.ok) : Icon(Icons.lock_outline, color: context.ink2),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Divided([for (final k in const ['pass.perk1', 'pass.perk2', 'pass.perk3', 'pass.perk4']) ListRow(leading: Icon(Icons.check, color: context.ink2), title: context.t(k))]),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }
}
