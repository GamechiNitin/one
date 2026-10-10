import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/responsive.dart';
import 'go_router_refresh_stream.dart';
import 'routes.dart';
import '../../features/assistant/presentation/pages/assistant_page.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/catalog/presentation/pages/catalog_detail_pages.dart';
import '../../features/catalog/presentation/pages/explore_page.dart';
import '../../features/catalog/presentation/pages/home_page.dart';
import '../../features/catalog/presentation/pages/player_page.dart';
import '../../features/catalog/presentation/pages/reels_page.dart';
import '../../features/creators/presentation/pages/creators_pages.dart';
import '../../features/events/presentation/pages/events_pages.dart';
import '../../features/marketplace/presentation/pages/marketplace_pages.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_pages.dart';
import '../../features/shell/app_shell.dart';
import '../../features/wallet/presentation/pages/wallet_pages.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Single place that declares every route and the auth redirect.
GoRouter createRouter(AuthCubit auth) {
  Widget wide(Widget child) => Wide(child: child);

  GoRoute pushed(String path, Widget Function(GoRouterState s) build) =>
      GoRoute(parentNavigatorKey: _rootKey, path: path, builder: (context, state) => wide(build(state)));

  StatefulShellBranch tab(String path, Widget page) =>
      StatefulShellBranch(routes: [GoRoute(path: path, builder: (context, state) => page)]);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    refreshListenable: GoRouterRefreshStream(auth.stream),
    redirect: (context, state) {
      final loggedIn = auth.state.loggedIn;
      final atSplash = state.matchedLocation == Routes.splash;
      if (!loggedIn) return atSplash ? null : Routes.splash;
      if (atSplash) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (context, state) => const Wide(maxWidth: 520, child: SplashPage())),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          tab(Routes.home, const HomePage()),
          tab(Routes.explore, const ExplorePage()),
          tab(Routes.creators, const CreatorsPage()),
          tab(Routes.shop, const MarketPage()),
          tab(Routes.rewards, const RewardsPage()),
          tab(Routes.profile, const ProfilePage()),
        ],
      ),
      pushed('/item/:id', (s) => ItemPage(itemId: s.pathParameters['id']!)),
      pushed('/player/:id', (s) => PlayerPage(itemId: s.pathParameters['id']!)),
      pushed('/category/:name', (s) => CategoryPage(category: Uri.decodeComponent(s.pathParameters['name']!))),
      pushed('/reels', (s) => ReelsPage(start: int.tryParse(s.uri.queryParameters['start'] ?? '') ?? 0)),
      pushed(Routes.live, (s) => const LiveTvPage()),
      pushed(Routes.offers, (s) => const OffersPage()),
      pushed(Routes.events, (s) => EventsPage(initialCategory: s.uri.queryParameters['cat'] ?? 'All')),
      pushed('/event/:id', (s) => EventDetailPage(eventId: s.pathParameters['id']!)),
      pushed(
        '/event/:id/checkout',
        (s) => CheckoutPage(
          eventId: s.pathParameters['id']!,
          qty: int.tryParse(s.uri.queryParameters['qty'] ?? '') ?? 1,
          pass: s.uri.queryParameters['pass'] == '1',
        ),
      ),
      pushed('/booked/:id', (s) => BookedPage(ticketId: s.pathParameters['id']!)),
      pushed('/ticket/:id', (s) => TicketPage(ticketId: s.pathParameters['id']!)),
      pushed(Routes.tickets, (s) => const TicketsPage()),
      pushed('/product/:id', (s) => ProductPage(productId: s.pathParameters['id']!)),
      pushed(Routes.cart, (s) => const CartPage()),
      pushed('/creator/:id', (s) => CreatorProfilePage(creatorId: s.pathParameters['id']!)),
      pushed(Routes.pass, (s) => const PassPage()),
      pushed(Routes.settings, (s) => const SettingsPage()),
      pushed(Routes.help, (s) => const HelpPage()),
      pushed('/assistant', (s) => AssistantPage(initialQuestion: s.uri.queryParameters['ask'])),
    ],
  );
}
