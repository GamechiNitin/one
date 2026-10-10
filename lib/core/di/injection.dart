import 'package:get_it/get_it.dart';
import 'core_module.dart';
import 'di_module.dart';
import '../../features/assistant/assistant_module.dart';
import '../../features/auth/auth_module.dart';
import '../../features/catalog/catalog_module.dart';
import '../../features/creators/creators_module.dart';
import '../../features/events/events_module.dart';
import '../../features/marketplace/marketplace_module.dart';
import '../../features/settings/settings_module.dart';
import '../../features/wallet/wallet_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service locator used by presentation code (`sl<MyBloc>()`).
final GetIt sl = GetIt.instance;

/// Registers every module. Order does not matter: factories resolve lazily.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  final modules = <DiModule>[
    CoreModule(prefs),
    const AuthModule(),
    const SettingsModule(),
    const WalletModule(),
    const CatalogModule(),
    const CreatorsModule(),
    const EventsModule(),
    const MarketplaceModule(),
    const AssistantModule(),
  ];
  for (final m in modules) {
    m.register(sl);
  }
}
