import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'core/di/injection.dart';
import 'core/l10n/app_localizations.dart';
import 'core/presentation/responsive.dart';
import 'core/presentation/ui_notifier.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/assistant/presentation/bloc/assistant_bloc.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/catalog/presentation/bloc/catalog_bloc.dart';
import 'features/catalog/presentation/bloc/library_cubit.dart';
import 'features/creators/presentation/bloc/creators_bloc.dart';
import 'features/events/presentation/bloc/events_bloc.dart';
import 'features/marketplace/presentation/bloc/market_blocs.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';

class OneApp extends StatefulWidget {
  const OneApp({super.key});
  @override
  State<OneApp> createState() => _OneAppState();
}

class _OneAppState extends State<OneApp> {
  late final GoRouter _router = createRouter(sl<AuthCubit>());

  @override
  void initState() {
    super.initState();
    // Kick off initial loads once. Each bloc caches and falls back to local data when offline.
    sl<WalletBloc>().add(const WalletStarted());
    sl<CatalogBloc>().add(const CatalogRequested());
    sl<CreatorsBloc>().add(const CreatorsRequested());
    sl<EventsBloc>().add(const EventsRequested());
    sl<MarketBloc>().add(const MarketRequested());
    sl<CartBloc>().add(const CartStarted());
    sl<AssistantBloc>().add(const AssistantStarted());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  ThemeMode _mode(String m) => switch (m) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthCubit>()),
        BlocProvider.value(value: sl<SettingsCubit>()),
        BlocProvider.value(value: sl<WalletBloc>()),
        BlocProvider.value(value: sl<CatalogBloc>()),
        BlocProvider.value(value: sl<LibraryCubit>()),
        BlocProvider.value(value: sl<CreatorsBloc>()),
        BlocProvider.value(value: sl<EventsBloc>()),
        BlocProvider.value(value: sl<MarketBloc>()),
        BlocProvider.value(value: sl<CartBloc>()),
        BlocProvider.value(value: sl<AssistantBloc>()),
      ],
      child: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) => MaterialApp.router(
          title: 'ONE',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _mode(settings.themeMode),
          locale: Locale(settings.languageCode),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          scaffoldMessengerKey: messengerKey,
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final tv = formFactorOf(mq.size.width) == FormFactor.tv;
            final content = tv ? MediaQuery(data: mq.copyWith(textScaler: const TextScaler.linear(1.15)), child: child!) : child!;
            return _UiMessageHost(child: content);
          },
        ),
      ),
    );
  }
}

/// Shows localized snackbars for messages emitted by blocs through [UiNotifier].
class _UiMessageHost extends StatefulWidget {
  final Widget child;
  const _UiMessageHost({required this.child});
  @override
  State<_UiMessageHost> createState() => _UiMessageHostState();
}

class _UiMessageHostState extends State<_UiMessageHost> {
  StreamSubscription<UiMessage>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = sl<UiNotifier>().stream.listen(_show);
  }

  void _show(UiMessage m) {
    final messenger = messengerKey.currentState;
    if (messenger == null || !mounted) return;
    final text = AppLocalizations.of(context).t(m.key, m.args);
    final wide = MediaQuery.sizeOf(context).width > 700;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), width: wide ? 420 : null, duration: const Duration(milliseconds: 2200)));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
