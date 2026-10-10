import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/presentation/responsive.dart';
import '../../core/presentation/widgets.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';

/// Adaptive navigation: bottom bar on phones, rail on tablet/web/TV.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  static const _tabs = <List<Object>>[
    ['tab.home', Icons.home_outlined, Icons.home_rounded],
    ['tab.explore', Icons.explore_outlined, Icons.explore],
    ['tab.creators', Icons.groups_outlined, Icons.groups],
    ['tab.shop', Icons.shopping_bag_outlined, Icons.shopping_bag],
    ['tab.rewards', Icons.card_giftcard_outlined, Icons.card_giftcard],
    ['tab.profile', Icons.person_outline, Icons.person],
  ];

  void _go(int i) => shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    void ask() => context.push(Routes.assistant());
    final fab = ff == FormFactor.mobile
        ? FloatingActionButton(backgroundColor: AppColors.blue, foregroundColor: Colors.white, shape: const CircleBorder(), tooltip: context.t('assistant.title'), onPressed: ask, child: const Icon(Icons.auto_awesome))
        : FloatingActionButton.extended(
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
            onPressed: ask,
            icon: const Icon(Icons.auto_awesome),
            label: Text(context.t('assistant.ask'), style: const TextStyle(fontWeight: FontWeight.w700)),
          );

    if (ff == FormFactor.mobile) {
      return Scaffold(
        body: SafeArea(bottom: false, child: shell),
        floatingActionButton: fab,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _go,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 68,
          destinations: [for (final d in _tabs) NavigationDestination(icon: Icon(d[1] as IconData), selectedIcon: Icon(d[2] as IconData), label: context.t(d[0] as String))],
        ),
      );
    }

    final extended = ff != FormFactor.tablet;
    return Scaffold(
      floatingActionButton: fab,
      body: SafeArea(
        child: Row(children: [
          NavigationRail(
            extended: extended,
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _go,
            labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            leading: Padding(padding: const EdgeInsets.symmetric(vertical: 18), child: OneLogo(size: extended ? 30 : 22)),
            destinations: [
              for (final d in _tabs)
                NavigationRailDestination(icon: Icon(d[1] as IconData), selectedIcon: Icon(d[2] as IconData), label: Text(context.t(d[0] as String), style: const TextStyle(fontWeight: FontWeight.w600))),
            ],
          ),
          VerticalDivider(width: 1, color: context.line),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(constraints: BoxConstraints(maxWidth: ff == FormFactor.tv ? 1600 : 1200), child: shell),
            ),
          ),
        ]),
      ),
    );
  }
}
