import 'package:flutter/material.dart';
import '../../../../core/presentation/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../assistant/presentation/widgets/assistant_card.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/app_settings.dart';
import '../bloc/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();

    Widget row(IconData i, String t, VoidCallback f, {Color? c}) => ListRow(
          leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: context.card2,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(i, size: 18, color: c ?? context.acc)),
          title: t,
          trailing: c == null ? const Icon(Icons.chevron_right) : null,
          onTap: f,
        );

    Widget segmented(List<String> values, String selected,
            String Function(String) label, ValueChanged<String> onPick) =>
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final v in values)
            Tap(
              radius: 999,
              onTap: () => onPick(v),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: v == selected ? AppColors.gradient : null,
                  color: v == selected ? null : context.card,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: v == selected ? Colors.transparent : context.line),
                ),
                child: Text(label(v),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: v == selected ? Colors.white : context.ink2)),
              ),
            ),
        ]);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('settings.title'))),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Text(context.t('settings.language'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 10),
        segmented(
            AppLocalizations.supportedLocales
                .map((l) => l.languageCode)
                .toList(),
            s.languageCode,
            (c) => AppLocalizations.languageNames[c] ?? c,
            cubit.setLanguage),
        const SizedBox(height: 22),
        Text(context.t('settings.theme'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 10),
        segmented(const ['system', 'light', 'dark'], s.themeMode,
            (v) => context.t('settings.theme.$v'), cubit.setTheme),
        const SizedBox(height: 22),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Divided([
            row(Icons.person_outline, context.t('settings.account'),
                () => _soon(context)),
            row(Icons.notifications_none, context.t('settings.notifications'),
                () => _soon(context)),
            row(Icons.lock_outline, context.t('settings.privacy'),
                () => _soon(context)),
            row(Icons.shield_outlined, context.t('settings.parental'),
                () => _soon(context)),
            row(Icons.phone_iphone, context.t('settings.devices'),
                () => _soon(context)),
            row(Icons.help_outline, context.t('settings.help'),
                () => context.push(Routes.help)),
            row(
                Icons.star_outline,
                context.t('settings.about'),
                () => ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('ONE v1.1.0')))),
            row(Icons.logout, context.t('settings.logout'),
                () => context.read<AuthCubit>().logout(),
                c: AppColors.live),
          ]),
        ),
      ]),
    );
  }

  void _soon(BuildContext context) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(context.t('common.comingSoon'))));
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) {
    final rows = [
      [
        'xfinity',
        'help.internet',
        'help.internetSub',
        'assistant.chip.internet'
      ],
      ['xumo', 'help.tv', 'help.tvSub', 'assistant.chip.tv'],
      ['comcast', 'help.billing', 'help.billingSub', 'assistant.chip.billing'],
      ['xfinity', 'help.setup', 'help.setupSub', 'assistant.chip.setup'],
    ];
    return Scaffold(
      appBar: AppBar(title: Text(context.t('settings.help'))),
      body: ListView(
          padding: const EdgeInsets.only(top: 6, bottom: 30),
          children: [
            const AssistantCard(),
            SectionHeader(context.t('help.quick')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Divided([
                  for (final r in rows)
                    ListRow(
                        leading: BrandBadge(r[0], size: 44),
                        title: context.t(r[1]),
                        sub: context.t(r[2]),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(
                            Routes.assistant(ask: AppLocalizations.en(r[3])))),
                ]),
              ),
            ),
          ]),
    );
  }
}

/// Interest chips shown on the profile.
class InterestChips extends StatelessWidget {
  const InterestChips({super.key});
  @override
  Widget build(BuildContext context) {
    final selected = context.select((SettingsCubit c) => c.state.interests);
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final k in AppSettings.allInterests)
        Tap(
          radius: 999,
          onTap: () => context.read<SettingsCubit>().toggleInterest(k),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              gradient: selected.contains(k) ? AppColors.gradient : null,
              color: selected.contains(k) ? null : context.card,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color:
                      selected.contains(k) ? Colors.transparent : context.line),
            ),
            child: Text(k,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: selected.contains(k) ? Colors.white : context.ink2)),
          ),
        ),
    ]);
  }
}
