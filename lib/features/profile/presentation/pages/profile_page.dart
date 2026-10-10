import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../settings/presentation/pages/settings_pages.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WalletBloc>().state.wallet;
    return ListView(padding: const EdgeInsets.only(bottom: 100), children: [
      PageTitle(context.t('profile.title'), trailing: IconBtn(Icons.settings_outlined, () => context.push(Routes.settings))),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
        child: Row(children: [
          const Avatar('N', AppColors.blue, size: 76),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Text('Nitin Gamechi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Verified()]),
              Text('@nitin_gamechi', style: TextStyle(color: context.ink2, fontSize: 12.5)),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(context.t('rewards.level', [w.level]), style: TextStyle(fontSize: 12, color: context.ink2)),
                Text('${w.levelProgress} / 1,000 PTS', style: TextStyle(fontSize: 12, color: context.ink2)),
              ]),
              const SizedBox(height: 4),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: w.levelProgress / 1000, minHeight: 7, backgroundColor: context.card2, valueColor: const AlwaysStoppedAnimation(AppColors.blue))),
            ]),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            for (final x in [['124', context.t('profile.posts')], ['2.4K', context.t('profile.followers')], ['420', context.t('profile.following')]])
              Expanded(child: Column(children: [Text(x[0], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), Text(x[1], style: TextStyle(fontSize: 11.5, color: context.ink2))])),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
        child: Row(children: [
          _Tile(context.t('profile.edit'), Icons.edit_outlined, () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('common.comingSoon'))))),
          const SizedBox(width: 10),
          _Tile(context.t('profile.walletEarn'), Icons.account_balance_wallet_outlined, () => context.go(Routes.rewards)),
          const SizedBox(width: 10),
          _Tile(context.t('home.events'), Icons.confirmation_number_outlined, () => context.push(Routes.tickets)),
        ]),
      ),
      SectionHeader(context.t('profile.interests')),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: InterestChips()),
      SectionHeader(context.t('pass.title'), action: context.t('profile.manage'), onAction: () => context.push(Routes.pass)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: GradCard(
          onTap: () => context.push(Routes.pass),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ONE ${w.plan}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(w.isPaid ? context.t('profile.passPerks') : context.t('profile.passUpgrade'), style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ]),
        ),
      ),
      SectionHeader(context.t('profile.services'), action: context.t('profile.getHelp'), onAction: () => context.push(Routes.help)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Divided([
            for (final x in const [
              ['xfinity', 'profile.internet', 'profile.internetSub', 'assistant.chip.internet'],
              ['xfinity', 'profile.mobile', 'profile.mobileSub', 'assistant.chip.billing'],
              ['peacock', 'profile.tvStreaming', 'profile.active', 'assistant.chip.tv'],
            ])
              ListRow(
                leading: BrandBadge(x[0], size: 40),
                title: context.t(x[1]),
                trailing: Text(context.t(x[2]), style: TextStyle(fontSize: 12, color: context.ink2)),
                onTap: () => context.push(Routes.assistant(ask: AppLocalizations.en(x[3]))),
              ),
          ]),
        ),
      ),
    ]);
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _Tile(this.label, this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
        child: AppCard(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(children: [
            IconTile(icon),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ]),
        ),
      );
}
